//
//  StoresMapView.swift
//  ApiAccessManagementDemo
//

import SwiftUI
import MapKit

struct StoresMapView: View {
    
    let storeType: StoreType
    @State var stores: [Store]?
    @State var error: Error?

    @State var selectedStoreIndex = 0
    @State var isStoreDetailsShown = false
    
    @State private var region = MKCoordinateRegion()
    @State private var response: HttpResponse<[Shop]>?
    
    var body: some View {
        ZStack {
            if let stores = stores {
                Map(coordinateRegion: $region,
                    showsUserLocation: false,
                    annotationItems: stores) { store in
                    MapAnnotation(coordinate: store.coordinate) {
                        ZStack {
                            Image("pin")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40)
                                .offset(x: 0, y: -20)
                        }
                        .frame(width: 60, height: 60)
                        .onTapGesture {
                            self.selectedStoreIndex = stores.firstIndex{ $0 == store } ?? 0
                            self.isStoreDetailsShown = true
                        }
                    }
                }

                if isStoreDetailsShown {
                    VStack {
                        Spacer().frame(maxHeight:.infinity)
                        StorePagingView(selection: $selectedStoreIndex, isShown: $isStoreDetailsShown, stores: stores, type: storeType)
                    }
                }
            } else {
                if let error = error {
                    Text("Error: \(error.localizedDescription)").multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text("Loading ...")
                }
            }
        }
        .onReceive(ProtectedStoreApi.shared.authorizationStateDidChange){ _ in
            update(reset: true)
        }
        .onReceive(ProtectedStoreApi.shared.configurationDidChange) { _ in
            update(reset: true)
        }
        .onAppear {
            update()
        }
    }
        
    private func update(reset: Bool = false) {
        guard self.response == nil else { return }
        
        let function = storeType == .shop ? ProtectedStoreApi.shared.fetchShops : ProtectedStoreApi.shared.fetchWarehouses
        self.response = function()
            .onSuccess { shops in
                self.stores = shops
                self.updateMapRegion(shops)
                self.response = nil
            }.onFailure { error in
                self.stores = nil
                self.selectedStoreIndex = 0
                self.isStoreDetailsShown = false
                self.error = error
                self.response = nil
            }
    }
    
    private func updateMapRegion(_ stores: [Store]?) {
        guard let center = stores?.first?.coordinate else {
            return
        }
        region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    }
}

extension Store: Identifiable {
    var coordinate: CLLocationCoordinate2D {
        let components = location.components(separatedBy: ",")
        guard components.count == 2 else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        return CLLocationCoordinate2D(latitude: Double(components[0])!, longitude: Double(components[1])!)
    }
}

struct StoresMapView_Previews: PreviewProvider {

    static var previews: some View {
        StoresMapView(storeType: .shop, stores: PreviewDataProvider.shops, error: nil, selectedStoreIndex: 0, isStoreDetailsShown: true)
        StoresMapView(storeType: .warehouse, stores: PreviewDataProvider.warehouses, error: nil, selectedStoreIndex: 0, isStoreDetailsShown: true).preferredColorScheme(.dark)
        StoresMapView(storeType: .shop, stores: PreviewDataProvider.shops, error: nil)
        StoresMapView(storeType: .shop, stores: nil, error: nil)
        StoresMapView(storeType: .shop, stores: nil, error: NSError(domain: "HTTPError", code: 401, userInfo: nil))
    }
}
