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
import OSLog


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

func getTimetableDay2(isWeekA: Bool, weekDay: Int, timetable: Timetable) -> Dictionary< UUID, Times.Period.Contents > {
	let weeks = timetable.timetable
	guard weekDay >= 2 && weekDay <= 6 else {
		Logger.dateTime.fault("Invalid weekday \(weekDay)")
		return [:]
	}
	if isWeekA {
		return weeks[0][weekDay]!
	} else {//weekB
		return weeks[1][weekDay]!
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
		Logger.updateTimer.log("Update timer fired")
        reload()
    }
    RunLoop.main.add(UpdateTimer!, forMode: .default)
	Logger.updateTimer.info("Succesfully set course change alarm for \(date.formatted(date: .numeric, time: .complete))")
}






//MARK: - OLD getCurrentClass
/*
func getCurrentClass(date: Date) -> Array<Course> {
    
    //MARK: Init and Ghost Week stuff
    let todayWeekday = weekdayNumber(date)//sunday = 1, mon = 2, etc
    Logger.<#logger#>.<#action#>("the weekday today is \(todayWeekday)")
    
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
        Logger.<#logger#>.<#action#>("Times today count is \(times2Day.count) and n+1 is \(n+1).")
        
        let next = times2Day.count >= (n+1) ? times2Day[n+1]: Int.max // next comparitive time; ensure we are not at end of array already
        
        
        
        if now==compare {
            
            Logger.<#logger#>.<#action#>("now\(now)==compare\(compare)")
            
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
            
            Logger.<#logger#>.<#action#>("now\(now)>compare\(compare) && now\(now)<next\(next)")
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




//MARK: - Newer methods



//MARK: findTimes
enum findTimesError: Error {
	case invalidMapping(_ fail: DisplayCourse)
}

func findTimes(_ wkday: Int, _ timetable: Timetable, includeFinishTime: Bool = true) throws -> [ (Time24, Optional<UUID>) ] {
	if let mapKey = timetable.times.mapping[wkday] {

		//Logger.dateTime.debug("findTimes got map key \(mapKey)")
		guard
			let variant = switch mapKey {
				case .variant(let id): timetable.times.variants[id]?.variant
				case .standard: timetable.times.standard
			}
		else {
			Logger.dateTime.fault("Time mapping value \( String(describing: mapKey) ) does not correspond to a variant in .variants.keys = \(timetable.times.variants.keys)")
			throw findTimesError.invalidMapping(failCourse(feedback: "Error D\(#line) Invalid mapping value \(mapKey)"))
		}
		//Logger.dateTime.debug("findTimes found variant: \(String(describing: variant))")
		//Logger.dateTime.debug("findTimes found times for weekday \(wkday)")

		var times: [(Time24, UUID?)] = variant.map { ($1.startTime, $0 as UUID?) }.sorted(by: { $0.0 < $1.0 })

		if includeFinishTime {

			let lastPeriod = variant.sorted { $0.value.startTime < $1.value.startTime }.last?.value
			let existingStart = Date(time24: lastPeriod?.startTime ?? 0900) //fetch start time of last period
			let end = existingStart.addingTimeInterval(TimeInterval((lastPeriod?.duration ?? 0) * 60 ))

			times.append( (Time24(from: end), nil) )
		}

		return times
	}
	//Logger.dateTime.debug("findTimes found (standard) times for weekday \(wkday)")
	return timetable.times.standard.map { ($1.startTime, $0 as UUID?) }.sorted(by: { $0.0 < $1.0 })
}



//MARK: Temp storage ping
func storagePing() -> Storage {
	//if need to update values across watch/phone, do so here
	return Storage.shared
}




//MARK: Class from Time & Weekday & if Week is A
func findClassFromTimeWeekDayAndIfWeekIsA_2(timetable: Timetable, period periodID: UUID, weekDay: Int, isWeekA: Bool) -> DisplayCourse {

	if !Storage.shared.termRunningGB { return noSchool(.noTerm) } //catch if term not running

	let week = timetable.timetable[isWeekA ? 0 : 1]
	let timetableDay = week[weekDay]

	// Expecting `[courseId, roomIndex]` at this time key
	guard let pair = timetableDay?[periodID] else {
		Logger.dateTime.warning("Time \(periodID) not found in timetableDay (probably a free period), or weekday \(weekDay) is invalid")
		return noSchool(.freePeriod)//failCourse(feedback: "Error D\(#line)")
	}
	/* (from the brief days when it was an array)
	// Ensure the pair has at least two integers
	guard pair.count >= 2 else {
		Logger.dateTime.fault("Invalid mapping for period \(periodID)")
		return failCourse(feedback: "Error D\(#line) invalid mapping for period \(periodID)")
	}
	 */

	// Look up the course; if missing, fail gracefully
	guard let course2 = timetable.courses[pair.courseID] else {
		Logger.dateTime.fault("Missing course for id \(pair.courseID)")
		return failCourse(feedback: "Error D\(#line) missing course for id \(pair.courseID)")
	}

	// If room index is valid, return with room; otherwise return base Course
	if pair.roomIndex >= 0 && pair.roomIndex < course2.rooms.count {
		return DisplayCourse(course2, room: course2.rooms[pair.roomIndex])
	} else {
		return DisplayCourse(course2)
	}

}




//MARK: getCurrentClass2
func getCurrentClass2(date: Date, timetable: Timetable) -> (current: DisplayCourse, next: DisplayCourse, timeslot: Timeslot) {
	//MARK: —Init and Ghost Week stuff
	let todayWeekday = weekdayNumber(date)//sunday = 1, mon = 2, etc
	Logger.dateTime.log("Getting current class...")

	var times2Day: [(Time24, UUID?)]

	let time24Now = Time24()

	//let times2Morrow: Array<Int>? = if todayWeekday<6 { weekdayTimes[todayWeekday-1] } else { nil }


	let Storage = storagePing()

	//MARK: —Guards

	let isweekA = getIfWeekIsA_FromDateAndGhost(
		originDate: Storage.startDateGB,
		ghostWeek: Storage.ghostWeekGB
	)
	let week = isweekA ? WeekAB.a : .b

	Logger.dateTime.info("The weekday today is \(todayWeekday). It is week \(String(reflecting: week))")

	guard Storage.termRunningGB else { // if holidays then return
		Logger.dateTime.info("Got current class. There's no school at the moment. [noTerm]")
		return (
			current: noSchool(.noTerm),
			next: noSchool(.noTerm),
			timeslot: Timeslot(week: week, day: todayWeekday, time: -1)
		) //MARK: Return A
	}


	guard todayWeekday >= 2, todayWeekday <= 6 else {
		Logger.dateTime.info("Got current class. There's no school at the moment. [weekend]")
		return (
			current: noSchool(.weekend),
			next: noSchool(.weekend),
			timeslot: Timeslot(week: week, day: todayWeekday, time: -1)
		) //MARK: Return B
	}



	//MARK: —Before/After

	//MARK: —Timing chaos

	//let times2Day: [Time24]
	do {
		times2Day = try findTimes(todayWeekday, timetable)
		Logger.dateTime.debug("Times for today are \(times2Day.map { $0.0 })")
	} catch findTimesError.invalidMapping(let fail) {
		return (
			current: fail,
			next: fail,
			timeslot: Timeslot(week: week, day: todayWeekday, time: -1)
		)
	} catch {
		fatalError("findTimes threw other than findTimesError.invalidMapping")
	}

	guard !times2Day.isEmpty else {
		return (
			current: noSchool(),
			next: noSchool(),
			timeslot: Timeslot(week: week, day: todayWeekday, time: -1)
		)
	}


	if time24Now < times2Day.first!.0 { // before first course/period/time
		setCourseChangeAlarm(for: times2Day.first!.0)
		Logger.dateTime.info("Got current class. There's no school at the moment. [beforeClass(startTime: \(times2Day.first!.0))]")

		return (
			current: noSchool(.beforeClass(startTime: times2Day.first!.0)),

			next: findClassFromTimeWeekDayAndIfWeekIsA_2(
					timetable: timetable,
					period: times2Day.first!.1 ?? UUID(),
					weekDay: todayWeekday,
					isWeekA: isweekA
				),
			timeslot: Timeslot(week: week, day: todayWeekday, time: -1)
		) //MARK: Return D

	} else if time24Now >= times2Day.last!.0 { // after last course/period/time
		Logger.dateTime.info("Got current class. There's no school at the moment. [afterClass]—ended at \(times2Day.last!.0)")
		//try setCourseChangeAlarm(for: times2Morrow!.first!) // TODO: setCourseChangeAlarm not configured for future days
		return (
			current: noSchool(.afterClass),
			next: noSchool(.afterClass),
			timeslot: Timeslot(week: week, day: todayWeekday, time: -1)
			) //MARK: Return C
	}

	//MARK: —THE LOOP
	//cycle through times til we find the two we are inbetween
	for n in 0..<(times2Day.count) {


		let compare = times2Day[n].0 // time we r comparing to
		let now = time24Now // current time
		//Logger.<#logger#>.<#action#>("- Times today count is \(times2Day.count) and n+1 is \(n+1).")

		let next = times2Day.count > (n+1) ? times2Day[n+1].0 : Int.max // next comparitive time; ensure we are not at end of array already



		if now == compare { //MARK: ——Bang on time

			let currentCourseLocal = findClassFromTimeWeekDayAndIfWeekIsA_2(
				timetable: timetable,
				period: times2Day[n].1 ?? UUID(),
			weekDay: todayWeekday, isWeekA: isweekA
			)


			let nextCourseLocal = if times2Day.last?.0 == next {
				noSchool(.afterClass)
			} else if next != Int.max {
					findClassFromTimeWeekDayAndIfWeekIsA_2(
						timetable: timetable,
						period: times2Day[n+1].1 ?? UUID(),
						weekDay: todayWeekday, isWeekA: isweekA
					)
			} else { noSchool(.afterClass) }


			setCourseChangeAlarm(for: next)
			Logger.dateTime.info("Got current class | now(\(now)) == compare(\(compare)) \nThe current class is \(currentCourseLocal.name). Next class is \(nextCourseLocal.name), due at \(next.display())")
			return (
				current: currentCourseLocal,
				next: nextCourseLocal,
				timeslot: Timeslot(week: week, day: todayWeekday, time: compare)
			) //MARK: Return D




		} else if now > compare &&  now < next { //MARK: ——In the Middle

			let currentCourseLocal = findClassFromTimeWeekDayAndIfWeekIsA_2(
				timetable: timetable,
				period: times2Day[n].1 ?? UUID(),
				weekDay: todayWeekday, isWeekA: isweekA
			)


			let nextCourseLocal = if times2Day.last?.0 == next {
				noSchool(.afterClass)
			} else if next != Int.max {
					findClassFromTimeWeekDayAndIfWeekIsA_2(
						timetable: timetable,
						period: times2Day[n+1].1 ?? UUID(),
						weekDay: todayWeekday, isWeekA: isweekA
					)
			} else { noSchool(.afterClass) }


			setCourseChangeAlarm(for: next)
			Logger.dateTime.info("Got current class | now(\(now)) > compare(\(compare)) && now(\(now)) < next(\(next)) \nThe current class is \(currentCourseLocal.name)\nNext class is \(nextCourseLocal.name), due at \(next.display())")
			return (
				current: currentCourseLocal,
				next: nextCourseLocal,
				timeslot: Timeslot(week: week, day: todayWeekday, time: compare)
			) //MARK: Return E

		} // either of these `if`s mean `now` is the current class and `next` is next
	} // for n

	// MARK: Fatal Error: Fell Through
	//NSLog("%@:%d @ getCurrentClass | %@ |🚨🚨 Catastrophic Error:\n    getCurrentClass fell through: Exhausted all possible options for day.\n    time: %@, times: %@\n", #fileID, #line, Date.now.formatted(date: .numeric, time: .complete), String(describing: time24Now), String(describing: times2Day))
	log()
	fatalError("\(#function) fell through\n\tWeek: \(week)\n\tDate: \(date)\n\tTimetable:\n\t\t \(timetable)")
	/*
	let failed = failCourse2(feedback: "TimeManager:\(#line)")
	return [failed, failed] //all class options should be exhausted, so this should not run. If it does, ERROR!!
	 */
}
