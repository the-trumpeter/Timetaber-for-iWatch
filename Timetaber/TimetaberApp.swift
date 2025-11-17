//
//  TimetaberApp.swift
//  Timetaber
//
//  Created by Gill Palmer on 14/8/2025.
//

import SwiftUI

@main
struct TimetaberApp: App {
    var body: some Scene {
        WindowGroup {
            TabView{
                Tab("Home", systemImage: "clock") { HomeView().environmentObject(LocalData.shared) }
				Tab("Timetable", systemImage: "list.bullet") { TimetableView(day: monA).environmentObject(LocalData.shared) }
				Tab("Settings", systemImage: "gear") { SettingsView() }
            }
        }
	}
}
