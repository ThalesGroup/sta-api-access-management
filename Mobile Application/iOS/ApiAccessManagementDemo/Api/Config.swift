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
        URL(string: publicClientWellknown.replacingOccurrences(of: ".well-known/openid-configuration", with: ""))!
    }
    
    /// URL for Authorized User Credentials
    var retailClientWellknownUrl: URL {
        URL(string: retailClientWellknown.replacingOccurrences(of: ".well-known/openid-configuration", with: ""))!
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
        
        for string in [config.publicClientId,
                       config.publicClientSecret,
                       config.retailClientId,
                       config.retailClientSecret] {
            guard !string.isEmpty else {
                return false
            }
        }
        
        for urlString in [config.apiUrl,
                          config.publicClientWellknown,
                          config.retailClientWellknown] {
            guard let _ = URL(string: urlString) else {
                return false
            }
        }
        
        return true
    }
}
