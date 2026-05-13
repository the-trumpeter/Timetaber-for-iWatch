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
	@ObservedObject var storage = Storage.shared

    var body: some Scene {
		let globalError = Binding(
			get: { storage.globalErrorMessage != "" },
			set: { new in
				if new {
					if storage.globalErrorMessage.isEmpty {
						Storage.shared.globalErrorMessage = "Error \(#line)"
					}
				} else {
					Storage.shared.globalErrorMessage = ""
				}
			}
		)
		WindowGroup {

			TabView{
				HomeView()
					.environmentObject(LocalData.shared)

				TimetableView()//ListView()
					.environmentObject(LocalData.shared)

				//SettingsView()
				//    .environmentObject(LocalData.shared)

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
			.alert(storage.globalErrorMessage, isPresented: globalError) {
				Button("OK") { storage.globalErrorMessage = "" }
			} message: {
				Text("Timetable may be outdated. Try sending full timetable from iOS app")
			}
			.onChange(of: Storage.shared.globalErrorMessage) { _, new in
				if !(new.isEmpty) {
					WKInterfaceDevice.current().play(.failure)
				}
			}

        }

    }
}
