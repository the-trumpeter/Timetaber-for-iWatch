//
//  TimetaberApp.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI

var currentClass: Class = LanguageClass //the current timetabled class in session.
var nextClass: Class = MathsClass
var period = 1
var viewNo = 1

let userDefaults = UserDefaults.standard
let standardKey = "timetaber.userdefalts.termdata1"
var keyExists: Bool = false





func readStoredData(key: String) -> Any {
    let readData = userDefaults.object(forKey: key)
    print("reading key:", readData as Any); return readData ?? false
}

func checkForStoredData(key: String) -> Bool {
    if readStoredData(key: key) as? Bool ?? false {
        return true
    } else {
        return false
    }
}

func writeStoredData(key: String, subject: Array<Any>) {
    userDefaults.set(subject, forKey: key)
}

func trySetup(dataKey: String) -> Void {
    //this can be dangerous because if it is run with different keys then its gonna make multiple stores
    
    //ensure key exists
    if checkForStoredData(key: dataKey) {
        // if the key exists
        keyExists = true
    } else {
        keyExists = false
        //it aint exist, gotta make one
        let newKey = [false, Date.now, false] as [Any]
        writeStoredData(key: dataKey, subject: newKey)
        keyExists = true
    }
    
    //resync the local variable with the store
    if termRunningGB != (readStoredData(key: dataKey) as! Array<Any>)[0] as! Bool {
        termRunningGB = (readStoredData(key: dataKey) as! Array<Any>)[0] as! Bool
    }
}





@main

struct Timetaber_Watch_AppApp: App {
    
    var body: some Scene {
        WindowGroup {
            TabView{
                HomeView()
                ListView()
                SettingsView()
            }
            .tabViewStyle(.carousel)
        }
    }
}
