//
//  ImportConfigurationView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct ImportConfigurationView: View {
    
    @Binding var isShown: Bool
    let configString: String

    @State var alertDescription: AlertDescription?
    
    var body: some View {
        Group {
            if let config = Config(withJsonString: configString) {
                NavigationView {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            infoPair(key: "API URL", value: config.apiUrl)
                            infoPair(key: "Public Client ID", value: config.publicClientId)
                            infoPair(key: "Public Client Secret", value: config.publicClientSecret)
                            infoPair(key: "Public Well-known Discovery", value: config.publicClientWellknown)
                            infoPair(key: "Retail Client ID", value: config.retailClientId)
                            infoPair(key: "Ratail Client Secret", value: config.retailClientSecret)
                            infoPair(key: "Retail Well-known Discovery", value: config.retailClientWellknown)
                        }
                    }
                    .navigationBarItems(leading: Button(action: { isShown.toggle() }, label: {
                        Text("Back").bold()
                    }))
                    .navigationBarTitle("Confirm Configuration", displayMode: .inline)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            Spacer()
                            Button(action: { doImport(config: config) }) {
                                Text("CONFIRM").bold()
                            }
                            Spacer()
                        }
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                NavigationView {
                    Text("The string file is not a valid configuration JSON file.")
                        .bold()
                        .multilineTextAlignment(.center)
                        .navigationBarItems(leading: Button(action: { isShown.toggle() }, label: {
                            Text("Back").bold()
                        }))
                        .navigationBarTitle("ERROR!", displayMode: .inline)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .alert(item: $alertDescription) { alertDescription in
            Alert(title: Text(alertDescription.title), message: Text(alertDescription.message), dismissButton: .cancel(Text("OK"), action: {
                isShown = false
            }))
        }
    }
    
    fileprivate func infoPair(key: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(key).font(.headline)
            Text(value)
        }
        .padding()
    }
    
    private func doImport(config: Config) {
        ProtectedStoreApi.saveConfig(config)
        ProtectedStoreApi.shared.updateConfig(config)
        alertDescription = AlertDescription(title: "Updated", message: "Configuration has been updated")
    }
}
struct ImportConfigurationView_Previews: PreviewProvider {
    
    static var configString: String {
        guard let defaultConfigPath = Bundle.main.path(forResource: "Config", ofType: "json") else { return ""}
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: defaultConfigPath))
            return String(data: data, encoding: .utf8) ?? ""
        }
        catch {
            return ""
        }
    }
    
    static var previews: some View {
        ImportConfigurationView(isShown: .constant(true), configString: configString)
        ImportConfigurationView(isShown: .constant(true), configString: "")
    }
}
