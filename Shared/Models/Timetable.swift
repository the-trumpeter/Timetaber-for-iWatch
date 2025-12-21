///Contains all data of a user's timetable.
class Timetable: Codable {
	var name: String
	//var icon: String
	//Doooo not modifyy!
	var formatProtocol: String = "0.0.3"

	/// All courses used in the timetable are stored in an array, with their index being a unique identifier (for use *within the timetable*, not on the frontend) for that course.
	var courses: [Int : Course2]

	var times: Times //I don't like this...
	var timetable: [TimetabledWeek]

	init(_ name: String, courses: [Int: Course2], times: Times, timetable: [TimetabledWeek] ) {
		self.name = name
		//self.icon = icon
		self.courses = courses
		self.times = times
		self.timetable = timetable
	}
}