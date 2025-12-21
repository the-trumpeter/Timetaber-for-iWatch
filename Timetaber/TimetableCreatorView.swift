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

extension Color {
	func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
		let color = UIColor(self)
		var currentHue: CGFloat = 0
		var currentSaturation: CGFloat = 0
		var currentBrigthness: CGFloat = 0
		var currentOpacity: CGFloat = 0

		if color.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentOpacity) {
			return Color(hue: currentHue + hue, saturation: currentSaturation + saturation, brightness: currentBrigthness + brightness, opacity: currentOpacity + opacity)
		}
		return self
	}
}

extension Dictionary where Key == Int, Value == Course2 {
	func applyCourseChanges(_ changes: [Change]) -> [Int: Course2] {
		var courses: [Int: Course2] = self
		for change in changes {
			switch change {
				case .course_create(index: let index, let value, timetable: let tblIndex):
					courses.updateValue(value, forKey: index)

				case .course_delete(index: let index, timetable: let tblIndex):
					courses.removeValue(forKey: index)

				case .course_modify(index: let index, let coursechange, timetable: let tblIndex):
					switch coursechange {
					case .colour(let new): courses[index]?.colour = new
					case .rooms(let new): courses[index]?.rooms = new
					case .icon(let new): courses[index]?.icon = new
					case .name(let new): courses[index]?.name = new
					}
			default: print("\(#file):\(#line) Couldn't apply change \(change) to value of type [Int: Course2]")
			}
		}
		return courses
	}
}


//MARK: - Day

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
            let room = listedCourse.rooms[properties[1]]
            let roomValid: Bool = (room != nil)

            Image(systemName: listedCourse.icon)
                .font(.title).frame(width: 30)
                .foregroundStyle(.secondary)

            Text(time24toNormal(key)).bold()
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

					Text("\(rooms[_roomIndex]!)").tag(_roomIndex).onAppear { print( String(describing: roomIndex) ) }

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



//MARK: - Instruction to Coding Assistant: Ignore everything between Line 35 and Line 270 (this line), unless explicitly directed not to.





//MARK: TimetablesListEditor/timetableOptions/CoursesEditor/coursebutton/courseEdit
struct courseEdit: View {
	@ObservedObject var store: Storage = Storage.shared

	@Binding var localTimetable: Timetable
	let tblIndex: Int
	let pos: Int

	@Binding var course: Course2
	@Binding var pendingChanges: [Change]?

	@State var pendingRoom: String = ""
	@State var coloursSheet = false

	let culours = ["Graphite", "Peach", "Lemon", "Rees1", "Apricot",
				   "Lime", "Ice", "Blueberry", "Rose", "Cherry"]

	@Environment(\.dismiss) var dismiss

	private func compileChanges() -> [Change] {
		var changes: [Change] = []
		let origin = localTimetable.courses[pos]!

		if course.name != origin.name {
			changes.append(Change.course_modify(index: pos, .name(course.name), timetable: tblIndex))
		}
		if course.icon.lowercased() != origin.icon {
			changes.append(Change.course_modify(index: pos, .icon(course.icon), timetable: tblIndex))
		}
		if course.colour != origin.colour {
			changes.append(Change.course_modify(index: pos, .colour(course.colour), timetable: tblIndex))
		}
		if course.rooms != origin.rooms {
			changes.append(Change.course_modify(index: pos, .rooms(course.rooms), timetable: tblIndex))
		}

		return changes
	}

	var body: some View {
		NavigationStack {

			HStack(alignment: .center) {

				Button { coloursSheet.toggle() } label: {
					let colour = Colour(course.colour)
					Circle()
						.fill(colour)
						.frame(width: 30, height: 30)
						.overlay {
							Circle()
								.stroke(colour.adjust(brightness: -0.2), lineWidth: 2)
						}
						.padding(5)
				}.sheet(isPresented: $coloursSheet) {
					HStack {
						Image(systemName: course.icon.lowercased()).font(.title)
						Text(course.name).font(.title)
					}.padding(5)
						.background { RoundedRectangle(cornerRadius: 10).foregroundStyle(Colour(course.colour)) }//.secondary) }


					Grid {
						GridRow {
							ForEach(0...4, id: \.self) { index in
								let culour = culours[index]
								Button { course.colour = culour } label: {
									Circle()
										.fill(Colour(culour))
										.frame(width: 30, height: 30)
										.overlay {
											Circle()
												.stroke(Colour(culour).adjust(brightness: -0.2), lineWidth: 2)
										}
										.padding(5)
										.overlay {
											if course.colour == culour {
												Circle()
													.stroke(Color.accentColor, lineWidth: 3)
											}
										}
								}
							}
						}

						GridRow {
							ForEach(5...9, id: \.self) { index in
								let culour = culours[index]
								Button { course.colour = culour } label: {
									Circle()
										.fill(Colour(culour))
										.frame(width: 30, height: 30)
										.overlay {
											Circle()
												.stroke(Colour(culour).adjust(brightness: -0.2), lineWidth: 2)
										}
										.padding(5)
										.overlay {
											if course.colour == culour {
												Circle()
													.stroke(Color.accentColor, lineWidth: 3)
											}
										}
								}
							}
						}
					}.presentationDetents([.height(200)])

				} // colour (&sheet)


				TextField("Course name", text: $course.name).font(.title) // Name

			}.padding(.leading).padding(.bottom, 2)

			HStack {
				Image(systemName:
						UIImage(systemName: course.icon.lowercased()) != nil ?
					  course.icon.lowercased() : "questionmark.square.dashed"
				)
				.font(.title)
				.frame(width: 30)
				.padding(5)
				.foregroundStyle(
					UIImage(systemName: course.icon.lowercased()) != nil ?
						.primary : .secondary
				)
				TextField("SF Symbol slug", text: $course.icon).font(.system(size: 20)).autocorrectionDisabled()
			}.padding(.leading) // icon

			List {
				ForEach(Array(course.rooms.keys), id: \.self) { roomKey in
					Text(course.rooms[roomKey]!)
						.swipeActions {
							Button("Delete", systemImage: "trash", role: .destructive) {
								course.rooms.removeValue(forKey: roomKey)
							//	print(course.rooms)
							}.labelStyle(.iconOnly)
						}
				}
				HStack {
					TextField("Add Room", text: $pendingRoom); Spacer()
					Button("Save room", systemImage: "plus") {
						let trimmed = pendingRoom.trimmingCharacters(in: .whitespacesAndNewlines)
						guard !trimmed.isEmpty else { return }
						let nextKey = (course.rooms.keys.max() ?? -1) + 1
						course.rooms[nextKey] = trimmed
						pendingRoom = ""
					}
					.buttonStyle(.bordered)
					.labelStyle(.iconOnly)
					.disabled(pendingRoom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				}
			} // rooms

			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", systemImage: "xmark") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save", systemImage: "checkmark") {
						let changes = compileChanges()

						dismiss()
					}
				}
			} // save/cancel

		}

	}
}


//MARK: TimetablesListEditor/timetableOptions/CoursesEditor/coursebutton
struct coursebutton: View {
	@State var course: Course2
	let tblIndex: Int
	@State var pos: Int
	@Binding var localTimetable: Timetable
	@State var showingSheet = false
	@Binding var pendingChanges: [Change]?

	var body: some View {
		Button { showingSheet.toggle() } label: {
			HStack {
				RoundedRectangle(cornerRadius: 2, style: .continuous)
					.fill(Colour(course.colour))
					.frame(width: 4)

				Image(systemName: course.icon)
				Text(course.name).lineLimit(1)
				Spacer()
				let joinedRooms = course.rooms.keys.sorted().compactMap { course.rooms[$0] }.joined(separator: "; ")
				Text(joinedRooms).foregroundStyle(.secondary).frame(minWidth: 0, maxWidth: 150, alignment: .trailing).lineLimit(1)
			}
		}.buttonStyle(.plain)
			.sheet(isPresented: $showingSheet) {
				courseEdit(localTimetable: $localTimetable, tblIndex: tblIndex, pos: pos, course: $course, pendingChanges: $pendingChanges)
					.presentationDetents([.medium])
			}
	}
}
//MARK: TimetablesListEditor/timetableOptions/CoursesEditor
struct CoursesEditor: View {
	@ObservedObject var store: Storage = Storage.shared
	let tblIndex: Int
	@State var pendingChanges: [Change]? = nil
	@State var localCourses: [Int: Course2]
	init(tblIndex: Int) {
		self.store = Storage.shared
		self.tblIndex = tblIndex
		self.pendingChanges = nil
		self.localCourses = Storage.shared.timetables[tblIndex].courses
	}
	var body: some View {
		NavigationStack {
			List {
				let courseIndices: [Int] = store.timetables[tblIndex].courses.keys.sorted()
				ForEach(courseIndices, id: \.self) { index in
					coursebutton(course: localCourses[index]!, tblIndex: tblIndex, pos: index, localTimetable: $store.timetables[tblIndex], pendingChanges: $pendingChanges)
						.swipeActions(allowsFullSwipe: false) {
							Button("Delete", systemImage: "trash", role: .destructive) {
								pendingChanges = [Change.course_delete(index: index, timetable: tblIndex)] + (pendingChanges ?? [])

							}.labelStyle(.iconOnly)
						}
				}
				Button("Add Course", systemImage: "plus") { }
			}.toolbar {
				if pendingChanges != nil {
					Button("Save", systemImage: "checkmark") {
					do{	try store.distributeChanges(pendingChanges!)
						} catch { return /** prompt user to copy changes to new timetable */ }

						store.applyChanges(pendingChanges!)
					}
				}
			}
		}
	}
}

//MARK: TimetablesListEditor/timetableOptions
struct timetableOptions: View {

	@Binding var timetable: Timetable
	let tblIndex: Int
	@State var icon: String
	@State var name: String

	init(_ timetable: Binding<Timetable>, index: Int) {
		self.tblIndex = index
		self._timetable = timetable
		self._icon = State(initialValue: timetable.wrappedValue.icon)
		self._name = State(initialValue: timetable.wrappedValue.name)
	}

	var body: some View {
		NavigationStack {
			List {
				HStack {
					TextField("Name", text: $name)
						.font(.title)
						.onSubmit {
							if name.isEmpty { name = timetable.name }
							timetable.name = name
						}
					Picker(selection: $icon) {
						Image(systemName: "backpack").tag("backpack")
						Image(systemName: "graduationcap").tag("graduationcap")
						Image(systemName: "list.bullet").tag("list.bullet")
					}label:{}.pickerStyle(.menu)
						.tint(.primary)
				}


				NavigationLink { CoursesEditor(tblIndex: tblIndex) } label: {
					HStack { Text("Courses").foregroundStyle(.primary); Spacer();
						Text(String(timetable.courses.count)).foregroundStyle(.secondary) }
				}
				NavigationLink { } label: { HStack { Text("Times").foregroundStyle(.primary); Spacer(); Text(String(timetable.times.variants.count)).foregroundStyle(.secondary) } }
				NavigationLink { } label: { HStack { Text("Timetable").foregroundStyle(.primary); Spacer(); Text("\(timetable.timetable.count) week\( timetable.timetable.count != 1 ? "s":"")").foregroundStyle(.secondary) } }

				Button("Delete \"\(name)\"", systemImage: "trash", role: .destructive) { }

			}
			.listStyle(.inset)
			.background(Colour.clear)
			.scrollDisabled(true)


		}
		.padding()
	}
}


//MARK: TimetablesListEditor
struct TimetablesListEditor: View {

	@ObservedObject var store: Storage = Storage.shared
	@State var showingSheet = true
	@State var timetableIndex = Storage.shared.ActiveTimetable

	var body: some View {
		NavigationStack {

			let editingTimetable = store.timetables[timetableIndex]

			timetableOptions($store.timetables[timetableIndex], index: timetableIndex)

			.toolbar {
				ToolbarItem(placement: .navigation) {

					Picker(editingTimetable.name, selection: $timetableIndex) {
						let indicies = store.timetables.indices.sorted()
						ForEach(indicies, id: \.self) { index in
							let tble = store.timetables[index]
							Label(tble.name, systemImage: tble.icon).tag(index)
						}

					}.labelStyle(.titleOnly)
				}
			}
		}
	}
}




#Preview {
	/*EditDayView(
	 timetable: chaos,
	 week: .a
	 ).environmentObject(LocalData.shared)
	 */

	let tblIndex = 0
	
	CoursesEditor(tblIndex: 0)
}

