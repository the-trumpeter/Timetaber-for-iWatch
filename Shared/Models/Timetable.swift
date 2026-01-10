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
	var standard: [Int: Period]

	///Timing variations set by the user
	var variants: [Int: Variant]

	///The weekday:timing mapping of days and timing
	var mapping: [Int: Int]




	init(standard: [Period], variants: [Int: Variant], mapping: [Int: String]) {
		self.standard = Dictionary(uniqueKeysWithValues: standard.enumerated().map { ($0.offset, $0.element) })
		self.variants = variants
		self.mapping = {
			var newmap: [Int: Int] = [:]
			for (k, v) in mapping {
				if v == "Standard" {
					newmap[k] = -1
				} else if let match = variants.first(where: {$1.name == v}) {
					newmap[k] = match.key
				}
			}
			Logger.general.debug("Initialised mapping from [Int: String] to: \(newmap)")
			return newmap
		}()
	}



	init(standard: [Int: Period], variants: [Int: Variant], mapping: [Int: Int]) {
		self.standard = standard
		self.variants = variants
		self.mapping = mapping
	}





	struct Variant: Codable, Equatable {
		var name: String
		var variant: [Int: Period]
		init (_ name: String, variant: [Period]) {
			self.name = name
			self.variant = Dictionary(uniqueKeysWithValues: variant.enumerated().map { ($0.offset, $0.element) })
		}
		init(_ name: String, variant: [Int: Period]) { self.name = name; self.variant = variant }
		init(name: String,   variant: [Int: Period]) { self.name = name; self.variant = variant }
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

	}



	///A time set, either the standard set or a user variation
	enum Set: Codable, Equatable {
		///The standard timing set
		case standard
		///A variation timing set
		case variant(_ key: Int)
	}

}





//MARK: Timetable
///Contains all data of a user's timetable.
class Timetable: Codable {
	var name: String
	var icon: String

	///May be used in future for JSON decoding to make sure that the input JSON format matches the installed app's format version. This may not be used, and likely might be done with JSONDecoder throws instead.
	var formatProtocol: String = "0.0.3"

	///All courses used in the timetable are stored in an array, with their index being a unique identifier (for use *within the timetable*, not on the frontend) for that course.
	var courses: [Int : Course2]

	///The timing of school days, i.e. when each period is and if/what are the variations for some weekdays (e.g, extended 'sport period' on Wednesdays)
	var times: Times ///I don't like this...

	///The timetable itself; the mapping between periods and courses for each day.
	var timetable: [Timetable.TimetabledWeek]


	///The mapping between periods, courses, and the rooms within those courses, for each day.
	///
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

	init() {
		self.name = "Timetable"
		self.icon = "backpack.badge.clock"
		self.courses = [:]
		self.times = Times(standard: [:], variants: [:], mapping: [:])
		self.timetable = [
			TimetabledWeek(
				monday:		[:],
				tuesday:	[:],
				wednesday:	[:],
				thursday:	[:],
				friday:		[:]
			),
			TimetabledWeek(
				monday:		[:],
				tuesday:	[:],
				wednesday:	[:],
				thursday:	[:],
				friday:		[:]
			)
		]
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
						Logger.timetableChanges.fault("Timetable cannot have more than 2 alternating weeks due to current beta limitations. \(String(reflecting: change))")
						failChanges.append(change)
						continue
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
				Logger.timetableChanges.fault("Couldn't compile \(String(reflecting: change)) to timetable \(self.name)")

			}//switch

		}//for each

		Logger.timetableChanges.info("Successfully applied changes to timetable \(self.name): \n\t\(successChanges)")
		if !failChanges.isEmpty { Logger.timetableChanges.error("Couldn't apply changes:\n\t\t\(failChanges)") }
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



	//MARK: Weeks
		/// Add a week to the timetable
	case	week_add(Timetable.TimetabledWeek, position: Int, timetable: Int)
		/// Modify an entry in a week of the timetable
	case	week_modifyEntry(weekIndex: Int, weekday: Int, time: Time24, [Int], timetable: Int)
		/// Remove a timetabled week
	case	week_remove(Int, timetable: Int)



	//MARK: Times

	enum TimesVariantChange: Codable {
		/// Rename a variation of day-period timing
		case rename(_ to: String)
		/// Change a `Period` in a variation of day-period timing
		case modifyEntry(_ entry: Int, to: Times.Period)
		/// Delete a `Period` **in** a variation of day-period timing
		case deleteEntry(_ entry: Int)
	}

		/// Add a variation of period times
	case	times_variants_add(key: Int, Times.Variant, timetable: Int)
		///	Modify a variation of day-period timing
	case	times_variant_modify(target: Times.Set, _ change: TimesVariantChange, timetable: Int)
		/// Delete **a** variation of period times. Not to be confused with `times_variants_deleteEntry`
	case 	times_variants_delete(_ key: Int, timetable: Int)
		/// Change the  period-times variation mapping for a day
	case	times_variant_key(weekday: Int, variant: Int?, timetable: Int)

}


