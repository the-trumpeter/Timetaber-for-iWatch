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
let CheckInCourse = DisplayCourse("Check In", icon: "face.smiling", room: "HG1", colour: "Graphite", listIcon: "face.smiling.inverse")

let English6 = DisplayCourse("English", icon: "book.closed", room: "BT6", colour: "Lemon")
let English9 = DisplayCourse("English", icon: "book.closed", room: "BT9", colour: "Lemon")

let GreaseOrchCourse = DisplayCourse("Orchestra", icon: "theatermasks", colour: "Cherry")

let HSIECourse = DisplayCourse("HSIE", icon: "archivebox", room: "BG8", colour: "Rees1")

let JCBCourse = DisplayCourse("Junior C.B.", icon: "music.note", colour: "Cherry")
let JSBCourse = DisplayCourse("Jr Stage", icon: "music.note", room: "BT1", colour: "Graphite", listName: "Junior S.B.")


let LunchPeriod = DisplayCourse("Lunch", icon: "fork.knife", colour: "Graphite", joke: "foood")

let MathsCourse = DisplayCourse("Maths", icon: "number", room: "FT5", colour: "Rose")
let MLPeriod = DisplayCourse("Music Lesson", icon: "music.note", colour: "Graphite")
let MultimediaCourse = DisplayCourse("Multimedia", icon: "movieclapper", room: "GG2", colour: "Blueberry")
let MSBCourse = DisplayCourse("Marching Band", icon: "flag.filled.and.flag.crossed", colour: "Cherry", listName: "Marching Bd.", listIcon: "flag.2.crossed.circle.fill")

let PACourseBG = DisplayCourse("PA Music", icon: "music.note", room: "BG1", colour: "Cherry")
let PACourseBT = DisplayCourse("PA Music", icon: "music.note", room: "BT1", colour: "Cherry")
let PACourseC1 = DisplayCourse("PA Music", icon: "music.note", room: "CG1", colour: "Cherry")

let PDHPE1 = DisplayCourse("PDHPE", icon: "figure.run", room: "AG1", colour: "Lime")
let PDHPE3 = DisplayCourse("PDHPE", icon: "figure.run", room: "AG3", colour: "Lime")
let PDHPEPrac = DisplayCourse("PDHPE", icon: "figure.run", room: "HALL", colour: "Lime")

let RecessPeriod = DisplayCourse("Recess", icon: "fork.knife", colour: "Graphite", joke: "like lunch but short")

let SCBCourse = DisplayCourse("Senior C.B.", icon: "music.note", colour: "Cherry")
let ScienceCourse = DisplayCourse("Science", icon: "flask", room: "FT10", colour: "Ice", listIcon: "flame.circle.fill")
let SSBCourse = DisplayCourse("Stage Band", icon: "music.note", colour: "cherry", listName: "Senior S.B.")

let TAS = DisplayCourse("TAS", icon: "hammer", room: "HG7", colour: "Blueberry")
let TCCourse = DisplayCourse("Theatre Crew", icon: "headset", colour: "Peach")

let VisualArtsCourse = DisplayCourse("Visual Arts", icon: "paintbrush.pointed", room: "HG5", colour: "Apricot", listName: "Art")

let yearAssembly = DisplayCourse("Year Assembly", icon: "person.3", colour: "Graphite", listName: "Assembly", listIcon: "person.2.circle.fill")
