package com.thalesgroup.apiprotection.model

import com.thalesgroup.apiprotection.restapi.*

class RetailRepository {

    var webservice: RetailRestApi? = null

    suspend fun getShops(token: String): MutableList<Shop>? {
        return webservice?.getShops(formatToken(token))?.toMutableList()
    }

    suspend fun getWarehouses(token: String): MutableList<Warehouse>? {
        return webservice?.getWarehouses(formatToken(token))?.toMutableList()
    }

    suspend fun getShopInfo(token: String, shopId: String): ShopInfo? {
        return webservice?.getShopInfo(formatToken(token), shopId)
    }

    suspend fun getShopStock(token: String, shopId: String): List<StockItem>? {
        return webservice?.getShopStock(formatToken(token), shopId)
    }

    suspend fun getShopProducts(token: String, shopId: String): List<Product>? {
        return webservice?.getShopProducts(formatToken(token), shopId)
    }

    suspend fun getWarehouseStock(token: String, warehouseId: String): List<StockItem>? {
        return webservice?.getWarehouseStock(formatToken(token), warehouseId)
    }

    suspend fun getWarehouseInfo(token: String, warehouseId: String): WarehouseInfo? {
        return webservice?.getWarehouseInfo(formatToken(token), warehouseId)
    }

    suspend fun moveStock(token: String, stockId: String, count: Int,  warehouseId: String, shopId: String) {
        val moveRequest = MoveRequest(count)
        webservice?.moveStock(formatToken(token), warehouseId, stockId, shopId, moveRequest)
    }

    suspend fun reset(token: String) {
        webservice?.reset(formatToken(token))
    }

    private fun formatToken(token: String): String {
        return "Bearer $token"
    }

}