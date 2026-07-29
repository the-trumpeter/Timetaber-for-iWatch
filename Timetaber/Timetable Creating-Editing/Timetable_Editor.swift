//
//  Timetable_Editor_New.swift
//  Timetaber
//
//  Created by Gill Palmer on 11/1/2026.
//

import SwiftUI
import OSLog




//MARK: Entry point
struct EditTimetableView: View {
	@EnvironmentObject var storage: Storage
	let tblIndex: Int
	var weekAOnly: Bool { storage.timetables[tblIndex].timetable.count == 1 }
	init(tblIndex: Int = 0) {
		self.tblIndex = tblIndex
	}
	var body: some View {
		NavigationStack {
			List {

				let sectA = if weekAOnly { "" } else { "Week A" }
				Section(sectA) { // Week A days
					//let suffix = if weekAOnly { "" } else { "A" } //if only one week, don't show A/B
					ForEach(2...6, id: \.self) { wkday in
						dayLink(tblIndex: tblIndex, wkAB: .a, day: wkday)
					}
				}

				if !weekAOnly {
					Section("Week B") { // Week B days
						ForEach(2...6, id: \.self) { wkday in
							dayLink(tblIndex: tblIndex, wkAB: .b, day: wkday)
						}
					}

				}//end if wkAonly

			}//end List

		}//end NavigationStack
	}//end var body
}// end struct EditTimetableView











/*
I'm gonna plan this well


MARK: - Link to Timetabled Day
Routing Weekday/WeekAB
• Navigate timetable view
	• 2WEEKS LEVEL 1
	• master view for editing timetable
	• from here,  select a weekday (weekb/a as well) to edit.
		i.e. List of NavigationLinks, sections for Weeks A/B
*/

fileprivate struct dayLink: View {
	@EnvironmentObject var storage: Storage
	var tblIndex: Int = 0
	var wkAB: WeekAB = .a
	var day: Weekday = 2

	init(tblIndex: Int, wkAB: WeekAB, day: Weekday) {
		self.tblIndex = tblIndex
		self.wkAB = wkAB
		self.day = day
	}

	var body: some View {

		@State var isToday = if Int(Calendar.current.component(.weekday, from: Date.now)) == day && storage.termRunningGB {

			if (
				(Calendar.current.component(.weekOfYear, from: storage.startDateGB) % 2) != 0
			) == (
				(Calendar.current.component(.weekOfYear, from: Date.now) % 2) != 0
			) {
				//they match, so currentWeek is same week a/b as originWeek
				if !storage.ghostWeekGB {
					wkAB == .a
				} else {
					wkAB == .b
				}
			} else {
				if !storage.ghostWeekGB {
					wkAB == .b
				} else {
					wkAB == .a
				}
			}
			
		} else {
			false
		}

		let dayString = ["Monday","Tuesday","Wednesday","Thursday","Friday"][day-2]
		NavigationLink(destination: EditTimetableDayView(tblIndex: tblIndex, week: wkAB, day: day)) {
			/*
			let isToday = Int(Calendar.current.component(.weekday, from: Date.now)) == day
			let isWeekA = getIfWeekIsA_FromDateAndGhost(originDate: storage.startDateGB, ghostWeek: storage.ghostWeekGB)
			let isActiveWeek = isWeekA == (wkAB == .a ? true : false)
			let shouldBold = isToday && storage.termRunningGB && isActiveWeek
			 */
			HStack {
				Text(dayString)
				Spacer()
				if isToday{
					Text("Today").foregroundStyle(.secondary)
				}
			}
		}
	}
}








/*
MARK: -
MARK: - EditTimetableDayView
• Day view
	• 1DAY LEVEL 2
	• SAVE CHANGES FROM HERE
	• Template view, used multiple times by master view, once for each day. seperated in hierarchy, not duplicated in parent view
	• from here, view periods and tap one to open editing sheet for that period
*/
fileprivate struct EditTimetableDayView: View {
	@EnvironmentObject var storage: Storage

	let tblIndex: Int
	let timingDetails: (weekab: WeekAB, weekday: Weekday)

	var timesVariation: (set: Times.TimingSet, variant: [UUID: Times.Period], name: String?) {
		let times = storage.timetables[tblIndex].times
		let timingSet = times.mapping[timingDetails.weekday] ?? .standard
		var variantName: String? = nil
		var variant: [UUID: Times.Period]? = nil
		switch timingSet {
			case .standard: variant = times.standard
			case .variant(let key):
				if !times.variants.keys.contains(key) {
					Logger.views.fault("Invalid mapping for day \(day, privacy: .public)")
				}
				let vnt = times.variants[key]!
				variantName = vnt.name

				variant = vnt.variant
		}
		return (timingSet, variant!, variantName)
	}


	@State private var didSyncWithEnvironment = false
	@State var day: [ UUID: Times.Period.Contents? ] //THIS IS WHAT WE'RE EDITING

	var pendingChanges: [Change] = []
	@State var isPendingChanges = false

	@State var discardConfirmation = false
	@Environment(\.dismiss) var dismiss

	@State var saveFailed = false

	@State var maximumRoomWidth: CGFloat = 0



	init(tblIndex: Int, week: WeekAB, day: Weekday) {
		self.timingDetails = (week, day)
		self.tblIndex = tblIndex

		_day = State(initialValue: Storage.shared.timetables[tblIndex].timetable[week]![day]!)

	}


	func compileChanges() -> [Change] {
		// Original snapshot for this week/day from storage (non-optional contents)
		guard let originalDay = storage.timetables[tblIndex]
			.timetable[timingDetails.weekab]?[timingDetails.weekday] else {
			Logger.editTimetable.fault("Couldn't load original day for week/day \(String(reflecting: timingDetails), privacy: .public)")
			return []
		}

		var changes: [Change] = []

		// Union of keys between original (non-optional) and edited (optional) dictionaries
		let allKeys = Set(originalDay.keys).union(day.keys)

		for periodID in allKeys {
			let originalValue: Times.Period.Contents? = originalDay[periodID]
			let editedValue: Times.Period.Contents?? = day[periodID] // outer optional: key existence; inner optional: free period

			switch (originalValue, editedValue) {
			case (nil, nil):
				// Neither had a value (unlikely because original is non-optional, but safe to ignore)
				break

			case (nil, .some(let maybeNew)):
				// Newly assigned contents where there wasn't one before
				if let newValue = maybeNew {
					changes.append(
						.week_modifyEntry(
							weekIndex: (timingDetails.weekab == .a ? 0 : 1),
							weekday: timingDetails.weekday,
							period: periodID,
							newValue,
							timetable: tblIndex
						)
					)
				} else {
					changes.append(
						.week_makeFreeEntry(
							weekab: timingDetails.weekab,
							weekday: timingDetails.weekday,
							period: periodID,
							timetable: tblIndex
						)
					)
				}

			case (.some(let old), .some(let maybeNew)):
				// Had a value before; may be updated or cleared now
				if let newValue = maybeNew {
					if old.courseID != newValue.courseID || old.roomIndex != newValue.roomIndex {
						changes.append(
							.week_modifyEntry(
								weekIndex: (timingDetails.weekab == .a ? 0 : 1),
								weekday: timingDetails.weekday,
								period: periodID,
								newValue,
								timetable: tblIndex
							)
						)
					}
				} else {
					changes.append(
						.week_makeFreeEntry(
							weekab: timingDetails.weekab,
							weekday: timingDetails.weekday,
							period: periodID,
							timetable: tblIndex
						)
					)
				}

			case (.some, nil):
				// Previous value existed, key now missing: treat as free period
				changes.append(
					.week_makeFreeEntry(
						weekab: timingDetails.weekab,
						weekday: timingDetails.weekday,
						period: periodID,
						timetable: tblIndex
					)
				)
			}
		}

		return changes
	}


	var navTitle: String {
		let suffix = if timingDetails.weekab == .a { " A" } else { " B" }
		return switch timingDetails.weekday {
			case 2: "Monday"+suffix
			case 3: "Tuesday"+suffix
			case 4: "Wednesday"+suffix
			case 5: "Thursday"+suffix
			case 6: "Friday"+suffix
			case 7: "Saturday"
			default: "Error \(#line)"
		}
	}

	var body: some View {
		NavigationStack {
			Group {
				if !timesVariation.variant.isEmpty {
					List {
						//list entry
						let courses = storage.timetables[tblIndex].courses
						ForEach(timesVariation.variant.sorted {$0.value.startTime<$1.value.startTime}, id: \.key
						) { (pdID, period) in

							TimetablePeriodRow(
								period: period,
								contents: Binding(
									get: { day[pdID] ?? nil },
									set: { day[pdID] = $0 }
								),
								courses: courses,
								maximumRoomWidth: $maximumRoomWidth
							)
							.listRowInsets(EdgeInsets())


						}//foreach
					}//list
				} else {
					VStack {
						Text("Map courses to periods here").padding(.bottom, 10)
						Text("There's no periods. Add some in Day Structure.")
					}.padding().foregroundStyle(.secondary)
				}
			}
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					if day != storage.timetables[tblIndex].timetable[timingDetails.weekab]?[timingDetails.weekday] {

						Button("Save changes", systemImage: "checkmark") {
							let changes = compileChanges()
							Logger.editTimetable.log("Saving \(changes.count, privacy: .public) Changes to timetable.")

							do {
								try storage.distributeChanges(changes)
								storage.applyChanges(changes)
							} catch {
								saveFailed = true
							}
							Logger.editTimetable.notice("Saved changes")
							// Reset local `day` to match the updated model so Save button disappears
							day = storage.timetables[tblIndex].timetable[timingDetails.weekab]![timingDetails.weekday]!
						}.tint(.blue)
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					Button {
						if day != storage.timetables[tblIndex].timetable[timingDetails.weekab]?[timingDetails.weekday] {
							discardConfirmation = true
						} else {
							dismiss()
						}
					} label: {
						if day != storage.timetables[tblIndex].timetable[timingDetails.weekab]?[timingDetails.weekday] {
							Label("Back", systemImage: "xmark")
						} else {
							Label("Back", systemImage: "chevron.left")
						}
					}
					.confirmationDialog(
						Text("Error \(#line)"),
						isPresented: $discardConfirmation
					) {
						Button("Discard Changes", role: .destructive) {
							withAnimation {
								guard let week = storage.timetables[tblIndex].timetable[timingDetails.weekab] else {
									Logger.editTimetable.fault("Week \(String(reflecting: timingDetails.weekab), privacy: .public ) invalid, cannot discard changes.")
									return
								}
								guard let d = week[timingDetails.weekday] else {
									Logger.editTimetable.fault("Weekday \(timingDetails.weekday, privacy: .public) invalid")
									return
								}
								day = d

							}
							Logger.views.info("Discarded changes to timetabled day")
						}
					} message: {
						Text("Are you sure you want to discard your changes?")
					}
				}

			}
			.alert("Couldn't send changes to watch.", isPresented: $saveFailed) {
				Button("OK") {
					saveFailed = false
				}
			}
			.navigationBarBackButtonHidden(true)
			.navigationTitle(navTitle)
			.navigationBarTitleDisplayMode(.inline)

			.onAppear {
				if !didSyncWithEnvironment {
					day = storage.timetables[tblIndex].timetable[timingDetails.weekab]![timingDetails.weekday]!
					didSyncWithEnvironment = true
					Logger.editTimetable.log("synced with environment for 'day' - \(String(reflecting: timingDetails))")
				}
			}

		}

	}//body
}







//MARK: - TimetablePeriodRow
/// Row displaying a single period in the day editor.
/// ## Discussion
/// Now takes a Binding to the period contents so edits can be propagated.
/// As of July 26, editing has been moved into Pickers embedded in the row itself rather than an external sheet. This is intended to streamline the process of 'bulk-editing' a day, especially when first creating the timetable.
fileprivate struct TimetablePeriodRow: View {
	let period: Times.Period
	@Binding var contents: Times.Period.Contents?
	let courses: [UUID: Course2]

	@State private var isSheetPresented: Bool = false
	@Binding var maximumRoomWidth: CGFloat

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

	/// Bind the optional 'contents'' courseID for the Picker, using nil to represent a free period
	private var selectedCourseIDBinding: Binding<UUID?> {
		Binding<UUID?> (
			get: { contents?.courseID },
			set: { newValue in
				withAnimation {
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
			}
		)
	}
	func setNewCourse(_ courseId: UUID?) {
		if let id = courseId {
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

	/// Binding for the roomIndex only if contents is non-nil
	private var roomIndexBinding: Binding<Int>? {
		guard contents != nil else { return nil }
		return Binding<Int>(
			get: { contents?.roomIndex ?? -1 },
			set: { n in withAnimation { contents?.roomIndex = n } }
		)
	}




	
	var coursePicker: some View {
		ZStack(alignment: .trailing) {
			Picker("Course", selection: selectedCourseIDBinding) {
				Text("Free period").tag(Optional<UUID>.none)
				Divider()
				ForEach(courses.map {(id: $0, course: $1)}.sorted(by: {$0.course.name < $1.course.name}), id: \.0) { entry in
					Label(entry.course.name, systemImage: entry.course.icon).tag(entry.id)
				}

			}
			.opacity(0)
			.labelsHidden()



			let fakeBinding: Binding<String> = Binding(get: { course.name }, set: { _ in } )
			Picker("fake picker!!", selection: fakeBinding) { Text(course.name).tag(course.name) }
			.labelsHidden().allowsHitTesting(false).tint(Colour.primary)

		}
		.layoutPriority(1)
		.if(course2 == nil) {
			$0.padding(.trailing)
		}
		.contentShape(Rectangle())
	}



	var roomPicker: some View {
		Group {
			if course2 != nil {
				HStack {
					if let binding = roomIndexBinding, let course2 = course2, !course2.rooms.isEmpty {
						Picker("Room", selection: binding) {
							ForEach(course2.rooms.map{(key:$0,room:$1)}, id: \.key) { tuple in
								Text(tuple.room).tag(tuple.key)
							}
						}
						.labelsHidden()
						.lineLimit(1)
						.foregroundStyle(.secondary)
						.onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { myWidth in
							if myWidth > maximumRoomWidth {
								maximumRoomWidth = myWidth
								Logger.editTimetable.debug("updated max width")
							}
						}
					} else {
						Colour.clear
					}
				}
				.frame(width: maximumRoomWidth, alignment: .trailing)
				.padding(.trailing).padding(.leading, -10)

			}
		}
	}



	var body: some View {

//		Button {
//			isSheetPresented = true
		//		} label: {
		HStack {

			//MARK: Period Display


			//MARK: Course Icon
			Image(systemName: course2?.icon ?? "clock")
				.frame(width: 25, height: 25)//, alignment: .trailing)
				.font(.title3)
				.padding(2)
				.foregroundColor((course2 != nil) ? course.colour.contrastingTextColor : .primary)

				.if(course2 != nil) {
					$0.background {
						RoundedRectangle(cornerRadius: 5.0).foregroundStyle( Colour(course.colour) )

					}
				}
				.padding(.trailing, 2)
				.padding(.leading)

			//MARK: Period Name
			Text(period.name)
				.lineLimit(1)
				.layoutPriority(2)
				.fixedSize()

			//period display


			Spacer()

			//MARK: Edit

			//course
			coursePicker


			//room
			roomPicker


		}//Row HStack


	}//body
}//TimetablePeriodRow - See extension below for viewbuilder stuff








//MARK: #Preview

#Preview {
	EditTimetableDayView(tblIndex: 0, week: .a, day: 2)
		.environmentObject(Storage.preview)
}

