//
//  Courses.swift
//  Timetaber for iWatch
//  Variable definition script
//
//  Created by Gill Palmer on 3/11/2024.
//

//  Define Course (subject, class etc) structure

import SwiftUI
import Foundation

struct Course {
    let name: String
    let icon: String
    let room: String
    let colour: String
}




//
//  Define all courses for user's timetable
//
//  (Will later script timetable builder thing in iOS companion app to create/edit these.)
//

let CheckInClass = Course(name: "Check In", icon: "face.smiling", room: "HG1", colour: "White")

let MathsClass = Course(name: "Maths", icon: "number", room: "FT5", colour: "Rose")
let English9 = Course(name: "English", icon: "book.closed", room: "BT9", colour: "Lemon")
let English6 = Course(name: "English", icon: "book.closed", room: "BT6", colour: "Lemon")
let ScienceClass = Course(name: "Science", icon: "flask", room: "FT10", colour: "Ice")

let HSIE = Course(name: "HSIE", icon: "archivebox", room: "BG8", colour: "Rees")


let PDHPE1 = Course(name: "PDHPE", icon: "figure.run", room: "AG1", colour: "Lime")
let PDHPE3 = Course(name: "PDHPE", icon: "figure.run", room: "AG3", colour: "Lime")
let TAS = Course(name: "TAS", icon: "hammer", room: "HG7", colour: "Blueberry")

let PAClassBT = Course(name: "PA Music", icon: "music.micophone", room: "BT1", colour: "Cherry")
let PAClassBG = Course(name: "PA Music", icon: "music.micophone", room: "BG1", colour: "Cherry")
let PAClassC1 = Course(name: "PA Music", icon: "music.micophone", room: "CG1", colour: "Cherry")
//let PAClassC2 = Course(name: "PA Music", icon: "music.micophone", room: "CG2", colour: "Cherry")

let MSBClass = Course(name: "Marching Band", icon: "flag.filled.and.flag.crossed", room: "None", colour: "Cherry")
let JCBClass = Course(name: "Junior C.B.", icon: "pencil", room: "None", colour: "Cherry")
//let SCBClass = Course(name: "Senior C.B.", icon: "pencil", room: "None", colour: "Cherry")
let TCClass = Course(name: "Theatre Crew", icon: "headset", room: "None", colour: "Peach")

let MultimediaClass = Course(name: "Multimedia", icon: "camera", room: "GG2", colour: "Blueberry")
let VisualArtsClass = Course(name: "Visual Arts", icon: "paintbrush.pointed", room: "HG5", colour: "Apricot")

let LunchClass = Course(name: "Lunch", icon: "fork.knife", room: "None", colour: "White")
let RecessClass = Course(name: "Recess", icon: "fork.knife", room: "None", colour: "White")

let noSchool = Course(name: "No classes", icon: "clock", room: "Sit back & relax!", colour: "White")
let yearAssemblyClass = Course(name: "Year Assembly", icon: "person.3", room: "None", colour: "White")

let JSBClass = Course(name: "Jr Stage", icon: "music.note", room: "BT1", colour: "White")

let MLClass = Course(name: "Music Lesson", icon: "music.note", room: "None", colour: "White")


let failCourse = Course(name: "Error", icon: "exclamationmark.triangle", room: "None", colour: "White")
