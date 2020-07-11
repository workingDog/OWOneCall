# SwiftUI OpenWeather One Call API library


[**OpenWeather One Call API**](https://openweathermap.org/api/one-call-api), 
"Make just one API call and get all your essential weather data for a specific location with our new OpenWeather One Call API."

**OWOneCall** is a small Swift library to connect to the [OpenWeather One Call API](https://openweathermap.org/api/one-call-api) and retrieve the chosen weather data. Made easy to use with SwiftUI.

Provides for current, forecast and historical weather data through a single function call.


### Usage

Weather data from [OpenWeather One Call API](https://openweathermap.org/api/one-call-api) is accessed through the use of a **OWProvider**, with a single function **getWeather**, eg:

    let weatherProvider = OWProvider(apiKey: "your key")
    @State var weather = OWResponse()
    ...
    weatherProvider.getWeather(lat: 35.661991, lon: 139.762735, weather: $weather, options: OWOptions.current())
    ...
    Text(weather.current?.weatherInfo() ?? "")

See [*OWOneCallExample*](https://github.com/workingDog/OWOneCallExample) for an example use.

### Options

Options available:

-   see [OpenWeather One Call API](https://openweathermap.org/api/one-call-api) for all the options available.

Create an options object such as this, to retrieve the current weather data:

    let myOptions = OWOptions(excludeMode: [.daily, .hourly, .minutely], units: .metric, lang: "en")

Additional convenience options to retrieve current and forecast weather data: 

-    OWOptions.current(lang: String = "en")
-    OWOptions.dailyForecast(lang: String = "en")  
-    OWOptions.hourlyForecast(lang: String = "en")

Additional convenience options to retrieve past historical weather data: 

-    OWHistOptions.yesterday(lang: String = "en")
-    OWHistOptions.daysAgo(day: Double, lang: String = "en")

Use the **lang** options parameter to chose the language of the results, default "en".


### Installation

Include the files in the **./Sources/OWOneCall** folder into your project or preferably use **Swift Package Manager**. 

#### Swift Package Manager  (SPM)

Create a Package.swift file for your project and add a dependency to:

    dependencies: [
      .package(url: "https://github.com/workingDog/OWOneCall.git", from: "1.1.1")
    ]

#### Using Xcode

    Select your project > Swift Packages > Add Package Dependency...
    https://github.com/workingDog/OWOneCall.git

Then in your code:

    import OWOneCall
    

### References

-    [OpenWeather One Call API](https://openweathermap.org/api/one-call-api)


### Requirement

Requires a valid OpenWeather key, see:

-    [OpenWeather how to start](https://openweathermap.org/appid)

### License

MIT
