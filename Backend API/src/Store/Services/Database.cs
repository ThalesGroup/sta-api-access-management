using System.Collections.Generic;
// ReSharper disable CollectionNeverUpdated.Global

namespace Store.Services
{
    /// <summary>
    /// Database object
    /// </summary>
    internal class Database{
        public List<StockLocation> Locations { get; set; }
        public List<ProductInfo> Products { get; set; }
    }
}