//
//  Course.swift
//  Timetaber
//
//  Created by Gill Palmer on 31/12/2025.
//

///A position in the timetable
///
///Used by UI to determine which course is to be displayed as 'current'.
///
///If we were to query `someCourse == currentCourse` to determine which course is the one we're in right now, it would become problematic if there were two of the same course in a day; both would be shown as 'current'. Instead, we use a by-time setup, querying `someTime == currentTime` to avoid duplicatory mixup.
struct Timeslot: Codable, Equatable {
	let week: WeekAB
	let day: Int //1=Sun, 2=Mon, ...7=Sat
	let time: Time24
	//let Timetable: Int
}

enum CourseType: Codable, Equatable {
	case standard
	case noSchool(TimeCase)
	case fail
}




/// Representing a class/course in a timetable.
///
/// This was recreated from Course (now `DisplayCourse`) to allow for easier management of room variations, as well as other small things
struct Course2: Codable, Equatable {
	var name:	 String
	var icon:	 String

	///If a course has muliple rooms used, store all the variations here and refer to each in the timetable.
	var rooms:	[Int: String]
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

	init(_ course: DisplayCourse, identifier: CourseType? = nil) {
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




/// Simplified version of `Course2`, used by UI.
///
/// `DisplayCourse` used to be 'Course', but was replaced with `Course2` in the construction of the iOS app to allow for easier management of room variations.
struct DisplayCourse {
	let name: String
	let icon: String
	let room: String?
	let colour: String

	let listName: String
	let listIcon: String
	let joke: String?
	let type: CourseType? //TODO: What on earth is this used for?

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
