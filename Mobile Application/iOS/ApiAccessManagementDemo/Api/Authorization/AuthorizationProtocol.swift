//
//  Authorization.swift
//  ApiAccessManagementDemo
//

import Foundation
import UIKit

/// Authorization State
enum AuthorizationState {

    typealias UserInfo = [AnyHashable: Any]

    
    /// Not Authorized state
    case notAuthorized
        
    /// Authorized state
    /// With relevant user info
    case authorized(userInfo: UserInfo)
}

/// Authorization API Protocol
protocol AuthorizationProtocol {
    
    typealias TokenInfo = (expirationDate: Date?, accessToken: String?, refreshToken: String?)
    
    /// Authorization State
    var authorizationState: AuthorizationState { get }
    
    var tokenInfo: TokenInfo? { get }
    
    /// User Authorization Flow
    /// - Parameters:
    ///   - presentingViewController: The view controller on which to present the login view to the user
    ///   - completion: Completion handler
    /// - Returns: ExternalUserAgentSession object to manage external agent.
    func requestAuthorization(presentingViewController: UIViewController, completion: @escaping (Bool, Error?) -> Void) -> ExternalUserAgentSession
    
    /// Get any fresh access token
    /// - Parameter callback: The callback
    func getFreshAccessToken(callback: @escaping (String?) -> Void)
    
    /// Reset/Clear auth state
    func reset()
}
