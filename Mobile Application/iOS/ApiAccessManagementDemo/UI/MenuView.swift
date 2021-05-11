//
//  MenuView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct MenuView: View {
    
    @State private var authorizationState: AuthorizationState = .notAuthorized

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .opacity(0.8)
                
                VStack(alignment: .leading) {
                    Text(authorizationState.detailedDescription.title).font(.headline)
                    if let subtitle = authorizationState.detailedDescription.subtitle {
                        Text(subtitle).font(.subheadline)
                    }
                }
                Spacer()
            }
            .padding([.top, .bottom], 30)
            
            Divider()
            
            HStack {
                Button(action: login, label: {
                    Image(systemName: "arrow.right.square").imageScale(.large)
                    Text("Login").font(.headline)
                })
                Spacer()
            }
            .padding([.top, .leading], 20)
            
            HStack {
                Button(action: logout, label: {
                    Image(systemName: "arrow.backward.square").imageScale(.large)
                    Text("Logout").font(.headline)
                })
                Spacer()
            }
            .padding([.top, .leading], 20)

            NavigationLink(destination: ConfigurationView()) {
                Image(systemName: "gear").imageScale(.large)
                Text("Server Configuration").font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding([.top, .leading], 20)

            Spacer()
        }
        .padding()
        .onReceive(ProtectedStoreApi.shared.authorizationStateDidChange) { state in
            authorizationState = state
        }
        .onAppear {
            authorizationState = ProtectedStoreApi.shared.authorizationState
        }
    }
    
    private func login() {
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        let _ = ProtectedStoreApi.shared.requestAuthorization(presentingViewController: viewController) { (_, _) in }
    }
    
    private func logout() {
        ProtectedStoreApi.shared.resetAuthorization()
    }
}

extension AuthorizationState {
    var detailedDescription:(title: String, subtitle: String?) {
        switch self {
        case .notAuthorized:
            return ("Not authorized", nil)
        case .authorized(let userInfo):
            guard let username = userInfo.name, let email = userInfo.email else {
                return ("Public Client Credentials","No user logged in")
            }
            return ("Authorized as \(username)", "<\(email)>")
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MenuView()
        }
    }
}
