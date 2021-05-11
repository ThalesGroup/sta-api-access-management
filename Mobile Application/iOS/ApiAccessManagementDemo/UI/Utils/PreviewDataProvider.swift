//
//  PreviewDataProvider.swift
//  ApiAccessManagementDemo
//

import Foundation

/// Data Provider for SwiftUI Preview
struct PreviewDataProvider {
    
    static let shops = [Shop(id: "Shop0 ID", name: "Shop0 Name", location: "45.00,-75.00"),
                        Shop(id: "Shop1 ID", name: "Shop1 Name", location: "45.05,-75.00")]
    
    static let warehouses = [Warehouse(id: "Warehouse0 ID", name: "Warehouse0 Name", location: "45.00,-75.00"),
                             Warehouse(id: "Warehouse1 ID", name: "Warehouse1 Name", location: "45.05,-75.00")]

    static let stockItems = [StockItem(id: "Stock0 ID", name: "Stock0 Name", count: 50, description: "Description of item with 50 stocks goes here"),
                             StockItem(id: "Stock1 ID", name: "Stock1 Name", count: 10, description: "Description of item with 10 stocks goes here"),
                             StockItem(id: "Stock2 ID", name: "Stock2 Name", count: 0, description: "Description of item with no available stock goes here")]
}
