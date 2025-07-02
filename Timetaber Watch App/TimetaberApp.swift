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


@main

struct Timetaber_Watch_AppApp: App {
    
    init() {
        calendar.timeZone = TimeZone.current
    }
    
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
