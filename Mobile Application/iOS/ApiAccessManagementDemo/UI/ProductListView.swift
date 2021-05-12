//
//  ProductListView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct ProductListView: View {
    
    let store: Store
    let storeType: StoreType
    
    @State var stockItems: [StockItem]?
    @State var error: Error?

    var body: some View {
        Group {
            if let stockItems = stockItems {
                ScrollView {
                    LazyVStack(spacing: 5) {
                        ForEach(stockItems, id: \.id) { item in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.name)
                                    .font(Font.system(size: 17, weight: .bold))
                                Text(item.description)
                                    .font(Font.system(size: 13))
                                    .foregroundColor(Color.init(UIColor.systemGray))
                                HStack {
                                    Image(systemName: item.count > 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(item.count > 0 ? .green : .red)
                                    Text(item.count > 0 ? "Stock Available (QTY: \(item.count))" : "Stock Not Available")
                                        .font(Font.system(size: 13))
                                    Spacer()

                                    if storeType == .warehouse {
                                        NavigationLink(
                                            destination:  MoveStockView(item: item, warehouse: store),
                                            label: {
                                                Text("MOVE ITEM")
                                                    .font(Font.system(size: 13))
                                            }
                                        )
                                    }
                                }.padding(.top, 3)
                            }.padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                            Divider().padding(.top, 10)
                        }
                    }
                }
            } else {
                if let error = error {
                    Text("Error: \(error.localizedDescription)").multilineTextAlignment(.center)
                } else {
                    Text("Loading ...")
                }
            }
        }
        .navigationBarTitle("List of Products", displayMode: .inline)
        .onAppear {
            update()
        }
    }
    
    private func update() {
        let function = storeType == .shop ? ProtectedStoreApi.shared.fetchShopStock : ProtectedStoreApi.shared.fetchWarehouseStock
        function(store.id).onSuccess { stockItems in
            self.stockItems = stockItems
        }
        .onFailure { error in
            self.error = error
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            NavigationView {
                ProductListView(store: PreviewDataProvider.shops[0], storeType: .shop, stockItems: PreviewDataProvider.stockItems)
            }
            
            NavigationView {
                ProductListView(store: PreviewDataProvider.warehouses[0], storeType: .warehouse, stockItems: PreviewDataProvider.stockItems)
            }.preferredColorScheme(.dark)

            ProductListView(store: PreviewDataProvider.shops[0], storeType: .shop, stockItems: nil)
        }
    }
}
