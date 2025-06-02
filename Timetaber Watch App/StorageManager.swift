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




class storage: ObservableObject {
    static let shared = storage()
    
    @AppStorage(runningKey) var termRunningGB = false
    @AppStorage(ghostWeekKey) var ghostWeekGB = false
    @AppStorage(startDateKey) var startDateGB = Date.now
    // 'GB' for 'global'
}



func reload() -> Void {
    
    GlobalData.shared.currentCourse = getCurrentClass(date: .now)[0]
    GlobalData.shared.nextCourse = getCurrentClass(date: .now)[1]
    
    
    print("Setup done\n")
    log()
    
}

