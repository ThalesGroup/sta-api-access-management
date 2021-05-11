//
//  DataTypes.swift
//  ApiAccessManagementDemo
//

import Foundation

struct Store: Decodable, Hashable {
    var id: String
    var name: String
    var location: String
}

struct StoreInfo: Decodable {
    var id: String
    var name: String
    var location: String
    var description: String
}

struct StockItem: Decodable {
    var id: String
    var name: String
    var count: Int
    var description: String
}

typealias Shop = Store
typealias ShopInfo = StoreInfo
typealias Warehouse = Store
typealias WarehouseInfo = StoreInfo
