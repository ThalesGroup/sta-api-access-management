//
//  ConfigurationView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct ConfigurationView: View {
    
    private let config = ProtectedStoreApi.shared.configuration
    
    @State private var isImporting = false
    @State private var confirmConfigIsShown = false
    @State private var importedConfigString: String?
    @State var alertDescription: AlertDescription?

    var body: some View {
        
        VStack {
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
            
            Spacer()
            
            NavigationLink(destination: OAuthInfoView()) {
                Image(systemName: "info.circle").imageScale(.large)
                Text("OAuth Info").font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding([.top, .leading, .trailing], 20)

            HStack {
                Button(action: { resetServer(confirmed: false) }, label: {
                    Image(systemName: "arrow.triangle.2.circlepath.circle").imageScale(.large)
                    Text("Reset Server").font(.headline)
                })
                Spacer()
            }
            .padding([.top, .leading], 20)

            HStack {
                Button(action: { isImporting = true }, label: {
                    Image(systemName: "square.and.arrow.down.on.square").imageScale(.large)
                    Text("Import Config").font(.headline)
                })
                Spacer()
            }
            .padding([.top, .leading], 20)
        }
        .navigationTitle("Configuration")
        .sheet(isPresented: $confirmConfigIsShown) {
            if let configString = importedConfigString {
                ImportConfigurationView(isShown:$confirmConfigIsShown, configString: configString)
            }
        }
        .alert(item: $alertDescription) { errorDescription in
            if let buttonInfo = errorDescription.buttonInfo {
                return Alert(title: Text(errorDescription.title), message: Text(errorDescription.message), primaryButton: .destructive(Text(buttonInfo.title), action: buttonInfo.action), secondaryButton: .cancel())
            } else {
                return Alert(title: Text(errorDescription.title), message: Text(errorDescription.message), dismissButton: .cancel(Text("OK")))
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            importConfigFile(result)
        }
    }

    fileprivate func infoPair(key: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(key).font(.headline)
            Text(value).lineLimit(nil).font(.system(size: 14, design: .monospaced))

        }
        .padding([.top, .leading, .trailing])
    }
        
    private func resetServer(confirmed: Bool) {
        guard confirmed else {
            self.alertDescription = AlertDescription(title: "Confirm Reset Server", message: "This will revert the server back to its default values.", buttonInfo: ("Confirm", {
                self.resetServer(confirmed: true)
            }))
            return
        }
        
        ProtectedStoreApi.shared.resetServer().onSuccess {
            self.alertDescription = AlertDescription(title: "Success", message: "Server has been reset")
        }.onFailure { error in
            self.alertDescription = AlertDescription(title: "Failed", message: "Reset was failed with error: \(error.localizedDescription)")
        }
    }
    
    private func importConfigFile(_ result: Result<[URL], Error>) {
        do {
            guard let selectedFile: URL = try result.get().first else { return }
                            
            let url = URL(fileURLWithPath: NSTemporaryDirectory() + "/Imported.json")
            let isAccessing = selectedFile.startAccessingSecurityScopedResource()
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            try FileManager.default.copyItem(at: selectedFile, to: url)
            if isAccessing {
                selectedFile.stopAccessingSecurityScopedResource()
            }
            guard let message = String(data: try Data(contentsOf: url), encoding: .utf8) else { return }
            self.importedConfigString = message
            self.confirmConfigIsShown =  true
        } catch {
            print("Importing file failed with error: \(error)")
        }
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConfigurationView()
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
