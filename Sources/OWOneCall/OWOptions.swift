//
//  OWOptions.swift
//  OWOneCall
//
//  Created by Ringo Wathelet on 2020/07/01.
//

import Foundation


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
    func toParamString() -> String
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
    
    public func toParamString() -> String {
        var stringer = ""
        stringer += "&dt=" + String(dt)
        if let wlang = lang {
            stringer += "&lang=" + wlang
        }
        return stringer
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
    
    public func toParamString() -> String {
        var stringer = ""
        if let wunits = units {
            stringer += "&units=" + wunits.rawValue
        }
        if let wmode = excludeMode, !wmode.isEmpty {
            stringer += "&exclude=" + wmode.map{$0.rawValue}.joined(separator: ",")
        }
        if let wlang = lang {
            stringer += "&lang=" + wlang
        }
        return stringer
    }
}
