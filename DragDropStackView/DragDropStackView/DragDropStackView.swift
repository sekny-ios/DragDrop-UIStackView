//
//  DragDropStackViewDelegate.swift
//  DragDropStackView
//
//  Created by SEKNY YIM on 29/1/25.
//



import UIKit
import RxSwift

final class DragDropStackView: UIStackView, DragDropable {
    // MARK: Property
    var dargDropDelegate: DragDropStackViewDelegate?
    var gestures = [UILongPressGestureRecognizer]()
    var dragDropEnabled = false {
        didSet { gestures.forEach { $0.isEnabled = dragDropEnabled } }
    }
    var disposeBag = DisposeBag()
    
    let config: DragDropConfig
    
    // MARK: Method
    init(config: DragDropConfig = DragDropConfig()) {
        self.config = config
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
    
    override func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        addLongPressGestureForDragDrop(arrangedSubview: view)
        gestures.last?.delegate = self
    }
}


// MARK: - DragDropStackView + UIGestureRecognizerDelegate
extension DragDropStackView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        !isStatusDragging
    }
}
