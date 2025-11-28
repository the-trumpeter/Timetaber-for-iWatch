//
//  TimetableCreatorView.swift
//  Timetaber
//
//  Created by Gill Palmer on 7/11/2025.
//
import SwiftUI

extension View {
	@ViewBuilder
	func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}

struct EditDayEntryView: View {
	@State var course: Course2
	@State var room: Int
	@State var time: Int

	@Environment(\.colorScheme) private var colourScheme

	var body: some View {
		
	}
}

struct EntryView: View {
	@State var showingSheet = false
	let day: [Int: [Int]]
	let key: Int
	let courses: [Int: Course2]

	@State var properties: [Int]

	@State var listedCourse: Course2

	init(
		day: [Int : [Int]],
		key: Int,
		courses: [Int : Course2],
	)
	{
		self.showingSheet = false
		self.day = day
		self.key = key
		self.courses = courses
		self.properties = day[key]!
		self.listedCourse = courses[ day[key]![0] ]!
	}

	var body: some View {

        HStack {
            let roomValid: Bool = listedCourse.rooms.indices.contains(properties[1])
            Image(systemName: listedCourse.icon)
                .font(.title).frame(width: 30)
                .foregroundStyle(.secondary)

            Text(time24toNormal(key)).bold()
            Spacer()
            VStack(alignment: .trailing) {
                Text(listedCourse.name).if(roomValid) { $0.font(.caption) }
                HStack {
                    if roomValid {
                        Text(listedCourse.rooms[properties[1]]).bold()
                    }
                }
            }
        }
        
		//dayEntry
		.swipeActions(allowsFullSwipe: false) {

			Button("Clear", systemImage: "trash") { print("~ \(properties)") }.tint(.red)

			Button("Edit", systemImage: "pencil") {
				showingSheet=true
			}.tint(.orange)

		}.sheet(isPresented: $showingSheet) {
			let editor = DayEditorView(
				courseIndex: properties[0],
				roomIndex: properties[1],
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


struct DayEditorView: View {
    @State var courseIndex: Int
	@State var roomIndex: Int?

	@Binding var showingSheet: Bool
	@Binding var properties: [Int]
    @Binding var listedCourse: Course2

	let courses: [Int: Course2]

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

					Text("\(rooms[_roomIndex])").tag(_roomIndex).onAppear { print( String(describing: roomIndex) ) }

				}
			} else {
                { roomIndex = nil; return EmptyView() }()
			}
		}.disabled(roomIndex == nil || rooms.isEmpty)
			.onChange(of: roomIndex, { print( "!! \(String(describing: roomIndex))" ) })
        
        HStack {
            Button("Cancel") {
                showingSheet = false
            }.buttonStyle(.bordered)
            
            Button("Save") {
                guard let index = roomIndex else {
                    properties = [courseIndex]
                    return
                }
                properties = [courseIndex, index]
                listedCourse = courses[courseIndex]!
                print([courseIndex, index])
                showingSheet = false
                print("saved, hopefully")
            }.buttonStyle(.borderedProminent)
        }
	}
}


struct EditDayView: View {
	//@EnvironmentObject var data: LocalData
	let timetable: Timetable
	@State var showingSheet: Bool
	@State var pendingChanges: Bool
	@State var header: String
	@State var week: WeekAB
	@State var day: [Int : [Int]]
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
		self.header = header ?? "Monday A"
		self.week = week
		self.day = day
		self.weekday = 2
		self.weekAOnly = weekAOnly
	}

	var body: some View {
		let courses = timetable.courses
		var dayKeys: [Int] {
			Array(day.keys).sorted(by: <).dropLast()
		}


		NavigationStack {
			List {
				ForEach(dayKeys, id: \.self) { key in

					EntryView(day: day, key: key, courses: courses)

				}
			}.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Back", systemImage: "chevron.left") { }
				}


				ToolbarItem(placement: .navigation) {
					Menu(header) {

						let suffix = if weekAOnly { "" } else if week == .a { " A" } else { " B" }
						/*let _week = if week == .a {
							timetable.timetable[0]
						} else {
							timetable.timetable[1]
						}*/

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
							/*header = switch new {
								case _week.monday: "Monday"+suffix
								case _week.tuesday: "Tuesday"+suffix
								case _week.wednesday: "Wednesday"+suffix
								case _week.thursday: "Thursday"+suffix
								case _week.friday: "Friday"+suffix
								default: "Error \(#line)"
							}*/
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

#Preview {
	EditDayView(
		timetable: chaos,
		week: .a
	).environmentObject(LocalData.shared)
}

