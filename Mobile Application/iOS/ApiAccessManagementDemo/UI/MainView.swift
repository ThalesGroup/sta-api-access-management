//
//  MainView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct MainView: View {

    let isMapView: Bool
    
    var body: some View {
        ZStack {
            if isMapView {
                TabView {
                    StoresMapView(storeType: .shop)
                        .tabItem { Label("SHOPS", systemImage: "map") }
                    StoresMapView(storeType: .warehouse)
                        .tabItem { Label("WAREHOUSES", systemImage: "map") }
                }
            } else {
                TabView {
                    StoresListView(storeType: .shop)
                        .tabItem { Label("SHOPS", systemImage: "list.bullet") }
                    StoresListView(storeType: .warehouse)
                        .tabItem { Label("WAREHOUSES", systemImage: "list.bullet") }
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView(isMapView: true)
            MainView(isMapView: false)
        }
    }
}
