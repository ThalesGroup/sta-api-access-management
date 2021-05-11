//
//  HttpClientProtocol.swift
//  ApiAccessManagementDemo
//

import Foundation

typealias HttpParams = [String: Any]

typealias HttpRelativePath = String

enum HttpMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

protocol HttpClientProtocol {
    func request<T>(_ endpoint: Endpoint<T>) -> HttpResponse<T>
}

final class HttpResponse<T> where T: Any {
    
    typealias SuccessHandler = (T) -> Void
    typealias FailureHandler = (Error) -> Void
    
    private(set) var successHandler: SuccessHandler? = nil
    private(set) var failureHandler: FailureHandler? = nil
    
    @discardableResult func onSuccess(_ successHandler: SuccessHandler?) -> HttpResponse<T> {
        self.successHandler = successHandler
        return self
    }
    
    @discardableResult func onFailure(_ failureHandler: FailureHandler?) -> HttpResponse<T> {
        self.failureHandler = failureHandler
        return self
    }
}

final class Endpoint<T> {
    let method: HttpMethod
    let path: HttpRelativePath
    let parameters: HttpParams?
    let headerParameters: HttpParams?
    let httpBody: Data?
    let decode: (Data) throws -> T

    init(method: HttpMethod = .GET,
         path: HttpRelativePath,
         parameters: HttpParams? = nil,
         headerParameters: HttpParams? = nil,
         httpBody: Data? = nil,
         decode: @escaping (Data) throws -> T) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.httpBody = httpBody
        self.decode = decode
        self.headerParameters = headerParameters
    }
}

extension Endpoint where T: Decodable {
    convenience init(method: HttpMethod = .GET,
                     path: HttpRelativePath,
                     parameters: HttpParams? = nil) {
        self.init(method: method, path: path, parameters: parameters) {
            try JSONDecoder().decode(T.self, from: $0)
        }
    }
}

extension Endpoint where T == Void {
    convenience init(method: HttpMethod = .GET,
                     path: HttpRelativePath,
                     parameters: HttpParams? = nil) {
        self.init(
            method: method,
            path: path,
            parameters: parameters,
            decode: { _ in () }
        )
    }
}

