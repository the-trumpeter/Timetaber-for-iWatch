//
//  Timetable.swift
//  Timetaber
//
//  Created by Gill Palmer on 19/12/2025.
//

import Foundation
import OSLog


//MARK: Timing

///The times and structure of a timetabled day (i.e. the whole timetable), including periods etc.
struct Times: Codable, Equatable {

	///Default times for the timetable
	var standard: [UUID: Period]

	///Timing variations set by the user
	var variants: [UUID: Variant]

	///The weekday:timing mapping of days and timing
	var mapping: [Weekday: Times.TimingSet]




	init(standard: [UUID: Period], variants: [UUID: Variant], mapping: [Weekday: String]) {
		self.standard = standard
		self.variants = variants
		self.mapping = {
			var newmap: [Weekday: Times.TimingSet] = [:]
			for (k, v) in mapping {
				if v == "Standard" {
					newmap[k] = .standard
				} else if let match = variants.first(where: {$1.name == v}) {
					newmap[k] = .variant(match.key)
				}
			}
			Logger.general.debug("Initialised mapping from [Int: String] to: \(newmap, privacy: .public)")
			return newmap
		}()
	}



	init(standard: [UUID: Period], variants: [UUID: Variant], mapping: [Weekday: Times.TimingSet]) {
		self.standard = standard
		self.variants = variants
		self.mapping = mapping
	}





	struct Variant: Codable, Equatable {
		var name: String
		var variant: [UUID: Period]

		init(_ name: String, variant: [UUID: Period]) { self.name = name; self.variant = variant }
		init(name: String,   variant: [UUID: Period]) { self.name = name; self.variant = variant }
	}



	///A period in a day.
	struct Period: Codable, Equatable {

		var name: String
		var startTime: Time24

		///The amount of minutes a period goes for
		var duration: Int

		init(_ name: String, startTime: Time24, duration dur: Int) {
			self.name = name
			self.startTime = startTime
			self.duration = dur
		}

		public struct Contents: Codable, Equatable {
			var courseID: UUID
			var roomIndex: Int //TODO: Make this optional instead of using '-1'
		}

	}



	///A time set, either the standard set or a user variation
	enum TimingSet: Codable, Equatable {
		///The standard timing set
		case standard
		///A variation timing set
		case variant(_ key: UUID)
	}

}



///A position in the timetable
///
///Used by UI to determine which course is to be displayed as 'current'.
///
///If we were to query `someCourse == currentCourse` to determine which course is the one we're in right now, it would become problematic if there were two of the same course in a day; both would be shown as 'current'. Instead, we use a by-time setup, querying `someTime == currentTime` to avoid duplicatory mixup.
struct Timeslot: Codable, Equatable {
	let week: WeekAB
	let day: Weekday //1=Sun, 2=Mon, ...7=Sat
	let time: Time24
	//let Timetable: Int
}
enum TimeslotError: Error {
	case invalidWeekday
	case noSchoolToday(noSchoolTodayReason)
	case invalidTime
	case noWeekB
	case invalidPeriod

	enum noSchoolTodayReason {
		case weekend
		case emptyTimes
	}
}

extension Array where Element == Timetable.TimetabledWeek  {

	subscript(index: WeekAB) -> Element? {
		switch index {
			case .a: return self[0]
			case .b: return self[1]
		}
	}

}


//MARK: - Timetable
///Contains all data of a user's timetable.
struct Timetable: Codable {



	//MARK: Properties

	var name: String
	var icon: String

	///May be used in future for JSON decoding to make sure that the input JSON format matches the installed app's format version. This may not be used, and likely might be done with JSONDecoder throws instead.
	var formatProtocol: String = "0.0.3"

	///All courses used in the timetable are stored in an array, with their index being a unique identifier (for use *within the timetable*, not on the frontend) for that course.
	var courses: [UUID : Course2]

	///The timing of school days, i.e. when each period is and if/what are the variations for some weekdays (e.g, extended 'sport period' on Wednesdays)
	var times: Times ///I don't like this...

	///The timetable itself; the mapping between periods and courses for each day.
	var timetable: [Timetable.TimetabledWeek]


	var isNew: Bool {
		let noCourses = courses.isEmpty
		let noTimingVariants = times.variants.isEmpty
		let noTimetable = self.timetable.allSatisfy(\.isEmpty)
		return noCourses && (noTimingVariants || noTimetable)
	}





	//MARK: TimetabledWeek
	///The mapping between periods, courses, and the rooms within those courses, for each day.
	///
//	///Format as follows: `[ (Period UUID): [(Course UUID), (Room index in course)] ]
	struct TimetabledWeek: Codable {

		var monday, tuesday, wednesday, thursday, friday: [ UUID: Times.Period.Contents ]

		init(monday: [UUID : Times.Period.Contents] = [:],
			 tuesday: [UUID : Times.Period.Contents] = [:],
			 wednesday: [UUID : Times.Period.Contents] = [:],
			 thursday: [UUID : Times.Period.Contents] = [:],
			 friday: [UUID : Times.Period.Contents] = [:]
		) {
			self.monday = monday
			self.tuesday = tuesday
			self.wednesday = wednesday
			self.thursday = thursday
			self.friday = friday
		}

		var isEmpty: Bool {
			let mon = self.monday.isEmpty
			let tue = self.tuesday.isEmpty
			let wed = self.wednesday.isEmpty
			let thu = self.thursday.isEmpty
			let fri = self.friday.isEmpty

			return mon && tue && wed && thu && fri
		}
		

		subscript(index: Weekday) -> [ UUID: Times.Period.Contents ]? {
			switch index {
				case 2: return monday
				case 3: return tuesday
				case 4: return wednesday
				case 5: return thursday
				case 6:	return friday
				default: return nil
			}
		}
	}




	//MARK: Period Contents from Timeslot
	func periodContentsFromTimeslot(_ timeslot: Timeslot) throws -> (UUID, Times.Period.Contents) {
		guard let week: TimetabledWeek = self.timetable[timeslot.week] else {
			let weeksNo = self.timetable.count
			Logger.dateTime.fault("Timeslot contained invalid week: \(String(reflecting: timeslot.week), privacy: .public ) Timetable only contains \(weeksNo, privacy: .public) week(s).")
			throw TimeslotError.noWeekB
		}

		guard let day = week[timeslot.day] else {
			Logger.dateTime.fault("Invalid weekday \(timeslot.day, privacy: .public) when getting period from timeslot")
			throw TimeslotError.invalidWeekday
		}
		guard let times = try? findTimes(timeslot.time, self).dropLast() else {
			Logger.dateTime.fault("Valid timeslot; but referenced day has no classes")
			throw TimeslotError.noSchoolToday(.emptyTimes)
		}

		guard let periodID = times.first(where: {$0.0 == timeslot.time})?.1 else {
			Logger.dateTime.fault("Invalid Time24 \(timeslot.time, privacy: .public) when getting period from timeslot")
			throw TimeslotError.invalidTime
		}

		guard let contents = day[periodID] else {
			Logger.dateTime.fault("Invalid period—could not find periodID \(periodID, privacy: .public) in day")
			throw TimeslotError.invalidPeriod
		}

		return (periodID, contents)
	}

	func periodFromUUID(_ uuid: UUID) -> Times.Period? {
		if let period = times.standard[uuid] {
			return period
		}
		for (_, variation) in times.variants {
			if let period = variation.variant[uuid] {
				return period
			}
		}
		Logger.dateTime.fault("UUID didn't correspond to period.")
		return nil
	}





	//MARK: Manual init
	init(_ name: String, icon: String, courses: [UUID: Course2], times: Times, timetable: [Timetable.TimetabledWeek] ) {
		self.name = name
		self.icon = icon
		self.courses = courses
		self.times = times
		self.timetable = timetable
	}





	//MARK: Blank init
	init(defaultValues: Bool = false) {

		if !defaultValues {

			self.name = "Timetable"
			self.icon = "backpack.badge.clock"
			self.courses = [:]
			self.times = Times(
				standard: [:] as [UUID: Times.Period],
				variants: [:] as [UUID: Times.Variant],
				mapping: [:] as [Weekday: Times.TimingSet]
			)
			self.timetable = [
				TimetabledWeek(),
				TimetabledWeek()
			]

		} else {

			//Default values
			let wedLunchID = UUID()
			let stdLunchID = UUID()

			let wedRecessID = UUID()
			let stdRecessID = UUID()

			let yaID = UUID()
			let checkinID = UUID()


			let wedSportID = UUID()
			let wedSport = Times.Variant("Wed. Sport",		variant: [
				UUID(): Times.Period ("1",		startTime: 0900,	duration: 60),
				UUID(): Times.Period ("2",		startTime: 1000,	duration: 50),
				yaID: Times.Period("YA",		startTime: 1050,	duration: 10),
				wedRecessID: Times.Period ("Recess",startTime: 1100,	duration: 20),
				UUID(): Times.Period ("3",		startTime: 1120,	duration: 50),
				UUID(): Times.Period ("4",		startTime: 1210,	duration: 50),
				wedLunchID: Times.Period ("Lunch",startTime: 1300,	duration: 30),
				UUID(): Times.Period ("Sport",		startTime: 1330,	duration: 50+50)
			]
			)

			let std = [
				checkinID: Times.Period ("Check In",startTime: 0900,	duration: 10),
				UUID(): Times.Period ("1",		startTime: 0910,	duration: 60),
				UUID(): Times.Period ("2",		startTime: 1010,	duration: 60),
				stdRecessID: Times.Period ("Recess",startTime: 1110,	duration: 20),
				UUID(): Times.Period ("3",		startTime: 1130,	duration: 60),
				UUID(): Times.Period ("4",		startTime: 1230,	duration: 60),
				stdLunchID: Times.Period ("Lunch",startTime: 1330,	duration: 40),
				UUID(): Times.Period ("5",		startTime: 1410,	duration: 60)
			]

			let checkInCourseID = UUID()
			let lunchCourseID = UUID()
			let recessCourseID = UUID()
			let yaCourseID = UUID()


			self.name = "Timetable"
			self.icon = "backpack.badge.clock"
			self.courses = [
				checkInCourseID: Course2("Check In", icon: "face.smiling", colour: "Graphite"),
				lunchCourseID: Course2("Lunch", icon: "fork.knife", colour: "Graphite"),
				recessCourseID: Course2("Recess", icon: "fork.knife", colour: "Graphite"),
				yaCourseID: Course2("Year Assembly", icon: "megaphone", colour: "Graphite"),
			]


			self.times = Times(
				standard: std,
				variants: [wedSportID: wedSport],
				mapping: [4: .variant(wedSportID)]
			)


			typealias C = Times.Period.Contents
			let stdDay = [
				checkinID: C(courseID: checkInCourseID, roomIndex: -1),
				stdRecessID:C(courseID: recessCourseID, roomIndex: -1),
				stdLunchID:C(courseID: lunchCourseID, roomIndex: -1)
			]
			let wed = [
				yaID: C(courseID: yaCourseID, roomIndex: -1),
				wedRecessID: C(courseID: recessCourseID, roomIndex: -1),
				wedLunchID: C(courseID: lunchCourseID, roomIndex: -1)
			]

			self.timetable = [
				TimetabledWeek(
					monday:		stdDay,
					tuesday:	stdDay,
					wednesday:	wed,
					thursday:	stdDay,
					friday:		stdDay
				),
				TimetabledWeek(
					monday:		stdDay,
					tuesday:	stdDay,
					wednesday:	wed,
					thursday:	stdDay,
					friday:		stdDay
				)
			]
		}
	}//init





	//MARK: JSON
	func encode() throws -> Data {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		let data = try encoder.encode(self)
		return data
	}
	init? (_ json: Data) {
		let decoder = JSONDecoder()
		do {
			let decoded = try decoder.decode(Timetable.self, from: json)
			self = decoded
		} catch {
			return nil
		}
	}






	//MARK: applyChanges
	/**
	 Apply a given set of `Change`s to the parent timetable.
	 - Parameter changes: The changes to be applied to the timetable.

	 Do not run `applyChanges` unless you have first successfully sent those changes to a user's Apple Watch via `distrubuteChanges`. If no Apple Watch is present, `distributeChanges` will return success.
	 */
	mutating func applyChanges(_ changes: [Change] ) {
		let name = self.name
		var successChanges: [Change] = []
		var failChanges: [Change] = []
		for change in changes {

			switch change {

				case .course_create(index: let index, let value, timetable: _):
					self.courses.updateValue(value, forKey:  index )
				successChanges.append(change)

				case .course_delete(index: let index, timetable: _):
					self.courses.removeValue(forKey: index)
				successChanges.append(change)

				case .course_modify(index: let index, let coursechange, timetable: _):
					switch coursechange {
						case .colour(let new): self.courses[index]?.colour = new
						case .rooms(let new): self.courses[index]?.rooms = new
						case .icon(let new): self.courses[index]?.icon = new
						case .name(let new): self.courses[index]?.name = new
					}
				successChanges.append(change)


				case .times_variant_key(weekday: let wkday, variant: let variant, timetable: _):
					guard let variant else {
						self.times.mapping.updateValue(.standard, forKey: wkday)
						break
					}
					self.times.mapping.updateValue(variant, forKey: wkday)
				successChanges.append(change)

				case .times_variants_add(key: let key, let variant, timetable: _):
					self.times.variants.updateValue(variant, forKey: key)
				successChanges.append(change)



				case .times_variant_modify(target: let target, let variantChange, timetable: _):
					switch variantChange {

						case .rename(let name):
							switch target {
							case .standard: failChanges.append(change); continue
							case .variant(let key):
								self.times.variants[key]?.name = name
							}

						case .modifyEntry(let setIdx, to: let value):
							switch target {
								case .standard: self.times.standard[setIdx] = value
								case .variant(let key): self.times.variants[key]?.variant[setIdx] = value
							}

						case .deleteEntry(let deletee):
							switch target {
								case .standard: self.times.standard.removeValue(forKey: deletee)
								case .variant(let key): self.times.variants[key]?.variant.removeValue(forKey: deletee)
							}
					}
				successChanges.append(change)

				case .timetable_icon(let icon, timetable: _):
				self.icon = icon
				successChanges.append(change)

				case .timetable_name(let name, timetable: _):
					self.name = name
				successChanges.append(change)


				case .week_add(let week, position: let pos, timetable: _):
					guard self.timetable.count < 2 else {
						Logger.timetableChanges.fault("Timetable cannot have more than 2 alternating weeks due to current beta limitations. \(String(reflecting: change), privacy: .public)")
						failChanges.append(change)
						continue
					}
					self.timetable.insert(week, at: pos)
				successChanges.append(change)

				case .week_modifyEntry(weekIndex: let wkIndex, weekday: let wkday, period: let period, let data, timetable: _):
					switch wkday {
						case 2: self.timetable[wkIndex].monday 	[period] 	= data
						case 3: self.timetable[wkIndex].tuesday	[period] 	= data
						case 4: self.timetable[wkIndex].wednesday	[period]	= data
						case 5: self.timetable[wkIndex].thursday	[period]	= data
						case 6: self.timetable[wkIndex].friday 	[period] 	= data
						default: failChanges.append(change); continue
					}
					successChanges.append(change)

				case .week_makeFreeEntry(weekab: let wkIndex, weekday: let wkday, period: let pd, timetable: _):
					let weekIndex: Int = (wkIndex == .a) ? 0 : 1
					guard self.timetable.indices.contains(weekIndex) else {
						Logger.timetableChanges.fault("Invalid week index when making free entry: \(String(reflecting: wkIndex), privacy: .public)")
						failChanges.append(change)
						continue
					}
					switch wkday {
						case 2: self.timetable[weekIndex].monday[pd] = nil
						case 3: self.timetable[weekIndex].tuesday[pd] = nil
						case 4: self.timetable[weekIndex].wednesday[pd] = nil
						case 5: self.timetable[weekIndex].thursday[pd] = nil
						case 6: self.timetable[weekIndex].friday[pd] = nil
						default:
							failChanges.append(change)
							continue
					}
					successChanges.append(change)

				case .week_remove(let wkIndex, timetable: _):
					self.timetable.remove(at: wkIndex)
					successChanges.append(change)

				default:
				Logger.timetableChanges.fault("Couldn't compile \(String(reflecting: change), privacy: .public) to timetable \(name, privacy: .public)")

			}//switch

		}//for each

		Logger.timetableChanges.notice("Successfully applied changes to timetable \(name, privacy: .public): \n\t\(successChanges, privacy: .public)")
		if !failChanges.isEmpty { Logger.timetableChanges.error("Couldn't apply changes:\n\t\t\(failChanges, privacy: .public)") }
	}//func applyChanges(_)


}












//MARK: - Device-persistent Mutation

/**
 A modification to a user's timetable(s).

 In order to save battery and processing power when syncing WatchOS and iOS apps, instead of copying over the whole timetable again when it is modified (or similar), compile the changes that the user has made into a smaller-sized 'list of instructions' that the WatchOS app can follow in order to produce an identical timetable to what is on the source-of-truth iOS app.

 Changes can be applied to a `Timetable`, or to `Storage` by calling the function `applyChanges(_:)`.

 See `applyChanges(_:)` and `distributeChanges(_:)` for more information on the application of changes.
 */
enum Change: Codable {

	//MARK: Timetables
		///	Create a timetable
	case	timetable_create(Timetable, index: Int)
		///	Change a timetable's name
	case	timetable_name(String, timetable: Int)
		///	Change a timetable's icon
	case	timetable_icon(String, timetable: Int)
		///	Delete a timetable
	case	timetable_delete(Int)



	//MARK: Courses
	/// Subproperty of `Change`, specifically dealing with changes within a `Course2`.
	enum Course2Change: Codable {
		/// Change a course's name
		case name(String)
		/// Change a course's icon
		case icon(String)
		/// Change a course's colour
		case colour(Colour)
		/// Change (redefine) a course's rooms
		case rooms([Int: String])
	}

	
		/// Create a `Course2` inside the timetable
	case	course_create(index: UUID, Course2, timetable: Int)
		/// Modify a course using a `Course2Change`
	case	course_modify(index: UUID, Course2Change, timetable: Int)
		/// Delete a course
	case	course_delete(index: UUID, timetable: Int)



	//MARK: Weeks
		/// Add a week to the timetable
	case	week_add(Timetable.TimetabledWeek, position: Int, timetable: Int)
		/// Modify an entry in a week of the timetable
	case	week_modifyEntry(weekIndex: Int, weekday: Weekday, period: UUID, Times.Period.Contents, timetable: Int)
		///	Clear an entry of a week; make it a free period
	case 	week_makeFreeEntry(weekab: WeekAB, weekday: Weekday, period: UUID, timetable: Int)
		/// Remove a timetabled week
	case	week_remove(Int, timetable: Int)



	//MARK: Times

	enum TimesVariantChange: Codable {
		/// Rename a variation of day-period timing
		case rename(_ to: String)
		/// Change a `Period` in a variation of day-period timing
		case modifyEntry(_ entry: UUID, to: Times.Period)
		/// Delete a `Period` **in** a variation of day-period timing
		case deleteEntry(_ entry: UUID)
	}

		/// Add a variation of period times
	case	times_variants_add(key: UUID, Times.Variant, timetable: Int)
		///	Modify a variation of day-period timing
	case	times_variant_modify(target: Times.TimingSet, _ change: TimesVariantChange, timetable: Int)
		/// Delete **a** variation of period times. Not to be confused with `times_variants_deleteEntry`
	case 	times_variants_delete(_ key: UUID, timetable: Int)
		/// Change the  period-times variation mapping for a day
	case	times_variant_key(weekday: Weekday, variant: Times.TimingSet?, timetable: Int)

}


