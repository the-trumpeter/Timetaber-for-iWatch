//
//  Views.swift
//  Timetaber
//
//  Created by Gill Palmer on 17/12/2024.
//

import Foundation

func getNextString() -> String{
    if nextCourse.room=="None" {
        return nextCourse.name
        
    } else if nextCourse.name=="No classes"{
        return ""
    } else {
        
        return nextCourse.name+" - "+nextCourse.room
    }
}
func roomOrNil() -> String{
    if currentCourse.room=="None" {
        return ""
    } else {
        return currentCourse.room
    }
}
func isNextNothing() -> String{
    if nextCourse.name=="No classes"{
        return ""
    } else {
        return "Next up:"
    }
}
func isPeriodNothing() -> String{
    if currentCourse.name=="No classes"{
        return ""
    } else {
        return "Period "+String(period)
    }
}
