//
//  LocalData.swift
//  Timetaber
//
//  Created by Gill Palmer on 7/11/2025.
//
//  This file (and Storage.swift) also contain general stuff for all targets, e.g. typealias, logging

import Foundation
import SwiftUI
import OSLog

///Flippity-flopping American English
typealias Colour = Color


let bID = Bundle.main.bundleIdentifier!
extension Logger {
	static let editCourses = Logger(subsystem: bID, category: "Timetable Edit Courses")
	static let editTimes = Logger(subsystem: bID, category: "Timetable Edit Times")
	static let editTimetable = Logger(subsystem: bID, category: "Timetable Edit Timetable")
	static let timetableChanges = Logger(subsystem: bID, category: "Timetable Changes")

	static let updateTimer = Logger(subsystem: bID, category: "Update Timer")
	static let dateTime = Logger(subsystem: bID, category: "Date/Time Computation")

	static let general = Logger(subsystem: bID, category: "General")

	static let term = Logger(subsystem: bID, category: "Term")
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
		let now = getCurrentClass2(date: .now, timetable: chaos)
		guard ((now[0] as? DisplayCourse) != nil), ((now[1] as? DisplayCourse) != nil), ((now[2] as? Timeslot) != nil), now.count == 3 else {
			fatalError("getCurrentClass2 returned contents other than `[Course, Course, Timeslot]`.\n\tContents: \(now)")
		}
		self.currentCourse = now[0] as! DisplayCourse
		self.nextCourse = now[1] as! DisplayCourse
		
		self.storage = Storage.shared

		self.currentTime = now[2] as! Timeslot
		Logger.general.log("LocalData initialised")
	}
}

