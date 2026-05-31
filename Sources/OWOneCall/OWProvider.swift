//
//  OWProvider.swift
//  OWOneCall
//
//  Created by Ringo Wathelet on 2020/06/29.
//

import Foundation
import SwiftUI

/**
 * provide access to the OpenWeather One Call data using a single function call
 */
open class OWProvider {
    
    public let client: OWClient
    
    /// default endpoint, One Call API 3.0
    public init(apiKey: String, baseURL: URL = URL(string: "https://api.openweathermap.org/data/3.0/onecall")!) {
        self.client = OWClient(apiKey: apiKey, baseURL: baseURL)
    }
    
    /// get the weather at the given location with the given options, results pass back through the weather binding
    open func getWeather(lat: Double, lon: Double, weather: Binding<OWResponse>, options: OWOptionsProtocol) async {
        let results: OWResponse? = await getWeather(lat: lat, lon: lon, options: options)
        if let results {
            weather.wrappedValue = results
        }
    }
    
    /// get the weather at the given location with the given options, with async
    open func getWeather(lat: Double, lon: Double, options: OWOptionsProtocol) async -> OWResponse? {
        do {
            let results: OWResponse = try await client.fetchThisAsync(lat: lat, lon: lon, options: options)
            
            return results
        } catch {
            print(error)
            return nil
        }
    }

}
