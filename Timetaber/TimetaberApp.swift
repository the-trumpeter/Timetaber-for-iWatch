//
//  TimetaberApp.swift
//  Timetaber
//
//  Created by Gill Palmer on 14/8/2025.
//

import SwiftUI

///White text against these colours is illegible; use black for them instead.
let coloursNeedBlackForeground = ["Peach", "Lemon"]


@main

///World's greatest timetable app
struct TimetaberApp: App {
    var body: some Scene {
        WindowGroup {
            TabView{
                Tab("Home", systemImage: "clock") { HomeView().environmentObject(LocalData.shared) }
                Tab("Timetable", systemImage: "list.bullet") { TimetableView(timetable: chaos).environmentObject(LocalData.shared) }
				Tab("Settings", systemImage: "gear") { SettingsView() }
            }
        }
	}
}
