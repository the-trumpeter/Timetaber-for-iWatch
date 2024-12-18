//
//  TimeManager.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 6/11/2024.
//

//  Notes:
//
//  Teachers try to keep week A on odd weeks, week B on even ones.
//  Week A is the start of each term
//  If teachers go back a week before students, it may be considered 'Week 0' and becomes Week A, causing week 1 to be week B
//

import Foundation

let dcs = DateComponents()
var theDate = Date()
let calendar = Calendar.current
let dFormatter = DateFormatter()


func hour(inDate: Date) -> String {
    return String(calendar.component(.hour, from: inDate))
}

func minutes(inDate: Date) -> String {
    return String(calendar.component(.minute, from: inDate))
}

func weekday(inDate: Date) -> String {
    return String(calendar.component(.weekday, from: inDate))
}

func day(inDate: Date) -> String {
    return String(calendar.component(.day, from: inDate))
}

func month(inDate: Date) -> String {
    return String(calendar.component(.month, from: inDate))
}

func year(inDate: Date) -> String {
    return String(calendar.component(.year, from: inDate))
}

func odd(number: Int) -> Bool {
    if number % 2 == 0 {
        return false
    } else {
        return true
    }
}


func getIfWeekIsA_FromDateAndGhost(originDate: Date, ghostWeek: Bool) -> Bool {
    //week A and B alternate each week. he input date is always a week a unless ghost is true.
    
    let originWeek = calendar.component(.weekOfYear, from: originDate)
    let currentWeek = calendar.component(.weekOfYear, from: Date())
    
    if odd(number: originWeek) == odd(number: currentWeek) {
        //they match, so the numbers must be same
        if !ghostWeek {
            return true
        } else {
            return false
        }
    } else {
        if !ghostWeek {
            return false
        } else {
            return true
        }
    }

}
