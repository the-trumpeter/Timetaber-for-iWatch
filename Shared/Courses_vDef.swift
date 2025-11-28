//
//  Courses.swift
//  Timetaber for iWatch
//  Variable definition script
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI
import Foundation


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
