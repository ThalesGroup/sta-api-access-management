//
//  ProtectedStoreApi.swift
//  ApiAccessManagementDemo
//

import Foundation
import Combine
import UIKit

enum StoreType {
    case shop
    case warehouse
}

/// Store API with Access Management Protection
class ProtectedStoreApi {

    // MARK: Authorization
    
    /// Authorization State
    var authorizationState: AuthorizationState = .notAuthorized
    
    /// Notifies changes to authorization state
    let authorizationStateDidChange = PassthroughSubject<AuthorizationState, Never>()
    
    /// Notifies changes to configuration
    let configurationDidChange = PassthroughSubject<Config, Never>()
    
    /// Login authorized user through a embedded webview
    func requestAuthorization(presentingViewController: UIViewController, completion: @escaping (Bool, Error?) -> Void) -> ExternalUserAgentSession {
        authWrapper.requestAuthorization(presentingViewController: presentingViewController, completion: completion)
    }
    
    /// Info of the current access token and refresh token if any
    var tokenInfo: AuthorizationProtocol.TokenInfo? {
        authWrapper.tokenInfo
    }
    /// Clear any authorization
    func resetAuthorization() {
        authWrapper.reset()
    }
    
    // MARK: - Configuration update

    /// Update the server configuration
    func updateConfig(_ config: Config) {
        _client = nil
        _authWrapper = nil
        configuration = config
        authorizationState = .notAuthorized
        configurationDidChange.send(configuration)
        authorizationStateDidChange.send(authorizationState)
    }
    
    // MARK: - Store API
    
    /// Fetch shops
    func fetchShops() -> HttpResponse<[Shop]> {
        client.request(StoreApi.fetchShops())
    }
    
    /// Fetch warehouses
    func fetchWarehouses() -> HttpResponse<[Warehouse]> {
        client.request(StoreApi.fetchWarehouses())
    }
    
    /// Fetch the shop info
    func fetchShopInfo(id: String) -> HttpResponse<ShopInfo> {
        client.request(StoreApi.fetchShopInfo(id: id))
    }
    
    /// Fetch the warehouse info
    func fetchWarehouseInfo(id: String) -> HttpResponse<WarehouseInfo> {
        client.request(StoreApi.fetchWarehouseInfo(id: id))
    }
    
    /// Fetch the stock items of a shop
    func fetchShopStock(id: String) -> HttpResponse<[StockItem]> {
        client.request(StoreApi.fetchShopStock(id: id))
    }
    
    /// Fetch the stock items of a warehouse
    func fetchWarehouseStock(id: String) -> HttpResponse<[StockItem]> {
        client.request(StoreApi.fetchWarehouseStock(id: id))
    }
    
    /// Move a stock to from a warehouse to a shop
    func moveStock(warehouseId: String, stockId: String, shopId: String, count: Int) -> HttpResponse<Void> {
        client.request(StoreApi.moveStock(warehouseId: warehouseId, stockId: stockId, shopId: shopId, count: count))
    }
    
    /// Revert the server to its default state.
    func resetServer() -> HttpResponse<Void> {
        client.request(StoreApi.reset())
    }
    
    // MARK: - Internal/Private
    
    fileprivate init(with config: Config) {
        self.configuration = config
    }
    
    private(set) var configuration: Config
    
    internal func getFreshAccessToken(callback: @escaping (String?) -> Void) {
        authWrapper.getFreshAccessToken(callback: callback)
    }
    
    private var anyCancellable: AnyCancellable?
    
    private var _authWrapper: AppAuthWrapper?
    private var authWrapper: AppAuthWrapper {
        if _authWrapper == nil {
            _authWrapper = AppAuthWrapper(configuration: configuration)
            anyCancellable = _authWrapper?.$authorizationState.sink(receiveCompletion: { _ in },
                                                                    receiveValue: { authorizationState in
                                                                        self.authorizationState = authorizationState
                                                                        self.authorizationStateDidChange.send(self.authorizationState)
                                                                    })
        }
        return _authWrapper!
    }
    
    private var _client: ProtectedHttpClient?
    private var client: ProtectedHttpClient {
        if _client == nil {
            _client = ProtectedHttpClient(baseUrl: URL(string: configuration.apiUrl)!, accessTokenHandler: { (callback) in
                self.authWrapper.getFreshAccessToken(callback: { accessToken in
                    callback(accessToken)
                })
            })
        }
        
        return _client!
    }
}

// MARK: - Extensions

extension AuthorizationState.UserInfo {
    
    var name: String? {
        self["name"] as? String
    }
    
    var email: String? {
        self["email"] as? String
    }
}

/// Globally shared object across the app
extension ProtectedStoreApi {
     
    static let configKey = "Config"
    
    static var shared: ProtectedStoreApi {
        return _model ?? ProtectedStoreApi()
    }
    
    static var isConfigured: Bool {
        if _model != nil {
            return true
        }
        configureSharedModel()
        return _model != nil
    }

    static func saveConfig(_ config: Config) {
        do {
            let encoded = try JSONEncoder().encode(config)
            let jsonString = String(data: encoded, encoding: .utf8)
            UserDefaults.standard.setValue(jsonString, forKey: configKey)
        } catch {
            print("Error in saving configuration \(error.localizedDescription)")
        }
    }

    private static var _model: ProtectedStoreApi?

    private static func configureSharedModel() {
        guard let jsonString =  UserDefaults.standard.value(forKey: configKey) as? String,
              let config = Config(withJsonString: jsonString)else {
            return
        }
        saveConfig(config)
        _model = ProtectedStoreApi(with: config)
    }
    
    private convenience init() {
        self.init(with: ProtectedStoreApi.defaultConfig!)
    }
    
    static private var defaultConfig: Config? {
        let assertFileError = { assert(false, "Config file not found") }
        do {
            guard let defaultConfigPath = Bundle.main.path(forResource: "Config", ofType: "json") else {
                assertFileError()
                return nil
            }
            let data = try Data(contentsOf: URL(fileURLWithPath: defaultConfigPath))
            guard let jsonString = String(data: data, encoding: .utf8) else {
                assertFileError()
                return nil
            }
            return Config(withJsonString: jsonString)
        } catch {
            assertFileError()
            return nil
        }
    }
}
