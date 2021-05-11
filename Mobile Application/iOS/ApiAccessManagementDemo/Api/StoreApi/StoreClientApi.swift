//
//  StoreApi.swift
//  ApiAccessManagementDemo
//

import Foundation


/// Store Client API
/// Refer to: https://storeapi.stademo.com:8090/swagger/index.html
enum StoreApi {
    
    /// Get the shops
    /// - Returns: Array of Shop
    static func getShops() -> Endpoint<[Shop]> {
        return Endpoint(path: "shop")
    }

    /// Get the warehouses
    /// - Returns: Array of Warehouse
    static func getWarehouses() -> Endpoint<[Warehouse]> {
        return Endpoint(path: "warehouse")
    }

    /// Get the shop info
    /// - Parameter id: shop id
    /// - Returns: ShopInfo
    static func getShopInfo(id: String) -> Endpoint<ShopInfo> {
        return Endpoint(path: "shop/\(id)")
    }

    /// Get the warehouse info
    /// - Parameter id: warehouse id
    /// - Returns: WarehouseInfo
    static func getWarehouseInfo(id: String) -> Endpoint<WarehouseInfo> {
        return Endpoint(path: "warehouse/\(id)")
    }
    
    /// Get the stock items of a shop
    /// - Parameter id: shop id
    /// - Returns: Array of StockItem
    static func getShopStock(id: String) -> Endpoint<[StockItem]> {
        return Endpoint(path: "shop/\(id)/stock")
    }

    /// Get the stock items of a warehouse
    /// - Parameter id: shop id
    /// - Returns: Array of StockItem
    static func getWarehouseStock(id: String) -> Endpoint<[StockItem]> {
        return Endpoint(path: "warehouse/\(id)/stock")
    }
    
    
    /// Moves a stock to from a warehouse to a shop
    /// - Parameters:
    ///   - warehouseId: warehouse id
    ///   - stockId: stock id
    ///   - shopId: shop id
    ///   - count: count of stock to move
    static func moveStock(warehouseId: String, stockId: String, shopId: String, count: Int) -> Endpoint<Void> {
        let data = "{\"count\": \(count) }".data(using: .utf8)!
        return Endpoint(method: .POST,
                        path: "warehouse/\(warehouseId)/stock/\(stockId)/move/\(shopId)",
                        parameters: nil,
                        headerParameters: ["Content-Type": "application/json"],
                        httpBody: data,
                        decode: { _ in () })
    }

    /// Reverts the server to its default state.
    static func reset() -> Endpoint<Void> {
        Endpoint(method: .POST, path: "reset", parameters: nil)
    }

}
