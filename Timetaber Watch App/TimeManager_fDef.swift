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

var calendar = Calendar.current
let dFormatter = DateFormatter()




//MARK: Weekday no; time24; odd
func weekdayNumber(_ ofDate: Date) -> Int {
    return Int(calendar.component(.weekday, from: ofDate)) // Sun=1, Sat=7
}


func time24() -> Int {
    dFormatter.dateFormat = "HHmm" // or hh:mm for 12 hr time
    return Int(dFormatter.string(from: .now))!
}



func odd(_ number: Int) -> Bool {
    if number % 2 == 0 {
        return false
    } else {
        return true
    }
}

//MARK: get if Week is A
func getIfWeekIsA_FromDateAndGhost(originDate: Date, ghostWeek: Bool) -> Bool {
    //week A and B alternate each week. he input date is always a week a unless ghost is true.
    
    let originWeek = calendar.component(.weekOfYear, from: originDate)
    let currentWeek = calendar.component(.weekOfYear, from: Date())
    
    
    
    if odd(originWeek) == odd(currentWeek) {
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


//MARK: Get timetabled day
func getTimetableDay(isWeekA: Bool, weekDay: Int) -> Dictionary<Int, Course> {
    if isWeekA {
        let timetableDay = wkA[weekDay-2]
        return timetableDay
    } else {
        let timetableDay = wkB[weekDay-2]
        return timetableDay
    }
    
}



//MARK: Class from Time & Weekday & if Week is A
func findClassfromTimeWeekDayNifWeekIsA(sessionStartTime: Int, weekDay: Int, isWeekA: Bool) -> Course {

    if !storage.shared.termRunningGB { return noSchool(.noTerm) } //catch if term not running
    
    if isWeekA {
        let timetableDay = wkA[weekDay-2]
        let re_turn = timetableDay[sessionStartTime] ?? failCourse(feedback: "TimeManager:\(#line)")
        return re_turn
    } else { //is weekB
        let timetableDay = wkB[weekDay-2]
        let re_turn = timetableDay[sessionStartTime] ?? failCourse(feedback: "TimeManager:\(#line)")
        return re_turn
    }
}






//MARK: - Timer
func dateFrom24hrInt(_ time24: Int) -> Date {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    components.timeZone = TimeZone.current
    components.hour = time24/100
    components.minute = time24%100
    components.second = 0
    print("""
            TimeManager_fDef.swift:\(#line) @ dateFrom24hrInt
                Composing date \(String(describing: components.hour!)):\(String(describing: components.minute!))
          """)
    guard let date = calendar.date(from: components) else {
        
        GlobalData.shared.currentCourse = failCourse(feedback: "TimeManager:\(#line)")
        NSLog("%@:%d @ dateFrom24hrInt | %@ | 🚨🚨 Catastrophic Error:\n    Composing date %@:%@.\n    DateComponents: %@", #file, #line, Date.now.formatted(date: .numeric, time: .complete), String(describing: components.hour), String(describing: components.minute), String(describing: components)
              )
        
        return Date.now
    }
    return date
}
    


var UpdateTimer: Timer?

func setCourseChangeAlarm(for time: Int) {
    UpdateTimer?.invalidate()
    
    let date = dateFrom24hrInt(time)
    UpdateTimer = Timer(fire: date, interval: 0, repeats: false) { timer in
        NSLog("Update timer fired; time is %@", Date.now.formatted(date: .numeric, time: .complete))
        reload()
    }
    RunLoop.main.add(UpdateTimer!, forMode: .default)
    NSLog("TimeManager_fDef.swift:%d - Succesfully set course change alarm for %@", #line, date.formatted(date: .numeric, time: .complete))
}






//MARK: - getCurrentClass
func getCurrentClass(date: Date) -> Array<Course> {
    
    //MARK: Init and Ghost Week stuff
    let todayWeekday = Int(weekdayNumber(date))//sunday = 1, mon = 2, etc
    print("TimeManager_fDef.swift:\(#line) - the weekday today is \(todayWeekday)")
    
    

    let time24Now = time24()
    
    
    
    if !storage.shared.termRunningGB { //if it is either holidays, sunday, monday or before school starts then noSchool - `||` means [OR]
        NSLog("> TimeManager_fDef.swift:%d - There's no school at the moment. ", #line)
        return [noSchool(.noTerm), noSchool(.noTerm)]
    } else if todayWeekday==1 || todayWeekday==7 {
        NSLog("> TimeManager_fDef.swift:%d - There's no school at the moment. ", #line)
        return [noSchool(.weekend), noSchool(.weekend)]
    }
    
    let isweekA = getIfWeekIsA_FromDateAndGhost(
        originDate: storage.shared.startDateGB,
        ghostWeek: storage.shared.ghostWeekGB)
    
    let day = getTimetableDay(
        isWeekA: isweekA,
        weekDay: weekdayNumber(date)
    )
    
    let tomorrowDay: [Int: Course]? = if isweekA && todayWeekday != 6 { wkA[todayWeekday-1] } else if todayWeekday != 6 { wkB[todayWeekday-1] } else { nil }
    
    let times2Day = Array(day.keys)
    let times2Morrow: Array<Int>?
    
    if let keys = tomorrowDay?.keys {
        times2Morrow = Array(keys)
    } else {
        times2Morrow = nil
    }
    

    if time24Now<times2Day.first! { // before first entry in day (before school)
        
        NSLog("> TimeManager_fDef.swift:%d - There's no school at the moment. ", #line)
        setCourseChangeAlarm(for: times2Day.first!)
        let nosc = noSchool(.beforeClass(startTime: times2Day.first!))
        return [nosc, day[times2Day.first!]!]
        
    } else if time24Now>=times2Day.last! {
        
        NSLog("> TimeManager_fDef.swift:%d - There's no school at the moment. ", #line)
        // try setCourseChangeAlarm(for: times2Morrow!.first!)
        // ^^ setCourseChangeAlarm(:) is not set up to times in future days
        let nosc = noSchool(.afterClass)
        return [nosc, nosc]
    }
    
    
    
    //MARK: Cycle through times
    //cycle through times til we find the two we are inbetween
    for n in 0...times2Day.count {
        
        /// The comparative entry from `times2Day` that is being analysed in comparison to `now`. Used in the `for` loop.
        let compare = times2Day[n]
        /// the integer 24hr time of the date `getCurrentClass` was called. Used in the `for` loop.
        let now = time24Now // current time
        print("TimeManager_fDef.swift:\(#line) - Times today count is \(times2Day.count) and n+1 is \(n+1).")
        /// The next comparitive time in `times2Day`; a ternary operator is in place to assign a value of `Int.max` in the case that the table has no further times.
        let next = times2Day.count >= (n+1) ? times2Day[n+1]: Int.max
        
        
        
        if now==compare {
            
            print("TimeManager_fDef.swift:\(#line) - now\(now)==compare\(compare)")
            
            let currentCourseLocal = findClassfromTimeWeekDayNifWeekIsA(
            sessionStartTime: now,
            weekDay: todayWeekday, isWeekA: isweekA
            )
            
            
            let nextCourseLocal: Course = if next != Int.max {
                    findClassfromTimeWeekDayNifWeekIsA(
                        sessionStartTime: next, weekDay: todayWeekday, isWeekA: isweekA
                    )
            } else { noSchool(.afterClass) }
            
            
            NSLog("> The current class is %@\n> Next class is %@, due at %@", currentCourseLocal.name, nextCourseLocal.name, time24toNormal(next))
            setCourseChangeAlarm(for: next)
            return [currentCourseLocal, nextCourseLocal]
            
        } else if now>compare &&  now<next {
            
            print("TimeManager_fDef.swift:\(#line) - now\(now)>compare\(compare) && now\(now)<next\(next)")
            let currentCourseLocal = findClassfromTimeWeekDayNifWeekIsA(
            sessionStartTime: compare,
            weekDay: todayWeekday, isWeekA: isweekA
            )
            
            
            let nextCourseLocal: Course = if next != Int.max {
                    findClassfromTimeWeekDayNifWeekIsA(
                        sessionStartTime: next, weekDay: todayWeekday, isWeekA: isweekA
                    )
            } else { noSchool(.afterClass) }
            
            
            
            NSLog("> The current class is %@\n> Next class is %@, due at %@", currentCourseLocal.name, nextCourseLocal.name, time24toNormal(next))
            setCourseChangeAlarm(for: next)
            return [currentCourseLocal, nextCourseLocal]
            
        } // either of these `if`s mean `now` is the current class and `next` is next
        
        
    } // for n
    
    // MARK: Catch
    NSLog("%@:%d @ getCurrentClass | %@ |🚨🚨 Catastrophic Error:\n    Exhausted all possible options for day.\n    time: %@, times: %@\n", #file, #line, Date.now.formatted(date: .numeric, time: .complete), String(describing: time24Now), String(describing: times2Day))
    
    let failed = failCourse(feedback: "TimeManager:\(#line)")
    return [failed, failed] //all class options should be exhausted, so this should not run. If it does, ERROR!!
}
