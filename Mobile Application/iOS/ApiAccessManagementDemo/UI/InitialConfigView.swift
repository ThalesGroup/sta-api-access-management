//
//  InitialConfigView.swift
//  ApiAccessManagementDemo
//

import SwiftUI

struct InitialConfigView: View {
    
    @Binding var hidden: Bool
    @State private var isImporting = false
    @State private var importedConfigString: String = ""
    @State private var confirmConfigIsShown = false
    
    var body: some View {
        
        NavigationView {
            VStack {
                Text("Server configuration not set!").font(.headline).padding()
                Text("Import a JSON-formatted config text file with the following shema:")
                ScrollView(.horizontal) {
                    Text(schema).font(.system(size: 14, design: .monospaced))
                        .padding()
                }.background(Color.init(UIColor.systemGray5))
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: { isImporting = true }, label: {
                        Image(systemName: "square.and.arrow.down.on.square").imageScale(.large)
                        Text("Import").font(.headline)
                    })
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $confirmConfigIsShown, onDismiss: {
            hidden = ProtectedStoreApi.isConfigured
        }, content: {
            if let configString = importedConfigString {
                ImportConfigurationView(isShown:$confirmConfigIsShown, configString: configString)
            }
        })
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            importConfigFile(result)
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
    
    private var schema: String {
        guard let defaultConfigPath = Bundle.main.path(forResource: "Config", ofType: "json") else { return ""}
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: defaultConfigPath))
            return String(data: data, encoding: .utf8) ?? ""

        } catch {
            return ""
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        InitialConfigView(hidden: .constant(false))
    }
}
