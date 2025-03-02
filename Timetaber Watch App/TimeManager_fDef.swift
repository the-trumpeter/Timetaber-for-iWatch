//
//  TimeManager_fDef.swift
//  Timetaber for iWatch
//  Function definition script
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

let calendar = Calendar.current
let dFormatter = DateFormatter()

let weekdayTimes: Array<Array<Int>> = [monTimes, normTimes, wedTimes, thuTimes, normTimes] //how best to handle weekends? make it only weekdays!
let weekA = [monA, tueA, wedA, thuA, friA]
let weekB = [monB, tueB, wedB, thuB, friB]




func weekday(inDate: Date) -> Int {
    return Int(calendar.component(.weekday, from: inDate))
}


func time24() -> Int {
    dFormatter.dateFormat = "HHmm" // or hh:mm for 12 h
    return Int(dFormatter.string(from: .now))!
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

    if !storage.shared.termRunningGB { return noSchool }
    
    if isWeekA {
        let timetableDay = weekA[weekDay-2]
        let re_turn = timetableDay[sessionStartTime] ?? failCourse(feedback: "re_turn TMan.125") //needs work
        return re_turn
    } else /* if weekB */ {
        let timetableDay = weekB[weekDay-2]
        let re_turn = timetableDay[sessionStartTime] ?? failCourse(feedback: "re_turn TMan.129")
        return re_turn
    }
}










func getCurrentClass(date: Date) -> Array<Course> {
    
    
    let todayWeekday = Int(weekday(inDate: date))//sunday = 1, mon = 2, etc
    print("the weekday today is \(todayWeekday)")
    
    
    var times2Day: Array<Int>
    
    if todayWeekday == 6 {
        times2Day = weekdayTimes.last!
    } else {
        times2Day = weekdayTimes[todayWeekday-1]
    }

    
    let time24Now = time24()
    
    
    
    
    if !storage.shared.termRunningGB || todayWeekday==1 || todayWeekday==7 || time24Now<times2Day.first! || time24Now>=times2Day.last!{ //if it is either holidays, sunday, monday or before school starts then noSchool - `||` means [OR]
        print("> There's no school at the moment.")
        nextCourse = noSchool
        return [noSchool]
    }
    
    

    
    let isweekA = getIfWeekIsA_FromDateAndGhost(
        originDate: storage.shared.startDateGB,
        ghostWeek: storage.shared.ghostWeekGB)
    
    
    print("Times today:",times2Day)
    
    
    
    
    
    
    
    //cycle through times til we find the two we are inbetween
    for n in 1...times2Day.count {
        
        
        let compare = times2Day[n] // time we r comparing to
        let now = time24Now // current time
        let next = if times2Day.count >= n+1 { times2Day[n+1] } else { Int(Double.infinity) }// next comparitive time; ensure we are not at end of array already
        
        
        
        if now==compare {
            
            
            let currentCourseLocal = findClassfromTimeWeekDayNifWeekIsA(
            sessionStartTime: now,
            weekDay: todayWeekday, isWeekA: isweekA
            )
            
            
            let nextCourseLocal: Course = if next != Int(Double.infinity) {
                    findClassfromTimeWeekDayNifWeekIsA(
                        sessionStartTime: next, weekDay: todayWeekday, isWeekA: isweekA
                    )
                } else { noSchool }
            
            
            
            print("The current class is \(currentCourseLocal.name)")
            
            return [currentCourseLocal, nextCourseLocal]
            
            
            
            
        } else if now>compare &&  now<next {
            
            
            let currentCourseLocal = findClassfromTimeWeekDayNifWeekIsA(
            sessionStartTime: compare,
            weekDay: todayWeekday, isWeekA: isweekA
            )
            
            
            let nextCourseLocal: Course = if next != Int(Double.infinity) {
                    findClassfromTimeWeekDayNifWeekIsA(
                        sessionStartTime: next, weekDay: todayWeekday, isWeekA: isweekA
                    )
                } else { noSchool }
            
            
            
            print("The current class is \(currentCourseLocal.name)")
            
            return [currentCourseLocal, nextCourseLocal]
            
        } // either of these if's mean its the current class
        
        
    } // for n
    
    
    print("> Exhausted all possible course options of day")
    
    let failed = failCourse(feedback: "exhaust getCur.222")
    return [failed, failed] //all class options should be exhausted, so this should not run. If it does, ERROR!!
}
