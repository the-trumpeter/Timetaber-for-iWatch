//
//  LocalData.swift
//  Timetaber
//
//  Created by Gill Palmer on 7/11/2025.
//
//  This file (and Storage.swift) also contain general stuff for all targets, e.g. typealias, logging

//	zsh to count lines of code in proj
//		cloc --include-lang=swift --not-match-d=Local,Old ~/Documents/GitHub/Timetaber

import Foundation
import SwiftUI
import OSLog


let bID = Bundle.main.bundleIdentifier!
extension Logger {
	static let editCourses = Logger(subsystem: bID, category: "Timetable Edit Courses")
	static let editTimes = Logger(subsystem: bID, category: "Timetable Edit Times")
	static let editTimetable = Logger(subsystem: bID, category: "Timetable Edit Timetable")
	static let timetableChanges = Logger(subsystem: bID, category: "Timetable Changes")

	static let updateTimer = Logger(subsystem: bID, category: "Refresh Timer")
	static let dateTime = Logger(subsystem: bID, category: "Date/Time Computation")

	static let general = Logger(subsystem: bID, category: "General")
	
	static let views = Logger(subsystem: bID, category: "Views")

	static let files = Logger(subsystem: bID, category: "Export/Import JSON")
	static let connectivity = Logger(subsystem: bID, category: "WatchConnectivity")
}

extension View {
	@ViewBuilder
	func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}



///Main data model
class LocalData: ObservableObject {
	static let shared = LocalData()
	@Published var currentCourse: DisplayCourse // the current timetabled class in session.
	@Published var nextCourse: DisplayCourse	 // the next timetabled class in session
	@Published var currentTime: Timeslot // the timeslot (unique ID) of the current course.

	

	let storage: Storage


	init() {
		Logger.general.log("Initialising LocalData...")

		let isweekA = getIfWeekIsA_FromDateAndGhost(
			originDate: Storage.shared.startDateGB,
			ghostWeek: Storage.shared.ghostWeekGB
		)
		var now: (current: DisplayCourse, next: DisplayCourse, timeslot: Timeslot)
			= (noSchool(.noTimetable), noSchool(.noTimetable), Timeslot(week: isweekA ? .a : .b, day: weekdayNumber(.now), time: -1))

		let activeIndex = Storage.shared.ActiveTimetable
		if Storage.shared.timetables.indices.contains(activeIndex) {
			let timetable = Storage.shared.timetables[activeIndex]
			now = getCurrentClass2(date: .now, timetable: timetable)
		}

		self.currentCourse = now.current
		self.nextCourse = now.next

		self.storage = Storage.shared

		self.currentTime = now.timeslot
		Logger.general.log("LocalData initialised")
	}
}
