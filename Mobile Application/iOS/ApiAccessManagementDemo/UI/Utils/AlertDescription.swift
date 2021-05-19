//
//  AlertDescription.swift
//  ApiAccessManagementDemo
//

import Foundation

/// Alert Description
struct AlertDescription: Identifiable {
    var id: String { title }
    var title: String
    var message: String
    var buttonInfo:(title: String, action: (() -> Void)?)?
}
