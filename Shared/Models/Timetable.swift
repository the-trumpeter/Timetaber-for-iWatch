//
//  Timetable.swift
//  Timetaber
//
//  Created by Gill Palmer on 19/12/2025.
//

import Foundation


//MARK: Timing

///The times and structure of a timetabled day (i.e. the whole timetable), including periods etc.
struct Times: Codable, Equatable {
	///Default times for the timetable
	var standard: [Period]

	///Timing variations set by the user
	var variants: [String: [Period]]

	///The weekday:timing mapping of days and timing
	var mapping: [Int: String]

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

	}

}





//MARK: Timetable
///Contains all data of a user's timetable.
class Timetable: Codable {
	var name: String
	var icon: String

	///May be used in future for JSON decoding to make sure that the input JSON format matches the app's version. This may not be used, and likely might be done with JSONDecoder throws instead.
	var formatProtocol: String = "0.0.3"

	///All courses used in the timetable are stored in an array, with their index being a unique identifier (for use *within the timetable*, not on the frontend) for that course.
	var courses: [Int : Course2]

	///The timing of school days, i.e. when each period is and if/what are the variations for some weekdays (e.g, extended 'sport period' on Wednesdays)
	var times: Times //I don't like this...

	///The timetable itself; the mapping between periods and courses for each day.
	var timetable: [Timetable.TimetabledWeek]


	///The mapping between periods, courses, and the rooms within those courses, for each day.
	///Format as follows: `[ (Start time): [(Course index), (Room index in course)] ]
	struct TimetabledWeek: Codable {
		var monday:			[ Time24: [Int] ]
		var tuesday:		[ Time24: [Int] ]
		var wednesday:		[ Time24: [Int] ]
		var thursday:		[ Time24: [Int] ]
		var friday:			[ Time24: [Int] ]
	}

	init(_ name: String, icon: String, courses: [Int: Course2], times: Times, timetable: [Timetable.TimetabledWeek] ) {
		self.name = name
		self.icon = icon
		self.courses = courses
		self.times = times
		self.timetable = timetable
	}

	
	/**
	 Apply a given set of `Change`s to the parent timetable.
	 - Parameter changes: The changes to be applied to the timetable.

	 Do not run `applyChanges` unless you have first successfully sent those changes to a user's Apple Watch via `distrubuteChanges`. If no Apple Watch is present, `distributeChanges` will return success.
	 */
	func applyChanges(_ changes: [Change] ) {
		var successChanges: [Change] = []
		var failChanges: [Change] = []
		for change in changes {

			switch change {

				case .course_create(index: let index, let value, timetable: _):
					self.courses.updateValue(value, forKey: index ?? self.courses.count)
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
						self.times.mapping.removeValue(forKey: wkday)
						break
					}
					self.times.mapping.updateValue(variant, forKey: wkday)
				successChanges.append(change)

				case .times_variants_add(named: let key, let variant, timetable: _):
					self.times.variants.updateValue(variant, forKey: key)
				successChanges.append(change)

				case .times_variant_modifyEntry(in: let key, toModify: let setIdx, let value, timetable: _):
					self.times.variants[key]?[setIdx] = value
				successChanges.append(change)

				case .times_variants_deleteEntry(in: let key, toDelete: let set, timetable: _):
				self.times.variants[key]?.remove(at: set)
				successChanges.append(change)

				case .timetable_icon(let icon, timetable: _):
					self.icon = icon
				successChanges.append(change)

				case .timetable_name(let name, timetable: _):
					self.name = name
				successChanges.append(change)


				case .week_add(let week, position: let pos, timetable: _):
					guard self.timetable.count < 2 else {
						fatalError("\(Date.now.formatted(date: .numeric, time: .complete))\(#fileID):\(#line)\n\tTimetable cannot have more than 2 alternating weeks due to current beta limitations\n\tAttempted to insert:\n\t\(week)\n\tat position <\(pos)>")
					}
					self.timetable.insert(week, at: pos)
				successChanges.append(change)

				case .week_modifyEntry(weekIndex: let wkIndex, weekday: let wkday, time: let time, let data, timetable: _):
					switch wkday {
						case 2: self.timetable[wkIndex].monday[time] = data
						case 3: self.timetable[wkIndex].tuesday[time] = data
						case 4: self.timetable[wkIndex].wednesday[time] = data
						case 5: self.timetable[wkIndex].thursday[time] = data
						case 6: self.timetable[wkIndex].friday[time] = data
						default: failChanges.append(change); continue
					}
					successChanges.append(change)

				case .week_remove(let wkIndex, timetable: _):
					self.timetable.remove(at: wkIndex)
					successChanges.append(change)

				default:
					print("\(#fileID):\(#line) Couldn't compile change\n\t\t\(change)\n\tto timetable \"\(self.name)\"")

			}//switch

		}//for each

		print("\(#fileID):\(#line) Timetable.applyChanges\n\tSuccessfully applied changes to timetable \"\(self.name)\":\n\t\t\(successChanges)\n\tCouldn't apply changes:\n\t\t\(failChanges)")
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

		///	Create a timetable
	case	timetable_create(Timetable, index: Int)
		///	Change a timetable's name
	case	timetable_name(String, timetable: Int)
		///	Change a timetable's icon
	case	timetable_icon(String, timetable: Int)
		///	Delete a timetable
	case	timetable_delete(Int)

	/// Subproperty of `Change`, specifically dealing with changes within a `Course2`.
	enum Course2Change: Codable {
		/// Change a course's name
		case name(String)
		/// Change a course's icon
		case icon(String)
		/// Change a course's colour
		case colour(String)
		/// Change (redefine) a course's rooms
		case rooms([Int: String])
	}

		/// Create a `Course2` inside the timetable
	case	course_create(index: Int? = nil, Course2, timetable: Int)
		/// Modify a course using a `Course2Change`
	case	course_modify(index: Int, Course2Change, timetable: Int)
		/// Delete a course
	case	course_delete(index: Int, timetable: Int)

		/// Add a week to the timetable
	case	week_add(Timetable.TimetabledWeek, position: Int, timetable: Int)
		/// Modify an entry in a week of the timetable
	case	week_modifyEntry(weekIndex: Int, weekday: Int, time: Time24, [Int], timetable: Int)
		/// Remove a timetabled week
	case	week_remove(Int, timetable: Int)

		/// Add a variation of period times
	case	times_variants_add(named: String, [Times.Period], timetable: Int)
		/// Change (redefine) a `Period` in a variation of period times
	case	times_variant_modifyEntry(in: String, toModify: Int, Times.Period, timetable: Int)
		/// Delete a `Period` in a variation of period times. Not to be confused with `times_variants_delete`
	case	times_variants_deleteEntry(in: String, toDelete: Int, timetable: Int)
		/// Delete a variation of period times. Not to be confused with `times_variants_deleteEntry`
	case 	times_variants_delete(_ named: String, timetable: Int)
		/// Change the  period-times variation mapping for a day
	case	times_variant_key(weekday: Int, variant: String?, timetable: Int)

}
