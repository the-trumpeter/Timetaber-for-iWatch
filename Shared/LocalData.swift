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
	@Published var currentCourse: Course  //  the current timetabled class in session.
	@Published var nextCourse: Course     //  the next timetabled class in session

	///This contains all timetables that the user has created. **This timetable set, of the iOS app, is the *global source of truth* for both apps, WatchOS and iOS. The WatchOS app will never, and can never, overwrite this, and any discrepancies will always resolve to the iOS app's data.**
	@Published var timetables: [Timetable]
	var ActiveTimetable: Int = 0
	@Published var timetable: Timetable

	let storage: Storage

	init() {
		print("LocalData init")
		let now = getCurrentClass2(date: .now, timetable: chaos)
		self.currentCourse = now[0]
		self.nextCourse = now[1]
		self.timetables = [chaos]
		self.storage = Storage()
		self.timetable = chaos //[_][self.ActiveTimetable]
	}
	#if os(watchOS)
	func pingPhone() {

	}
	#endif
}
