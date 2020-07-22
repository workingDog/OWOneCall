//
//  OWClient.swift
//  OWOneCall
//
//  Created by Ringo Wathelet on 2020/06/29.
//

import Foundation
import Combine


/*
 * represents an error during a connection
 */
public enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .networkError(let from):
            return from.localizedDescription
        }
    }
}

/*
 * a network connection to openweather one call API server
 * info at: https://openweathermap.org/api/one-call-api
 */
public class OWClient {
    
    let apiKey: String
    let sessionManager: URLSession
    
    let mediaType = "application/json; charset=utf-8"
    let oneCallURL = "https://api.openweathermap.org/data/2.5/onecall"
    let timemachine = "/timemachine"
    
    public init(apiKey: String) {
        self.apiKey = "appid=" + apiKey
        self.sessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30  // seconds
            configuration.timeoutIntervalForResource = 30 // seconds
            return URLSession(configuration: configuration)
        }()
    }

    private func baseUrl(_ locParam: String, options: OWOptionsProtocol) -> URL? {
        if options is OWHistOptions {
            return URL(string: "\(oneCallURL)\(timemachine)?\(locParam)\(options.toParamString())&\(apiKey)")
        } else {
            return URL(string: "\(oneCallURL)?\(locParam)\(options.toParamString())&\(apiKey)")
        }
    }
    
    /*
     * fetch data from the server. A GET request with the chosen parameters is sent to the server.
     * The server response is parsed then converted to an object, typically OWResponse.
     *
     * @param parameters
     * @return a AnyPublisher<T?, APIError>
     */
    public func fetchThis<T: Decodable>(param: String, options: OWOptionsProtocol) -> AnyPublisher<T?, APIError> {
        guard let url = baseUrl(param, options: options) else {
            return Just<T?>(nil).setFailureType(to: APIError.self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }
    
    private func doDataTaskPublish<T: Decodable>(request: URLRequest) -> AnyPublisher<T?, APIError> {
        return self.sessionManager.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                if (httpResponse.statusCode == 401) {
                    throw APIError.apiError(reason: "Unauthorized")
                }
                if (httpResponse.statusCode == 403) {
                    throw APIError.apiError(reason: "Resource forbidden")
                }
                if (httpResponse.statusCode == 404) {
                    throw APIError.apiError(reason: "Resource not found")
                }
                if (405..<500 ~= httpResponse.statusCode) {
                    throw APIError.apiError(reason: "client error")
                }
                if (500..<600 ~= httpResponse.statusCode) {
                    throw APIError.apiError(reason: "server error")
                }

                return try? JSONDecoder().decode(T.self, from: data)
            }
            .mapError { error in
                // return the APIError type error
                if let error = error as? APIError {
                    return error
                }
                // a URLError, convert it to APIError type error
                if let urlerror = error as? URLError {
                    return APIError.networkError(from: urlerror)
                }
                // unknown error condition
                return APIError.unknown
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
 
}
