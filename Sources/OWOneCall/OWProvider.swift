//
//  OWProvider.swift
//  OWOneCall
//
//  Created by Ringo Wathelet on 2020/06/29.
//

import Foundation
import Combine
import SwiftUI

/**
 * provide access to the OpenWeather One Call data using a single function call
 */
open class OWProvider {
    
    private let client: OWClient
    public var cancellable: AnyCancellable?
    
    public init(apiKey: String) {
        self.client = OWClient(apiKey: apiKey)
    }
    
    // get the weather at the given location with the given options, results pass back through the weather binding
    open func getWeather(lat: Double, lon: Double, weather: Binding<OWResponse>, options: OWOptionsProtocol) {
        cancellable = getOWResponse(lat: lat, lon: lon, options: options)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                if let theWeather = resp {
                    weather.wrappedValue = theWeather
                }
            })
    }
    
    // get the weather at the given location with the given options, with the old style callback
    open func getWeather(lat: Double, lon: Double, options: OWOptionsProtocol, completion: @escaping (OWResponse?) -> Void) {
        cancellable = getOWResponse(lat: lat, lon: lon, options: options)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                // todo error handling
                }
            }, receiveValue: { resp in
                return completion(resp)
            })
    }
    
    private func getOWResponse(lat: Double, lon: Double, options: OWOptionsProtocol) -> AnyPublisher<OWResponse?, APIError> {
        return client.fetchThis(param: "lat=\(lat)&lon=\(lon)", options: options)
    }
    
}
