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


func roomOrBlank(_ course: Course) -> String{
    if course.room=="None" {
        if course.joke == "None" {
            return ""
        }
        return course.joke
    } else {
        return course.room
    }
}

func getNextString(_ course: Course) -> String {
    if GlobalData.shared.currentCourse.name=="Error" {
        return "bit.ly/ttberError1"
    }
    if course.name == noSchool.name || course.name == "Error" || GlobalData.shared.currentCourse.name=="Error" {
        return ""
    } else if course.room != "None" {
            return course.name+" - "+course.room
        }
    return course.name

}


func nextPrefix(_ course: Course) -> String{
    if GlobalData.shared.currentCourse.name=="Error" {
        return "Report this:"
    }
    if course.name == noSchool.name || course.name == "Error" {
        return ""
    }
    return "Next up:"
}

func time24toNormal(_ time24: Int) -> String {
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
