//
//  Extensions.swift
//  DragDropStackView
//
//  Created by SEKNY YIM on 29/1/25.
//
import UIKit

extension DragDropable where Self: UIStackView {
    func addLongPressGestureForDragDrop(arrangedSubview: UIView) {
        arrangedSubview.rx.longPressGesture(configuration: { [weak self] gesture, delegate in
            gesture.minimumPressDuration = self?.config.longPressMinimumDuration ?? 0
            gesture.isEnabled = true
            arrangedSubview.addGestureRecognizer(gesture)
            self?.gestures.append(gesture)
        })
        .subscribe { [weak self] gesture in
            self?.handleLongPress(gesture)
        }
        .disposed(by: disposeBag)
    }
    
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
            case .began:
                handleBegan(gesture: gesture)
            case .changed:
                handleChanged(gesture: gesture)
            default:
                    // ended, cancelled, failed
                handleEnded(gesture: gesture)
        }
    }
    
    func handleBegan(gesture: UILongPressGestureRecognizer) {
        guard !isStatusDragging else { return }
        isStatusDragging = true
        dargDropDelegate?.didBeginDrag()
        if let gestureView = gesture.view {
            actualView = gestureView
        }
        originalPosition = gesture.location(in: self)
        originalPosition.y -= config.dragBeganEffectOffsetY
        pointForDragDrop = originalPosition
        animateBeganDrag()
    }
    
    func animateBeganDrag() {
        clipsToBounds = config.clipsToBoundsWhileDragDrop
        guard let actualView else { return }
        
        snapshotView = actualView.snapshotView(afterScreenUpdates: true)
        snapshotView?.frame = actualView.frame
        finalDragDropFrame = actualView.frame
        if let snapshotView {
            addSubview(snapshotView)
        }
        
        actualView.alpha = 0
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: { self.animateBeganDragEffect() },
            completion: nil
        )
    }
    
    func animateBeganDragEffect() {
        let scale = CGAffineTransform(scaleX: config.dargViewScale, y: config.dargViewScale)
        let translation = CGAffineTransform(translationX: 0, y: config.dragBeganEffectOffsetY)
        snapshotView?.transform = scale.concatenating(translation)
        snapshotView?.alpha = config.snapshotViewAlpha
        
        arrangedSubviews
            .filter { $0 != actualView }
            .forEach { subview in
                subview.transform = CGAffineTransform(scaleX: config.otherViewsScale, y: config.otherViewsScale)
            }
    }
    
    func handleChanged(gesture: UILongPressGestureRecognizer) {
        let newLocation = gesture.location(in: self)
        let xOffset = newLocation.x - originalPosition.x
        let yOffset = newLocation.y - originalPosition.y
        let translation = CGAffineTransform(translationX: xOffset, y: yOffset)
        
        guard let snapshotView else { return }
        let scale = CGAffineTransform(scaleX: config.dargViewScale, y: config.dargViewScale)
        snapshotView.transform = scale.concatenating(translation)
        
        let maxY = snapshotView.frame.maxY
        let midY = snapshotView.frame.midY
        let minY = snapshotView.frame.minY
        let index = arrangedSubviews
            .firstIndex(where: { $0 == actualView }) ?? 0
        
        if midY > pointForDragDrop.y {
            handleChangedWhenDraggingDown(index: index, maxY: maxY, midY: midY, minY: minY)
        } else {
            handleChangedWhenDraggingUp(index: index, maxY: maxY, midY: midY, minY: minY)
        }
    }
    
    func handleChangedWhenDraggingDown(index: Int, maxY: Double, midY: Double, minY: Double) {
        dargDropDelegate?.dargging(inUpDirection: false, maxY: maxY, minY: minY)
        guard
            let nextView = arrangedSubviews[safe: index + 1],
            let actualView,
            midY > nextView.frame.midY
        else { return }
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.insertArrangedSubview(nextView, at: index)
                self.insertArrangedSubview(actualView, at: index + 1)
            }
        )
        finalDragDropFrame = actualView.frame
        pointForDragDrop.y = actualView.frame.midY
    }
    
    func handleChangedWhenDraggingUp(index: Int, maxY: Double, midY: Double, minY: Double) {
        dargDropDelegate?.dargging(inUpDirection: true, maxY: maxY, minY: minY)
        guard
            let previousView = arrangedSubviews[safe: index - 1],
            let actualView,
            midY < previousView.frame.midY
        else { return }
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.insertArrangedSubview(previousView, at: index)
                self.insertArrangedSubview(actualView, at: index - 1)
            }
        )
        finalDragDropFrame = actualView.frame
        pointForDragDrop.y = actualView.frame.midY
    }
    
    func handleEnded(gesture: UILongPressGestureRecognizer) {
        animateDrop()
        isStatusDragging = false
        dargDropDelegate?.didEndDrop()
    }
    
    func animateDrop() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: { self.animateDropEffect() },
            completion: { _ in
                self.snapshotView?.removeFromSuperview()
                self.actualView?.alpha = 1
                self.clipsToBounds = !self.config.clipsToBoundsWhileDragDrop
            }
        )
    }
    
    func animateDropEffect() {
        snapshotView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        snapshotView?.frame = finalDragDropFrame
        snapshotView?.alpha = 1.0
        
        arrangedSubviews
            .forEach { subview in
                UIView.animate(
                    withDuration: 0.3) {
                        subview.transform = .identity
                    } completion: { _ in
                        subview.layer.removeAllAnimations()
                    }
            }
    }
}

// MARK: - Extension + Stored Property

private struct AssociatedKeys {
    static var isStatusDragging = "isStatusDragging"
    static var finalDragDropFrame = "finalDragDropFrame"
    static var originalPosition = "originalPosition"
    static var pointForDragDrop = "pointForDragDrop"
    static var actualView = "actualView"
    static var snapshotView = "snapshotView"
}

extension DragDropable {
    var isStatusDragging: Bool {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.isStatusDragging) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.isStatusDragging, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var finalDragDropFrame: CGRect {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.finalDragDropFrame) as? CGRect) ?? .zero }
        set { objc_setAssociatedObject(self, &AssociatedKeys.finalDragDropFrame, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var originalPosition: CGPoint {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.originalPosition) as? CGPoint) ?? .zero }
        set { objc_setAssociatedObject(self, &AssociatedKeys.originalPosition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var pointForDragDrop: CGPoint {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.pointForDragDrop) as? CGPoint) ?? .zero }
        set { objc_setAssociatedObject(self, &AssociatedKeys.pointForDragDrop, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var actualView: UIView? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.actualView) as? UIView) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.actualView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var snapshotView: UIView? {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.snapshotView) as? UIView) }
        set { objc_setAssociatedObject(self, &AssociatedKeys.snapshotView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
