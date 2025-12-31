//
//  24_Hour_Time.swift
//  Timetaber
//
//  Created by Gill Palmer on 31/12/2025.
//

import Foundation

/// A 24-hour time
typealias Time24 = Int

fileprivate let dFormatter = DateFormatter()

extension Time24 {
	
	/// Get the current time as an integer value
	/// - Returns: The current 24-hour time.
	init() {
		dFormatter.dateFormat = "HHmm" // or hh:mm for 12 hr time
		self = Time24(dFormatter.string(from: .now))!
	}
	
	/// Extract a time from a `Date`
	/// - Parameter date: A `Date` containing the time to be extracted.
	init(from date: Date) {
		let cpts = Calendar.current.dateComponents([.hour, .minute], from: date)
		self = (cpts.hour!*100 + cpts.minute!)
	}

	/// Create a human-readable `String`
	/// - Returns: A human-readable, twelve-hour `String` with hours/minutes seperator.
	///
	/// Does not include am/pm, for readability—this may be changed in future but for now will remain as is in order to maximise simplicity and at-a-glance readability.
	func display() -> String {
		let twelveHour: Int? = if self >= 1300 { self - 1200 } else {nil}
		var stringTime = String(twelveHour ?? self)
		stringTime.insert(":", at: stringTime.index(stringTime.endIndex, offsetBy: -2))
		return stringTime
	}
}

extension Date {
	/// Create a `Date` value from a 24-hour timecode
	/// - Parameter time24: A 24-hr time, e.g. `0900` (9am), `1345` (1:45pm)
	init(time24: Time24) {
		var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
		components.timeZone = TimeZone.current
		components.hour = time24/100
		components.minute = time24%100
		components.second = 0
		//print("\(#fileID):\(#line) @ \(#function) Composing date \(String(describing: components.hour!)):\(String(describing: components.minute!))")
		guard let date = Calendar.current.date(from: components) else {
			log()
			fatalError("\(#fileID):\(#line) @ \(#function) | \(Date.now.formatted(date: .numeric, time: .complete))\n\tAttempting: \(String(describing: components.hour)):\(String(describing: components.minute))\n\tDateComponents: \(String(describing: components))")
		}
		self = date
	}
}


/*
/// Create a displayable `String` from a provided time.
/// - Parameter time24: The raw time to be converted
/// - Returns: A human-readable, twelve-hour `String` with hours/minutes seperator.
///
/// Does not include am/pm, for readability—this may be changed in future but for now will remain as is in order to maximise simplicity and at-a-glance readability.
func time24toNormal(_ time24: Time24) -> String {
	var twelveHour: Int? = if time24 > 1200 { time24 - 1200 } else {nil}
	var stringTime = String(twelveHour ?? time24)
	stringTime.insert(":", at: stringTime.index(stringTime.endIndex, offsetBy: -3))
	return stringTime
}
*/

/*
/// Convert a 24-hour timecode to a `Date`
/// - Parameter time24: A 24-hr time, e.g. `0900` (9am), `1345` (1:45pm)
/// - Returns: `Date` comprised of the provided time and today's date.
func dateFrom24hrInt(_ time24: Time24) -> Date {
	var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
	components.timeZone = TimeZone.current
	components.hour = time24/100
	components.minute = time24%100
	components.second = 0
	//print("\(#fileID):\(#line) @ \(#function) Composing date \(String(describing: components.hour!)):\(String(describing: components.minute!))")
	guard let date = calendar.date(from: components) else {
		log()
		fatalError("\(#fileID):\(#line) @ \(#function) | \(Date.now.formatted(date: .numeric, time: .complete))\n\tAttempting: \(String(describing: components.hour)):\(String(describing: components.minute))\n\tDateComponents: \(String(describing: components))")
	}
	return date
}
*/

/*
/// Extract a time from a `Date`
/// - Parameter date: A `Date` containing the time to be extracted
/// - Returns: The time of day contained within the date, formatted in 24-hour time as `Time24`
func hr24IntFromDate(_ date: Date) -> Time24 {
	let cpts = Calendar.current.dateComponents([.hour, .minute], from: date)
	return cpts.hour!*100 + cpts.minute!

}
*/
