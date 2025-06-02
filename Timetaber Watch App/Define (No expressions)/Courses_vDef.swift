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
    
    let listName: String
    let listIcon: String
    let joke: String
    
    init(name: String, icon: String, room: String? = nil, colour: String,
         listName: String? = nil, listIcon: String? = nil, joke: String? = nil)
    {
        
        self.name = name
        self.icon = icon
        self.room = room ?? "None"
        self.colour = colour
        
        self.listName = listName ?? name
        self.listIcon = listIcon ?? (icon+".circle.fill")
        
        self.joke = joke ?? ""
    }
    
    
}




//
//  Define all courses for user's timetable
//
//  (Will later script timetable builder thing in iOS companion app to create/edit these.)
//
//  (alphabetical order)

let CheckInCourse = Course(name: "Check In", icon: "face.smiling", room: "HG1", colour: "White", listIcon: "face.smiling.inverse")

let English6 = Course(name: "English", icon: "book.closed", room: "BT6", colour: "Lemon")
let English9 = Course(name: "English", icon: "book.closed", room: "BT9", colour: "Lemon")

let HSIE = Course(name: "HSIE", icon: "archivebox", room: "BG8", colour: "Rees", listIcon: "clock.circle.fill")

let JCBCourse = Course(name: "Junior C.B.", icon: "pencil", colour: "Cherry", listName: "Concert Band")
let JSBCourse = Course(name: "Jr Stage", icon: "music.note", room: "BT1", colour: "White")

let LunchPeriod = Course(name: "Lunch", icon: "fork.knife", colour: "White", joke: "foood")

let MathsCourse = Course(name: "Maths", icon: "number", room: "FT5", colour: "Rose")
let MLPeriod = Course(name: "Music Lesson", icon: "music.note", colour: "White")
let MultimediaCourse = Course(name: "Multimedia", icon: "camera", room: "GG2", colour: "Blueberry")
let MSBCourse = Course(name: "Marching Band", icon: "flag.filled.and.flag.crossed", colour: "Cherry", listName: "Marching B.", listIcon: "flag.2.crossed.circle.fill")

let PACourseBG = Course(name: "PA Music", icon: "music.microphone", room: "BG1", colour: "Cherry")
let PACourseBT = Course(name: "PA Music", icon: "music.microphone", room: "BT1", colour: "Cherry")
let PACourseC1 = Course(name: "PA Music", icon: "music.microphone", room: "CG1", colour: "Cherry", listIcon: "music.microphone.circle.fill")

let PDHPE1 = Course(name: "PDHPE", icon: "figure.run", room: "AG1", colour: "Lime")
let PDHPE3 = Course(name: "PDHPE", icon: "figure.run", room: "AG3", colour: "Lime")
let PDHPEPrac = Course(name: "PDHPE", icon: "figure.run", room: "HALL", colour: "Lime")

let RecessPeriod = Course(name: "Recess", icon: "fork.knife", colour: "White", joke: "like lunch but short")

let ScienceCourse = Course(name: "Science", icon: "flask", room: "FT10", colour: "Ice", listIcon: "flame.circle.fill")

let TAS = Course(name: "TAS", icon: "hammer", room: "HG7", colour: "Blueberry")
let TCCourse = Course(name: "Theatre Crew", icon: "headset", colour: "Peach")

let VisualArtsCourse = Course(name: "Visual Arts", icon: "paintbrush.pointed", room: "HG5", colour: "Apricot", listName: "Art")

let yearAssembly = Course(name: "Year Assembly", icon: "person.3", colour: "White", listIcon: "person.2.circle.fill")




let noSchool = Course(
    name: "No school", icon: "clock",
    colour: "White",
    joke: storage.shared.termRunningGB ? "No term running.": ((weekdayNumber(ofDate: .now)==1 || weekdayNumber(ofDate: .now)==7) ? "Happy weekend!" :"Not yet, anyway...")
)


let promoCourse = Course( //tempoary...?
    name: "Timetaber",
    icon: "applewatch",
    room: "The Apple Watch Timetable App",
    colour: "Promo"
)


func failCourse(feedback: String? = "None") -> Course {
    return Course(name: "Error", icon: "exclamationmark.triangle", room: feedback ?? "None", colour: "White", listIcon: "exclamationmark.triangle")
}
