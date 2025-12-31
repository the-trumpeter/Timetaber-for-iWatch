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


/*
let weekA = [monA, tueA, wedA, thuA, friA]
let weekB = [monB, tueB, wedB, thuB, friB]
*/


enum WeekAB: Codable { case a; case b }

func weekdayNumber(_ ofDate: Date) -> Int {
	return Int(Calendar.current.component(.weekday, from: ofDate)) // Sun=1, Sat=7
}


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

func getTimetableDay2(isWeekA: Bool, weekDay: Int, timetable: Timetable) -> Dictionary< Int, [Int] > {
	let weeks = timetable.timetable
	if isWeekA {
		switch weekDay {
			case 2: return weeks[0].monday
			case 3: return weeks[0].tuesday
			case 4: return weeks[0].wednesday
			case 5: return weeks[0].thursday
			case 6: return weeks[0].friday
			default: return [:]
		}
	} else {
		switch weekDay {
			case 2: return weeks[1].monday
			case 3: return weeks[1].tuesday
			case 4: return weeks[1].wednesday
			case 5: return weeks[1].thursday
			case 6: return weeks[1].friday
			default: return [:]
		}
	}
}

func getIfWeekIsA_FromDateAndGhost(originDate: Date, ghostWeek: Bool) -> Bool {
	//week A and B alternate each week. he input date is always a week a unless ghost is true.

	let originWeek = Calendar.current.component(.weekOfYear, from: originDate)
	let currentWeek = Calendar.current.component(.weekOfYear, from: Date())



	if (originWeek%2 != 0) == (currentWeek%2 != 0) {
		//they match, so currentWeek is same week a/b as originWeek
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


//MARK: - Timer

///Fires at change of classes to update views and other data
var UpdateTimer: Timer?

func setCourseChangeAlarm(for time: Time24) {
    UpdateTimer?.invalidate()
    
	let date = Date(time24: time)
    UpdateTimer = Timer(fire: date, interval: 0, repeats: false) { timer in
        print("\(#fileID):\(#line) Update timer fired; time is \(Date.now.formatted(date: .numeric, time: .complete))")
        reload()
    }
    RunLoop.main.add(UpdateTimer!, forMode: .default)
	print("\(#fileID):\(#line) Succesfully set course change alarm for \(date.formatted(date: .numeric, time: .complete))")
}






//MARK: - OLD getCurrentClass
/*
func getCurrentClass(date: Date) -> Array<Course> {
    
    //MARK: Init and Ghost Week stuff
    let todayWeekday = weekdayNumber(date)//sunday = 1, mon = 2, etc
    print("\(#fileID).swift:\(#line) - the weekday today is \(todayWeekday)")
    
    //func sK(_ dict: [Int: Course]) -> [Int] { Array(dict.keys).sorted(by:  <) } // sK for sortKeys
    ///returns `d.keys.sorted()`
    func sK(_ d: [Int: Course]) -> [Int] { d.keys.sorted() }
    let weekdayTimes: Array<Array<Int>> = [ sK(monA), sK(tueA), sK(wedA), sK(thuA), sK(friA) ]

    var times2Day: Array<Int>

    let time24Now = Time24()

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
        print("\(#fileID).swift:\(#line) - Times today count is \(times2Day.count) and n+1 is \(n+1).")
        
        let next = times2Day.count >= (n+1) ? times2Day[n+1]: Int.max // next comparitive time; ensure we are not at end of array already
        
        
        
        if now==compare {
            
            print("\(#fileID).swift:\(#line) - now\(now)==compare\(compare)")
            
            let currentCourseLocal = findClassfromTimeWeekDayNifWeekIsA(
            sessionStartTime: now,
            weekDay: todayWeekday, isWeekA: isweekA
            )
            
            
            let nextCourseLocal: Course = if next != Int.max {
                    findClassfromTimeWeekDayNifWeekIsA(
                        sessionStartTime: next, weekDay: todayWeekday, isWeekA: isweekA
                    )
            } else { noSchool(.afterClass) }
            
            
            NSLog("> The current class is %@\n> Next class is %@, due at %@", currentCourseLocal.name, nextCourseLocal.name, next.display())
            setCourseChangeAlarm(for: next)
            return [currentCourseLocal, nextCourseLocal]
            
            
        } else if now>compare &&  now<next {
            
            print("\(#fileID).swift:\(#line) - now\(now)>compare\(compare) && now\(now)<next\(next)")
            let currentCourseLocal = findClassfromTimeWeekDayNifWeekIsA(
            sessionStartTime: compare,
            weekDay: todayWeekday, isWeekA: isweekA
            )
            
            
            let nextCourseLocal: Course = if next != Int.max {
                    findClassfromTimeWeekDayNifWeekIsA(
                        sessionStartTime: next, weekDay: todayWeekday, isWeekA: isweekA
                    )
            } else { noSchool(.afterClass) }
            
            
            
            NSLog("> The current class is %@\n> Next class is %@, due at %@", currentCourseLocal.name, nextCourseLocal.name, next.display())
            setCourseChangeAlarm(for: next)
            return [currentCourseLocal, nextCourseLocal]
            
        } // either of these `if`s mean `now` is the current class and `next` is next
        
        
    } // for n
    
    // MARK: Catch
    NSLog("%@:%d @ getCurrentClass | %@ |🚨🚨 Catastrophic Error:\n    Exhausted all possible options for day.\n    time: %@, times: %@\n", #fileID, #line, Date.now.formatted(date: .numeric, time: .complete), String(describing: time24Now), String(describing: times2Day))
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
func findClassfromTimeWeekDayNifWeekIsA2(timetable: Timetable, sessionStartTime: Int, weekDay: Int, isWeekA: Bool) -> DisplayCourse {

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
	// Expecting `[courseId, roomIndex]` at this time key
	guard let pair = timetableDay[sessionStartTime] else {
		return failCourse(feedback: "DateTime:\(#line)")
	}
	// Ensure the pair has at least two integers
	guard pair.count >= 2 else {
		return failCourse(feedback: "DateTime:\(#line) invalid mapping for time \(sessionStartTime)")
	}
	let courseId = pair[0]
	let roomIndex = pair[1]

	// Look up the course; if missing, fail gracefully
	guard let course2 = timetable.courses[courseId] else {
		return failCourse(feedback: "DateTime:\(#line) missing course for id \(courseId)")
	}

	// If room index is valid, return with room; otherwise return base Course
	if roomIndex >= 0 && roomIndex < course2.rooms.count {
		return DisplayCourse(course2, room: course2.rooms[roomIndex])
	} else {
		return DisplayCourse(course2)
	}

}




//MARK: getCurrentClass2
func getCurrentClass2(date: Date, timetable: Timetable) -> Array<Any> {

	//MARK: —Init and Ghost Week stuff
	let todayWeekday = weekdayNumber(date)//sunday = 1, mon = 2, etc
	print("\(#fileID):\(#line) the weekday today is \(todayWeekday)")

	//func sK(_ dict: [Int: Course]) -> [Int] { Array(dict.keys).sorted(by:  <) } // sK for sortKeys
	///returns `d.keys.sorted()`
	func sK(_ d: [Int: [Int]]) -> [Int] { d.keys.sorted() }

	var times2Day: Array<Int>

	let time24Now = Time24()

	//let times2Morrow: Array<Int>? = if todayWeekday<6 { weekdayTimes[todayWeekday-1] } else { nil }


	let Storage = storagePing()

	//MARK: —Guards

	let isweekA = getIfWeekIsA_FromDateAndGhost(
		originDate: Storage.startDateGB,
		ghostWeek: Storage.ghostWeekGB
	)
	let week = isweekA ? WeekAB.a : .b

	guard Storage.termRunningGB else { // if holidays then return
		print("> There's no school at the moment. [noTerm]")
		print("\(#fileID):\(#line) \(#function) exit with result .noTerm")
		return [noSchool(.noTerm), noSchool(.noTerm), Timeslot(week: week, day: todayWeekday, time: -1)]//MARK: Return A
	}


	guard (2...6).contains(todayWeekday) else {
		print("> There's no school at the moment. [weekend]")
		print("\(#fileID):\(#line) \(#function) exit with result .weekend")
		return [noSchool(.weekend), noSchool(.weekend), Timeslot(week: week, day: todayWeekday, time: -1)]//MARK: Return B
	}

	//MARK: —Before/After

	let weekdayTimes: Array<[Time24]> = {
		let wk=timetable.timetable[isweekA ? 0 : 1]
		return [ sK(wk.monday), sK(wk.tuesday), sK(wk.wednesday), sK(wk.thursday), sK(wk.friday) ]

	}()

	times2Day = weekdayTimes[todayWeekday-2]

	if time24Now<times2Day.first! { // before first course/period/time
		setCourseChangeAlarm(for: times2Day.first!)
		print("\(#fileID):\(#line) \(#function) exit with result .beforeClass(startTime: \(times2Day.first!))")
		print("> There's no school at the moment. [beforeClass]")
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
		print("\(#fileID):\(#line) \(#function) exit with result .afterClass")
		print("> There's no school at the moment. [afterClass]")
		//try setCourseChangeAlarm(for: times2Morrow!.first!) // TODO: setCourseChangeAlarm not configured for future days
		return [noSchool(.afterClass), noSchool(.afterClass), Timeslot(week: week, day: todayWeekday, time: -1)] //MARK: Return C
	}

	//MARK: —THE LOOP
	//cycle through times til we find the two we are inbetween
	for n in 0...times2Day.count {


		let compare = times2Day[n] // time we r comparing to
		let now = time24Now // current time
		//print("\(#fileID):\(#line) - Times today count is \(times2Day.count) and n+1 is \(n+1).")

		let next = times2Day.count >= (n+1) ? times2Day[n+1]: Int.max // next comparitive time; ensure we are not at end of array already



		if now==compare { //MARK: ——Bang on time

			let currentCourseLocal = findClassfromTimeWeekDayNifWeekIsA2(
				timetable: timetable, sessionStartTime: now,
			weekDay: todayWeekday, isWeekA: isweekA
			)


			let nextCourseLocal = if next != Int.max {
					findClassfromTimeWeekDayNifWeekIsA2(
						timetable: timetable, sessionStartTime: next, weekDay: todayWeekday, isWeekA: isweekA
					)
			} else { noSchool(.afterClass) }


			setCourseChangeAlarm(for: next)
			print("\(#fileID):\(#line) \(#function) exit with result now(\(now)) == compare(\(compare))")
            print("> The current class is \(currentCourseLocal.name)\n> Next class is \(nextCourseLocal.name), due at \(next.display())")
			return [currentCourseLocal, nextCourseLocal, Timeslot(week: week, day: todayWeekday, time: compare)]//MARK: Return D




		} else if now>compare &&  now<next { //MARK: ——In the Middle

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


			setCourseChangeAlarm(for: next)
			print("\(#fileID):\(#line) \(#function) exit with result now(\(now)) > compare(\(compare)) && now(\(now)) < next(\(next))")
			print("> The current class is \(currentCourseLocal.name)\n> Next class is \(nextCourseLocal.name), due at \(next.display())")
			return [currentCourseLocal, nextCourseLocal, Timeslot(week: week, day: todayWeekday, time: compare)] //MARK: Return E

		} // either of these `if`s mean `now` is the current class and `next` is next
	} // for n

	// MARK: Fatal Error: Fell Through
	//NSLog("%@:%d @ getCurrentClass | %@ |🚨🚨 Catastrophic Error:\n    getCurrentClass fell through: Exhausted all possible options for day.\n    time: %@, times: %@\n", #fileID, #line, Date.now.formatted(date: .numeric, time: .complete), String(describing: time24Now), String(describing: times2Day))
	log()
	print(#fileID+String(#line))
	fatalError("\(Date.now.formatted(date: .numeric, time: .complete)) | \(#fileID):\(#line)\n\t\(#function) fell through\n\tWeek: \(week)\n\tDate: \(date)\n\tTimetable:\n\t\t \(timetable)")
	/*
	let failed = failCourse2(feedback: "TimeManager:\(#line)")
	return [failed, failed] //all class options should be exhausted, so this should not run. If it does, ERROR!!
	 */
}

