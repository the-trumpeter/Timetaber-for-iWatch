//
//  StorageManager.swift
//  Timetaber Watch App
//
//  Created by Gill Palmer on 4/1/2025.
//

import Foundation
import SwiftUI


let userDefaults = UserDefaults.standard


let runningKey = "timetaber.userdefalts.termRunning"

let ghostWeekKey = "timetaber.userdefalts.ghostWeek"

let startDateKey = "timetaber.userdefalts.startDate"




class storage {
    static let shared = storage()
    
    @State @AppStorage(runningKey) var termRunningGB = false
    @State @AppStorage(ghostWeekKey) var ghostWeekGB = false
    @State @AppStorage(startDateKey) var startDateGB = Date.now
    
}



func reload(globalData: GlobalData) -> Void {    
    
    globalData.currentCourse = getCurrentClass(date: .now)[0]
    globalData.nextCourse = getCurrentClass(date: .now)[1]
    
    
    print("Setup done\n")
    log()
    
}

