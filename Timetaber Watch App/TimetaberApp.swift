//
//  TimetaberApp.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI

var currentCourse: Course = getCurrentClass(date: .now) //the current timetabled class in session.
var nextCourse: Course = MathsClass
var viewNo = 1





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
        }
    }
}
