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
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone, current, minutely, hourly, daily
        case timezoneOffset = "timezone_offset"
    }
    
    public init() {
        self.lat = 0.0
        self.lon = 0.0
        self.timezone = ""
        self.timezoneOffset = 0
        self.current = Current()
        self.minutely = []
        self.hourly = []
        self.daily = []
    }
    
    public func weatherInfo() -> String {
        return current != nil ? current!.weatherInfo() : ""
    }
}

// MARK: - Current
public struct Current: Codable {
    
    public let dt: Int
    public let sunrise, sunset: Int
    public let temp, feelsLike: Double
    public let pressure, humidity: Int
    public let dewPoint, uvi: Double
    public let clouds, visibility: Int
    public let windSpeed: Double
    public let windDeg: Int
    public let weather: [Weather]
    public let rain: Rain?
    public let snow: Snow?
    public let windGust: Double?
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp, pressure, humidity, uvi, clouds, visibility, weather, rain, snow
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
    
    public init() {
        self.dt = 0
        self.sunrise = 0
        self.sunset = 0
        self.temp = 0.0
        self.feelsLike = 0.0
        self.pressure = 0
        self.humidity = 0
        self.dewPoint = 0.0
        self.uvi = 0.0
        self.clouds = 0
        self.visibility = 0
        self.windSpeed = 0.0
        self.windDeg = 0
        self.weather = []
        self.rain = Rain()
        self.snow = Snow()
        self.windGust = 0.0
    }
    
    // convenience function
    public func getDate() -> Date {
        return self.dt.dateFromUTC()
    }
    
    // convenience function
    public func weatherInfo() -> String {
        let theTemp = String(format: "%.1f", self.temp)
        return (self.weather.first != nil)
            ? "\(self.weather.first!.weatherDescription.capitalized) \(theTemp)°"
            : ""
    }

    // convenience function
    public func formattedDate(format: String, lang: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: lang)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self.dt.dateFromUTC())
    }
    
    public func weatherIconName() -> String {
        return self.weather.first != nil ? self.weather.first!.iconNameFromId : "smiley"
    }
    
}

// MARK: - Rain
public struct Rain: Codable {
    public let the1H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
    }
    
    public init() {
        self.the1H = 0.0
    }
    
    // for the case where we have:  "rain": { }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let theRain = try? values.decode(Rain.self, forKey: .the1H) {
            self.the1H = theRain.the1H
        } else {
            self.the1H = nil
        }
    }
    
}

// MARK: - Snow
public struct Snow: Codable {
    public let the1H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
    }
    
    public init() {
        self.the1H = nil
    }
    
    // for the case where we have:  "snow": { }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let theRain = try? values.decode(Snow.self, forKey: .the1H) {
            self.the1H = theRain.the1H
        } else {
            self.the1H = 0.0
        }
    }
}

// todo more Rain and snow --> 3h

// MARK: - Weather
public struct Weather: Codable {
    public let id: Int
    public let main, weatherDescription, icon: String
    
    enum CodingKeys: String, CodingKey {
        case id, main, icon
        case weatherDescription = "description"
    }
    
    public init() {
        self.id = 0
        self.main = ""
        self.weatherDescription = ""
        self.icon = ""
    }
    
    public var iconNameFromId: String {
        switch id {
        case 200...232:  // thunderstorm
            return "could.bolt.rain"
        case 300...301: // drizzle
            return "cloud.drizzle"
        case 500...531: // rain
            return "cloud.rain"
        case 600...622: // snow
            return "cloud.snow"
        case 701...781: // fog, haze, dust
            return "cloud.fog"
        case 800:       //  clear sky
            return "sun.max"
        case 801...804:
            return "cloud.sun"
        default:
            return "cloud.sun"
        }
    }
}

// MARK: - Daily
public struct Daily: Codable, Hashable  {
    
    public let dt: Int
    public let sunrise, sunset: Int
    public let temp: DailyTemp
    public let feelsLike: FeelsLike
    public let pressure, humidity: Int
    public let dewPoint, windSpeed: Double
    public let windDeg: Int
    public let windGust: Double?
    public let weather: [Weather]
    public let clouds: Int
    public let rain: Double?
    public let snow: Double?
    public let uvi: Double
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp, pressure, humidity, weather, clouds, uvi, snow, rain
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
    
    public init() {
        self.dt = 0
        self.sunrise = 0
        self.sunset = 0
        self.temp = DailyTemp()
        self.feelsLike = FeelsLike()
        self.pressure = 0
        self.humidity = 0
        self.dewPoint = 0.0
        self.uvi = 0.0
        self.clouds = 0
        self.windSpeed = 0.0
        self.windDeg = 0
        self.windGust = 0.0
        self.weather = []
        self.rain = 0.0
        self.snow = 0.0
    }
    
    // convenience function
    public func getDate() -> Date {
        return self.dt.dateFromUTC()
    }
    
    public static func == (lhs: Daily, rhs: Daily) -> Bool {
        lhs.dt == rhs.dt
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dt)
    }
}

// MARK: - FeelsLike
public struct FeelsLike: Codable {
    public let day, night, eve, morn: Double
    
    public init() {
        self.day = 0.0
        self.night = 0.0
        self.eve = 0.0
        self.morn = 0.0
    }
}

// MARK: - DailyTemp
public struct DailyTemp: Codable {
    
    public let day, min, max, night: Double
    public let eve, morn: Double
    
    public init() {
        self.day = 0.0
        self.min = 0.0
        self.max = 0.0
        self.night = 0.0
        self.eve = 0.0
        self.morn = 0.0
    }
}

// MARK: - Hourly
public struct Hourly: Codable {
    
    public let dt: Int
    public let temp, feelsLike: Double
    public let pressure, humidity: Int
    public let dewPoint: Double
    public let clouds: Int
    public let windSpeed: Double
    public let windDeg: Int
    public let windGust: Double?
    public let weather: [Weather]
    public let rain: Rain?
    
    enum CodingKeys: String, CodingKey {
        case dt, temp,pressure, humidity, clouds, weather, rain
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
    
    public init() {
        self.dt = 0
        self.temp = 0.0
        self.feelsLike = 0.0
        self.pressure = 0
        self.humidity = 0
        self.dewPoint = 0.0
        self.clouds = 0
        self.windSpeed = 0.0
        self.windDeg = 0
        self.windGust = 0.0
        self.weather = []
        self.rain = Rain()
    }
    
    // convenience function
    public func getDate() -> Date {
        return self.dt.dateFromUTC()
    }
}

// MARK: - Minutely
public struct Minutely: Codable {
    public let dt: Int
    public let precipitation: Double
    
    public init() {
        self.dt = 0
        self.precipitation = 0.0
    }
}
