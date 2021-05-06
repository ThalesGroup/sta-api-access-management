using System.Collections.Generic;
// ReSharper disable UnusedAutoPropertyAccessor.Global

namespace Store.Services
{
    using Newtonsoft.Json;
    using Newtonsoft.Json.Converters;

    /// <summary>
    /// Location of inventory items
    /// </summary>
    // ReSharper disable once ClassNeverInstantiated.Global
    public class StockLocation
    {
        /// <summary>
        /// Name of the location
        /// </summary>
        public string Name { get; set; }
        
        /// <summary>
        /// Type of location
        /// </summary>
        [JsonConverter(typeof(StringEnumConverter))]
        public LocationType Type { get; set; }
        
        /// <summary>
        /// Location
        /// </summary>
        public string Location { get; set; }
        
        /// <summary>
        /// Id of the location
        /// </summary>
        public string Id { get; set; }
        
        /// <summary>
        /// list of items in stock
        /// </summary>
        public List<StockListing> Stock { get; set; }
        
        /// <summary>
        /// Description of the location
        /// </summary>
        public string Description { get; set; }
    }
}