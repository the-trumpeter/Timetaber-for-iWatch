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
let weekA = [monA, tueA, wedA, thuA, friA]
let weekB = [monB, tueB, wedB, thuB, friB]



enum ClassCalculationError: Error {
    case exhaustedAllPotentialTimes(startDate: Date, ghostWeek: Bool)
    case variableFailed
    case somethingWasMissingExternally
    case error
}



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
    } else { if !ghostWeek {
            return false
        } else {
            return true
        }
    }

}



func findClassfromTimeWeekDayNifWeekIsA(sessionStartTime: Int, weekDay: Int, isWeekA: Bool) -> Course {
    let workingWeekDay = weekDay-1
    if !termRunningGB { return noSchool }
    
    if isWeekA {
        let timetableDay = weekA[workingWeekDay]
        return timetableDay[sessionStartTime]!
    } else /* if weekB */ {
        let timetableDay = weekB[workingWeekDay]
        return timetableDay[sessionStartTime]!
    }
}




func getCurrentClass(date: Date) -> Course {
    
    let todayWeekday = weekday(inDate: date)
    print("the weekday today is \(todayWeekday)")
    
    let times2Day = weekdayTimes[todayWeekday-1]
    let time24Now = time24()
    
    if !termRunningGB || todayWeekday==1 || todayWeekday==7 || time24Now<times2Day.first! { //if it is either holidays, sunday, monday or before school starts then noSchool - '||' means [OR]
        print("> There's no school at the moment.")
        return noSchool
    }
    
    

    
    let isweekA = getIfWeekIsA_FromDateAndGhost(
        originDate: readStoredData(key: startDateKey) as! Date,
        ghostWeek: readStoredData(key: ghostWeekKey) as! Bool)
    
    
    print("Times today:",times2Day)
    
    
    //cycle through times til we find the two we are inbetween
    for n in 1...times2Day.count {
        
        let t = times2Day[n] // time we r comparing to
        let c = time24Now // current time
        let i = if times2Day.count >= n+1 { times2Day[n+1] } else { Int(Double.infinity) }// next comparitive time; ensure we are not at end of array already
        
        if c==t {
            
            let currentClass = findClassfromTimeWeekDayNifWeekIsA(
            sessionStartTime: c,
            weekDay: todayWeekday, isWeekA: isweekA
            )
            
            print("The current class is \(currentClass)")
            return currentClass
            
            
        } else if c>t &&  c<i {
            
            let currentClass = findClassfromTimeWeekDayNifWeekIsA(
            sessionStartTime: c,
            weekDay: todayWeekday, isWeekA: isweekA
            )
            
            print("The current class is \(currentClass)")
            return currentClass
            
        } // if | either of these mean its the current class
            
    } // for n
    
    return failCourse //all class options should be exhausted, so this should not run. If it does, ERROR!!
    
}
