//
//  Change.swift
//  Timetaber
//
//  Created by Gill Palmer on 21/7/2026.
//

import Foundation

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

