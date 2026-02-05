//
//  Courses_Editor.swift
//  Timetaber
//
//  Created by Gill Palmer on 27/12/2025.
//

import SwiftUI
import OSLog



fileprivate struct symbolchooser: View {
	@Binding var course: Course2
	//@Binding var debugDelayDismiss: Bool
	@Environment(\.dismiss) var dismiss
	var body: some View {
		ScrollView {
			LazyVGrid(
				columns: [
					GridItem(.fixed(50)),
					GridItem(.fixed(50)),
					GridItem(.fixed(50)),
					GridItem(.fixed(50))
				],
			) {
				ForEach(sfsymbols, id: \.self) { symbol in
					Button(symbol, systemImage: symbol) {
						course.icon = symbol
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {dismiss()} )

					}
					.font(.title)
					.labelStyle(.iconOnly)
					.frame(width: 45, height: 45)
					.buttonStyle(.plain)
					.if(course.icon == symbol) {
						$0.background {
							RoundedRectangle(cornerRadius: 5.0).foregroundStyle(.tertiary)
						}
					}
					.if(course.icon != symbol) {
						$0.background {
							RoundedRectangle(cornerRadius: 5.0).opacity(0.0)
						}
					}

					.padding(15)

				}
			}.padding()
		}

	}
}


//MARK: TimetablesListEditor/timetableOptions/CoursesEditor/coursebutton/courseEdit
fileprivate struct courseEdit: View {

	let tblIndex: Int
	let pos: UUID

	let isNewCourse: Bool

	@Binding var parentCourse: Course2
	@State var course: Course2
	@Binding var pendingChanges: [Change]?

	@State private var pendingRoom: String = ""
	@State private var coloursSheet = false
	@State private var iconSheetPopover = false

	let colours = ["Graphite", "Peach", "Lemon", "Rees1", "Apricot",
				   "Lime", "Ice", "Blueberry", "Rose", "Cherry"]

	@Environment(\.dismiss) var dismiss
	@FocusState private var nameFieldIsFocused: Bool


	@State var debugSymbolDismissDelay = false

	private func compileChanges() -> [Change] {
		
		var changes: [Change] = []

		let origin = parentCourse

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

				TextField("Course name", text: $course.name)
					.font(.title)
					.focused($nameFieldIsFocused)
					.task(id: isNewCourse) {
						// Ensure focus is requested after presentation settles to avoid slow/ignored focus
						if isNewCourse {
							await MainActor.run { course.name = "" }
							await MainActor.run { nameFieldIsFocused = true }
						}
					}
					.multilineTextAlignment(.leading)



				Button { iconSheetPopover.toggle() } label: {
					//let colour = Colour(course.colour)
					Image(systemName: course.icon)
						.font(.title)//.frame(width: 30, height: 30)
						.background {
							Circle()
								.opacity(0.0)
						}
						.padding(5)
				}.sheet(isPresented: $iconSheetPopover) {
					symbolchooser(course: $course, )//debugDelayDismiss: $debugSymbolDismissDelay)
				}

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
								let colour = colours[index]
								Button { course.colour = colour } label: {
									Circle()
										.fill(Colour(colour))
										.frame(width: 30, height: 30)
										.overlay {
											Circle()
												.stroke(Colour(colour).adjust(brightness: -0.2), lineWidth: 2)
										}
										.padding(5)
										.overlay {
											if course.colour == colour {
												Circle()
													.stroke(Color.accentColor, lineWidth: 3)
											}
										}
								}
							}
						}

						GridRow {
							ForEach(5...9, id: \.self) { index in
								let colour = colours[index]
								Button { course.colour = colour } label: {
									Circle()
										.fill(Colour(colour))
										.frame(width: 30, height: 30)
										.overlay {
											Circle()
												.stroke(Colour(colour).adjust(brightness: -0.2), lineWidth: 2)
										}
										.padding(5)
										.overlay {
											if course.colour == colour {
												Circle()
													.stroke(Color.accentColor, lineWidth: 3)
											}
										}
								}
							}
						}
					}.presentationDetents([.height(200)])

				} // colour (&sheet)

			}//.padding(.leading).padding(.bottom, 2)
			.padding()

			HStack {
				/*Image(systemName:
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
				TextField("SF Symbol slug", text: $course.icon).font(.system(size: 20)).autocorrectionDisabled(); #warning("TODO Create SF Symbol chooser")
				 */
			}//.padding(.leading) // icon

			List {
				ForEach(Array(course.rooms.keys), id: \.self) { roomKey in
					Text(course.rooms[roomKey]!)
						.swipeActions {
							Button("Delete", systemImage: "trash", role: .destructive) {
								course.rooms.removeValue(forKey: roomKey)
							//	Logger.<#logger#>.<#action#>(course.rooms)
							}.labelStyle(.iconOnly)
						}
				}
				HStack {
					TextField("Add Room", text: $pendingRoom).multilineTextAlignment(.leading); Spacer()
					Button("Save room", systemImage: "plus") {
						let trimmed = pendingRoom.trimmingCharacters(in: .whitespacesAndNewlines)
						guard !trimmed.isEmpty else { return }
						let nextKey = (course.rooms.keys.max() ?? -1) + 1
						course.rooms[nextKey] = trimmed
						pendingRoom = ""
					}
					.opacity(pendingRoom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.0 : 1.0)
					.buttonStyle(.bordered)
					.labelStyle(.iconOnly)
					.disabled(pendingRoom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

				}
				//Toggle("Symbols delay dismiss", systemImage: "stethoscope", isOn: $debugSymbolDismissDelay)
			}.scrollContentBackground(.hidden)
			// rooms

			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", systemImage: "xmark") {
						dismiss()
					}
				} 
				ToolbarItem(placement: .confirmationAction) {
					Button("Save", systemImage: "checkmark") {
						let changes = compileChanges()
						pendingChanges = changes + (pendingChanges ?? [])
						parentCourse = course
						Logger.editCourses.debug("parent course is now \(String(reflecting: parentCourse) )")
						dismiss()
					}
				}
			} // save/cancel

		}//.padding()

	}
}
//MARK: TimetablesListEditor/timetableOptions/CoursesEditor/coursebutton
fileprivate struct coursebutton: View {
	@State private var isPressed = false
	let tblIndex: Int
	var localCourses: Binding<[UUID: Course2]>
	var course: Binding<Course2>

	let isNewCourse: Bool


	let pos: UUID
	@State var showingSheet = false

	var pendingChanges: Binding<[Change]?>

	private var courseExists: Bool {
		localCourses.wrappedValue[pos] != nil
	}

	init(localCourses: Binding<[UUID : Course2]>, tblIndex: Int, pos: UUID, pendingChanges: Binding<[Change]?>, isNewCourse: Bool = false) {
		self.localCourses = localCourses
		self.course = Binding(
			get: { localCourses.wrappedValue[pos]! },
			set: { localCourses.wrappedValue[pos] = $0 }
		)
		self.tblIndex = tblIndex
		self.pos = pos
		self.showingSheet = false
		self.pendingChanges = pendingChanges
		self.isNewCourse = isNewCourse

	}

	var body: some View {
		Button { showingSheet.toggle() } label: {

			HStack {
				RoundedRectangle(cornerRadius: 2)
					.fill(Colour(course.wrappedValue.colour))
					.frame(width: 4)

				Image(systemName: course.wrappedValue.icon)
				Text(course.wrappedValue.name).lineLimit(1)

				Spacer()

                let joinedRooms: String = course.wrappedValue.rooms
                    .sorted(by: { $0.key < $1.key })
                    .map { $0.value }
                    .joined(separator: "; ")

				Text(joinedRooms)
					.foregroundStyle(.secondary)
					.frame(maxWidth: 150, alignment: .trailing)
					.lineLimit(1)
			}.contentShape(Rectangle())
		}


		.buttonStyle(.plain)
		.disabled(!courseExists)

		.sheet(isPresented: $showingSheet) {
			courseEdit(tblIndex: tblIndex, pos: pos, isNewCourse: isNewCourse, parentCourse: course, course: course.wrappedValue, pendingChanges: pendingChanges)
				.presentationDetents([.medium])
		}
		.onChange(of: courseExists) { _, exists in
			if !exists {
				showingSheet = false
			}
		}
	}
}

//MARK: TimetablesListEditor/timetableOptions/CoursesEditor

///Edit courses.
struct CoursesEditor: View {
	@ObservedObject var store: Storage = Storage.shared
	let tblIndex: Int

	@State var pendingChanges: [Change]? = nil

	@State var localCourses: [UUID: Course2]

	@State var newCourseSheet = false
	@State var newCourse_fakePending: [Change]? = nil //courseEdit computes EDITS from tblIndex and pos, but it writes them back here where I can discard them and replace them with a .course_add
	@State var newCourse_fakeNewCourse: Course2 = Course2("\u{0000}\u{0001}\u{0002}\u{0003}\u{0004}\u{0005}\u{0006}\u{0007}", icon: "book.closed", rooms: [], colour: "Graphite", identifier: .standard) //courseEdit wil be comparing its normal Course2 with a control one of impossible characters, therefore there will always be changes.

	@State var showingAlert = false
	@State var alertIndex: UUID? = nil

	init(tblIndex: Int = 0) {
		self.tblIndex = tblIndex
		self.localCourses = Storage.shared.timetables[tblIndex].courses
	}
	var body: some View {
		NavigationStack {
			List {
                // Precompute a stable, type-explicit sorted list to help the type-checker
                let sortedCourses: [(id: UUID, course: Course2)] = localCourses
                    .map { ($0.key, $0.value) }
                    .sorted { lhs, rhs in
                        lhs.1.name.localizedCaseInsensitiveCompare(rhs.1.name) == .orderedDescending
                    }

                ForEach(sortedCourses, id: \.id) { entry in
                    let index = entry.id
                    coursebutton(localCourses: $localCourses, tblIndex: tblIndex, pos: index, pendingChanges: $pendingChanges)
				}

				Button("Add Course", systemImage: "plus") {
					newCourse_fakePending = []
					newCourse_fakeNewCourse = Course2("\u{0000}\u{0001}\u{0002}\u{0003}\u{0004}\u{0005}", icon: "book.closed", rooms: [], colour: "Graphite", identifier: .standard)

					newCourseSheet.toggle()
				}
				.sheet(isPresented: $newCourseSheet) {
					///ondismiss
					if newCourse_fakeNewCourse.name != "\u{0000}\u{0001}\u{0002}\u{0003}\u{0004}\u{0005}\u{0006}\u{0007}" {
						let id = UUID()
						pendingChanges = [Change.course_create(index: id, newCourse_fakeNewCourse, timetable: tblIndex)] + (pendingChanges ?? [])
						localCourses.applyCourseChanges([Change.course_create(index: id, newCourse_fakeNewCourse, timetable: tblIndex)])
					}
				} content: {
					courseEdit(tblIndex: 0, pos: UUID(), isNewCourse: true, parentCourse: $newCourse_fakeNewCourse, course: Course2("Course", icon: "book.closed", rooms: [], colour: "Graphite", identifier: .standard), pendingChanges: $newCourse_fakePending)
						.presentationDetents([.medium])
				}



			}.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					if !(pendingChanges?.isEmpty ?? true) {
						Button("Save", systemImage: "checkmark") {
							do{	try store.distributeChanges(pendingChanges!)
							} catch { return /** prompt user to copy changes to new timetable */ }

							store.applyChanges(pendingChanges!)

							pendingChanges = nil
						}
					}
				}
			}

			.onAppear {
				localCourses = store.timetables[tblIndex].courses
			}
		}
		.alert("Delete \"\( (alertIndex.flatMap { localCourses[$0]?.name }) ?? "Error \(#line)" )\"?", isPresented: $showingAlert) {
			Button("Delete", role: .destructive) {
				// Capture the course name before deletion so we can still display/log it after removal
				let deletedName = alertIndex.flatMap { localCourses[$0]?.name } ?? "Error \(#line)"

				// Ensure we have a valid UUID to delete
				guard let id = alertIndex else { return }
				let change = Change.course_delete(index: id, timetable: tblIndex)
				pendingChanges = [change] + (pendingChanges ?? [])
				localCourses.applyCourseChanges([change])

				Logger.editCourses.log("Unconfirmedly removed \"\(deletedName)\" from UI courses")
			}
			Button("Cancel", role: .cancel) {}
		}.navigationTitle("All Courses")
			.onAppear {
				Logger.editCourses.log("Started editing courses")
			}
	}
}

