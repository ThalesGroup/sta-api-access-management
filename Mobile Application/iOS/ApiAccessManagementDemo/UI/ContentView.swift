//
//  ContentView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct ContentView: View {

    @State var isConfigured = ProtectedStoreApi.isConfigured
    
    var body: some View {
        if isConfigured {
            MainView()
        } else {
            InitialConfigView(hidden: $isConfigured)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(isConfigured: true)
            ContentView(isConfigured: false)
        }
    }
}
