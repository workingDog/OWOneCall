//
//  OWResponse.swift
//  OWOneCall
//
//  Created by Ringo Wathelet on 2020/06/30.
//
import Foundation


// MARK: - OWResponse
public struct OWResponse: Codable {
    
    public let lat, lon: Double
    public let timezone: String
    public let timezoneOffset: Int
    public let current: Current?
    public let minutely: [Minutely]?
    public let hourly: [Hourly]?
    public let daily: [Daily]?
    public let alerts: [OWAlert]?
    
    public init(lat: Double = 0.0, lon: Double = 0.0,
                timezone: String = "GMT", timezoneOffset: Int = 0, current: Current? = nil,
                minutely: [Minutely]? = [], hourly: [Hourly]? = [], daily: [Daily]? = [],
                alerts: [OWAlert]? = []) {
        
        self.lat = lat
        self.lon = lon
        self.timezone = timezone
        self.timezoneOffset = timezoneOffset
        self.current = current
        self.minutely = minutely
        self.hourly = hourly
        self.daily = daily
        self.alerts = alerts
    }
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone, current, minutely, hourly, daily, alerts
        case timezoneOffset = "timezone_offset"
    }

    /// return some weather info from the current weather primary (ie first weather)
    public func weatherInfo() -> String {
        return current != nil ? current!.weatherInfo() : ""
    }
}

// MARK: - Current
public struct Current: Codable {
    
    public let dt, sunrise, sunset, pressure, humidity, clouds, visibility, windDeg: Int
    public let temp, feelsLike, dewPoint, uvi, windSpeed: Double
    public let windGust: Double?
    public let weather: [Weather]
    public let rain: Rain?
    public let snow: Snow?
 
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp, pressure, humidity, uvi, clouds, visibility, weather, rain, snow
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
    
    /// return `dt` as a Date
    public func getDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(dt))
    }
    
    /// return some weather info from the chosen index of the weather array or an empty string
    public func weatherInfo(at index: Int = 0) -> String {
        let theTemp = String(format: "%.1f", temp)
        return (index < weather.count) ? "\(weather[index].weatherDescription.capitalized) \(theTemp)°" : ""
    }

    /// return the SFSymbol icon name from the chosen index of the weather array or an empty string
    public func weatherIconName(at index: Int = 0) -> String {
        return (index < weather.count) ? weather[index].iconNameFromId : ""
    }
    
    /// return the SFSymbol name equivalent to the icon name at the chosen index of the weather array or an empty string
    public func weatherSymbolName(at index: Int = 0) -> String {
        return (index < weather.count) ? weather[index].iconSymbolName : ""
    }

}

public struct Rain: Codable {
    public let the1H: Double?
    public let the3H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
        case the3H = "3h"
    }
    
    // for the case where we have:  "rain": { }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let theRain = try? values.decode(Rain.self, forKey: .the1H) {
            self.the1H = theRain.the1H
        } else {
            self.the1H = nil
        }
        if let theRain = try? values.decode(Rain.self, forKey: .the3H) {
            self.the3H = theRain.the3H
        } else {
            self.the3H = nil
        }
    }
     
}

public struct Snow: Codable {
    public let the1H: Double?
    public let the3H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
        case the3H = "3h"
    }

    // for the case where we have:  "snow": { }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let theSnow = try? values.decode(Snow.self, forKey: .the1H) {
            self.the1H = theSnow.the1H
        } else {
            self.the1H = nil
        }
        if let theSnow = try? values.decode(Snow.self, forKey: .the3H) {
            self.the3H = theSnow.the3H
        } else {
            self.the3H = nil
        }
    }

}

// MARK: - Weather
public struct Weather: Identifiable, Codable {
    public let id: Int
    public let main, weatherDescription, icon: String
    
    /// the SFSymbol name to use as the default icon name
    public static var defaultIcon = "questionmark"
    
    enum CodingKeys: String, CodingKey {
        case id, main, icon
        case weatherDescription = "description"
    }
    
    /// return the equivalent SFSymbol name from the weather condition `id` number
    public var iconNameFromId: String {
        switch id {
            case 200...232: return "cloud.bolt.rain"
            case 300...301: return "cloud.rain"
            case 500...504: return "cloud.heavyrain"
            case 511: return "cloud.snow"
            case 520...531: return "cloud.rain"
            case 600...622: return "cloud.snow"
            case 701...781: return "cloud.fog"
            case 800: return "sun.max"
            case 801: return "cloud.sun"
            case 802...804: return "cloud"
        default: return Weather.defaultIcon
        }
    }
    
    /// return the equivalent SFSymbol name from the `icon` name
    public var iconSymbolName: String {
        switch icon {
            case "01d","01n": return "sun.max"
            case "02d","02n": return "cloud.sun"
            case "03d","03n": return "cloud"
            case "04d","04n": return "cloud"
            case "09d","09n": return "cloud.rain"
            case "10d","10n": return "cloud.heavyrain"
            case "11d","11n": return "cloud.bolt.rain"
            case "13d","13n": return "cloud.snow"
            case "50d","50n": return "cloud.fog"
        default: return Weather.defaultIcon
        }
    }

}

// MARK: - Daily
public struct Daily: Identifiable, Codable {
    public let id = UUID()
    
    public let dt, sunrise, sunset, pressure, humidity, windDeg, clouds: Int
    public let dewPoint, windSpeed: Double
    public let windGust, rain, snow, uvi: Double?
    public let temp: DailyTemp
    public let feelsLike: FeelsLike
    public let weather: [Weather]
    public let pop: Double?
    public let visibility: Int?
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp, pressure, humidity, visibility, weather, clouds, uvi, snow, rain, pop
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
    
    /// return `dt` as a Date
    public func getDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(dt))
    }
    
    /// return the SFSymbol name from the chosen index of the weather array or an empty string
    public func weatherIconName(at index: Int = 0) -> String {
        return (index < weather.count) ? weather[index].iconNameFromId : ""
    }
    
    /// return the SFSymbol name equivalent to the icon name from the chosen index of the weather array or an empty string
    public func weatherSymbolName(at index: Int = 0) -> String {
        return (index < weather.count) ? weather[index].iconSymbolName : ""
    }
 
}

// MARK: - FeelsLike
public struct FeelsLike: Codable {
    public let day, night, eve, morn: Double
}

// MARK: - DailyTemp
public struct DailyTemp: Codable {
    public let day, min, max, night, eve, morn: Double
}

// MARK: - Hourly
public struct Hourly: Identifiable, Codable {
    public let id = UUID()
    
    public let dt, pressure, humidity, clouds, windDeg: Int
    public let temp, feelsLike, dewPoint, windSpeed: Double
    public let windGust: Double?
    public let weather: [Weather]
    public let rain: Rain?
    public let snow: Snow?
    public let pop: Double?
    public let visibility: Int?
    
    enum CodingKeys: String, CodingKey {
        case dt, temp, pressure, humidity, visibility, clouds, weather, rain, snow, pop
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
    
    /// return `dt` as a Date
    public func getDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(dt))
    }
    
    /// return the SFSymbol name from the chosen index of the weather array or an empty string
    public func weatherIconName(at index: Int = 0) -> String {
        return (index < weather.count) ? weather[index].iconNameFromId : ""
    }
    
    /// return the SFSymbol name equivalent to the icon name from the chosen index of the weather array or an empty string
    public func weatherSymbolName(at index: Int = 0) -> String {
        return (index < weather.count) ? weather[index].iconSymbolName : ""
    }
    
}

// MARK: - Minutely
public struct Minutely: Identifiable, Codable {
    public let id = UUID()
    
    public let dt: Int
    public let precipitation: Double
    
    enum CodingKeys: String, CodingKey {
        case dt, precipitation
    }

    /// return `dt` as a Date
    public func getDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(dt))
    }
}

// MARK: - OWAlert
public struct OWAlert: Identifiable, Codable {
    public let id = UUID()
    
    public let senderName: String
    public let event: String
    public let start: Int
    public let end: Int
    public let description: String
    public let tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case event, description, start, end, tags
        case senderName = "sender_name"
    }
    
    /// return `start` as a Date
    public func getStartDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(start))
    }
    
    /// return `end` as a Date
    public func getEndDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(end))
    }

}

