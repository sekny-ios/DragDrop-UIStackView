//
//  ProductModel.swift
//  DragDropStackView
//
//  Created by SEKNY YIM on 29/1/25.
//
import Foundation

// MARK: - ProductModel
struct ProductModel: Codable {
    let id: Int?
    let title: String?
    let price: Int?
    let description: String?
    let images: [String]?
    let creationAt, updatedAt: String?
    let category: CategoryModel?
    var sequence: Int?
}
