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
		//TODO: update from phone here
    }
    
    var body: some Scene {
        
        WindowGroup {
            
            TabView{
                HomeView()
                    .environmentObject(LocalData.shared)
                
                ListView()
                    .environmentObject(LocalData.shared)
                
                SettingsView()
                    .environmentObject(LocalData.shared)
                
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
