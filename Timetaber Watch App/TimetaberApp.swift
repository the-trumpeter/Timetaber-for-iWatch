//
//  TimetaberApp.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI




var currentCourse: Course = getCurrentClass(date: .now) //the current timetabled class in session.
var nextCourse: Course = noSchool

var viewNo = 1





func log() {
    print("""
    ~ Log - \(Date().description) {
        Current class is \(currentCourse.name).
        Term running is \(storage.shared.termRunningGB), ghost week is \(storage.shared.ghostWeekGB).
    } End Log ~
    """)
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
            .onAppear() {
                log()
            }
        }
        
    }
}
