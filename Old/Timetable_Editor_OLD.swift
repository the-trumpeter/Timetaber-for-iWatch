//
//  Timetable_Editor.swift
//  Timetaber
//
//  Created by Gill Palmer on 27/12/2025.
//

//MARK: NO TARGET MEMBERSHIP

import SwiftUI
import OSLog


//MARK: - Day

fileprivate struct EntryView: View {
	@State var showingSheet = false
	let day: [UUID: Times.Period.Contents]
	let key: UUID
	let courses: [UUID: Course2]
	let time: Time24?

	@State var properties: Times.Period.Contents

	@State var listedCourse: Course2

	init?(
		day: [UUID : Times.Period.Contents],
		key: UUID,
		courses: [UUID : Course2],
		time: Time24?
	)
	{
		self.showingSheet = false
		self.day = day
		self.key = key
		self.courses = courses

		guard let prop = day[key] else {
			Logger.editTimetable.fault("UUID \(key, privacy: .public) not present in day")
			return nil
		}
		self.properties = prop

		guard let course = courses[ prop.courseID ] else {
			Logger.editTimetable.fault("Course UID \(prop.courseID, privacy: .public) not valid")
			return nil
		}
		self.listedCourse = course

		self.time = time
	}

	var body: some View {

        HStack {
			let room = listedCourse.rooms[properties.roomIndex]
            let roomValid: Bool = (room != nil)

            Image(systemName: listedCourse.icon)
                .font(.title).frame(width: 30)
                .foregroundStyle(.secondary)

			Text(time?.display() ?? "Error \(#line)").bold()
            Spacer()
            VStack(alignment: .trailing) {
                Text(listedCourse.name).if(roomValid) { $0.font(.caption) }
                HStack {
                    if let room {
                        Text(room).bold()
                    }
                }
            }
        }
        
		//dayEntry
		.swipeActions(allowsFullSwipe: false) {

			Button("Clear", systemImage: "trash") {
				#warning("TODO Free periods")
			}.tint(.red)

			Button("Edit", systemImage: "pencil") {
				showingSheet=true
			}.tint(.orange)

		}.sheet(isPresented: $showingSheet) {
			let editor = DayEditorView(
				showingSheet: $showingSheet,
				properties: $properties,
                listedCourse: $listedCourse,
				courses: courses
			)
			editor
			.presentationDetents([.medium])
		}
	}
}


fileprivate struct DayEditorView: View {
    @State var courseIndex: UUID
	@State var roomIndex: Int?

	@Binding var showingSheet: Bool
	@Binding var properties: Times.Period.Contents
    @Binding var listedCourse: Course2

	let courses: [UUID: Course2]

	init(
        showingSheet: Binding<Bool>,
        properties: Binding<Times.Period.Contents>,
        listedCourse: Binding<Course2>,
        courses: [UUID : Course2]
    ) {
        // Initialize state from the current wrapped values
        self._showingSheet = showingSheet
        self._properties = properties
        self._listedCourse = listedCourse
        self.courses = courses
        // Derive initial picker selections from current properties
        self._courseIndex = State(initialValue: properties.wrappedValue.courseID)
        self._roomIndex = State(initialValue: properties.wrappedValue.roomIndex)
    }

	var body: some View {
		
		Picker("Course", selection: $courseIndex) {
			ForEach(Array(courses.keys).sorted(by: <), id: \.self) { _key in
				let _course = courses[_key]!
                Label(_course.name, systemImage: _course.icon).tag(_key)
			}
        }

		let rooms = courses[courseIndex]!.rooms
		Picker("Room", selection: $roomIndex) {
			if roomIndex != nil && !rooms.isEmpty {
				ForEach( (0...rooms.count-1), id: \.self) { _roomIndex in

					Text("\(rooms[_roomIndex]!, privacy: .public)").tag(_roomIndex)//.onAppear { Logger.<#logger#>.<#action#>( String(describing: roomIndex) ) }

				}
			} else {
                { roomIndex = nil; return EmptyView() }()
			}
		}.disabled(roomIndex == nil || rooms.isEmpty)
			//.onChange(of: roomIndex, { Logger.<#logger#>.<#action#>( "!! \(String(describing: roomIndex), privacy: .public)" ) })

        HStack {
            Button("Cancel") {
                showingSheet = false
            }.buttonStyle(.bordered)
            
            Button("Save") {
                guard let rIndex = roomIndex else {
					properties = Times.Period.Contents(courseID: courseIndex, roomIndex: -1)
                    return
                }
				properties = Times.Period.Contents(courseID: courseIndex, roomIndex: rIndex)
                listedCourse = courses[courseIndex]!
                //Logger.<#logger#>.<#action#>([courseIndex, index])
                showingSheet = false
				Logger.editTimetable.log("Hopefully (i.e. this probably hasn't) saved changes")
            }.buttonStyle(.borderedProminent)
        }
	}
}

///Edit the content of each week
struct EditDayView: View {
	//@EnvironmentObject var data: LocalData
	let timetable: Timetable
	@State var showingSheet: Bool
	@State var pendingChanges: Bool
	@State var header: String
	@State var week: WeekAB
	@State var day: [UUID : Times.Period.Contents]
	@State var weekday: Int
	@State var weekAOnly: Bool


	init(timetable: Timetable,
		header: String? = nil,
		week: WeekAB,
		weekAOnly: Bool = false
		) {
		let day = timetable.timetable[0].monday
		self.timetable = timetable
		self.showingSheet = false
		self.pendingChanges = false
		self.header = header ?? "Error \(#line)"
		self.week = week
		self.day = day
		self.weekday = 2
		self.weekAOnly = weekAOnly
	}

	var body: some View {
		let courses = timetable.courses
		var dayKeys: [UUID] {
			Array(day.keys).sorted(by: <).dropLast()
		}


		NavigationStack {
			List {
				ForEach(dayKeys, id: \.self) { key in
					let period = timetable.periodFromUUID(key)
					if let entry = EntryView(day: day, key: key, courses: courses, time: period?.startTime) {
						entry
					} else {
						Text("Error \(#line)")
					}


				}
			}.toolbar {

/*				ToolbarItem(placement: .topBarLeading) {
					Button("Back", systemImage: "chevron.left") { }
				}
 */


				ToolbarItem(placement: .navigation) {
					Menu(header) {

						let suffix = if weekAOnly { "" } else if week == .a { " A" } else { " B" }

/*						let _week = if week == .a {
							timetable.timetable[0]
						} else {
							timetable.timetable[1]
						}
 */

						ControlGroup {
							Button("Week A", systemImage: "a.square") { week = .a }
							Button("Week B", systemImage: "b.square") { week = .b }
						} label: { Label(header, systemImage: "a.square") }.menuActionDismissBehavior(.disabled)

						Picker("Day", selection: $weekday) {

							Text("Monday"+suffix).tag(2)
							Text("Tuesday"+suffix).tag(3)
							Text("Wednesday"+suffix).tag(4)
							Text("Thursday"+suffix).tag(5)
							Text("Friday"+suffix).tag(6)

						}.onChange(of: weekday) { _, new in
							//TODO: Update list
/*							header = switch new {
								case _week.monday: "Monday"+suffix
								case _week.tuesday: "Tuesday"+suffix
								case _week.wednesday: "Wednesday"+suffix
								case _week.thursday: "Thursday"+suffix
								case _week.friday: "Friday"+suffix
								default: "Error \(#line)"
							}
 */

						}
					}
				}

				ToolbarItem(placement: .confirmationAction) {
					if pendingChanges {
						Button(action: { /* TODO: implement save */ }) {
							Image(systemName: "checkmark")
						}.tint(.blue)
					}
				}

			}
		}

	}
}

