//
//  Classes.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

struct Class {
    let id: Int
    let name: String
    let icon: String
    let room: String
    let colour: String
}


let CheckInClass = Class(id: 1,name: "Check In", icon: "face.smiling", room: "None", colour: "White")

let MathsClass = Class(id: 2, name: "Maths", icon: "number", room: "FT3", colour: "Rose")
let EnglishClass = Class(id: 3, name: "English", icon: "book.closed", room: "BT4", colour: "Lemon")
let LanguageClass = Class(id: 4, name: "French", icon: "bubble.left", room: "FT8", colour: "Apricot")
let ScienceClass = Class(id: 26, name: "Science", icon: "flask", room: "FT11", colour: "Ice")
let Science2Class = Class(id: 27, name: "Science", icon: "flask", room: "FG2", colour: "Ice")

let HSIERees = Class(id: 5, name: "HSIE", icon: "archivebox", room: "BG4", colour: "Rees")
let PDHPEPrac = Class(id:6 , name: "PDHPE", icon: "figure.run", room: "HALL", colour: "Lime")

let HSIEAnder = Class(id: 8, name: "HSIE", icon: "archivebox", room: "BG10", colour: "Rees")
let PDHPETheo = Class(id: 9, name: "PDHPE", icon: "figure.run", room: "THEORY", colour: "Lime")
let TAS_G = Class(id: 10,name: "TAS", icon: "hammer", room: "GG3", colour: "Blueberry")
let TAS_H = Class(id: 7, name: "TAS", icon: "hammer", room: "HG6", colour: "Blueberry")

let PAClassBT = Class(id: 11, name: "PA Music", icon: "music.micophone", room: "BT1", colour: "Cherry")
let PAClassBG = Class(id: 12, name: "PA Music", icon: "music.micophone", room: "BG1", colour: "Cherry")
let PAClassC1 = Class(id: 13, name: "PA Music", icon: "music.micophone", room: "CG1", colour: "Cherry")
let PAClassC2 = Class(id: 14, name: "PA Music", icon: "music.micophone", room: "CG2", colour: "Cherry")

let MusicClassBG = Class(id: 15, name: "Music", icon: "music.micophone", room: "BG1", colour: "Cherry")
let MusicClassBT = Class(id: 16, name: "Music", icon: "music.micophone", room: "BT1", colour: "Cherry")
let MusicClassC1 = Class(id: 17, name: "Music", icon: "music.micophone", room: "CG1", colour: "Cherry")
let MusicClassC2 = Class(id: 18, name: "Music", icon: "music.micophone", room: "CG2", colour: "Cherry")

let MSBClass = Class(id: 19, name: "Marching Band", icon: "flag.filled.and.flag.crossed", room: "None", colour: "Cherry")
let CBClass = Class(id: 20, name: "Concert Band", icon: "pencil", room: "None", colour: "Cherry")
let TCClass = Class(id: 21, name: "Theatre Crew", icon: "headset", room: "None", colour: "Peach")

//let MultimediaClass = Class(id: 22, name: "Multimedia", icon: "camera", room: "TBD", colour: "Peach")

let LunchClass = Class(id: 23, name: "Lunch", icon: "fork.knife", room: "None", colour: "White")
let RecessClass = Class(id: 24, name: "Recess", icon: "fork.knife", room: "None", colour: "White")

let noSchool = Class(id: 25, name: "No classes", icon: "clock", room: "Sit back & relax!", colour: "White")
let yearAssemblyClass = Class(id: 28, name: "Year Assembly", icon: "person.3", room: "None", colour: "White")

let JSBClass = Class(id: 29, name: "Jr Stage", icon: "music.note", room: "BT1", colour: "White")

let MLClass = Class(id: 30, name: "Music Lesson", icon: "music.note", room: "None", colour: "White")


let allClasses = [CheckInClass, MathsClass, EnglishClass, LanguageClass, ScienceClass, Science2Class, HSIERees, PDHPEPrac, HSIEAnder, PDHPETheo, TAS_G, TAS_H, PAClassBT, PAClassBG, PAClassC1, PAClassC2, MusicClassBG, MusicClassBT, MusicClassC1, MusicClassC2, MSBClass, CBClass, TCClass, LunchClass, RecessClass, yearAssemblyClass, JSBClass, MLClass]//noSchool excluded
