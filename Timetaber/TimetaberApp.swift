//
//  TimetaberApp.swift
//  Timetaber
//
//  Created by Gill Palmer on 14/8/2025.
//

import SwiftUI


import OSLog


///White text against these colours is illegible; use black for them instead.
let coloursNeedBlackForeground = [ Colour("peach"), Colour("lemon"), Colour("ice"), Colour("lime") ]
///Black text against these colours (e.g. in ForEach and other non-Home views) is illegible; use white for them instead.
let coloursNeedWhiteForeground = [ Colour("black"), Colour("blueberry") ]


@main

///World's greatest timetable app
struct TimetaberApp: App {
	var body: some Scene {
        WindowGroup {
            TabView{
                Tab("Home", systemImage: "clock") { HomeView().environmentObject(LocalData.shared) }
                Tab("Timetable", systemImage: "list.bullet") { TimetableView().environmentObject(LocalData.shared) }
				Tab("Settings", systemImage: "gear") { SettingsView() }
            }
        }
	}
}
