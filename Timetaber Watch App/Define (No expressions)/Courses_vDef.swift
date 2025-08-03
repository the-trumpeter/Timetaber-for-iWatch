//
//  Courses.swift
//  Timetaber for iWatch
//  Variable definition script
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI
import Foundation





/*
Define all courses for user's timetable
 
(Will later script timetable builder thing in iOS companion app to create/edit these.)
(alphabetical order)


let CheckInCourse = Course(name: "Check In", icon: "face.smiling", room: "HG1", colour: "White", listIcon: "face.smiling.inverse")

let English6 = Course(name: "English", icon: "book.closed", room: "BT6", colour: "Lemon")
let English9 = Course(name: "English", icon: "book.closed", room: "BT9", colour: "Lemon")

let GreaseOrchCourse = Course(name: "Orchestra", icon: "theatermasks", colour: "Cherry")

let HSIECourse = Course(name: "HSIE", icon: "archivebox", room: "BG8", colour: "Rees")

let JCBCourse = Course(name: "Junior C.B.", icon: "music.note", colour: "Cherry")
let JSBCourse = Course(name: "Jr Stage", icon: "music.note", room: "BT1", colour: "White", listName: "Junior S.B.")

let LunchPeriod = Course(name: "Lunch", icon: "fork.knife", colour: "White", joke: "foood")

let MathsCourse = Course(name: "Maths", icon: "number", room: "FT5", colour: "Rose")
let MLPeriod = Course(name: "Music Lesson", icon: "music.note", colour: "White")
let MultimediaCourse = Course(name: "Multimedia", icon: "movieclapper", room: "GG2", colour: "Blueberry")
let MSBCourse = Course(name: "Marching Band", icon: "flag.filled.and.flag.crossed", colour: "Cherry", listName: "Marching Bd.", listIcon: "flag.2.crossed.circle.fill")

let PACourseBG = Course(name: "PA Music", icon: "music.note", room: "BG1", colour: "Cherry")
let PACourseBT = Course(name: "PA Music", icon: "music.note", room: "BT1", colour: "Cherry")
let PACourseC1 = Course(name: "PA Music", icon: "music.note", room: "CG1", colour: "Cherry")

let PDHPE1 = Course(name: "PDHPE", icon: "figure.run", room: "PRAC", colour: "Lime")
let PDHPE3 = Course(name: "PDHPE", icon: "figure.run", room: "THEORY", colour: "Lime")
let PDHPEPrac = Course(name: "PDHPE", icon: "figure.run", room: "HALL", colour: "Lime")

let RecessPeriod = Course(name: "Recess", icon: "fork.knife", colour: "White", joke: "like lunch but short")

let SCBCourse = Course(name: "Senior C.B.", icon: "music.note", colour: "Cherry")
let ScienceCourse = Course(name: "Science", icon: "flask", room: "FT10", colour: "Ice", listIcon: "flame.circle.fill")
let SSBCourse = Course(name: "Stage Band", icon: "music.note", colour: "Cherry", listName: "Senior S.B.")

let TAS = Course(name: "TAS", icon: "hammer", room: "FT4", colour: "Blueberry")
let TCCourse = Course(name: "Theatre Crew", icon: "headset", colour: "Peach")

let VisualArtsCourse = Course(name: "Visual Arts", icon: "paintbrush.pointed", room: "HG5", colour: "Apricot", listName: "Art")

let yearAssembly = Course(name: "Year Assembly", icon: "person.3", colour: "White", listName: "Assembly", listIcon: "person.2.circle.fill")
*/


/// Various situations in which there is no school.\
/// See `noSchool`.
enum TimeCase {
    case weekend
    case noTerm
    case beforeClass(startTime: Int)
    case afterClass
}
/// Returns a `Course` representing the absence of school; with a `joke` relevant to the current date/time of interaction, obtained through the `key` parameter.\
/// If `key` is not initialised, the `joke` will default to `"Not yet, anyway..."`.
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

    return Course(name: "No school", icon: "clock", room: nil, colour: "White", listName: nil, listIcon: nil, joke: joke)
}


///Method to handle informal errors, fails and exhaustions; so, bugs. Feedback of `"filename:\(#line)"` should be input to the `feedback` parameter.\
///Display the error to the user for reporting by setting `GlobalData.shared.currentCourse` to an instance of `failCourse`. They will be directed to open an Issue in the GitHub repository.
func failCourse(feedback: String? = "None") -> Course {
    return Course(name: "Error", icon: "exclamationmark.triangle", room: feedback ?? "None", colour: "White", listName: nil, listIcon: "exclamationmark.triangle", joke: nil)
}
