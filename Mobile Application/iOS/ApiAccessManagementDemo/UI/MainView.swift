//
//  MainView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct MainView: View {

    @State private var isMapView = true
    @State private var showsMenu = false
    
    var body: some View {
        NavigationView {
            Group {
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
            .navigationBarItems(trailing: NavigationLink(
                                    destination: MenuView(),
                                    isActive: $showsMenu,
                                    label: {
                                        Image(systemName: "gear").imageScale(.large)
                                    }))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: { isMapView.toggle() }, label: {
                        HStack {
                            Text("View Mode : ").bold()
                            Image(systemName: isMapView ? "map" : "list.bullet").imageScale(.large)
                        }
                    })
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
        }
    }
}
