using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json;

namespace Store.Services
{
    internal class InventoryDatabase : IInventoryDatabase
    {
        private Database _database;

        public InventoryDatabase()
        {
            Reset();
        }
        
        public IEnumerable<StockLocation> GetShops()
        {
            return this._database.Locations.Where(item => item.Type == LocationType.Store);
        }

        public StockLocation GetShop(string id)
        {
            return this.GetLocation(id, LocationType.Store);
        }

        public IEnumerable<StockLocation> GetWarehouses()
        {
            return this._database.Locations.Where(item => item.Type == LocationType.Warehouse);
        }

        public StockLocation GetWarehouse(string id)
        {
            return this.GetLocation(id, LocationType.Warehouse);
        }

        private StockLocation GetLocation(string id, LocationType type)
        {
            var location =  this._database.Locations.Where(item => item.Type == type).FirstOrDefault(item => item.Id == id);
            if (location == null)
            {
                throw new NotFoundException($"{id} {type.ToString()} Not found");
            }

            return location;
        }

        public IEnumerable<ProductInfo> GetProducts(string locationId, LocationType type)
        {
            return this.GetLocation(locationId, type).Stock.Where(item => item.Count > 0).Select(stockItem => this._database.Products.FirstOrDefault(item => item.Id == stockItem.Id)).Where(product => product != null);
        }

        public IEnumerable<InventoryItem> GetInventory(string locationId, LocationType type)
        {
            return (from product in this._database.Products let listing = this.GetLocation(locationId, type).Stock.FirstOrDefault(item => item.Id == product.Id) ?? new StockListing {Id = product.Id, Count = 0} select new InventoryItem {Product = product, Listing = listing});
        }
        

        public class NotFoundException : Exception
        {
            public NotFoundException(string msg) : base(msg)
            {
            }
        }

        public bool MoveStock(string fromWarehouseId, string toShopId, string itemId, int count)
        {
            var warehouse = this.GetLocation(fromWarehouseId, LocationType.Warehouse);
            var store  = this.GetLocation(toShopId, LocationType.Store);
            
            var stockItem = warehouse.Stock.FirstOrDefault(item => item.Id == itemId);
            if (stockItem == null)
            {
                throw new NotFoundException($"Stock item {itemId} Not found");
            }

            if (stockItem.Count < count)
            {
                // not enough items in stock
                return false;
            }
            
            var storeItem = store.Stock.FirstOrDefault(item => item.Id == itemId);
            if (storeItem == null)
            {
                stockItem.Count -= count;
                storeItem = new StockListing
                {
                    Id = stockItem.Id,
                    Count = count,
                };
                store.Stock.Add(storeItem);
                return true;
            }

            stockItem.Count -= count;
            storeItem.Count += count;
            return true;

        }

        public void Reset()
        {
            var dbFile = Environment.GetEnvironmentVariable("STORE_DB_PATH");
            if (dbFile == null)
            {
                this._database = new Database
                {
                    Locations = new List<StockLocation>(),
                    Products = new List<ProductInfo>()
                };
            }
            else
            {
                this._database = JsonConvert.DeserializeObject<Database>(File.ReadAllText(dbFile));
            }
        }
    }
}