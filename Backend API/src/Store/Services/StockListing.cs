namespace Store.Services
{
    /// <summary>
    /// Item in stock
    /// </summary>
    public class StockListing
    {
        /// <summary>
        /// Id of the item
        /// </summary>
        public string Id { get; set; }

        /// <summary>
        /// Number of items in stock
        /// </summary>
        public int Count { get; set; }
    }
}