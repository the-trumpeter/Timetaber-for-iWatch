//
//  Timetable_sharing.swift
//  Timetaber
//
//  Created by Gill Palmer on 17/10/2025.
//

//MARK: Course2
/// Representing a class/course in a timetable.
struct Course2: Encodable {
	var name:	String
	var icon:	String
	var rooms: [String] ///If a course has muliple rooms used, store all the variations here
	//var room:	String?
	var colour:	String

	var listName:	String?
	var listIcon:	String
	var joke:		String?

	let identifier:	Identifier?
	init(_ name: String, icon: String, rooms: [String] = [], colour: String,
		 listName: String? = nil, listIcon: String? = nil, joke: String? = nil, identifier: Identifier? = nil)
	{

		self.name = name
		self.icon = icon
		self.rooms = rooms
		self.colour = colour

		self.listName = listName
		self.listIcon = listIcon ?? (icon+".circle.fill")

		self.joke = joke

		self.identifier = identifier

	}

	/// Returns a copy of this course with an explicit room selected for a timetable slot.
	func with(room explicitRoom: String) -> Course2 {
		var copy = self
		copy.rooms = [explicitRoom]
		return copy
	}
}

//MARK: Timetable setup

struct TimetabledWeek: Encodable {
	var monday:			[ Int: [Int] ]
	var tuesday:		[ Int: [Int] ]
	var wednesday:		[ Int: [Int] ]
	var thursday:		[ Int: [Int] ]
	var friday:			[ Int: [Int] ]
}

struct TimeSet: Encodable {
	var startTime: Int;
	// in minutes
	var duration: Int
}
struct Times: Encodable {
	var standard: [ TimeSet ]
	var variants: [String: [TimeSet]]
	var variantDays: [Int: String]
}
//MARK: - class Timetale
///Contains all data of a user's timetable.
class Timetable: Encodable {
	var name: String
	private let formatProtocol: String = "0.0.3"

	/// All courses used in the timetable are stored in an array, with their index being a unique identifier (for use *within the timetable*, not on the frontend) for that course.
	var courses: [Int : Course2]

	var times: Times //I don't like this...
	var timetable: [TimetabledWeek]

	init(_ name: String, courses: [Int: Course2], times: Times, timetable: [TimetabledWeek] ) {
		self.name = name
		self.courses = courses
		self.times = times
		self.timetable = timetable
	}
}

//MARK: - Definition test
let chaos = Timetable(
	"Gill's Timetable",
	courses: [
		 0: Course2("Check In", 	icon: "face.smiling",				rooms: ["HG1"], 				colour: "Graphite",								listIcon: "face.smiling.inverse"),
		 1: Course2("English", 		icon: "book.closed", 				rooms: ["BT6", "BT9"],			colour: "Lemon"),
		 2: Course2("Orchestra", 	icon: "theatermasks", 												colour: "Cherry"),
		 3: Course2("HSIE",			icon: "archivebox", 				rooms: ["BG8"], 				colour: "Rees"),
		 4: Course2("Junior C.B.",	icon: "music.note", 												colour: "Cherry"),
		 5: Course2("Jr Stage",		icon: "music.note", 				rooms: ["BT1"], 				colour: "Graphite",	listName:"Junior S.B."),
		 6: Course2("Lunch", 		icon: "fork.knife", 												colour: "Graphite"),
		 7: Course2("Maths",		icon: "number", 					rooms: ["FT5"], 				colour: "Rose"),
		 8: Course2("Music Lesson", icon: "music.note", 												colour: "Graphite"),
		 9: Course2("Multimedia", 	icon: "movieclapper",				rooms: ["GG2"], 				colour: "Blueberry"),
		10: Course2("Marching Band",icon: "flag.filled.and.flag.crossed", 								colour: "Cherry",	listName:"Marching Bd.",	listIcon: "flag.2.crossed.circle.fill"),
		11: Course2("PA Music", 	icon: "music.note",					rooms: ["BG1", "BT1", "CG1"],	colour: "Cherry"),
		12: Course2("PDHPE", 		icon: "figure.run", 				rooms: ["PRAC", "THEORY"],		colour: "Lime"),
		13: Course2("Recess", 		icon: "fork.knife", 												colour: "Graphite"),
		14: Course2("Senior C.B.", 	icon: "music.note", 												colour: "Cherry"),
		15: Course2("Science", 		icon: "flask", 						rooms: ["FT10"], 				colour: "Ice",									listIcon: "flame.circle.fill"),
		16: Course2("Stage Band",	icon: "music.note", 												colour: "cherry", 	listName: "Senior S.B."),
		17: Course2("TAS", 			icon: "hammer", 					rooms: ["HG7"], 				colour: "Blueberry"),
		18: Course2("Theatre Crew",	icon: "headset", 													colour: "Peach"),
		19: Course2("Visual Arts", 	icon: "paintbrush.pointed",			rooms: ["HG5"], 				colour: "Apricot", 	listName: "Art"),
		20: Course2("Year Assembly",icon: "person.3", 													colour: "Graphite",	listName: "Assembly",		listIcon: "person.2.circle.fill"),
	],

	times: Times(
		standard: [
			TimeSet(startTime: 0900, duration: 10),
			TimeSet(startTime: 0910, duration: 60),
			TimeSet(startTime: 1010, duration: 60),
			TimeSet(startTime: 1110, duration: 20),
			TimeSet(startTime: 1130, duration: 60),
			TimeSet(startTime: 1230, duration: 60),
			TimeSet(startTime: 1330, duration: 40),
			TimeSet(startTime: 1410, duration: 60)
		],
		variants: [
			"9:30 Music lesson": [
				TimeSet(startTime: 0900, duration: 10),
				TimeSet(startTime: 0910, duration: 20),
				TimeSet(startTime: 0930, duration: 30),
				TimeSet(startTime: 1000, duration: 10),
				TimeSet(startTime: 1010, duration: 60),
				TimeSet(startTime: 1110, duration: 20),
				TimeSet(startTime: 1130, duration: 60),
				TimeSet(startTime: 1230, duration: 60),
				TimeSet(startTime: 1330, duration: 40),
				TimeSet(startTime: 1410, duration: 60)
			],
			"Band til 5pm": [
				TimeSet(startTime: 0900, duration: 10),
				TimeSet(startTime: 0910, duration: 60),
				TimeSet(startTime: 1010, duration: 60),
				TimeSet(startTime: 1110, duration: 20),
				TimeSet(startTime: 1130, duration: 60),
				TimeSet(startTime: 1230, duration: 60),
				TimeSet(startTime: 1330, duration: 40),
				TimeSet(startTime: 1410, duration: 60),
				TimeSet(startTime: 1510, duration: 110)
			],
			"Band til 5:30": [
				TimeSet(startTime: 0900, duration: 10),
				TimeSet(startTime: 0910, duration: 60),
				TimeSet(startTime: 1010, duration: 60),
				TimeSet(startTime: 1110, duration: 60),
				TimeSet(startTime: 1130, duration: 60),
				TimeSet(startTime: 1230, duration: 60),
				TimeSet(startTime: 1330, duration: 60),
				TimeSet(startTime: 1410, duration: 60),
				TimeSet(startTime: 1510, duration: 140)
			],
			"Band til 4:30": [
				TimeSet(startTime: 0900, duration: 10),
				TimeSet(startTime: 0910, duration: 60),
				TimeSet(startTime: 1010, duration: 60),
				TimeSet(startTime: 1110, duration: 20),
				TimeSet(startTime: 1130, duration: 60),
				TimeSet(startTime: 1230, duration: 60),
				TimeSet(startTime: 1330, duration: 40),
				TimeSet(startTime: 1410, duration: 60),
				TimeSet(startTime: 1510, duration: 80)
			],
		],
		variantDays: [
			2: "9:30 Music lesson", //mon
			3: "Band til 5pm",		//tue
			4: "Band til 5:30",		//wed
			5: "Band til 4:30"		//thu
		]
	),
	timetable: [
		// Week A (key 1): Mon..Fri (from previous 1..5)
		TimetabledWeek(
			monday: [
				0900: [0,  0],
				0910: [1,  1],
				0930: [8,  0],
				1000: [1,  1],
				1010: [11, 0],
				1110: [13, 0],
				1130: [12, 1],
				1230: [15, 0],
				1330: [5,  0],
				1410: [19, 0],
				1510: [21, 0]
			],
			tuesday: [
				0900: [0,  0],
				0910: [19, 0],
				1010: [11, 2],
				1110: [13, 0],
				1130: [12, 0],
				1230: [1,  1],
				1330: [6,  0],
				1410: [7,  0],
				1510: [16, 0],
				1700: [21, 0]
			],
			wednesday: [
				0900: [17, 0],
				1050: [20, 0],
				1100: [13, 0],
				1120: [15, 0],
				1210: [7,  0],
				1300: [6,  0],
				1330: [18, 0],
				1510: [10, 0],
				1730: [21, 0]
			],
			thursday: [
				0900: [0,  0],
				0910: [15, 0],
				1010: [9,  0],
				1110: [13, 0],
				1130: [3,  0],
				1230: [1,  0],
				1330: [6,  0],
				1410: [4,  0],
				1630: [2,  0],
			],
			friday: [
				0900: [0,  0],
				0910: [17, 0],
				1010: [12, 0],
				1110: [13, 0],
				1130: [15, 0],
				1230: [1,  1],
				1330: [6,  0],
				1410: [9,  0],
				1510: [21, 0]
			]
		),

		// Week B (key 2): Mon..Fri (from previous 6..10)
		TimetabledWeek(
			monday: [
				0900: [0,  0],
				0910: [1,  1],
				1000: [8,  0],
				1030: [19, 0],
				1110: [13, 0],
				1130: [3,  0],
				1230: [7,  0],
				1330: [5,  0],
				1410: [12, 1],
				1510: [21, 0]
			],
			tuesday: [
				0900: [0,  0],
				0910: [9,  0],
				1010: [7,  0],
				1110: [13, 0],
				1130: [11, 1],
				1230: [1,  1],
				1330: [6,  0],
				1410: [17, 0],
				1510: [16, 0],
				1700: [21, 0]
			],
			wednesday: [
				0900: [3,  0],
				1000: [7,  0],
				1050: [20, 0],
				1100: [13, 0],
				1120: [19, 0],
				1210: [15, 0],
				1300: [6,  0],
				1330: [14, 0],
				1510: [10, 0],
				1730: [21, 0]
			],
			thursday: [
				0900: [0,  0],
				0910: [19, 0],
				1010: [15, 0],
				1110: [13, 0],
				1130: [1,  1],
				1230: [7,  0],
				1330: [6,  0],
				1410: [4,  0],
				1530: [2,  0],
				1700: [21, 0]
			],
			friday: [
				0900: [0,  0],
				0910: [7,  0],
				1010: [3,  0],
				1110: [13, 0],
				1130: [17, 0],
				1230: [15, 0],
				1330: [6,  0],
				1410: [11, 2],
				1510: [21, 0]
			]
		)
	]
)

