//
//  NewStuff.swift
//  Timetaber
//
//  Created by Gill Palmer on 20/11/2025.
//

// Data Type? More like AARGHta Type!


import Foundation
import SwiftUI



//MARK: - typealias Colour
typealias Colour = Color









//MARK: - Course and Course2




//MARK: Course
/// Representing a class/course in a timetable.
struct Course {
	let name: String
	let icon: String
	let room: String?
	let colour: String

	let listName: String
	let listIcon: String
	let joke: String?
	let type: CourseType?

	init( _	name: 		String,
			icon: 		String,
			room: 		String? 	= nil,
			colour: 	String,
			listName: 	String? 	= nil,
			listIcon: 	String? 	= nil,
			joke: 		String? 	= nil,
			identifier:	CourseType? = nil
	)
	{

		self.name = name
		self.icon = icon
		self.room = room
		self.colour = colour

		self.listName = listName ?? name
		self.listIcon = listIcon ?? (icon+".circle.fill")

		self.joke = joke
		self.type = identifier
	}


	init(_ course2: Course2, room: String? = nil, identifier: CourseType? = nil) {
		self.name = course2.name
		self.icon = course2.icon
		self.room = room
		self.colour = course2.colour
		self.listName = course2.listName ?? name
		self.listIcon = course2.listIcon
		self.joke = course2.joke
		self.type = identifier ?? course2.type ?? nil
	}

}



//MARK: Course2
/// Representing a class/course in a timetable.
/// Second version, including data for location in the timetable,
struct Course2: Codable, Equatable {
	var name:	 String
	var icon:	 String
	var rooms:	[Int: String] ///If a course has muliple rooms used, store all the variations here
//	var room:	 String?
	var colour:	 String

	var listName:	String?
	var listIcon:	String
	var joke:		String?

	let type:	CourseType?
    
	init(_ name: String, icon: String, rooms: [String] = [], colour: String,
		 listName: String? = nil, listIcon: String? = nil, joke: String? = nil, identifier: CourseType? = nil)
	{

		self.name = name
		self.icon = icon
		self.rooms = Dictionary(uniqueKeysWithValues: zip(rooms.indices, rooms))
		self.colour = colour

		self.listName = listName
		self.listIcon = listIcon ?? (icon+".circle.fill")

		self.joke = joke

		self.type = identifier

	}

	init(_ course: Course, identifier: CourseType? = nil) {
		self.name = course.name
		self.icon = course.icon
		self.rooms = if course.room != nil { [0: course.room!] } else { [:] }
		self.colour = course.colour
		self.listName = course.listName
		self.listIcon = course.listIcon
		self.joke = course.joke
		self.type = identifier ?? course.type ?? nil
	}
}














//MARK: No School and Fail
/// Returns a `Course` representing the absence of school; with a `joke` relevant to the current date/time of interaction, obtained through the `key` parameter.\
/// If `key` is not initialised; the `joke` will default to `"Not yet, anyway..."`.
func noSchool(_ key: TimeCase? = nil) -> Course {
	let joke: String = switch key {
		case .weekend: "It's the weekend."
		case .noTerm: "No term running."
		case .noTimetable: "No timetable available."
		case .beforeClass(let startTime): "First class at \(time24toNormal(startTime))."
		case .afterClass: "School's out for today!"
	//	case .freePeriod: "No class right now"
		default: "Not yet, anyway..."
	}
	let name: String = switch key {
	//	case .freePeriod: "Free Period"
		default: "No School"
	}


	let id: CourseType? = if key != nil { CourseType.noSchool(key!) } else { nil }
	return Course(name, icon: "clock", colour: "Graphite", joke: joke, identifier: id)
}


/// Various situations in which there is no school.\
/// See `noSchool`.
enum TimeCase: Codable, Equatable {
	case weekend
	case noTerm
	case noTimetable
	case beforeClass(startTime: Int)
	case afterClass
//	case freePeriod
}



///Method to handle informal errors, fails and exhaustions; so, bugs. Feedback of `"<#shortened filename#>:\(#line)"` should be input to the `feedback` parameter.\
///Display the error to the user for reporting by setting `LocalData.shared.currentCourse` to an instance of `failCourse`. They _should_ be directed to open an Issue in the GitHub repository.
func failCourse(feedback: String? = "None") -> Course {
	return Course("Error", icon: "exclamationmark.triangle", room: feedback ?? "None", colour: "Graphite", listIcon: "exclamationmark.triangle")
}



func noSchool2(_ timecase: TimeCase? = nil) -> Course2 {
	guard let key = timecase else { return failCourse2(feedback: "TimeManager:\(#line)")}
7
	let joke: String = switch key {
		case .weekend: "It's the weekend."
		case .noTerm: "No term running."
		case .noTimetable: "No timetable available."
		case .beforeClass(let startTime): "First class at \(time24toNormal(startTime))."
		case .afterClass: "School's out for today!"
	}
	return Course2("No school", icon: "clock", colour: "Graphite", joke: joke, identifier: .noSchool(key) )
}



func failCourse2(feedback: String? = "None") -> Course2 {
	let rooms: [String] = if feedback != nil { [feedback!] } else { [] }
	return Course2("Error", icon: "exclamationmark.triangle", rooms: rooms, colour: "Graphite", listIcon: "exclamationmark.triangle", identifier: .fail)
}



//MARK: Conversion

enum ConversionError: Error {
	case noParameters
	case bothInputs
	case unexpectedNil
	case identifierNotProvided
}




/*
 func convertCourse(
	course: Course? = nil,
	course2: Course2? = nil, room: String? = nil,
	identifier: CourseType? = nil
) throws -> Any {

	guard (course != nil) != (course2 != nil) else { // only one input provided
		throw ConversionError.bothInputs
	}

	if course2 != nil {
		// Course2 to Course
		//guard let id: Identifier = identifier else {throw ConversionError.identifierNotProvided}
		return Course(
			course2!.name,
			icon: course2!.icon,
			room: room,
			colour: course2!.colour,
			listName: course2!.listName,
			listIcon: course2!.listIcon,
			joke: course2!.joke,
			identifier: { if course2!.type != nil { return course2!.type! } else { return identifier } }()
		)
	}
	if course != nil {
		return Course2(
			course!.name,
			icon: course!.icon,
			rooms: { if let rm = course?.room { return [rm] } else { return [] } }(),
			colour: course!.colour,
			listName: course!.listName,
			listIcon: course!.listIcon,
			joke: course!.joke,
			identifier: { if course!.type != nil { return course!.type! } else { return identifier } }()
		)
	}
	throw {
		return ConversionError.noParameters
	}()
}
 */













//MARK: - UI functions



func roomOrBlank(_ course: Course) -> String? {
	guard let room = course.room else {
		guard let joke = course.joke else {
			return nil
		}
		return joke
	}
	return room
}


func getNextString(_ course: Course) -> String {
	if course.name == "Error" || LocalData.shared.currentCourse.name=="Error" {
		return "bit.ly/ttberError1"
	}
	if course.name == "No school" {
		return ""
	} else if let room = course.room {
		return course.name+" - "+room
	}
	return course.name

}


func nextPrefix(_ course: Course) -> String {
	if course.name == "Error" {
		return "Report this:"
	}
	if course.name == "No school" {
		return ""
	}
	return "Next up:"
}











//MARK: - Date & Time


func time24toNormal(_ time24: Int) -> String {
	var stringTime = String(time24)
	if stringTime.count == 3 {
		stringTime.insert(":", at: stringTime.index(stringTime.startIndex, offsetBy: 1))
		return stringTime
	} else if stringTime.count == 4 {
		stringTime.insert(":", at: stringTime.index(stringTime.startIndex, offsetBy: 2))
		return stringTime
	}
	return stringTime
}




func dateFrom24hrInt(_ time24: Int) -> Date {
	var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
	components.timeZone = TimeZone.current
	components.hour = time24/100
	components.minute = time24%100
	components.second = 0
	print("TimeManager_fDef.swift:\(#line) @ dateFrom24hrInt\n\tComposing date \(String(describing: components.hour!)):\(String(describing: components.minute!))")
	guard let date = calendar.date(from: components) else {

		LocalData.shared.currentCourse = failCourse(feedback: "TimeManager:\(#line)")
		NSLog("%@:%d @ dateFrom24hrInt | %@ | 🚨🚨 Catastrophic Error:\n    Composing date %@:%@.\n    DateComponents: %@", #file, #line, Date.now.formatted(date: .numeric, time: .complete), String(describing: components.hour), String(describing: components.minute), String(describing: components)
			  )
		log()
		return Date.now
	}
	return date
}



func getTimetableDay2(isWeekA: Bool, weekDay: Int, timetable: Timetable) -> Dictionary< Int, [Int] > {
	let weeks = timetable.timetable
	if isWeekA {
		switch weekDay {
			case 2: return weeks[0].monday
			case 3: return weeks[0].tuesday
			case 4: return weeks[0].wednesday
			case 5: return weeks[0].thursday
			case 6: return weeks[0].friday
			default: return [:]
		}
	} else {
		switch weekDay {
			case 2: return weeks[1].monday
			case 3: return weeks[1].tuesday
			case 4: return weeks[1].wednesday
			case 5: return weeks[1].thursday
			case 6: return weeks[1].friday
			default: return [:]
		}
	}
}


func weekdayNumber(_ ofDate: Date) -> Int {
	return Int(calendar.component(.weekday, from: ofDate)) // Sun=1, Sat=7
}


func time24() -> Int {
	dFormatter.dateFormat = "HHmm" // or hh:mm for 12 hr time
	return Int(dFormatter.string(from: .now))!
}



func odd(_ number: Int) -> Bool {
	if number % 2 == 0 {
		return false
	} else {
		return true
	}
}


func getIfWeekIsA_FromDateAndGhost(originDate: Date, ghostWeek: Bool) -> Bool {
	//week A and B alternate each week. he input date is always a week a unless ghost is true.

	let originWeek = calendar.component(.weekOfYear, from: originDate)
	let currentWeek = calendar.component(.weekOfYear, from: Date())



	if odd(originWeek) == odd(currentWeek) {
		//they match, so the numbers must be same
		if !ghostWeek {
			return true
		} else {
			return false
		}
	} else { if !ghostWeek {
			return false
		} else {
			return true
		}
	}

}



func getTimetableDay(isWeekA: Bool, weekDay: Int) -> Dictionary<Int, Course> {
	if isWeekA {
		let timetableDay = weekA[weekDay-2]
		return timetableDay
	} else {
		let timetableDay = weekB[weekDay-2]
		return timetableDay
	}

}















//MARK: - Timetable



//MARK: Timetable Structs/Enums

struct Timeslot: Codable, Equatable {
	let week: WeekAB
	let day: Int //1=Sun, 2=Mon, ...7=Sat
	let time: Int
	//let Timetable: Timetable
}

enum WeekAB: Codable { case a; case b }

enum CourseType: Codable, Equatable {
	case standard
	case noSchool(TimeCase)
	case fail
}






