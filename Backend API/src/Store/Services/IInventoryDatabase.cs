using System.Collections.Generic;

namespace Store.Services
{
    /// <summary>
    /// Store Interface
    /// </summary>
    public interface IInventoryDatabase
    {
        /// <summary>
        /// Get a list of shops
        /// </summary>
        /// <returns>list of shops</returns>
        IEnumerable<StockLocation> GetShops();
        
        /// <summary>
        /// Get a shop
        /// </summary>
        /// <param name="id">Id of the shop</param>
        /// <returns>the requested shop</returns>
        StockLocation GetShop(string id);
        
        /// <summary>
        /// Gets a list of warehouses
        /// </summary>
        /// <returns>list of warehouses</returns>
        IEnumerable<StockLocation> GetWarehouses();
        /// <summary>
        /// 
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        StockLocation GetWarehouse(string id);

        /// <summary>
        /// Gets a list of all products at a location
        /// </summary>
        /// <param name="locationId">id of the location</param>
        /// <param name="type">type of location</param>
        /// <returns>list of products</returns>
        IEnumerable<ProductInfo> GetProducts(string locationId, LocationType type);
        
        /// <summary>
        /// Gets a list of inventory items
        /// </summary>
        /// <param name="locationId">id of the location</param>
        /// <param name="type">type of location</param>
        /// <returns></returns>
        IEnumerable<InventoryItem> GetInventory(string locationId, LocationType type);

        /// <summary>
        /// Moves stock from warehouse to store
        /// </summary>
        /// <param name="fromWarehouseId">Id of the warehouse</param>
        /// <param name="toShopId">Id of the shop</param>
        /// <param name="itemId">Id of the item</param>
        /// <param name="count">number of items to move</param>
        /// <returns>true if the move was successful</returns>
        bool MoveStock(string fromWarehouseId, string toShopId, string itemId, int count);

        /// <summary>
        /// Resets the sock levels to default
        /// </summary>
        void Reset();
    }
}   