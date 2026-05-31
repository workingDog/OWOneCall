//
//  OWOptions.swift
//  OWOneCall
//
//  Created by Ringo Wathelet on 2020/07/01.
//

import Foundation


/// convenience
extension Array where Element == URLQueryItem {
    
    mutating func append<T>(name: String, value: T?) {
        guard let value else { return }
        append(URLQueryItem(name: name, value: String(describing: value)))
    }
    
}

/*
 * parameters to exclude some parts of the weather data from the API response
 */
public enum ExcludeMode: String {
    case current
    case minutely
    case hourly
    case daily
    case alerts
}

/*
 * parameters for units, Standard (Kelvin), metric (Celsius), or imperial (Fahrenheit) units
 */
public enum Units: String {
    case metric
    case imperial
    case standard
}

public protocol OWOptionsProtocol {
    func toQueryItems() -> [URLQueryItem]
}

/*
 * Options to use for retrieving historical weather data
 */
public class OWHistOptions: OWOptionsProtocol {
    
    private var dt: Int
    private var lang: String?
    
    public init(dt: Int, lang: String = "en") {
        self.dt = dt
        self.lang = lang
    }

    public init(date: Date, lang: String = "en") {
        self.dt = Int(date.timeIntervalSince1970)
        self.lang = lang
    }
    
    // day is the number of days in the past
    public static func daysAgo(day: Double, lang: String = "en") -> OWHistOptions {
        return OWHistOptions(date: Date().addingTimeInterval(-60*60*24*day), lang: lang)
    }
    
    public static func yesterday(lang: String = "en") -> OWHistOptions {
        return OWHistOptions.daysAgo(day: 1.0, lang: lang)
    }
    
    public func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        items.append(name: "dt", value: dt)
        items.append(name: "lang", value: lang)

        return items
    }
}

/*
 * Options to use for retrieving current and forecast weather data
 */
public class OWOptions: OWOptionsProtocol {
    
    private var excludeMode: [ExcludeMode]?
    private var units: Units?
    private var lang: String?
    
    
    public init(excludeMode: [ExcludeMode], units: Units, lang: String) {
        self.excludeMode = excludeMode
        self.units = units
        self.lang = lang
    }
    
    // for everything
    public init() { }
    
    // for everything
    public init(lang: String = "en") { }
    
    // just the current weather
    public static func current(lang: String = "en") -> OWOptions {
        let options = OWOptions()
        options.excludeMode = [.daily, .hourly, .minutely, .alerts]
        options.units = .metric
        options.lang = lang
        return options
    }
    
    // daily and current weather
    public static func dailyForecast(lang: String = "en") -> OWOptions {
        let options = OWOptions()
        options.excludeMode = [.hourly, .minutely, .alerts]
        options.units = .metric
        options.lang = lang
        return options
    }
    
    // hourly and current weather
    public static func hourlyForecast(lang: String = "en") -> OWOptions {
        let options = OWOptions()
        options.excludeMode = [.daily, .minutely, .alerts]
        options.units = .metric
        options.lang = lang
        return options
    }
    
    // just the alerts
    public static func alerts(lang: String = "en") -> OWOptions {
        let options = OWOptions()
        options.excludeMode = [.daily, .hourly, .minutely, .current]
        options.units = .metric
        options.lang = lang
        return options
    }

    public func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        items.append(name: "units", value: units)
        items.append(name: "lang", value: lang)
        
        if let excludeMode {
            items.append(name: "exclude", value: excludeMode.map { String($0.rawValue) }.joined(separator: ","))
        }

        return items
    }
}
