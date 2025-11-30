//
//  StorageManager.swift
//  Timetaber Watch App
//
//  Created by Gill Palmer on 4/1/2025.
//

import Foundation
import SwiftUI


let runningKey = "timetaber.userdefaults.termRunning"

let ghostWeekKey = "timetaber.userdefaults.ghostWeek"

let startDateKey = "timetaber.userdefaults.startDate"



// Use SF Symbols directly to avoid missing-asset crashes at runtime //TODO: Will this work?
let customSymbols = [
    "paintbrush.pointed.circle.fill": Image(systemName: "paintbrush.pointed.circle.fill"),
    "music.note.circle.fill": Image(systemName: "music.note.circle.fill"),
    "movieclapper.circle.fill": Image(systemName: "movieclapper.circle.fill")
]


func log() {
    NSLog("""
        ~ Log - %@ ~
            Current course: %@, Next course: %@
            Term running: <%@>, Ghost week: <%@>
            Is today in week A?: <%@>
        ~ End Log ~
        """,
        Date.now.formatted(date: .numeric, time: .complete),
        LocalData.shared.currentCourse.name,
        LocalData.shared.nextCourse.name,
        String(describing: Storage.shared.termRunningGB),
        String(describing: Storage.shared.ghostWeekGB),
        String(describing: getIfWeekIsA_FromDateAndGhost(originDate: .now, ghostWeek: Storage.shared.ghostWeekGB) )
    )

}

class Storage: ObservableObject {

    static let shared = Storage() //there is LocalData.storage, but it points here

    @AppStorage(runningKey) var termRunningGB = true//false
    @AppStorage(ghostWeekKey) var ghostWeekGB = false

    // Backwards-compatible storage for Date using Double (timeIntervalSince1970)
    var startDateGB: Date {
        get {
            let seconds = UserDefaults.standard.double(forKey: startDateKey)
            if seconds == 0 {
                // If not set, default to now and persist once for consistency
                let now = Date()
                UserDefaults.standard.set(now.timeIntervalSince1970, forKey: startDateKey)
                return now
            }
            return Date(timeIntervalSince1970: seconds)
        }
        set {
            UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: startDateKey)
        }
    }
}

func reload() -> Void {
    let now = getCurrentClass2(date: .now, timetable: chaos)
    LocalData.shared.currentCourse = now[0] as! Course
    LocalData.shared.nextCourse = now[1] as! Course
    LocalData.shared.currentTime = now[2] as! Timeslot
	
    print("Setup done\n")
    log()
}

