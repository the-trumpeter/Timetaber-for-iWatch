//
//  StorageManager.swift
//  Timetaber Watch App
//
//  Created by Gill Palmer on 4/1/2025.
//

import Foundation



let userDefaults = UserDefaults.standard


let runningKey = "timetaber.userdefalts.termRunning"

let ghostWeekKey = "timetaber.userdefalts.ghostWeek"

let startDateKey = "timetaber.userdefalts.startDate"


var termRunningGB = false
var ghostWeekGB = false


func readStoredData(key: String) -> Any {
    let readData = userDefaults.object(forKey: key)
    print("reading key: ", readData as Any)
    return readData as Any
}




func checkForStoredData(key: String) -> Bool {
    let store = userDefaults.object(forKey: key)
    if store != nil { print("\(key) exists!"); return true
    } else { print("\(key) doesn't exist!"); return false }
}




func writeToStore(key: String, data: Any) {
    userDefaults.set(data, forKey: key)
    print("Set data of \(data) to key \(key)!")
}






func trySetup() -> Void {
    if !checkForStoredData(key: runningKey) { //ensure term-running store exists
        writeToStore(key: runningKey, data: false) //if not, make it
    }
    termRunningGB = readStoredData(key: runningKey) as! Bool // update global term-running var

    if !checkForStoredData(key: ghostWeekKey) { // ensure ghost-week store exists
        writeToStore(key: ghostWeekKey, data: false) // if not, make it
    }
    
    if !checkForStoredData(key: startDateKey) {
        writeToStore(key: startDateKey, data: Date.now)
    }
    
    
    if termRunningGB == true {
        updateCurrents()
    }
    
    print("Setup done")
    print("Current course: \(currentCourse.name)")
    
}
