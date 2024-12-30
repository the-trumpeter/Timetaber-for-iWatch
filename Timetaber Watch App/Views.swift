//
//  Views.swift
//  Timetaber
//
//  Created by Gill Palmer on 17/12/2024.
//

import Foundation

func getNextString() -> String{
    if nextClass.room=="None" {
        return nextClass.name
        
    } else if nextClass.name=="No classes"{
        return ""
    } else {
        
        return nextClass.name+" - "+nextClass.room
    }
}
func roomOrNil() -> String{
    if currentClass.room=="None" {
        return ""
    } else {
        return currentClass.room
    }
}
func isNextNothing() -> String{
    if nextClass.name=="No classes"{
        return ""
    } else {
        return "Next up:"
    }
}
func isPeriodNothing() -> String{
    if currentClass.name=="No classes"{
        return ""
    } else {
        return "Period "+String(period)
    }
}
