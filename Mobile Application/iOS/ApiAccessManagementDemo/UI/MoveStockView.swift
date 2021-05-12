//
//  MoveStockView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct MoveStockView: View {
    
    var item: StockItem
    var warehouse: Store
    
    @State var shops: [Shop]?
    @State var selected: Shop?
    @State var alertDescription: AlertDescription?
    @State var countToMove = ""
        
    var body: some View {
        VStack {
            Text("Move count ( <= \(item.count))").padding(.top)
            TextField(countToMove, text: $countToMove)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .frame(width: 200)
                .padding(.bottom)
            
            Divider()
            
            if let shops = shops {
                List(shops, id: \.id) { shop in
                    HStack {
                        Text("\(shop.name)").font(Font.system(size: 17, weight: .bold))
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(shop == selected ? Color.blue.opacity(0.2) : Color.clear)
                    .onTapGesture {
                        if selected == nil {
                            selected = shop
                        } else {
                            if (selected! == shop) {
                                selected = nil
                            } else {
                                selected = shop
                            }
                        }
                    }
                }
            } else {
                Text("Loading...")
            }
            Spacer()
        }
        .navigationBarTitle("Move Stock", displayMode: .inline)
        .navigationBarItems(trailing: Button("Move", action: moveStock))
        .onAppear {
            countToMove = item.count > 0 ? "1" : "0"
            ProtectedStoreApi.shared.fetchShops().onSuccess { (shops) in
                self.shops = shops
            }
        }
        .alert(item: $alertDescription) { errorDescription in
            Alert(title: Text(errorDescription.title), message: Text(errorDescription.message), dismissButton: .cancel(Text("OK")))
        }
    }
    
    private func moveStock() {
        guard let count = Int(countToMove), count > 0 else {
            self.alertDescription = AlertDescription(title: "Incorrect Input", message: "Enter integer!")
            return
        }
                
        guard let selected = selected else {
            self.alertDescription = AlertDescription(title: "Missing Destination", message: "Select a shop to which to move the stock.")
            return
        }
        
        ProtectedStoreApi.shared.moveStock(warehouseId: warehouse.id,
                                           stockId: item.id,
                                           shopId: selected.id,
                                           count: count)
            .onSuccess {
                self.alertDescription = AlertDescription(title: "Success", message: "Stock has been moved successfully")
            }
            .onFailure { error in
                let message = "Error: \(error.localizedDescription)"
                self.alertDescription = AlertDescription(title: "Failed", message: message)
            }
    }
}

struct MoveStockView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NavigationView {
                MoveStockView(item: PreviewDataProvider.stockItems[0],
                              warehouse: PreviewDataProvider.warehouses[0],
                              shops: PreviewDataProvider.shops,
                              selected: PreviewDataProvider.shops[1],
                              countToMove: "1")
            }
        }
    }
}

