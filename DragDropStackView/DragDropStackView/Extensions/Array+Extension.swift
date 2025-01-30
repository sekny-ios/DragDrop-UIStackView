//
//  Untitled.swift
//  DragDropStackView
//
//  Created by SEKNY YIM on 29/1/25.
//

import Foundation
extension Array {
    subscript (safe index: Int) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
