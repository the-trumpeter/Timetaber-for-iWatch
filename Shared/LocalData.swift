//
//  LocalData.swift
//  Timetaber
//
//  Created by Gill Palmer on 7/11/2025.
//

import Foundation
import SwiftUI

///The local equivalent of `GlobalData`. NOTE: iOS DATA IS THE ROOT SOURCE OF TRUTH FOR TIMETABER'S STORAGE.
class LocalData: ObservableObject {
	static let shared = LocalData()
	@Published var currentCourse: Course // the current timetabled class in session.
	@Published var nextCourse: Course	 // the next timetabled class in session
	@Published var currentTime: Timeslot // the timeslot (unique ID) of the current course.

	///This contains all timetables that the user has created. **This timetable set, of the iOS app, is the *global source of truth* for both apps, WatchOS and iOS. The WatchOS app will never, and can never, overwrite this, and any discrepancies will always resolve to the iOS app's data.**
	@Published var timetables: [Timetable]
	var ActiveTimetable: Int = 0
	@Published var timetable: Timetable

	let storage: Storage

	init() {
		print("LocalData init")
		let now = getCurrentClass2(date: .now, timetable: chaos)
		guard ((now[0] as? Course) != nil), ((now[1] as? Course) != nil), ((now[2] as? Timeslot) != nil), now.count == 3 else {
			fatalError("\(Date.now.formatted(date: .numeric, time: .complete)) | \(#file):\(#line)\n\tgetCurrentClass2 returned contents other than `[Course, Course, Timeslot]`.\n\tContents: \(now)")
		}
		self.currentCourse = now[0] as! Course
		self.nextCourse = now[1] as! Course
		self.timetables = [chaos]
		self.storage = Storage()
		self.timetable = chaos //[_][self.ActiveTimetable]
		self.currentTime = now[2] as! Timeslot
	}
	#if os(watchOS)
	func pingPhone() {

	}
	#endif
}
