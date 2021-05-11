//
//  ContentView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct ContentView: View {
    
    @State var showsMenu = false
    @State var isMapView = true
    
    var body: some View {
        NavigationView {
            MainView(isMapView: isMapView)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
