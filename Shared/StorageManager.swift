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


class GlobalData: ObservableObject {
    static let shared = GlobalData()
    @Published var currentCourse: Course = getCurrentClass(date: .now)[0]  //  the current timetabled class in session.
    @Published var nextCourse: Course = getCurrentClass(date: .now)[1]     //  the next timetabled class in session
}


let customSymbols = [
    "paintbrush.pointed.circle.fill": Image(.paintbrushPointedCircleFill),
    "music.note.circle.fill": Image(.musicNoteCircleFill),
    "movieclapper.circle.fill": Image(.movieclapperCircleFill)
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
        GlobalData.shared.currentCourse.name,
        GlobalData.shared.nextCourse.name,
        String(describing: storage.shared.termRunningGB),
        String(describing: storage.shared.ghostWeekGB),
        String(describing: getIfWeekIsA_FromDateAndGhost(originDate: .now, ghostWeek: storage.shared.ghostWeekGB) )
    )

}

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

