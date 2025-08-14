//
//  TimetaberApp.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI

@main

struct Timetaber_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
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
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    reload()
                }
            }
        }
        
    }
}
