//
//  StoreApi.swift
//  ApiAccessManagementDemo
//

import Foundation

/// Store API
/// Refer to: https://storeapi.stademo.com:8090/swagger/index.html
enum StoreApi {
    
    /// Fetch shops
    static func fetchShops() -> Endpoint<[Shop]> {
        return Endpoint(path: "shop")
    }

    /// Fetch warehouses
    static func fetchWarehouses() -> Endpoint<[Warehouse]> {
        return Endpoint(path: "warehouse")
    }

    /// Fetch the shop info
    static func fetchShopInfo(id: String) -> Endpoint<ShopInfo> {
        return Endpoint(path: "shop/\(id)")
    }

    /// Fetch the warehouse info
    static func fetchWarehouseInfo(id: String) -> Endpoint<WarehouseInfo> {
        return Endpoint(path: "warehouse/\(id)")
    }
    
    /// Fetch the stock items of a shop
    static func fetchShopStock(id: String) -> Endpoint<[StockItem]> {
        return Endpoint(path: "shop/\(id)/stock")
    }

    /// Fetch the stock items of a warehouse
    static func fetchWarehouseStock(id: String) -> Endpoint<[StockItem]> {
        return Endpoint(path: "warehouse/\(id)/stock")
    }
    
    /// Move a stock to from a warehouse to a shop
    static func moveStock(warehouseId: String, stockId: String, shopId: String, count: Int) -> Endpoint<Void> {
        let data = "{\"count\": \(count) }".data(using: .utf8)!
        return Endpoint(method: .POST,
                        path: "warehouse/\(warehouseId)/stock/\(stockId)/move/\(shopId)",
                        parameters: nil,
                        headerParameters: ["Content-Type": "application/json"],
                        httpBody: data,
                        decode: { _ in () })
    }

    /// Revert the server to its default state.
    static func reset() -> Endpoint<Void> {
        Endpoint(method: .POST, path: "reset", parameters: nil)
    }
}
