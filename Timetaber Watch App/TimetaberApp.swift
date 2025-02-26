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

func updateCurrents() {
    currentCourse = getCurrentClass(date: .now)//getCurrentClass(date: .now) //the current timetabled class in session.
    nextCourse = noSchool
}


@main

struct Timetaber_Watch_AppApp: App {
    
    @AppStorage(runningKey) var termRunningGB = false
    @AppStorage(ghostWeekKey) var ghostWeekGB = false
    @AppStorage(startDateKey) var startDateGB = Date.now
    
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
