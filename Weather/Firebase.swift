//
//  Firebase.swift
//  STRV
//
//  Created by Riccardo Rizzo on 29/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import Firebase

public class FirebaseDB {
    
    private var loggedToDatabase:Bool
    var UserName:String
    var Password:String
    let firebaseUrl = "https://brilliant-torch-9095.firebaseio.com"
    
    public init(userName:String,password:String,localStorage:Bool) {
        
        loggedToDatabase = false
        self.UserName = userName
        self.Password = password
        
        //Use persistent data in case of networking problem
        Firebase.defaultConfig().persistenceEnabled = localStorage
    }
   
    /* Login to database. You can use:
    This function can be accept login data from user, but for now I set it at runtime

    Save the city and data to database
    First attempt to login on database.
    Create on database a structure like this:
    
    USER_NAME ____
                 |
                 |- DATE AND TIME ---
                                    |
                                    |- Weather 1
                                    |- Weather 2
                                    |- Weather 3
    
    */
    func saveToDatabase(city:String, weatherInfos:String) {
        
        let ref = Firebase(url: firebaseUrl)
        ref.keepSynced(true)  //Also allow local storage
        
        if !loggedToDatabase {
            
            ref.authUser(self.UserName, password: self.Password,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        println("An error occurred when login")
                        self.loggedToDatabase = false
                    } else {
                        println("Login to firebase")
                        self.loggedToDatabase = true
                        // Use unique chil creation
                        var usersRef = ref.childByAppendingPath(self.UserName.stringByReplacingOccurrencesOfString(".", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil))  //Replace the @ character because Firebase don't accept it
                        // Save new Data
                        let dateString:String = NSDateFormatter.localizedStringFromDate(NSDate.new(), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                        
                        var childList = usersRef.childByAppendingPath(dateString.stringByReplacingOccurrencesOfString("/", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil))
                        var usersData = ["city": city, "weather": weatherInfos]
                        childList.setValue(usersData)

                    }
            })
        }
        else
        {
            // Use unique chil creation
            var usersRef = ref.childByAppendingPath(self.UserName.stringByReplacingOccurrencesOfString(".", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil))  //Replace the @ character because Firebase don't accept it
            // Save new Data
            let dateString:String = NSDateFormatter.localizedStringFromDate(NSDate.new(), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
            
            var childList = usersRef.childByAppendingPath(dateString.stringByReplacingOccurrencesOfString("/", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil))
            var usersData = ["city": city, "weather": weatherInfos]
            childList.setValue(usersData)

        }
    }
    
}
