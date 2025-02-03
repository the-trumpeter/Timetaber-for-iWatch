//
//  Views.swift
//  Timetaber
//
//  Created by Gill Palmer on 17/12/2024.
//
//  Supporting functions etc. for Views
//
import Foundation

func getNextString() -> String{
    if nextCourse.room=="None" {
        return nextCourse.name
        
    } else if nextCourse.name=="No classes" || nextCourse.name == "Error" {
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
    if nextCourse.name=="No classes" || nextCourse.name=="Error"{
        return ""
    } else {
        return "Next up:"
    }
}
