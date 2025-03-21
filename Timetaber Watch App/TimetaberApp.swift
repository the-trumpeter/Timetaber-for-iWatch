//
//  TimetaberApp.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI



//var nowData = getCurrentClass(date: .now)
@Observable class GlobalData {
    var currentCourse: Course = getCurrentClass(date: .now)[0] //  the current timetabled class in session.
    var nextCourse: Course = getCurrentClass(date: .now)[1] //  the next timetabled class in session
}

var viewNo = 1





func log() {
    print("""
    ~ Log - \(Date().description) {
        Current class is \(GlobalData().currentCourse.name).
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
                    .environment(GlobalData())
                
                ListView()
                    .environment(GlobalData())
                
                SettingsView()
                    .environment(GlobalData())
                
            }
            .tabViewStyle(.carousel)
            .onAppear() {
                log()
            }
            
        }
        
    }
}
