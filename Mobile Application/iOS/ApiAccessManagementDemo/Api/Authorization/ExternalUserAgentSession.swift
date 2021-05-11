//
//  ExternalUserAgentSession.swift
//  ApiAccessManagementDemo
//

import Foundation

protocol ExternalUserAgentSession {
    
    /// Cancel ongoing login request.
    func cancel()
    
    /// Cancel ongoing login request with completion handler.
    /// - Parameter completion: completion handler
    func cancelWithCompletion(completion: @escaping (() -> Void))
    
    /// Resume external user agent.
    /// - Parameter url: The redirect URL
    func resumeExternalUserAgentWithURL(_ url: URL) -> Bool
    
    /// Fail current session
    /// - Parameter error: error describing the operation
    func failExternalUserAgentFlowWithError(_ error: Error)
}

