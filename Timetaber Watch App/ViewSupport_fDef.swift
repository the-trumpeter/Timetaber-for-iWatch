//
//  ViewSuppport.swift
//  Timetaber Watch App
//  Function definition script
//
//  Created by Gill Palmer on 17/12/2024.
//
//  Supporting functions etc. for Views
//

import Foundation
import SwiftUI

func getNextString(course: Course) -> String{
    if course.room=="None" || course.name == noSchool.name || course.name == "Error" {
        return ""
    } else {
        
        return course.name+" - "+course.room
    }
}
func roomOrBlank(course: Course) -> String{
    if course.room=="None" {
        if course.joke != "" {
            return course.joke
        }
        return ""
    } else {
        return course.room
    }
}
func nextPrefix(course: Course) -> String{
    if course.name==noSchool.name || course.name=="Error"{
        return ""
    } else {
        return "Next up:"
    }
}

func time24toNormal(time24: Int) -> String {
    var stringTime = String(time24)
    if stringTime.count == 3 {
        stringTime.insert(":", at: stringTime.index(stringTime.startIndex, offsetBy: 1))
        return stringTime
    } else if stringTime.count == 4 {
        stringTime.insert(":", at: stringTime.index(stringTime.startIndex, offsetBy: 2))
        return stringTime
    }
    return stringTime
}

func validateIcon(_ string: String) -> Image {
    let customSymbols = [
        "paintbrush.pointed.circle.fill": Image(.paintbrushPointedCircleFill),
        "music.note.circle.fill": Image(.musicNoteCircleFill)
    ]
    return customSymbols[string] ?? Image(systemName: string)
}
