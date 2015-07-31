//
//  SecondViewController.swift
//  STRV
//
//  Created by Riccardo Rizzo on 28/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit

extension UIColor {
    public convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = advance(rgba.startIndex, 1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (count(hex)) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                println("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

class ForecastViewController: UIViewController {

    @IBOutlet var forecastTableView: UITableView!
    @IBOutlet var forecastViewTitle: UINavigationItem!
    let locationManager:CLLocationManager? = CLLocationManager()
    let refreshControl:UIRefreshControl? = UIRefreshControl()
    
    var Client: Sweather?
    var resultWeather:[Weather] = []
    var wasUpdated:Bool = false             //This bool is used to prevent a contunuos refresh
    
    
    override func viewDidAppear(animated: Bool) {
    
        locationManager?.startUpdatingLocation()
        wasUpdated = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setup()
    }
    
    func refreshWeatherForecastWithLocation(currentPosition:CLLocationCoordinate2D) {
        resultWeather = []  //Empty the container
        Client?.dailyForecast(currentPosition) { result in
            switch result {
            case .Error(let response, let error):
                println("Some error occured. Try again.")
            case .Success(let response, let dictionary):
                //  println("Received data: \(dictionary)")
                let city = (dictionary["city"] as! NSDictionary).objectForKey("name") as! String
                self.forecastViewTitle.title = city
                
                let temp_forecast = dictionary.valueForKey("list") as! NSArray
                for d in temp_forecast {
                    var newWeather:Weather = Weather()
                    let weather = (d.valueForKey("weather") as! NSArray).objectAtIndex(0) as! NSDictionary
                    let temp = d.valueForKey("temp") as! NSDictionary
                    
                    let deltaTime = d.valueForKey("dt") as! NSNumber
                    let description = weather.objectForKey("description") as! String
                    let icon = weather.objectForKey("icon") as! String
                    let mainWeather = weather.objectForKey("main") as! String
                    let dayTemp = temp.objectForKey("day") as! NSNumber
                    
                    newWeather.DateTime = NSDate(timeIntervalSince1970:deltaTime.doubleValue)
                    newWeather.Description = description
                    newWeather.Icon = icon
                    newWeather.Temperature = Int(dayTemp)
                    newWeather.Weather = mainWeather
                    self.resultWeather.append(newWeather)
                }
                self.forecastTableView.reloadData()
                NSLog("Updating complete!")
            }
        }
    }
    
    /*****
    * This function return a string containing the name of the day
    ******/
    func getDayOfWeek(today:NSDate)->String {
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE";
        let dayString:String = dateFormatter.stringFromDate(today).capitalizedString
        return dayString
    }
    
    
    /************
     I don't have image for all weather conditions
     so I have used only few
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
        case "01d": weatherImage = UIImage(named: "forecast_Sun")
        case "01n": weatherImage = UIImage(named: "forecast_Sun")
        case "02d": weatherImage = UIImage(named: "forecast_CS")
        case "02n": weatherImage = UIImage(named: "forecast_CS")
        case "03d": weatherImage = UIImage(named: "forecast_CS")
        case "03n": weatherImage = UIImage(named: "forecast_CS")
        case "04d": weatherImage = UIImage(named: "forecast_CL")
        case "04n": weatherImage = UIImage(named: "forecast_CL")
        case "09d": weatherImage = UIImage(named: "forecast_CL")
        case "09n": weatherImage = UIImage(named: "forecast_CL")
        case "10d": weatherImage = UIImage(named: "CR")
        case "10n": weatherImage = UIImage(named: "CR")
        case "11d": weatherImage = UIImage(named: "forecast_Wind")
        case "11n": weatherImage = UIImage(named: "forecast_Wind")
        case "13d": weatherImage = UIImage(named: "forecast_Wind")
        case "13n": weatherImage = UIImage(named: "forecast_Wind")
        case "50d": weatherImage = UIImage(named: "forecast_Wind")
        case "50n": weatherImage = UIImage(named: "forecast_Wind")
        default: return UIImage()
        }
        
        return weatherImage!
    }
    
    func setup() {
        
        locationManager?.requestWhenInUseAuthorization()
        self.forecastTableView.delegate = self
        self.forecastTableView.dataSource = self
        self.forecastViewTitle.title = ""
        Client = Sweather(apiKey: "your_key", temperatureFormat: Sweather.TemperatureFormat.Celsius)
        locationManager?.delegate = self
        refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.forecastTableView.addSubview(refreshControl!)
    }
    
    func handleRefresh(sender:AnyObject) {
    // Have a table view refresh
        NSLog("Refresh")
        if locationManager != nil {
            wasUpdated = false
            locationManager?.startUpdatingLocation()
        }
    }
}


extension ForecastViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.resultWeather.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.forecastTableView.dequeueReusableCellWithIdentifier("CustomCell") as! WeatherCustomCell
        if indexPath.row <= self.resultWeather.count {
            
            let currentWeather:Weather =  self.resultWeather[indexPath.row]
            
            cell.weatherDay.text = getDayOfWeek(currentWeather.DateTime)
            cell.weatherDescription.text = currentWeather.Description
            cell.weatherImage.image = getImageByIconWeatherName(currentWeather.Icon)
            cell.weatherTemp.text = String(format: "\(currentWeather.Temperature)°C")
            
            cell.weatherDay.textColor = UIColor(rgba: "#333333")
            cell.weatherDescription.textColor = UIColor(rgba: "#333333")
            cell.weatherTemp.textColor = UIColor(rgba: "#2f91ff")
        }
        
        return cell
    }
    
}

extension ForecastViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if !wasUpdated {
            refreshWeatherForecastWithLocation(locationManager!.location.coordinate)
            refreshControl?.endRefreshing()
            wasUpdated = true
        }
        else {
            locationManager?.stopUpdatingLocation()
        }
    }
    
}