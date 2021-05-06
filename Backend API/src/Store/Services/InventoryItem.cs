namespace Store.Services
{
    /// <summary>
    /// Inventory Item
    /// </summary>
    public class InventoryItem
    {
        /// <summary>
        /// Inventory listing
        /// </summary>
        public StockListing Listing { set; get; }
        
        /// <summary>
        /// Product information
        /// </summary>
        public ProductInfo Product { set; get; }
    }
}