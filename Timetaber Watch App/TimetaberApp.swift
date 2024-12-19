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
let runningKey = "timetaber.userdefalts.termRunning"
let ghostWeekKey = "timetaber.userdefalts.ghostWeek"
let startDateKey = "timetaber.userdefalts.startDate"





func readStoredData(key: String) -> Any {
    let readData = userDefaults.object(forKey: key)
    print("reading key:", readData as Any)
    return readData as Any
}

func checkForStoredData(key: String) -> Bool {
    let store = userDefaults.object(forKey: key)
    if store != nil { return true
    } else { return false }
}

func writeToStore(key: String, data: Any) {
    userDefaults.set(data, forKey: key)
}

func trySetup() -> Void {
    
    if !checkForStoredData(key: runningKey) {
        writeToStore(key: runningKey, data: false)
        if termRunningGB != readStoredData(key: runningKey) as! Bool {
            termRunningGB = readStoredData(key: runningKey) as! Bool
        }
    }
    if !checkForStoredData(key: ghostWeekKey) {
        
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
