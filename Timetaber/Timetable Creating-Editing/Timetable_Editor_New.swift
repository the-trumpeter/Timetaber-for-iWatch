//
//  Timetable_Editor_New.swift
//  Timetaber
//
//  Created by Gill Palmer on 11/1/2026.
//

import SwiftUI
import OSLog

/*
I'm gonna plan this well


MARK: - EditTimetableView
• Navigate timetable view
	• 2WEEKS LEVEL 1
	• master view for editing timetable
	• from here,  select a weekday (weekb/a as well) to edit.
		i.e. List of NavigationLinks, sections for Weeks A/B
*/
struct EditTimetableView: View {
	@ObservedObject var store = Storage.shared
	let tblIndex: Int
	let weekAOnly: Bool
	init(tblIndex: Int = 0) {
		self.weekAOnly = (Storage.shared.timetables[tblIndex].timetable.count == 1)
		self.tblIndex = tblIndex
	}
	var body: some View {
		NavigationStack {
			List {
				let sectA = if weekAOnly { "" } else { "Week A" }
				Section(sectA) { // Week A days
					//let suffix = if weekAOnly { "" } else { "A" } //if only one week, don't show A/B
					NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: .a, day: 2)) {
						Text("Monday")
					}
					NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: .a, day: 3)) {
						Text("Tuesday")
					}
					NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: .a, day: 4)) {
						Text("Wednesday")
					}
					NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: .a, day: 5)) {
						Text("Thursday")
					}
					NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: .a, day: 6)) {
						Text("Friday")
					}
				}

				if !weekAOnly {
					Section("Week B") { // Week B days
						NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: .b, day: 2)) {
							Text("Monday")
						}
						NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: .b, day: 3)) {
							Text("Tuesday")
						}
						NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: .b, day: 4)) {
							Text("Wednesday")
						}
						NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: .b, day: 5)) {
							Text("Thursday")
						}
						NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: .b, day: 6)) {
							Text("Friday")
						}
					}

				}//end if

			}//end List

		}//end NavigationStack
	}//end var body
}// end struct EditTimetableView

//MARK: TimetablePeriodRow
/// Row displaying a single period in the day editor.
/// Now takes a Binding to the period contents so edits can propagate.
fileprivate struct TimetablePeriodRow: View {
	let period: Times.Period
	@Binding var contents: Times.Period.Contents?
	let courses: [UUID: Course2]

	@State private var isSheetPresented: Bool = false

	var course2: Course2? {
		if let cts = contents {
			return courses[cts.courseID]
		} else {
			return nil
		}
	}
	var course: DisplayCourse {
		if let c2 = course2, let cts = contents {
			return DisplayCourse(c2, room: c2.rooms[cts.roomIndex])
		} else {
			return noSchool(.freePeriod)
		}
	}

	/// Binding that maps the optional contents' courseID for the Picker, using nil for Free period
	private var selectedCourseIDBinding: Binding<UUID?> {
		Binding<UUID?> (
			get: { contents?.courseID },
			set: { newValue in
				if let id = newValue {
					// Update or create contents
					if contents == nil {
						contents = Times.Period.Contents(courseID: id, roomIndex: 0)
					} else {
						contents?.courseID = id
					}
				} else {
					// nil value means Free period
					contents = nil
				}
			}
		)
	}

	/// Binding for the roomIndex only if contents is non-nil
	private var roomIndexBinding: Binding<Int>? {
		guard contents != nil else { return nil }
		return Binding<Int>(
			get: { contents?.roomIndex ?? -1 },
			set: { contents?.roomIndex = $0 }
		)
	}

	var body: some View {
		Button {
			isSheetPresented = true
		} label: {
			HStack {

				HStack {
					Image(systemName: course2?.icon ?? "clock")
						.frame(width: 25, height: 25)//, alignment: .trailing)
						.font(.title3)
						.padding(2)
						.if(coloursNeedWhiteForeground.contains(course.colour)) { $0.foregroundStyle(.white)//If I have time, instead of using white, mask through the background to get same colour as list bg
						}
						.if(coloursNeedBlackForeground.contains(course.colour)) { $0.foregroundStyle(.black)//If I have time, instead of using white, mask through the background to get same colour as list bg
						}

				}
				.if(course2 != nil) {
					$0.background {
						RoundedRectangle(cornerRadius: 5.0).foregroundStyle( Colour(course.colour) )

					}
				}
				.padding(.trailing, 2)
				.padding(.leading)
				Text(period.name)
				Spacer()


				Text(course.name)
				//.foregroundStyle(Colour(course.colour))
					.if(course2 == nil) {
						$0.foregroundStyle(.secondary).padding(.trailing)
					}
				if course2 != nil {
					HStack {
						if let room = course.room {
							Text(room).foregroundStyle(.secondary)
						}
					}
					.frame(width: 45, alignment: .trailing)
					.padding(.trailing)

				}
			}
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)

		.sheet(isPresented: $isSheetPresented) {
			//MARK: Period contents editor
			VStack {
				HStack {
					if Int(period.name) != nil {
						Text("Period")
					}
					Text(period.name)
						.bold()
				}
				HStack {
					Picker(selection: selectedCourseIDBinding) {
						Text("Free period").tag(Optional<UUID>.none)
						Divider()
						ForEach(courses.map {(id: $0, course: $1)}.sorted(by: {$0.course.name > $1.course.name}), id: \.0) { entry in
							Label(entry.course.name, systemImage: entry.course.icon).tag(entry.id)
						}

					} label: {
						HStack {
							Image(systemName: course.icon.lowercased())
							Text(course.name)
						}.padding(2)
							.background { RoundedRectangle(cornerRadius: 10).foregroundStyle(Colour(course.colour.lowercased())) }//.secondary) }
					}
					if let binding = roomIndexBinding, let course2 = course2, !course2.rooms.isEmpty {
						Picker("Room", selection: binding) {
							ForEach(course2.rooms.map{(key:$0,room:$1)}, id: \.key) { tuple in
								Text(tuple.room).tag(tuple.key)
							}
						}
					}
				}

			}

			.presentationDetents([.height(200.0)])
		}

	}
}

/*
MARK: - EditTimetableDayView
• Day view
	• 1DAY LEVEL 2
	• SAVE CHANGES FROM HERE
	• Template view, used multiple times by master view, once for each day. seperated in hierarchy, not duplicated in parent view
	• from here, view periods and tap one to open editing sheet for that period
*/
fileprivate struct EditTimetableDayView: View {
	@ObservedObject var origin = Storage.shared

	let tblIndex: Int

	let timesVariation: (set: Times.TimingSet, variant: [UUID: Times.Period], name: String?)
	@State var day: [ UUID: Times.Period.Contents? ]

	var pendingChanges: [Change] = []

	init(tblIndex: Int, week: WeekAB, day: Weekday) {
		let store = Storage.shared

		//note if timetable doesn't have specified week before crashing. that's a Testflight Me probem.
		if !store.timetables.indices.contains(tblIndex) {
			Logger.views.fault("Timetables don't contain timetable for index \(tblIndex)")
		}
		self.tblIndex = tblIndex


		let times = store.timetables[tblIndex].times
		// gather stuff for timing information
		let timingSet = times.mapping[day] ?? .standard
		var variantName: String? = nil
		let variant = switch timingSet {
			case .standard: times.standard
			case .variant(let key): {
					if  !times.variants.keys.contains(key) {
						Logger.views.fault("Invalid mapping for day \(day)")
					}
					let Vnt = times.variants[key]!
					variantName = Vnt.name
					return Vnt.variant
				}()
		}

		self.timesVariation = (timingSet, variant, variantName)


		if store.timetables[tblIndex].timetable[week]![day] == nil {
			Logger.views.fault("Invalid weekday \(day)")
		}
		self.day = store.timetables[tblIndex].timetable[week]![day]!
	}


	var body: some View {

		List {
			//list entry
			let courses = origin.timetables[tblIndex].courses
            ForEach(timesVariation.variant.sorted {$0.value.startTime<$1.value.startTime}, id: \.key
			) { (pdID, period) in

				/*
				 MARK: - Period List Entry View
				 Do I really need this? It's just a HStack
				• Period list item day
					• EXTRACTED TEMPLATE
					• LIST TEMPLATE VIEW used multiple times by parent view
					• Reuseable template for Day view (used in the list of periods
				 */
				TimetablePeriodRow(
					period: period,
					contents: Binding(
						get: { day[pdID] ?? nil },
						set: { day[pdID] = $0 }
					),
					courses: courses
				)
				.listRowInsets(EdgeInsets())


			}//foreach
		}//list

	}//body
}





/*

• Edit period sheet
	• 1PERIOD LEVEL 3
	• Base editing view; edit the course in a period and the room of that course
	• Also can: Clear period (free period)

 */



#Preview {
	EditTimetableDayView(tblIndex: 0, week: .a, day: 2)
}

