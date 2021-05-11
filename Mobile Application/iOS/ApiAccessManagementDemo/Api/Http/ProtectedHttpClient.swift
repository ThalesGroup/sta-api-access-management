//
//  ProtectedHttpClient.swift
//  ApiAccessManagementDemo
//

import Foundation

/// Implementation of HttpClient protocol
/// With API Protection (Access Token)
final class ProtectedHttpClient: HttpClientProtocol {
    
    typealias AccessTokenHandler = (_ callback: @escaping (String?) -> Void) -> Void
    
    init(baseUrl: URL, accessTokenHandler: @escaping AccessTokenHandler) {
        self.baseUrl = baseUrl
        self.accessTokenHandler = accessTokenHandler
    }
        
    func request<T>(_ endpoint: Endpoint<T>) -> HttpResponse<T> {

        let httpResponse = HttpResponse<T>()

        accessTokenHandler { accessToken in
            
            var request = URLRequest(url: self.baseUrl.appendingPathComponent(endpoint.path))
            request.httpMethod = endpoint.method.rawValue
            if let headers = endpoint.headerParameters {
                for (key, value) in headers {
                    request.setValue(value as? String, forHTTPHeaderField: key)
                }
            }
            
            if let accessToken = accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            if let httpBody = endpoint.httpBody {
                request.httpBody = httpBody
            }

            //print("Request: \(request)")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                var object: T?
                var theError: Error?
                
                defer {
                    DispatchQueue.main.async {
                        if let object = object {
                            httpResponse.successHandler?(object)
                        } else {
                            httpResponse.failureHandler?(theError ?? NSError(domain: "HttpErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Undefined Error"]))
                        }
                    }
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    theError = error
                    return
                }

                //print("Response: \(request); Code: \(response.statusCode)")

                let result = HttpCode(response.statusCode)
                
                guard result.success else {
                    theError = result.error
                    return
                }
                
                do {
                    object = try endpoint.decode(data)
                }
                catch {
                    theError = error
                }
            }.resume()
        }
        
        return httpResponse
    }
    
    private let baseUrl: URL
    private let accessTokenHandler: AccessTokenHandler
}

struct HttpCode {
    
    private(set) var success: Bool
    private(set) var error: Error?
    
    init(_ statusCode: Int) {
        
        let httpCode = "\nHTTP: \(statusCode)"
        
        var success = false
        var errorMessage = ""

        switch statusCode {
        case 200...299:
            success = true
            errorMessage = "Success" + httpCode
        case 400:
            errorMessage = "Failed: Bad Request" + httpCode
        case 401:
            errorMessage = "Failed: Unauthorized (RFC 7235)" + httpCode
        case 403:
            errorMessage = "Failed: Forbidden" + httpCode
        case 404:
            errorMessage = "Failed: Not Found" + httpCode
        case 405:
            errorMessage = "Failed: Method Not Allowed" + httpCode
        case 406:
            errorMessage = "Failed: Not Acceptable" + httpCode
        default:
            errorMessage = "Generic Failure" + httpCode + "See for details: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes"
        }
        
        self.success = success
        self.error = success ? nil : NSError(domain: "HttpErrorDomain", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
    }
}

