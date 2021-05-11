//
//  Config.swift
//  ApiAccessManagementDemo
//

import Foundation

/// Configuration Details for the Authorization and
/// Client API
struct Config: Codable {
    var apiUrl: String
    var publicClientId: String
    var publicClientSecret: String
    var publicClientWellknown: String
    var retailClientId: String
    var retailClientSecret: String
    var retailClientWellknown: String
}

extension Config {
    
    /// Init with JSON formatted config file
    /// Returns nil if string is malformed.
    init?(withJsonString jsonString: String) {
        guard let config = Config.decode(jsonString.data(using: .utf8) ?? Data()) else {
            return nil
        }
        self = config
    }
    
    /// URL for Public Client Credentials
    var publicClientWellknownUrl: URL {
        URL(string: publicClientWellknown)!
    }
    
    /// URL for Authorized User Credentials
    var retailClientWellknownUrl: URL {
        URL(string: retailClientWellknown)!
    }

    private static func decode(_ data: Data) -> Config? {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(Config.self, from: data)
            return validateParams(config: decoded) ? decoded : nil
        } catch {
            return nil
        }
    }
    
    private static func validateParams(config: Config) -> Bool {
        
        let uuidStrings = [config.publicClientId,
                           config.publicClientSecret,
                           config.retailClientId,
                           config.retailClientId]
        
        let urlStrings = [config.apiUrl,
                          config.publicClientWellknown,
                          config.retailClientWellknown]
        
        for uuidString in uuidStrings {
            guard let _ = UUID(uuidString: uuidString) else {
                return false
            }
        }
        
        for urlString in urlStrings {
            guard let _ = URL(string: urlString) else {
                return false
            }
        }
        
        return true
    }
}
