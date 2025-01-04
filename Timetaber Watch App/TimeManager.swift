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

var theDate = Date()
let calendar = Calendar.current
let dFormatter = DateFormatter()

let weekdayTimes = [monTimes, normTimes, wedTimes, thuTimes, normTimes] //how best to handle weekends? make it only weekdays!



func hour(inDate: Date) -> Int {
    return Int(calendar.component(.hour, from: inDate))
}

func minutes(inDate: Date) -> Int {
    return Int(calendar.component(.minute, from: inDate))
}




func weekday(inDate: Date) -> Int {
    return Int(calendar.component(.weekday, from: inDate))
}




func day(inDate: Date) -> Int {
    return Int(calendar.component(.day, from: inDate))
}

func month(inDate: Date) -> Int {
    return Int(calendar.component(.month, from: inDate))
}

func year(inDate: Date) -> Int {
    return Int(calendar.component(.year, from: inDate))
}




func time24() -> Int {
    dFormatter.dateFormat = "HHmm" // or hh:mm for 12 h
    return Int(dFormatter.string(from: theDate))!
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



func findClassfromTimeNGhostweek(startTime: Int, ghostWeek: Bool) {
    
}




func getCurrentClass() -> Class {
    let todayWeekday = weekday(inDate: .now)
    print(todayWeekday)
    
    if !termRunningGB || todayWeekday==1 || todayWeekday==7 { //if it is either holidays, sunday or monday then noSchool
        return noSchool
    }
    
    
    let times2Day = weekdayTimes[todayWeekday-1]
    let time24Now = time24()
    
    let isweekA = getIfWeekIsA_FromDateAndGhost(originDate: readStoredData(key: startDateKey) as! Date, ghostWeek: readStoredData(key: ghostWeekKey) as! Bool)
    
    print("timesToday:",times2Day)
    
    
    //cycle through times til we find the two we are inbetween
    for n in 1...times2Day.count {
        
        let t = times2Day[n] // time we r comparing to
        let c = time24Now // current time
        let i = times2Day[n+1] // next comparitive time
        
        if c==t {  } //either of these mean its the current class
        else if c>t &&  c<i { }
            
    }
    
    
    return noSchool
}
