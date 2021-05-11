//
//  StoreRowView.swift
//  ApiAccessManagementDemo
//

import SwiftUI
import UIKit

struct StoreRowView: View {
    
    @Binding var isShown: Bool
    let store: Store
    let storeType: StoreType
    
    @State var description: String?
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .layoutPriority(-1)
                }
                
                Text(store.name)
                    .font(Font.system(size: 17, weight: .bold))
                    .foregroundColor(Color.init(UIColor.label))
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 2)
                
                Text(description ?? "Loading ...")
                    .lineLimit(4)
                    .foregroundColor(Color.init(UIColor.systemGray))
                    .font(Font.system(size: 15))
                    .padding([.leading, .trailing])
                
                Spacer()
                
                Divider()
                
                NavigationLink(
                    destination: ProductListView(store: store, storeType: storeType),
                    label: {
                        HStack {
                            Spacer()
                            Text("VIEW PRODUCT LIST")
                                .font(Font.system(size: 15))
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 7, trailing: 20))
                        }
                    }
                )
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { isShown.toggle() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(Font.system(size: 25, weight: .bold))
                            .foregroundColor(Color.white)
                            .padding()
                            .shadow(radius: 2.0)
                    }
                }
                Spacer()
            }
        }
        .background(Color.init(UIColor.systemBackground))
        .frame(height: StoreRowView.cellHeight)
        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
        .shadow(radius: 5.0)
        .frame(maxWidth: .infinity)
        .onAppear {
            getBannerImage()
            update()
        }
    }

    private func update() {
        guard description == nil else { return }
        let function = storeType == .shop ? ProtectedStoreApi.shared.fetchShopInfo : ProtectedStoreApi.shared.fetchWarehouseInfo
        function(store.id).onSuccess { info in
            self.description = info.description
        }
    }
    
    private func getBannerImage() {
        guard image == nil else { return }
        guard let path = storeType == .shop ? shopBannerPath : warehouseBannerPath  else { return }
        guard let image = UIImage(contentsOfFile: path) else { return }
        self.image = image.cropped(targetSize: CGSize(width: UIScreen.main.bounds.width, height: 150))
    }
    
    static let cellHeight = CGFloat(275)
    private let shopBannerPath = Bundle.main.path(forResource: "store_card_banner.jpg", ofType: nil)
    private let warehouseBannerPath = Bundle.main.path(forResource: "warehouse_card_banner.jpg", ofType: nil)
}

struct ShopRowView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            StoreRowView(isShown: .constant(true), store: PreviewDataProvider.shops[0], storeType: .shop, description: nil)
            StoreRowView(isShown: .constant(true), store: PreviewDataProvider.warehouses[0], storeType: .warehouse, description: "Description goes here...").preferredColorScheme(.dark)
        }.padding()
    }
}
