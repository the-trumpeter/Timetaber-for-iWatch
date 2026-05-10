//
//  Onboarder.swift
//  Timetaber
//
//  Created by Gill Palmer on 7/5/2026.
//

import SwiftUI


fileprivate struct onboarderButtons: View {
	@ObservedObject var storage = Storage.shared
	var body: some View {
		Group {
			Button { storage.initialiseTimetables(.blank) } label: {
				HStack { Spacer(); Text("Blank Timetable").font(.title2); Spacer() }
					.frame(minHeight: 40)
			}
			Button { storage.initialiseTimetables(.template) } label: {
				HStack { Spacer(); Text("HSPA Template").font(.title2); Spacer() }
					.frame(minHeight: 40)
			}
			Button { storage.initialiseTimetables(.demo) } label: {
				HStack { Spacer(); Text("Demo Timetable").font(.title2); Spacer() }
					.frame(minHeight: 40)
			}
		}
		.buttonStyle(.borderedProminent)
	}
}
struct Onboarder: View {
	var body: some View {
		VStack {
			Group {
				Text("Welcome to Timetaber").font(.largeTitle).bold()
				Text("Let's get you set up").font(.title2).foregroundStyle(.secondary)
			}.padding(.leading, 5).padding(.trailing, 5)
			Spacer()
			VStack(spacing: 10) {
				if #available(iOS 26.0, *) {
					onboarderButtons()
						.glassEffect()
				} else {
					onboarderButtons()
				}
			}.padding(.leading).padding(.trailing)
		}

	}
}
