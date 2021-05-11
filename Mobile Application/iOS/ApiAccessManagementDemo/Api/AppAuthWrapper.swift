//
//  AppAuthWrapper.swift
//  ApiAccessManagementDemo
//

import Foundation
import AppAuth

/// Implementation of AuthorizationApi
/// Wrapper of AppAuth library (https://github.com/openid/AppAuth-iOS.git)
class AppAuthWrapper: AuthorizationProtocol {
        
    @Published var authorizationState: AuthorizationState = .notAuthorized

    init(configuration: Config) {
        self.configuration = configuration
        validateOAuthConfiguration()
    }
    
    func requestAuthorization(presentingViewController: UIViewController, completion: @escaping (Bool, Error?) -> Void) -> ExternalUserAgentSession {
        
        doUserAuth(presentingViewController: presentingViewController, completion: completion)
    }

    func getFreshAccessToken(callback: @escaping (String?) -> Void) {
        doGetFreshAccessToken(callback: callback)
    }
    
    func reset() {
        doLogout()
    }
        
    var tokenInfo: TokenInfo? {
        getTokenInfo()
    }

    //MARK: - Private
    
    private var configuration: Config
    private var authorizationWorkFlow: ExternalUserAgentSessionImpl?
    private let redirectUrl: URL = URL(string: "com.spe-demo.apps:/auth")!
    
    /// User Auth (Authorization Code + PKCE)
    private var userAuth: OIDAuthState?
    
    /// Client Auth (Client Credential Flow)
    private var clientAuth: OIDAuthState?

    /// Default authorization flow (Client credential flow).
    private func doClientAuth(completion: @escaping () -> Void) {
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: configuration.publicClientWellknownUrl) { deviceConfiguration, error in
            guard let config = deviceConfiguration else {
                self.log("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                completion()
                return
            }
                                    
            let request = OIDTokenRequest(configuration: config,
                                          grantType: OIDGrantTypeClientCredentials,
                                          authorizationCode: nil,
                                          redirectURL: nil,
                                          clientID: self.configuration.publicClientId,
                                          clientSecret: self.configuration.publicClientSecret,
                                          scope: "\(OIDScopeOpenID) \(OIDScopeEmail) \(OIDScopeProfile)",
                                          refreshToken: nil,
                                          codeVerifier: nil,
                                          additionalParameters: nil)
            
            OIDAuthorizationService.perform(request) { response, error in
                
                guard let response = response else {
                    guard let error = error else {
                        completion()
                        return
                    }
                    self.log("Error: \(error.localizedDescription)")
                    completion()
                    return
                }
                
                self.log("Public Auth: response.accessToken = \(response.accessToken ?? "NULL")")
                self.log("Public Auth: response.idToken = \(response.idToken ?? "NULL")")
                self.log("Public Auth: response.refreshToken = \(response.refreshToken ?? "NULL")")
                
                self.clientAuth = OIDAuthState(authorizationResponse: nil, tokenResponse: response, registrationResponse: nil)
                
                self.authorizationState = .authorized(userInfo: self.parseAccessTokenClaims(response.idToken))
                
                completion()
            }
        }
    }

    private func doUserAuth(presentingViewController: UIViewController, completion: @escaping (Bool, Error?) -> Void) -> ExternalUserAgentSession {
        
        let workflow = ExternalUserAgentSessionImpl()
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: configuration.retailClientWellknownUrl) { config, error in
            
            guard let config = config else {
                self.log("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                completion(false, error)
                return
            }
                        
            let configuration = self.configuration
            
            let request = OIDAuthorizationRequest(configuration: config,
                                                  clientId: configuration.retailClientId,
                                                  clientSecret: configuration.retailClientSecret,
                                                  scopes: [OIDScopeOpenID, OIDScopeEmail, OIDScopeProfile],
                                                  redirectURL: self.redirectUrl,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
            
            let currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) { authState, error in

                if authState != nil {
                    self.log("Got authorization tokens. Access token: \(authState?.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
                } else {
                    self.log("AuthState = nil. Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                    completion(false, error)
                    return
                }
                
                self.log("Auth State: response.accessToken = \(authState?.lastTokenResponse?.accessToken ?? "NULL")")
                self.log("Auth State: response.idToken = \(authState?.lastTokenResponse?.idToken ?? "NULL")")
                self.log("Auth State: response.refreshToken = \(authState?.lastTokenResponse?.refreshToken ?? "NULL")")

                self.userAuth = authState

                self.getFreshAccessToken(callback: { _ in })
                
                let success = (authState?.isAuthorized ?? false)
                
                if authState?.isAuthorized ?? false {
                    let userInfo = self.parseAccessTokenClaims(authState?.lastTokenResponse?.idToken ?? "")
                    self.authorizationState = .authorized(userInfo: userInfo)
                } else {
                    self.authorizationState = .notAuthorized
                }
                
                completion(success, success ? nil : error)
                
                self.authorizationWorkFlow = nil
            }
            
            self.authorizationWorkFlow?.innerSession = currentAuthorizationFlow
        }
        
        self.authorizationWorkFlow = workflow
        return workflow

    }
    
    private func doGetFreshAccessToken(callback: @escaping (String?) -> Void) {
        let freshToken:(OIDAuthState?) -> Void  = { state in
            if let state = state {
                state.performAction { (accessToken, _, _) in
                    callback(accessToken)
                }
            } else {
                callback(nil)
            }
        }
        
        // Looks for user authorization first
        if let authState = userAuth {
            freshToken(authState)
            return
        }
        
        // For public authorization, we need to manually refresh if needed,
        // as autoRefresh (in state.performAction) is not supported by AppAuth library
        let needsManualRefresh = clientAuth?.lastTokenResponse?.needsManualRefresh ?? true
        if needsManualRefresh {
            doClientAuth {
                freshToken(self.clientAuth)
            }
        } else {
            freshToken(clientAuth)
        }
    }
    
    private func doLogout() {
        userAuth = nil
        if clientAuth != nil {
            authorizationState = .authorized(userInfo: parseAccessTokenClaims(clientAuth?.lastTokenResponse?.idToken))
        } else {
            authorizationState = .notAuthorized
        }
    }
    
    private func getTokenInfo() -> TokenInfo? {
        var authState: OIDAuthState?
        
        if self.userAuth != nil {
            authState = self.userAuth
        } else if self.clientAuth != nil {
            authState = clientAuth
        }
        
        if let authState = authState {
            return (authState.lastTokenResponse?.accessTokenExpirationDate, authState.lastTokenResponse?.accessToken, authState.lastTokenResponse?.refreshToken)
        } else {
            return nil
        }
    }
    
    /// Parses JWT id token and extracts the name and email of the authorized user.
    private func parseAccessTokenClaims(_ idToken: String?) -> AuthorizationState.UserInfo {
        if let token = OIDIDToken(idTokenString: idToken ?? "") {
            return token.claims
        } else {
            log("Error parsing user details")
            return [:]
        }
    }
    
    /// Sanity check for app settings
    private func validateOAuthConfiguration() {
        
        // verifies that the custom URI scheme has been updated in the Info.plist
        guard let urlTypes: [AnyObject] = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [AnyObject], urlTypes.count > 0 else {
            assertionFailure("No custom URI scheme has been configured for the project.")
            return
        }

        guard let items = urlTypes[0] as? [String: AnyObject],
            let urlSchemes = items["CFBundleURLSchemes"] as? [AnyObject], urlSchemes.count > 0 else {
            assertionFailure("No custom URI scheme has been configured for the project.")
            return
        }

        guard let urlScheme = urlSchemes[0] as? String else {
            assertionFailure("No custom URI scheme has been configured for the project.")
            return
        }

        assert(redirectUrl.absoluteString.hasPrefix(urlScheme),
                "Configure the URI scheme in Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) " +
                "with the scheme of your redirect URI. Full instructions: " +
                "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md")
    }
    
    private func log(_ string: String) {
        // print(string)
    }
}

// MARK: - ExternalUserAgentSessionImpl

private class ExternalUserAgentSessionImpl: ExternalUserAgentSession {
    
    var innerSession: OIDExternalUserAgentSession?
        
    func cancel() {
        innerSession?.cancel()
    }
    
    func cancelWithCompletion(completion: @escaping (() -> Void)) {
        innerSession?.cancel(completion: completion)
    }
    
    func resumeExternalUserAgentWithURL(_ url: URL) -> Bool {
        innerSession?.resumeExternalUserAgentFlow(with: url) ?? false
    }
    
    func failExternalUserAgentFlowWithError(_ error: Error) {
        innerSession?.failExternalUserAgentFlowWithError(error)
    }
}


private extension OIDTokenResponse {
    
    static let expiryTimeTolerance: TimeInterval = 90
    
    /// We mark needsManualRefresh if interval before expiry is less than 90 seconds.
    var needsManualRefresh: Bool {
        guard let expirationDate = accessTokenExpirationDate else {
            return false
        }        
        return expirationDate.timeIntervalSince(Date()) < OIDTokenResponse.expiryTimeTolerance
    }
}
