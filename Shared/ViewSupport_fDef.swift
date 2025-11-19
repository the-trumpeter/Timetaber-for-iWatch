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


typealias Colour = Color

func roomOrBlank(_ course: Course) -> String? {
	guard let room = course.room else {
		guard let joke = course.joke else {
			return nil
		}
		return joke
	}
	return room
}

func getNextString(_ course: Course) -> String {
    if course.name == "Error" || LocalData.shared.currentCourse.name=="Error" {
        return "bit.ly/ttberError1"
    }
    if course.name == "No school" {
        return ""
	} else if let room = course.room {
        return course.name+" - "+room
	}
    return course.name

}


func nextPrefix(_ course: Course) -> String{
    if course.name == "Error" {
        return "Report this:"
    }
    if course.name == "No school" {
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
