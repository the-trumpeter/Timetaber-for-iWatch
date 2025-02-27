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



class globalStorage {
    
    static let shared = globalStorage()
    
    @State @AppStorage(runningKey) var termRunningGB = false
    @State @AppStorage(ghostWeekKey) var ghostWeekGB = false
    @State @AppStorage(startDateKey) var startDateGB = Date.now
    
}
let storage = globalStorage.shared



func log() {
    print("Current class is \(currentCourse.name).")
    print("Term running is \(storage.termRunningGB), ghost week is \(storage.ghostWeekGB).")
    print("It is \(Date().description).")
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
