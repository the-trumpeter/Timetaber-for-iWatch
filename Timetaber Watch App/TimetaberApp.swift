//
//  TimetaberApp.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI



class GlobalData: ObservableObject {
    static let shared = GlobalData()
    @Published var currentCourse: Course = getCurrentClass(date: .now)[0]  //  the current timetabled class in session.
    @Published var nextCourse: Course = getCurrentClass(date: .now)[1]     //  the next timetabled class in session
}

var viewNo = 1

let customSymbols = [
    "paintbrush.pointed.circle.fill": Image(.paintbrushPointedCircleFill),
    "music.note.circle.fill": Image(.musicNoteCircleFill),
    "movieclapper.circle.fill": Image(.movieclapperCircleFill)
]



func log() {
    print("""
    ~ Log - \(Date().description) {
        Current course is '\(GlobalData.shared.currentCourse.name)', next course is '\(GlobalData.shared.nextCourse.name)'.
        Term running is <\(storage.shared.termRunningGB)>, ghost week is <\(storage.shared.ghostWeekGB)>.
    } End Log ~
    """)
}


@main

struct Timetaber_Watch_AppApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            
            TabView{
                HomeView()
                    .environmentObject(GlobalData.shared)
                
                ListView()
                    .environmentObject(GlobalData.shared)
                
                SettingsView()
                    .environmentObject(GlobalData.shared)
                
            }
            .tabViewStyle(.carousel)
            .onAppear() {
                log()
            }
            
        }
        
    }
}
