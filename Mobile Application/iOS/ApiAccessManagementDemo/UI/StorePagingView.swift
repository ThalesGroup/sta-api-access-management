//
//  StorePagingView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct StorePagingView: View {

    @Binding var selection: Int
    @Binding var isShown: Bool

    let stores:[Store]
    let type: StoreType
        
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                TabView(selection: $selection) {
                    ForEach(0..<stores.count) { i in
                        StoreRowView(isShown: $isShown, store: stores[i], storeType: type)
                    }
                    .padding(.all, 20)
                }
                .frame(width: UIScreen.main.bounds.width, height: StoreRowView.cellHeight)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
    }
}

struct ShopPagingView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            StorePagingView(selection: .constant(0), isShown: .constant(true), stores: PreviewDataProvider.shops, type: .shop)
            StorePagingView(selection: .constant(0), isShown: .constant(true), stores: PreviewDataProvider.warehouses, type: .warehouse).preferredColorScheme(.dark)
        }
    }
}
