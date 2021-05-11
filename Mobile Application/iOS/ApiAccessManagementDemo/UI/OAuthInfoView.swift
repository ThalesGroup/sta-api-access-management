//
//  OAuthInfoView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct OAuthInfoView: View {
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                infoPair(key: "Auth Type", value: ProtectedStoreApi.shared.authorizationState.stringValue)
                infoPair(key: "Expiration Time", value: "\(Int(ProtectedStoreApi.shared.tokenInfo?.expirationDate?.remainingTime ?? 0)) seconds")
                infoPair(key: "Access Token", value: ProtectedStoreApi.shared.tokenInfo?.accessToken ?? "Not set")
                infoPair(key: "Refresh Token", value: ProtectedStoreApi.shared.tokenInfo?.refreshToken ?? "Not set")
            }
        }
        .navigationTitle("OAuth Information")
    }
    
    fileprivate func infoPair(key: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(key).font(.headline)
            HStack {
                Spacer().frame(width: 50)
                Text(value).lineLimit(nil).font(.system(size: 14, design: .monospaced))
            }
        }
        .padding([.top, .leading, .trailing])
    }
}

extension Date {
    var remainingTime: TimeInterval {
        let timeInternal = self.timeIntervalSince(Date())
        return timeInternal > 0 ? timeInternal : 0
    }
}

fileprivate extension AuthorizationState {
    var stringValue: String {
        switch self {
        case .notAuthorized:
            return "Not Authorized"
        case .authorized(let userInfo):
            guard let _ = userInfo.name, let _ = userInfo.email else {
                return "Client Credentials"
            }
            return "Authorized"
        }
    }
}

struct OAuthInfoView_Previews: PreviewProvider {
    static var previews: some View {
        OAuthInfoView()
    }
}
