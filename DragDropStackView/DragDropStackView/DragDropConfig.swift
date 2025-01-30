//
//  DragDropConfig.swift
//  DragDropStackView
//
//  Created by SEKNY YIM on 29/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

struct DragDropConfig {
    let clipsToBoundsWhileDragDrop: Bool
    let dragEffectCornerRadius: Double
    let dargViewScale: Double
    let otherViewsScale: Double
    let snapshotViewAlpha: Double
    let dragBeganEffectOffsetY: Double
    let longPressMinimumDuration: Double
    
    init(
        clipsToBoundsWhileDragDrop: Bool = false,
        dragEffectCornerRadius: Double = 8.0,
        dargViewScale: Double = 1.2,
        otherViewsScale: Double = 0.9,
        snapshotViewAlpha: Double = 0.85,
        dragBeganEffectOffsetY: Double = 4.0,
        longPressMinimumDuration: Double = 0.2
    ) {
        self.clipsToBoundsWhileDragDrop = clipsToBoundsWhileDragDrop
        self.dragEffectCornerRadius = dragEffectCornerRadius
        self.dargViewScale = dargViewScale
        self.otherViewsScale = otherViewsScale
        self.snapshotViewAlpha = snapshotViewAlpha
        self.dragBeganEffectOffsetY = dragBeganEffectOffsetY
        self.longPressMinimumDuration = longPressMinimumDuration
    }
}

protocol DragDropStackViewDelegate {
    func didBeginDrag()
    func dargging(inUpDirection up: Bool, maxY: CGFloat, minY: CGFloat)
    func didEndDrop()
}

protocol DragDropable: AnyObject {
    var dargDropDelegate: DragDropStackViewDelegate? { get }
    var config: DragDropConfig { get }
    var gestures: [UILongPressGestureRecognizer] { get set }
    var disposeBag: DisposeBag { get }
    
        /// Each views inside stackView must call this
        ///
        ///
    func addLongPressGestureForDragDrop(arrangedSubview: UIView)
}
