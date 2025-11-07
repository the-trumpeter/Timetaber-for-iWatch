//
//  Courses.swift
//  Timetaber for iWatch
//  Variable definition script
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI
import Foundation

enum WeekAB { case a; case b}
enum Identifier: Equatable {
	case standard(Timeslot)
	case noSchool
	case fail
}
struct Timeslot: Equatable {
	let time: Int
	let day: Int //1=Sun, 2=Mon, ...7=Sat
	let week: WeekAB
	//let Timetable: Timetable
}

/// Representing a class/course in a timetable.
struct Course {
    let name: String
    let icon: String
    let room: String?
    let colour: String
    
    let listName: String
    let listIcon: String
    let joke: String?
	let identifier: Identifier?

    init(_ name: String, icon: String, room: String? = nil, colour: String,
         listName: String? = nil, listIcon: String? = nil,
		 joke: String? = nil,
		 identifier: Identifier? = nil
	)
    {
        
        self.name = name
        self.icon = icon
        self.room = room
        self.colour = colour
        
        self.listName = listName ?? name
        self.listIcon = listIcon ?? (icon+".circle.fill")
        
        self.joke = joke
		self.identifier = identifier
    }

}


//MARK: - Old Courses
/*
Define all courses for user's timetable
 
(Will later script timetable builder thing in iOS companion app to create/edit these.)
(alphabetical order)
*/
let CheckInCourse = Course("Check In", icon: "face.smiling", room: "HG1", colour: "Graphite", listIcon: "face.smiling.inverse")

let English6 = Course("English", icon: "book.closed", room: "BT6", colour: "Lemon")
let English9 = Course("English", icon: "book.closed", room: "BT9", colour: "Lemon")

let GreaseOrchCourse = Course("Orchestra", icon: "theatermasks", colour: "Cherry")

let HSIECourse = Course("HSIE", icon: "archivebox", room: "BG8", colour: "Rees")

let JCBCourse = Course("Junior C.B.", icon: "music.note", colour: "Cherry")
let JSBCourse = Course("Jr Stage", icon: "music.note", room: "BT1", colour: "Graphite", listName: "Junior S.B.")


let LunchPeriod = Course("Lunch", icon: "fork.knife", colour: "Graphite", joke: "foood")

let MathsCourse = Course("Maths", icon: "number", room: "FT5", colour: "Rose")
let MLPeriod = Course("Music Lesson", icon: "music.note", colour: "Graphite")
let MultimediaCourse = Course("Multimedia", icon: "movieclapper", room: "GG2", colour: "Blueberry")
let MSBCourse = Course("Marching Band", icon: "flag.filled.and.flag.crossed", colour: "Cherry", listName: "Marching Bd.", listIcon: "flag.2.crossed.circle.fill")

let PACourseBG = Course("PA Music", icon: "music.note", room: "BG1", colour: "Cherry")
let PACourseBT = Course("PA Music", icon: "music.note", room: "BT1", colour: "Cherry")
let PACourseC1 = Course("PA Music", icon: "music.note", room: "CG1", colour: "Cherry")

let PDHPE1 = Course("PDHPE", icon: "figure.run", room: "AG1", colour: "Lime")
let PDHPE3 = Course("PDHPE", icon: "figure.run", room: "AG3", colour: "Lime")
let PDHPEPrac = Course("PDHPE", icon: "figure.run", room: "HALL", colour: "Lime")

let RecessPeriod = Course("Recess", icon: "fork.knife", colour: "Graphite", joke: "like lunch but short")

let SCBCourse = Course("Senior C.B.", icon: "music.note", colour: "Cherry")
let ScienceCourse = Course("Science", icon: "flask", room: "FT10", colour: "Ice", listIcon: "flame.circle.fill")
let SSBCourse = Course("Stage Band", icon: "music.note", colour: "cherry", listName: "Senior S.B.")

let TAS = Course("TAS", icon: "hammer", room: "HG7", colour: "Blueberry")
let TCCourse = Course("Theatre Crew", icon: "headset", colour: "Peach")

let VisualArtsCourse = Course("Visual Arts", icon: "paintbrush.pointed", room: "HG5", colour: "Apricot", listName: "Art")

let yearAssembly = Course("Year Assembly", icon: "person.3", colour: "Graphite", listName: "Assembly", listIcon: "person.2.circle.fill")


/// Various situations in which there is no school.\
/// See `noSchool`.
enum TimeCase {
    case weekend
    case noTerm
    case beforeClass(startTime: Int)
    case afterClass
}
/// Returns a `Course` representing the absence of school; with a `joke` relevant to the current date/time of interaction, obtained through the `key` parameter.\
/// If `key` is not initialised; the `joke` will default to `"Not yet, anyway..."`.
func noSchool(_ key: TimeCase? = nil) -> Course {
    let joke: String

    switch key {
    case .weekend:
        joke = "It's the weekend."
    case .noTerm:
        joke = "No term running."
    case .beforeClass(let startTime):
        joke = "First class at \(time24toNormal(startTime))."
    case .afterClass:
        joke = "School's out for today!"
    case nil:
        joke = "Not yet, anyway..."
    }
    
    return Course("No school", icon: "clock", colour: "Graphite", joke: joke)
}


///Method to handle informal errors, fails and exhaustions; so, bugs. Feedback of `"filename:\(#line)"` should be input to the `feedback` parameter.\
///Display the error to the user for reporting by setting `GlobalData.shared.currentCourse` to an instance of `failCourse`. They will be directed to open an Issue in the GitHub repository.
func failCourse(feedback: String? = "None") -> Course {
    return Course("Error", icon: "exclamationmark.triangle", room: feedback ?? "None", colour: "Graphite", listIcon: "exclamationmark.triangle")
}
