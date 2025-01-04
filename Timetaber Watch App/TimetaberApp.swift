//
//  TimetaberApp.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI

var currentClass: Class = LanguageClass //the current timetabled class in session.
var nextClass: Class = MathsClass
var period = 1
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
