# SwiftUI OpenWeather One Call API library


[One Call API 3.0](https://openweathermap.org/api/one-call-3)

"Make just one API call and get all your essential weather data for a specific location with our new OpenWeather One Call API."

**OWOneCall** is a small Swift library to connect to the [One Call API 3.0](https://openweathermap.org/api/one-call-3) and retrieve the chosen weather data. Made easy to use with SwiftUI.

Provides for current, forecast and historical weather data through a single function call.

### Usage

Weather data from [OpenWeather One Call API](https://openweathermap.org/api/one-call-api) is accessed through the use of a **OWProvider**, with a single function **getWeather**, eg:

```swift
let weatherProvider = OWProvider(apiKey: "your key")  // default One Call API 3.0
@State var weather = OWResponse()
...

Alternatively;

let weatherProvider = OWProvider(apiKey: "your key", urlString: "https://api.openweathermap.org/data/3.0/onecall")  


// using a binding
weatherProvider.getWeather(lat: 35.661991, lon: 139.762735, weather: $weather, options: OWOptions.current())
...
Text(weather.current?.weatherInfo() ?? "")

// or using the async style, eg with `.task {...}`
if let results = await weatherProvider.getWeather(lat: 35.661991, lon: 139.762735, options: OWOptions.dailyForecast(lang: lang)) {
        weather = results
}

// or using the callback style, eg with `.onAppear {...}`
weatherProvider.getWeather(lat: 35.661991, lon: 139.762735, options: OWOptions.current()) { response in
       if let theWeather = response {
          self.weather = theWeather
       }
}
```

See the following for example uses:

-   [*OWOneCallExample*](https://github.com/workingDog/OWOneCallExample) 

-   [SwiftUI Weather App](https://github.com/workingDog/YAWA)


### Options

Options available:

-   see [OpenWeather One Call API](https://openweathermap.org/api/one-call-api) for all the options available.

Create an options object such as this, to retrieve the current weather data:

```swift
let myOptions = OWOptions(excludeMode: [.daily, .hourly, .minutely], units: .metric, lang: "en")
```

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

```swift
dependencies: [
  .package(url: "https://github.com/workingDog/OWOneCall.git", from: "1.3.2")
]
```

#### Using Xcode

    Select your project > Swift Packages > Add Package Dependency...
    https://github.com/workingDog/OWOneCall.git

Then in your code:

```swift
import OWOneCall
```
    
### References

-    [OpenWeather One Call API](https://openweathermap.org/api/one-call-api)


### Requirement

Requires a valid OpenWeather key, see:

-    [OpenWeather how to start](https://openweathermap.org/appid)

### License

MIT
