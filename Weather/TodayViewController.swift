//
//  FirstViewController.swift
//  STRV
//
//  Created by Riccardo Rizzo on 28/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit

class TodayViewController: UIViewController {

    
    @IBOutlet var todayImage: UIImageView!
    @IBOutlet var todayCity: UILabel!
    @IBOutlet var todayWeather: UILabel!
    @IBOutlet var todayHumidity: UILabel!
    @IBOutlet var todayWind: UILabel!
    @IBOutlet var todayRain: UILabel!
    @IBOutlet var todayCompass: UILabel!
    @IBOutlet var todayTemperature: UILabel!
    @IBOutlet var shareButton: UIButton!
    
    let kAppDatabaseSupport:Bool = true         //Set it to 'false' to disable database support
    let kAppLocalDatabaseStorage:Bool = true    //Set it to 'false' to disable local caching of data
    
    var Client: Sweather?
    var locationManager:CLLocationManager = CLLocationManager()
    var wasUpdated:Bool = false;
    var loggedToDatabase:Bool = false
    var refreshComponents:UIActivityIndicatorView?
    var Firebase:FirebaseDB?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize client for loading JSON data from openweather website
        Client = Sweather(apiKey: "your_key", temperatureFormat: Sweather.TemperatureFormat.Celsius)
        
        if kAppDatabaseSupport {
            //Create a database object and try to login with passed credentials
            Firebase = FirebaseDB(userName: "r.riki@tiscali.it",password: "123456",localStorage: kAppLocalDatabaseStorage)
        }
        
        //Add a activity control
        refreshComponents = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        refreshComponents?.hidesWhenStopped = true
        refreshComponents?.center = self.todayImage.center
        self.view.addSubview(refreshComponents!)
    }
    
    override func viewDidAppear(animated: Bool) {
        setup()
        
        refreshComponents?.center = self.todayImage.center
        self.todayImage.hidden = true
        refreshComponents?.startAnimating()
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        let city:String = self.todayCity.text!
        var weather:String = self.todayWeather.text!
        weather = weather.stringByReplacingOccurrencesOfString("|", withString: "and is", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let cityDescr = String(format: "Today in \(city) is \(weather)")
        let imageWeather:UIImage = self.todayImage.image!
        
        let shareItems:Array = [cityDescr,imageWeather]
        let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    /*
        Save the city and data to database
    */
    func saveToDatabase(city:String, weatherInfos:String) {
        if kAppDatabaseSupport {
            Firebase?.saveToDatabase(city, weatherInfos: weatherInfos)
        }
    }
    
    //Initialize the UI and core
    func setup() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        wasUpdated = false
        
        self.todayRain.text = String(format:"0mm")
        self.todayCity.text = "No location"
        self.todayWeather.text = ""
        self.todayHumidity.text = ""
        self.todayWind.text = ""
        self.todayTemperature.text = ""
        self.todayCompass.text = ""
        
        self.todayCity.textColor = UIColor(rgba: "#333333")
        self.todayWeather.textColor = UIColor(rgba: "#2f91ff")
        
        self.todayRain.textColor = UIColor(rgba: "#333333")
        self.todayHumidity.textColor = UIColor(rgba: "#333333")
        self.todayWind.textColor = UIColor(rgba: "#333333")
        self.todayTemperature.textColor = UIColor(rgba: "#333333")
        self.todayCompass.textColor = UIColor(rgba: "#333333")
        shareButton.setTitleColor(UIColor(rgba: "#FF8847"), forState: UIControlState.Normal)
    }

    /************
    I don't have image for all weather conditions
    so I have used only some for rapresenting all the possibilities
    *************/
    func getImageByIconWeatherName(icon:String) -> UIImage {
        
        /*  those are the icon string rappresentation
        take from openweather website. Transform it to image
        *****************************************
        01d.png  	01n.png  	clear sky
        02d.png  	02n.png  	few clouds
        03d.png  	03n.png  	scattered clouds
        04d.png  	04n.png  	broken clouds
        09d.png  	09n.png  	shower rain
        10d.png  	10n.png  	rain
        11d.png  	11n.png  	thunderstorm
        13d.png  	13n.png  	snow
        50d.png  	50n.png     mist
        */
        
        var weatherImage:UIImage?
        
        switch icon {
            case "01d": weatherImage = UIImage(named: "Sun_Big")
            case "01n": weatherImage = UIImage(named: "Sun_Big")
            case "02d": weatherImage = UIImage(named: "Cloudy_Big")
            case "02n": weatherImage = UIImage(named: "Cloudy_Big")
            case "03d": weatherImage = UIImage(named: "Cloudy_Big")
            case "03n": weatherImage = UIImage(named: "Cloudy_Big")
            case "04d": weatherImage = UIImage(named: "Cloudy_Big")
            case "04n": weatherImage = UIImage(named: "Cloudy_Big")
            case "09d": weatherImage = UIImage(named: "Cloudy_Big")
            case "09n": weatherImage = UIImage(named: "Cloudy_Big")
            case "10d": weatherImage = UIImage(named: "CR")
            case "10n": weatherImage = UIImage(named: "CR")
            case "11d": weatherImage = UIImage(named: "Wind_Big")
            case "11n": weatherImage = UIImage(named: "Wind_Big")
            case "13d": weatherImage = UIImage(named: "Wind_Big")
            case "13n": weatherImage = UIImage(named: "Wind_Big")
            case "50d": weatherImage = UIImage(named: "Wind_Big")
            case "50n": weatherImage = UIImage(named: "Wind_Big")
            default: return UIImage()
        }
        
        return weatherImage!
    }

    
    //This function convert the wind direction to a readable string
    func convertWindDirection(direction:CGFloat) -> String {
        if direction > 348.75 && direction < 11.25 {
            return "N"
        }
        else if direction >= 11.25 && direction < 33.75 {
            return "NNE"
        }
        else if direction >= 33.75 && direction < 56.25 {
            return "NE"
        }
        else if direction >= 56.25 && direction < 78.75 {
            return "ENE"
        }
        else if direction >= 78.75 && direction < 101.25 {
            return "E"
        }
        else if direction >= 101.25 && direction < 123.75 {
            return "ESE"
        }
        else if direction >= 123.75 && direction < 146.25 {
            return "SE"
        }
        else if direction >= 146.25 && direction < 168.75 {
            return "SSE"
        }
        else if direction >= 168.75 && direction < 191.25 {
            return "S"
        }
        else if direction >= 191.25 && direction < 213.75 {
            return "SSW"
        }
        else if direction >= 213.75 && direction < 236.25 {
            return "SW"
        }
        else if direction >= 236.25 && direction < 258.75 {
            return "WSW"
        }
        else if direction >= 258.75 && direction < 281.25 {
            return "W"
        }
        else if direction >= 281.25 && direction < 203.75 {
            return "WNW"
        }
        else if direction >= 303.75 && direction < 326.25 {
            return "NW"
        }
        else if direction >= 326.25 && direction < 348.75 {
            return "NNW"
        }
        else {
            return ""
        }
    }
    
    
    /*
        Update the weather datas.
        Parameter: Coordinates
    */
    func refreshWeatherForecastWithLocation(currentPosition:CLLocationCoordinate2D) {
        refreshComponents?.center = self.todayImage.center
        refreshComponents?.startAnimating()
        
        Client?.currentWeather(currentPosition) { result in
            switch result {
                case .Error(let response, let error):
                    
                    self.refreshComponents?.stopAnimating()
                    println("Some error occured. Try again.")
                case .Success(let response, let dictionary):
                    
                    // Get temperature,data and other infos for the selected city
                    let country = dictionary["sys"]!["country"] as! String
                    let city = dictionary["name"] as! String;
                    let temperature = dictionary["main"]!["temp"] as! Int;
                    let humidity = dictionary["main"]!["humidity"] as! Int;
                    let pressure = dictionary["main"]!["pressure"] as! Int;
                    let weatherDescription = dictionary["weather"]![0]!["description"] as! String
                    let iconWeather = dictionary["weather"]![0]!["icon"] as! String
                    let windSpeed = dictionary["wind"]!["speed"]
                    let windDirection =  dictionary["wind"]?["deg"]
                    let rain = dictionary["rain"]?["3h"]
                    
                    // Optional value can be nil if is not downloaded
                    // Check if this value exist and is a good value
                    if rain is NSNumber {
                        self.todayRain.text = String(format:"\(rain)mm")
                    }
                    else {
                        self.todayRain.text = String(format:"0mm")
                    }
                    if windDirection is NSNumber  {
                       self.todayCompass.text = self.convertWindDirection(windDirection as! CGFloat)
                    }
                    else {
                        self.todayCompass.text = "--"
                    }
                    
                    if windSpeed is NSNumber {
                        self.todayWind.text = String(format: "\(windSpeed as! CGFloat)km/h")
                    }
                    else {
                         self.todayWind.text = "--"
                    }

                    //Print the datas
                    self.todayCity.text = city + "," + country
                    self.todayWeather.text = "\(temperature)°C | " + weatherDescription
                    self.todayHumidity.text = String(format:"\(humidity)%%")
                    self.todayTemperature.text = String(format:"\(pressure)hPa")
                    self.todayImage.image = self.getImageByIconWeatherName(iconWeather)
                    self.saveToDatabase(self.todayCity.text!, weatherInfos: self.todayWeather.text!)
                    
                    //Remove the refresh components
                    self.refreshComponents?.stopAnimating()
                    self.todayImage.hidden = false
            }
        }
    }
}


//I use separate extension for protocol delegate for having code readability
extension TodayViewController:CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if !wasUpdated {
            refreshWeatherForecastWithLocation(locationManager.location.coordinate);
            wasUpdated = true
        }
        else {
            locationManager.stopUpdatingLocation()
        }
    }
}

