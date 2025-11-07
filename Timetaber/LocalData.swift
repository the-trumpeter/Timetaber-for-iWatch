//
//  LocalData.swift
//  Timetaber
//
//  Created by Gill Palmer on 7/11/2025.
//

import Foundation
import SwiftUI

///The local equivalent of `GlobalData`. NOTE: iOS DATA IS THE ROOT SOURCE OF TRUTH FOR TIMETABER'S STORAGE.
class LocalStorage: ObservableObject {
	static let shared = GlobalData()
	@Published var currentCourse: Course// = getCurrentClass(date: .now)[0]  //  the current timetabled class in session.
	@Published var nextCourse: Course// = getCurrentClass(date: .now)[1]     //  the next timetabled class in session

	///This contains all timetables that the user has created. **This timetable set, of the iOS app, is the *global source of truth* for both apps, WatchOS and iOS. The WatchOS app will never, and can never, overwrite this, and any discrepancies will always resolve to the iOS app's data.**
	@Published var timetables: [Timetable]

	let storage = Storage()

}
