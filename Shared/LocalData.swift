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

	

	let storage: Storage


	init() {
		print("\(#fileID):\(#line) Start LocalData init")
		let now = getCurrentClass2(date: .now, timetable: chaos)
		guard ((now[0] as? Course) != nil), ((now[1] as? Course) != nil), ((now[2] as? Timeslot) != nil), now.count == 3 else {
			fatalError("\(Date.now.formatted(date: .numeric, time: .complete)) | \(#fileID):\(#line)\n\tgetCurrentClass2 returned contents other than `[Course, Course, Timeslot]`.\n\tContents: \(now)")
		}
		self.currentCourse = now[0] as! Course
		self.nextCourse = now[1] as! Course
		
		self.storage = Storage.shared

		self.currentTime = now[2] as! Timeslot
		print("\(#fileID):\(#line)  End LocalData init")
	}
}

