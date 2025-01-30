//
//  CategoryModel.swift
//  DragDropStackView
//
//  Created by SEKNY YIM on 29/1/25.
//
import Foundation

// MARK: - Category
struct CategoryModel: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let creationAt, updatedAt: String?
}
