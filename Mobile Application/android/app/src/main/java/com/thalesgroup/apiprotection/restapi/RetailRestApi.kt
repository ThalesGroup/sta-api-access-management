package com.thalesgroup.apiprotection.restapi

import retrofit2.http.*

/**
 * Describes the backend API. Apis take an authorization header, which is sent as a bearer token. This
 * must be formatted previously before being passed to the API.
 */
interface RetailRestApi {

    @GET("shop")
    suspend fun getShops(@Header("Authorization") value: String): List<Shop>

    @GET("shop/{shopId}")
    suspend fun getShopInfo(@Header("Authorization") value: String, @Path("shopId") shopId: String): ShopInfo

    @GET("shop/{shopId}/stock")
    suspend fun getShopStock(@Header("Authorization") value: String, @Path("shopId") shopId: String): List<StockItem>

    @GET("shop/{shopId}/products")
    suspend fun getShopProducts(@Header("Authorization") value: String, @Path("shopId") shopId: String): List<Product>

    @GET("warehouse")
    suspend fun getWarehouses(@Header("Authorization") value: String): List<Warehouse>

    @GET("warehouse/{warehouseId}")
    suspend fun getWarehouseInfo(@Header("Authorization") value: String, @Path("warehouseId") warehouseId: String): WarehouseInfo

    @GET("warehouse/{warehouseId}/stock")
    suspend fun getWarehouseStock(@Header("Authorization") value: String, @Path("warehouseId") warehouseId: String): List<StockItem>

    @POST("warehouse/{warehouseId}/stock/{stockId}/move/{shopId}")
    suspend fun moveStock(@Header("Authorization") value: String, @Path("warehouseId") warehouseId: String, @Path("stockId") stockId: String, @Path("shopId") shopId: String, @Body request: MoveRequest)

    @POST("reset")
    suspend fun reset(@Header("Authorization") value: String)

}