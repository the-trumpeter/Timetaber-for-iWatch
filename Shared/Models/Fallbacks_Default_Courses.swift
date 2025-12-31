//
//  at.swift
//  Timetaber
//
//  Created by Gill Palmer on 31/12/2025.
//

/*
/// Returns a `Course` representing the absence of school; with a `joke` relevant to the current date/time of interaction, obtained through the `key` parameter.\
/// If `key` is not initialised; the `joke` will default to `"Not yet, anyway..."`.
 */

/// The absence of school
/// - Parameter key: A `TimeCase` which directly influences the content of the return value.
/// - Returns: A `DisplayCourse`, ready to be displayed in the UI.
func noSchool(_ key: TimeCase? = nil) -> DisplayCourse {
	let joke: String = switch key {
		case .weekend: "It's the weekend."
		case .noTerm: "No term running."
		case .noTimetable: "No timetable available."
		case .beforeClass(let startTime): "First class at \(startTime.display())."
		case .afterClass: "School's out for today!"
	//	case .freePeriod: "No class right now"
		default: "Not yet, anyway..."
	}
	let name: String = switch key {
	//	case .freePeriod: "Free Period"
		default: "No School"
	}


	let id: CourseType? = if key != nil { CourseType.noSchool(key!) } else { nil }
	return DisplayCourse(name, icon: "clock", colour: "Graphite", joke: joke, identifier: id)
}


/// Various scenarios in which there are no classes.
/// 
/// See `noSchool`.
enum TimeCase: Codable, Equatable {
	case weekend
	case noTerm
	case noTimetable
	case beforeClass(startTime: Time24)
	case afterClass
//	case freePeriod
}



/// Method to handle unexpected bugs.
/// - Parameter feedback: Submit `"\(#fileID):\(#line)"`.
/// - Returns: Display the error to the user for reporting by setting `LocalData.shared.currentCourse` to an instance of `failCourse`. They _should_ be directed to open an Issue in the GitHub repository.
///
/// With the planned use of TestFlight, the direction to the user to file bug report(s) may change.
func failCourse(feedback: String? = "None") -> DisplayCourse {
	return DisplayCourse("Error", icon: "exclamationmark.triangle", room: feedback ?? "None", colour: "Graphite", listIcon: "exclamationmark.triangle")
}
