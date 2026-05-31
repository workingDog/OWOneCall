//
//  OWClient.swift
//  OWOneCall
//
//  Created by Ringo Wathelet on 2020/06/29.
//

import Foundation


/*
 * error during a connection
 */
public enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    public var errorDescription: String? {
        return switch self {
            case .unknown:  "Unknown error"
            case .apiError(let reason), .parserError(let reason): reason
            case .networkError(let from): from.localizedDescription
        }
    }
}

/*
 * a network connection to openweather one call API server
 * info at: https://openweathermap.org/api/one-call-api
 */
public class OWClient {
    
    public let sessionManager: URLSession
    public let acceptType: String
    public let contentType: String
    public let userAgent: String
    
    private let apiKey: String
    public let baseURL: URL


    public init(apiKey: String, baseURL: URL = URL(string: "https://api.openweathermap.org/data/3.0/onecall")!) {
        self.apiKey = apiKey
        self.baseURL = baseURL

        self.acceptType = "application/json; charset=utf-8"
        self.contentType = "application/json; charset=utf-8"
        self.userAgent = "OWOneCall"

        self.sessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30  // seconds
            configuration.timeoutIntervalForResource = 30 // seconds
            return URLSession(configuration: configuration)
        }()
    }
    
    /*
     * fetch data from the server. A GET request with the chosen parameters is sent to the server.
     * The server response is returned as Data.
     *
     * @components the URLComponents
     * @options OCOptions
     * @return Data
     */
    public func fetchThisAsync(components: URLComponents, options: OWOptionsProtocol) async throws -> Data {
        
        guard let _ = components.url else {
            throw APIError.apiError(reason: "Unable to create URL components")
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue(acceptType, forHTTPHeaderField: "Accept")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
  //      print("\n---> url: \(components.url!.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
  //          print("---> data: \(String(data: data, encoding: .utf8) as AnyObject)")
            
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
            if (httpResponse.statusCode != 200) {
                throw APIError.networkError(from: URLError(.badServerResponse))
            }
            
            return data
        }
        catch let error as APIError {
            throw APIError.apiError(reason: error.localizedDescription)
        }
        catch {
            throw APIError.unknown
        }
    }

    /*
     * fetch data from the server. A GET request with the chosen parameters is sent to the server.
     * The server response is parsed then converted to an object, typically OWResponse.
     *
     * @lat Double
     * @lon Double
     * @options OWOptionsProtocol
     * @return a T
     */
    public func fetchThisAsync<T: Decodable>(lat: Double, lon: Double, options: OWOptionsProtocol) async throws -> T {

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!

        if options is OWHistOptions {
            components.path += "/timemachine"
        }

        var queryItems: [URLQueryItem] = options.toQueryItems()
        queryItems.append(name: "appid", value: apiKey)
        queryItems.append(name: "lat", value: lat)
        queryItems.append(name: "lon", value: lon)

        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        do {
            let data = try await fetchThisAsync(components: components, options: options)
            
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            throw APIError.apiError(reason: error.localizedDescription)
        }
    }

}
