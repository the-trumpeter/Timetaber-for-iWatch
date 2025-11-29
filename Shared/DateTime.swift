//
//  TimeManager.swift
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

let weekA = [monA, tueA, wedA, thuA, friA]
let weekB = [monB, tueB, wedB, thuB, friB]





/*
//MARK: Class from Time & Weekday & if Week is A
func findClassfromTimeWeekDayNifWeekIsA(sessionStartTime: Int, weekDay: Int, isWeekA: Bool) -> Course {

    if !Storage.shared.termRunningGB { return noSchool(.noTerm) } //catch if term not running
    
    if isWeekA {
        let timetableDay = weekA[weekDay-2]
        let re_turn = timetableDay[sessionStartTime] ?? failCourse(feedback: "TimeManager:\(#line)")
        return re_turn
    } else { //is weekB
        let timetableDay = weekB[weekDay-2]
        let re_turn = timetableDay[sessionStartTime] ?? failCourse(feedback: "TimeManager:\(#line)")
        return re_turn
    }
}
 */

//MARK: - Timer
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






//MARK: - OLD getCurrentClass
/*
func getCurrentClass(date: Date) -> Array<Course> {
    
    //MARK: Init and Ghost Week stuff
    let todayWeekday = Int(weekdayNumber(date))//sunday = 1, mon = 2, etc
    print("TimeManager_fDef.swift:\(#line) - the weekday today is \(todayWeekday)")
    
    //func sK(_ dict: [Int: Course]) -> [Int] { Array(dict.keys).sorted(by:  <) } // sK for sortKeys
    ///returns `d.keys.sorted()`
    func sK(_ d: [Int: Course]) -> [Int] { d.keys.sorted() }
    let weekdayTimes: Array<Array<Int>> = [ sK(monA), sK(tueA), sK(wedA), sK(thuA), sK(friA) ]

    var times2Day: Array<Int>

    let time24Now = time24()

    //let times2Morrow: Array<Int>? = if todayWeekday<6 { weekdayTimes[todayWeekday-1] } else { nil }
    
    
    if !Storage.shared.termRunningGB { //if it is either holidays, sunday, monday or before school starts then noSchool - `||` means [OR]
        NSLog("> There's no school at the moment. [noTerm]")
        return [noSchool(.noTerm), noSchool(.noTerm)]
    }
    
    
    if todayWeekday==1 || todayWeekday==7 {
        NSLog("> There's no school at the moment. [weekend]")
        return [noSchool(.weekend), noSchool(.weekend)]
    }
    
    
    times2Day = weekdayTimes[todayWeekday-2]
    
    let isweekA = getIfWeekIsA_FromDateAndGhost(
        originDate: Storage.shared.startDateGB,
        ghostWeek: Storage.shared.ghostWeekGB)
    
    if time24Now<times2Day.first! { // before first course/period/time
        
        NSLog("> There's no school at the moment. [beforeClass]")
        setCourseChangeAlarm(for: times2Day.first!)
        return [noSchool(.beforeClass(startTime: times2Day.first!)),
                findClassfromTimeWeekDayNifWeekIsA(
                    sessionStartTime: times2Day.first!,
                    weekDay: todayWeekday,
                    isWeekA: isweekA)]
        
    } else if time24Now>=times2Day.last! { // after last course/period/time
        
        NSLog("> There's no school at the moment. [afterClass]")
        //try setCourseChangeAlarm(for: times2Morrow!.first!) // TODO: setCourseChangeAlarm not configured for future days
        return [noSchool(.afterClass), noSchool(.afterClass)]
    }
    
    //MARK: Cycle through times
    //cycle through times til we find the two we are inbetween
    for n in 0...times2Day.count {
        
        
        let compare = times2Day[n] // time we r comparing to
        let now = time24Now // current time
        print("TimeManager_fDef.swift:\(#line) - Times today count is \(times2Day.count) and n+1 is \(n+1).")
        
        let next = times2Day.count >= (n+1) ? times2Day[n+1]: Int.max // next comparitive time; ensure we are not at end of array already
        
        
        
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
    log()
    
    let failed = failCourse(feedback: "TimeManager:\(#line)")
    return [failed, failed] //all class options should be exhausted, so this should not run. If it does, ERROR!!
}

*/




//MARK: - New


//MARK: Temp storage ping
func storagePing() -> Storage {
	//if need to update values across watch/phone, do so here
	return Storage.shared
}


//MARK: Class from Time & Weekday & if Week is A
func findClassfromTimeWeekDayNifWeekIsA2(timetable: Timetable, sessionStartTime: Int, weekDay: Int, isWeekA: Bool) -> Course {

	if !Storage.shared.termRunningGB { return noSchool(.noTerm) } //catch if term not running

	let week = timetable.timetable[isWeekA ? 0 : 1]
	let timetableDay: [ Int: [Int] ] = {
		switch weekDay {
			case 2: return week.monday
			case 3: return week.tuesday
			case 4: return week.wednesday
			case 5: return week.thursday
			case 6: return week.friday
			default: return [:]
		}
	}()
	guard let now = timetableDay[sessionStartTime] else { return failCourse(feedback: "TimeManager:\(#line)") }

	let course2: Course2 = timetable.courses[now[0]]!
	let roomIndex = now[1]
	let room: String = course2.rooms[roomIndex]
	// convertCourse throws; use try? and fall back to a failure Course if conversion fails
	if let converted = try? convertCourse(course2: course2, room: room) as? Course {
	    return converted
	} else {
	    return failCourse(feedback: "TimeManager:\(#line)")
	}
}




//MARK: getCurrentClass2
func getCurrentClass2(date: Date, timetable: Timetable) -> Array<Any> {
	print("getCurrentClass2 running")

	//MARK: —Init and Ghost Week stuff
	let todayWeekday = Int(weekdayNumber(date))//sunday = 1, mon = 2, etc
	print("TimeManager_fDef.swift:\(#line) - the weekday today is \(todayWeekday)")

	//func sK(_ dict: [Int: Course]) -> [Int] { Array(dict.keys).sorted(by:  <) } // sK for sortKeys
	///returns `d.keys.sorted()`
	func sK(_ d: [Int: [Int]]) -> [Int] { d.keys.sorted() }

	var times2Day: Array<Int>

	let time24Now = time24()

	//let times2Morrow: Array<Int>? = if todayWeekday<6 { weekdayTimes[todayWeekday-1] } else { nil }


	let Storage = storagePing()

	//MARK: —Guards

	let isweekA = getIfWeekIsA_FromDateAndGhost(
		originDate: Storage.startDateGB,
		ghostWeek: Storage.ghostWeekGB
	)
	let week = isweekA ? WeekAB.a : .b

	guard Storage.termRunningGB else { // if holidays then return
		NSLog("> There's no school at the moment. [noTerm]")
		print(#file+String(#line))
		return [noSchool(.noTerm), noSchool(.noTerm), Timeslot(week: week, day: todayWeekday, time: -1)]//MARK: Return A
	}


	guard (2...6).contains(todayWeekday) else {
		NSLog("> There's no school at the moment. [weekend]")
		print(#file+String(#line))
		return [noSchool(.weekend), noSchool(.weekend), Timeslot(week: week, day: todayWeekday, time: -1)]//MARK: Return B
	}

	//MARK: —Before/After

	let weekdayTimes: Array<[Int]> = {
		let wk=timetable.timetable[isweekA ? 0 : 1]
		print(#file+String(#line))
		return [ sK(wk.monday), sK(wk.tuesday), sK(wk.wednesday), sK(wk.thursday), sK(wk.friday) ]

	}()

	times2Day = weekdayTimes[todayWeekday-2]

	if time24Now<times2Day.first! { // before first course/period/time

		NSLog("> There's no school at the moment. [beforeClass]")
		setCourseChangeAlarm(for: times2Day.first!)
		print(#file+String(#line))
		return [noSchool(.beforeClass(startTime: times2Day.first!)),

				findClassfromTimeWeekDayNifWeekIsA2(
					timetable: timetable,
					sessionStartTime: times2Day.first!,
					weekDay: todayWeekday,
					isWeekA: isweekA
				),
				Timeslot(week: week, day: todayWeekday, time: -1)
		]//MARK: Return D

	} else if time24Now>=times2Day.last! { // after last course/period/time

		NSLog("> There's no school at the moment. [afterClass]")
		//try setCourseChangeAlarm(for: times2Morrow!.first!) // TODO: setCourseChangeAlarm not configured for future days
		print(#file+String(#line))
		return [noSchool(.afterClass), noSchool(.afterClass), Timeslot(week: week, day: todayWeekday, time: -1)] //MARK: Return C
	}

	//MARK: —THE LOOP
	//cycle through times til we find the two we are inbetween
	for n in 0...times2Day.count {


		let compare = times2Day[n] // time we r comparing to
		let now = time24Now // current time
		print("TimeManager_fDef.swift:\(#line) - Times today count is \(times2Day.count) and n+1 is \(n+1).")

		let next = times2Day.count >= (n+1) ? times2Day[n+1]: Int.max // next comparitive time; ensure we are not at end of array already



		if now==compare { //MARK: ——Bang on time

			print("TimeManager_fDef.swift:\(#line) - now\(now)==compare\(compare)")

			let currentCourseLocal = findClassfromTimeWeekDayNifWeekIsA2(
				timetable: timetable, sessionStartTime: now,
			weekDay: todayWeekday, isWeekA: isweekA
			)


			let nextCourseLocal = if next != Int.max {
					findClassfromTimeWeekDayNifWeekIsA2(
						timetable: timetable, sessionStartTime: next, weekDay: todayWeekday, isWeekA: isweekA
					)
			} else { noSchool(.afterClass) }


			NSLog("> The current class is %@\n> Next class is %@, due at %@", currentCourseLocal.name, nextCourseLocal.name, time24toNormal(next))
			setCourseChangeAlarm(for: next)
			print(#file+String(#line))
			return [currentCourseLocal, nextCourseLocal, Timeslot(week: week, day: todayWeekday, time: compare)]//MARK: Return D




		} else if now>compare &&  now<next { //MARK: ——In the Middle

			print("TimeManager_fDef.swift:\(#line) - now\(now)>compare\(compare) && now\(now)<next\(next)")
			let currentCourseLocal = findClassfromTimeWeekDayNifWeekIsA2(
				timetable: timetable,
				sessionStartTime: compare,
				weekDay: todayWeekday, isWeekA: isweekA
			)


			let nextCourseLocal = if next != Int.max {
					findClassfromTimeWeekDayNifWeekIsA2(
						timetable: timetable,
						sessionStartTime: next, weekDay: todayWeekday, isWeekA: isweekA
					)
			} else { noSchool(.afterClass) }



			NSLog("> The current class is %@\n> Next class is %@, due at %@", currentCourseLocal.name, nextCourseLocal.name, time24toNormal(next))
			setCourseChangeAlarm(for: next)
			print(#file+String(#line))
			return [currentCourseLocal, nextCourseLocal, Timeslot(week: week, day: todayWeekday, time: compare)] //MARK: Return E

		} // either of these `if`s mean `now` is the current class and `next` is next
	} // for n

	// MARK: Fatal Error: Fell Through
	//NSLog("%@:%d @ getCurrentClass | %@ |🚨🚨 Catastrophic Error:\n    getCurrentClass fell through: Exhausted all possible options for day.\n    time: %@, times: %@\n", #file, #line, Date.now.formatted(date: .numeric, time: .complete), String(describing: time24Now), String(describing: times2Day))
	log()
	print(#file+String(#line))
	fatalError("\(Date.now.formatted(date: .numeric, time: .complete)) | \(#file):\(#line)\n\tgetCurrentClass fell through\n\tDate: \(date)\n\tTimetable: \(timetable)")
	/*
	let failed = failCourse2(feedback: "TimeManager:\(#line)")
	return [failed, failed] //all class options should be exhausted, so this should not run. If it does, ERROR!!
	 */
}

