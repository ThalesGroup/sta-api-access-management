//
//  StoresListView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct StoresListView: View {
    
    let storeType: StoreType
    @State var stores: [Store]?
    @State var error: Error?
    
    var body: some View {
        VStack {
            if let stores = stores {
                ScrollView {
                    LazyVStack {
                        ForEach(stores) { store in
                            StoreRowView(isShown: .constant(true), store: store, storeType: storeType)
                                .padding([.top, .leading, .trailing], 15)
                        }
                        Spacer()
                    }
                }
            } else {
                if let error = error {
                    Text(error.localizedDescription).multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text("Loading ...")
                }
            }
        }
        .onReceive(ProtectedStoreApi.shared.authorizationStateDidChange){ _ in
            update(reset: true)
        }
        .onReceive(ProtectedStoreApi.shared.configurationDidChange){ _ in
            update(reset: true)
        }
        .onAppear {
            update()
        }
    }
    
    private func update(reset: Bool = false) {
        if reset {
            self.stores = nil
        }
        let function = storeType == .shop ? ProtectedStoreApi.shared.fetchShops : ProtectedStoreApi.shared.fetchWarehouses
        function()
            .onSuccess { shops in
                self.stores = shops
            }.onFailure { error in
                self.error = error
            }
    }
}

struct StoresListView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            StoresListView(storeType: .shop, stores: PreviewDataProvider.shops, error: nil)
            StoresListView(storeType: .warehouse, stores: PreviewDataProvider.warehouses, error: nil).preferredColorScheme(.dark)
            StoresListView(storeType: .shop, stores: nil, error: nil)
            StoresListView(storeType: .shop, stores: nil, error: NSError(domain: "HTTPError", code: 401, userInfo: nil))
        }
    }
}
