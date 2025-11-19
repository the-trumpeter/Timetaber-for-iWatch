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
        let timetableDay = weekA[weekDay-2]
        return timetableDay
    } else {
        let timetableDay = weekB[weekDay-2]
        return timetableDay
    }
    
}



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






//MARK: - Timer
func dateFrom24hrInt(_ time24: Int) -> Date {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    components.timeZone = TimeZone.current
    components.hour = time24/100
    components.minute = time24%100
    components.second = 0
    print("TimeManager_fDef.swift:\(#line) @ dateFrom24hrInt\n\tComposing date \(String(describing: components.hour!)):\(String(describing: components.minute!))")
    guard let date = calendar.date(from: components) else {
        
        LocalData.shared.currentCourse = failCourse(feedback: "TimeManager:\(#line)")
        NSLog("%@:%d @ dateFrom24hrInt | %@ | 🚨🚨 Catastrophic Error:\n    Composing date %@:%@.\n    DateComponents: %@", #file, #line, Date.now.formatted(date: .numeric, time: .complete), String(describing: components.hour), String(describing: components.minute), String(describing: components)
              )
        log()
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






//MARK: - New


//MARK: View Support
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


//MARK: Fail, Noschool
func failCourse2(feedback: String? = "None") -> Course2 {
	let rooms: [String] = if feedback != nil { [feedback!] } else { [] }
	return Course2("Error", icon: "exclamationmark.triangle", rooms: rooms, colour: "Graphite", listIcon: "exclamationmark.triangle", identifier: .fail)
}
func noSchool2(_ timecase: TimeCase? = nil) -> Course2 {
	guard let key = timecase else { return failCourse2(feedback: "TimeManager:\(#line)")}

	let joke: String = switch key {
		case .weekend: "It's the weekend."
		case .noTerm: "No term running."
		case .noTimetable: "No timetable available."
		case .beforeClass(let startTime): "First class at \(time24toNormal(startTime))."
		case .afterClass: "School's out for today!"
	}

	return Course2("No school", icon: "clock", colour: "Graphite", joke: joke, identifier: .noSchool(key) )
}

//MARK: Temp storage ping
func storagePing() -> Storage {
	//if need to update values across watch/phone, do so here
	return Storage.shared
}

enum ConversionError: Error {
	case noParameters
	case bothInputs
	case unexpectedNil
	case identifierNotProvided
}
func convertCourse(course: Course? = nil, course2: Course2? = nil, room: String? = nil, identifier: Identifier? = nil) throws -> Any {
	guard (course != nil) != (course2 != nil) else { // only one input provided
		throw ConversionError.bothInputs
	}

	if course2 != nil {
		// Course2 to Course
		//guard let id: Identifier = identifier else {throw ConversionError.identifierNotProvided}
		return Course(
			course2!.name,
			icon: course2!.icon,
			room: room,
			colour: course2!.colour,
			listName: course2!.listName,
			listIcon: course2!.listIcon,
			joke: course2!.joke,
			identifier: { if course2!.identifier != nil { return course2!.identifier! } else { return identifier } }()
		)
	}
	if course != nil {
		return Course2(
			course!.name,
			icon: course!.icon,
			rooms: { if let rm = course?.room { return [rm] } else { return [] } }(),
			colour: course!.colour,
			listName: course!.listName,
			listIcon: course!.listIcon,
			joke: course!.joke,
			identifier: { if course!.identifier != nil { return course!.identifier! } else { return identifier } }()
		)
	}
	throw {
		return ConversionError.noParameters
	}()
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
func getCurrentClass2(date: Date, timetable: Timetable) -> Array<Course> {
	print("getCurrentClass2 running")
	//MARK: Init and Ghost Week stuff
	let todayWeekday = Int(weekdayNumber(date))//sunday = 1, mon = 2, etc
	print("TimeManager_fDef.swift:\(#line) - the weekday today is \(todayWeekday)")

	//func sK(_ dict: [Int: Course]) -> [Int] { Array(dict.keys).sorted(by:  <) } // sK for sortKeys
	///returns `d.keys.sorted()`
	func sK(_ d: [Int: [Int]]) -> [Int] { d.keys.sorted() }

	var times2Day: Array<Int>

	let time24Now = time24()

	//let times2Morrow: Array<Int>? = if todayWeekday<6 { weekdayTimes[todayWeekday-1] } else { nil }


	let Storage = storagePing()

	guard Storage.termRunningGB else { // if holidays then return
		NSLog("> There's no school at the moment. [noTerm]")
		print(#file+String(#line))
		return [noSchool(.noTerm), noSchool(.noTerm)]
	}


	guard (2...6).contains(todayWeekday) else {
		NSLog("> There's no school at the moment. [weekend]")
		print(#file+String(#line))
		return [noSchool(.weekend), noSchool(.weekend)]
	}


	let isweekA = getIfWeekIsA_FromDateAndGhost(
		originDate: Storage.startDateGB,
		ghostWeek: Storage.ghostWeekGB
	)

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
				)
		]

	} else if time24Now>=times2Day.last! { // after last course/period/time

		NSLog("> There's no school at the moment. [afterClass]")
		//try setCourseChangeAlarm(for: times2Morrow!.first!) // TODO: setCourseChangeAlarm not configured for future days
		print(#file+String(#line))
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
			return [currentCourseLocal, nextCourseLocal]


		} else if now>compare &&  now<next {

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
			return [currentCourseLocal, nextCourseLocal]

		} // either of these `if`s mean `now` is the current class and `next` is next
	} // for n

	// MARK: Fatal Error: Fell Through
	//NSLog("%@:%d @ getCurrentClass | %@ |🚨🚨 Catastrophic Error:\n    getCurrentClass fell through: Exhausted all possible options for day.\n    time: %@, times: %@\n", #file, #line, Date.now.formatted(date: .numeric, time: .complete), String(describing: time24Now), String(describing: times2Day))
	log()
	print(#file+String(#line))
	fatalError("\(Date.now.formatted(date: .numeric, time: .complete)) | \(#file):\(#line)\n\tgetCurrentClass fell through: Exhausted all possible options for day.\n\tDate: \(date)\n\tTimetable: \(timetable)")
	/*
	let failed = failCourse2(feedback: "TimeManager:\(#line)")
	return [failed, failed] //all class options should be exhausted, so this should not run. If it does, ERROR!!
	 */
}

