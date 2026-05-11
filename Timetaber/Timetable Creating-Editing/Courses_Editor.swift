//
//  Courses_Editor.swift
//  Timetaber
//
//  Created by Gill Palmer on 27/12/2025.
//

import SwiftUI
import OSLog

typealias ColourPicker = ColorPicker





// Source - https://stackoverflow.com/a/79637700
// Posted by Forrest, modified by community. See post 'Timeline' for change history
// Retrieved 2026-04-27, License - CC BY-SA 4.0

private struct ColorPickerSizeModifier: ViewModifier {
	let width: CGFloat
	let height: CGFloat

	@State private var systemSize: CGSize?

	private var scale: CGSize {
		guard let systemSize else { return CGSize(width: 1, height: 1) }

		return CGSize(
			width: width / systemSize.width,
			height: height / systemSize.height
		)
	}

	func body(content: Content) -> some View {
		return content
			.scaleEffect(scale)
			.overlay {
				GeometryReader { geometry in
					Color.clear
						.preference(key: SystemSizeKey.self, value: geometry.size)
				}
			}
			.onPreferenceChange(SystemSizeKey.self) { [$systemSize] height in
				$systemSize.wrappedValue = height
			}
			.frame(width: width, height: height)
	}
}

private struct SystemSizeKey: PreferenceKey {
	static let defaultValue: CGSize = .zero
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

extension View {
	func colorPickerWheelFrame(width: CGFloat, height: CGFloat) -> some View {
		modifier(ColorPickerSizeModifier(width: width, height: height))
	}
}

// End copyrighted content







//MARK: New Symbol Chooser
fileprivate struct symbolBackground: View {
	@Binding var course: Course2
	let symbol: String
	var body: some View {
		RoundedRectangle(cornerRadius: 5.0)
			.foregroundStyle(Colour(course.colour))
			.opacity((course.icon != symbol) ? 0.0 : 1.0)
	}
}

fileprivate struct symbolchooser_new: View {
	@Binding var course: Course2
	let colours: [String]

	//	@Environment(\.dismiss) var dismiss

	var body: some View {

		HStack {
			let name = if course.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { "Course" } else { course.name }
			Image(systemName: course.icon.lowercased()).font(.title)
			Text(name).font(.title)
		}
		.foregroundColor(course.colour.contrastingTextColor)

		.padding(5)
		.background {
			RoundedRectangle(cornerRadius: 10)
				.foregroundStyle(course.colour)
		}//.secondary) }
		.padding(.top, 30)
		.padding(.bottom, 3)

		ScrollView(.vertical, showsIndicators: true) {//TODO: Open scroll on selected item
			Spacer().frame(height: 20)
			ForEach(0...(sfsymbols.count)/4-1, id: \.self) { I in

				HStack(spacing: 12) {

					let sI = if I==0 { 0 } else { (I*4) }
					let symbolIndexes = sI...(sI+3)
					ForEach(symbolIndexes, id: \.self) { i in

						let symbol = sfsymbols[i]
						if i == sI {
							Spacer()
						}
						Image(systemName: symbol)
							.onTapGesture {
								course.icon = symbol
							}
							.foregroundColor(course.icon == symbol ? course.colour.contrastingTextColor : .primary)

							.font(.title)
						//							.labelStyle(.iconOnly)
							.frame(width: 45, height: 45)
							.background {
								symbolBackground(course: $course, symbol: symbol)
							}
						Spacer().if(i != sI+3) { $0.frame(maxWidth: 2) }
					}
				}
				if I != (sfsymbols.count)/4-1 {
					Spacer().frame(height: 20)
				}
			}
			//			.padding(.horizontal, 10)
			Spacer().frame(height: 30)
		}
		.mask(
			LinearGradient(
				gradient: Gradient(stops: [
					.init(color: .clear, location: 0.0),
					.init(color: .black, location: 0.1),
					.init(color: .black, location: 0.9),
					.init(color: .clear, location: 1.0),
				]),
				startPoint: .top,
				endPoint: .bottom
			)
		)
		.padding(.bottom, -3)
		.presentationDetents([.height(500)])
	}
}





//MARK: ~/coursebutton/courseEdit
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

	let colours = ["black", "graphite", "peach", "lemon", 	  "rees1", "apricot",
				   "white", "lime", 	"ice", 	 "blueberry", "rose",  "cherry"]

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


				//MARK: Icon
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
					symbolchooser_new(course: $course, colours: colours)//debugDelayDismiss: $debugSymbolDismissDelay)

				}

				//MARK: Colours
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

					VStack {
						//MARK: sheet
						//Preview
						HStack {
							HStack {
								let name = if course.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { "Course" } else { course.name }
								Image(systemName: course.icon.lowercased()).font(.title)
								Text(name).font(.title)
							}
							.foregroundColor(course.colour.contrastingTextColor)
							.padding(5)
							.background {
								RoundedRectangle(cornerRadius: 10)
									.foregroundStyle(course.colour)
							}

							Spacer()

							//custom colour
							Circle() //put identical circle behind so layout doesn't change
								.fill(Colour.clear)
								.frame(width: 30, height: 30)
								.overlay {
									Circle()
										.stroke(Colour.clear, lineWidth: 2)
								}
								.padding(5)
								.overlay { //layout-insensitive overlay of ColourPicker
									ColourPicker("Course colour", selection: $course.colour, supportsOpacity: false)
										.labelsHidden()
										.colorPickerWheelFrame(width: 35, height: 35)
								}
						}
						.padding(.bottom, 12)

						//Colour grid
						VStack {

							//top 6, minus 'black'
							HStack {
								ForEach(1...5, id: \.self) { i in
									let colour = colours[i]
									Button { course.colour = Colour(colour) } label: {
										Circle()
											.fill(Colour(colour.lowercased()))
											.frame(width: 30, height: 30)
											.overlay {
												Circle()
													.stroke(Colour(colour.lowercased()).adjust(brightness: -0.2), lineWidth: 2)
											}
											.padding(5)
											.overlay {
												if course.colour == Colour(colour) {
													Circle()
														.stroke(Color.accentColor, lineWidth: 3)
												}
											}
										if i != 5 { Spacer() }
									}
								}
							}

							//bottom
							HStack {
								//bottom 5 colours, minus 'white'
								ForEach(7...11, id: \.self) { i in
									let colour = colours[i]
									Button { course.colour = Colour(colour) } label: {
										Circle()
											.fill(Colour(colour))
											.frame(width: 30, height: 30)
											.overlay {
												Circle()
													.stroke(Colour(colour).adjust(brightness: -0.2), lineWidth: 2)
											}
											.padding(5)
											.overlay {
												if course.colour == Colour(colour) {
													Circle()
														.stroke(Color.accentColor, lineWidth: 3)
												}
											}
										if i != 11 { Spacer() }
									}
								}
							}
						}

					}
					.padding(.leading, 45)
					.padding(.trailing, 45)

					.presentationDetents([.height(210)])

				} // colour (&sheet)



			}
			.padding()
			//Header HStack end






			//MARK: Old icon
			//			HStack {
			//				Image(systemName:
			//						UIImage(systemName: course.icon.lowercased()) != nil ?
			//					  course.icon.lowercased() : "questionmark.square.dashed"
			//				)
			//				.font(.title)
			//				.frame(width: 30)
			//				.padding(5)
			//				.foregroundStyle(
			//					UIImage(systemName: course.icon.lowercased()) != nil ?
			//						.primary : .secondary
			//				)
			//				TextField("SF Symbol slug", text: $course.icon).font(.system(size: 20)).autocorrectionDisabled(); #warning("TODO Create SF Symbol chooser")
			//
			//			}.padding(.leading)

			//MARK: Rooms
			List {
				ForEach(Array(course.rooms.keys), id: \.self) { roomKey in
					Text(course.rooms[roomKey]!) //TODO: Make editable
						.swipeActions {
							Button("Delete", systemImage: "trash", role: .destructive) { //TODO: Confirmation to delete course
								course.rooms.removeValue(forKey: roomKey)
							}.labelStyle(.iconOnly)
						}
				}
				HStack {
					TextField("Add Room", text: $pendingRoom)
						.multilineTextAlignment(.leading)
						.onSubmit {
							let trimmed = pendingRoom.trimmingCharacters(in: .whitespacesAndNewlines)
							guard !trimmed.isEmpty else { return }
							let nextKey = (course.rooms.keys.max() ?? -1) + 1
							course.rooms[nextKey] = trimmed
							pendingRoom = ""
						}
					Spacer()
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
			}.scrollContentBackground(.hidden)



			//MARK: Toolbar
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
						Button("Save", systemImage: "checkmark") {
							let changes = compileChanges()
							withAnimation {
								pendingChanges = changes + (pendingChanges ?? [])
								parentCourse = course
							}
							Logger.editCourses.debug("parent course is now \(String(reflecting: parentCourse), privacy: .public )")
							dismiss()
						}
					}
				}
				.navigationBarTitleDisplayMode(.inline)

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
		let roomsArray: [(Int, String)] = course.wrappedValue.rooms.map { ($0.key, $0.value) }
		let sortedRooms: [(Int, String)] = roomsArray.sorted { (lhs: (Int, String), rhs: (Int, String)) -> Bool in
			lhs.0 < rhs.0
		}
		let joinedRooms: String = sortedRooms.map { (pair: (Int, String)) in pair.1 }.joined(separator: "; ")

		Button { showingSheet.toggle() } label: {

			HStack {
				RoundedRectangle(cornerRadius: 2)
					.fill(Colour(course.wrappedValue.colour))
					.frame(width: 4)

				Image(systemName: course.wrappedValue.icon)
				Text(course.wrappedValue.name).lineLimit(1)

				Spacer()

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
			//INTERACTIVE DISMISS
				.interactiveDismissDisabled()
		}
		.onChange(of: courseExists) { _, exists in
			if !exists {
				showingSheet = false
			}
		}
	}
}



fileprivate struct CoursesListRows: View {
	let sortedIDs: [UUID]
	@Binding var localCourses: [UUID: Course2]
	let tblIndex: Int
	@Binding var pendingChanges: [Change]?

	var body: some View {
		ForEach(sortedIDs, id: \.self) { key in
			coursebutton(localCourses: $localCourses,
						 tblIndex: tblIndex,
						 pos: key,
						 pendingChanges: $pendingChanges)
			.swipeActions(edge: .trailing) {
				Button("Delete", role: .destructive) {
					pendingChanges = [Change.course_delete(index: key, timetable: tblIndex)] + (pendingChanges ?? [])
				}
			}
		}
	}
}

//MARK: Public access Courses editor

///Edit courses.
struct CoursesEditor: View {
	@ObservedObject var store: Storage = Storage.shared
	let tblIndex: Int

	@State var pendingChanges: [Change]? = nil
	@State var localCourses: [UUID: Course2]

	@State var newCourseSheet = false
	@State var newCourse_fakePending: [Change]? = nil //courseEdit computes EDITS from tblIndex and pos, but it writes them back here where I can discard them and replace them with a .course_add
	@State var newCourse_fakeNewCourse: Course2 = Course2("\u{0000}\u{0001}\u{0002}\u{0003}\u{0004}\u{0005}\u{0006}\u{0007}", icon: "book.closed", rooms: [], colour: "Graphite", identifier: .standard) //courseEdit wil be comparing its normal Course2 with a control one of impossible characters, therefore there will always be changes.

	@State var showingDeleteConfirmation = false
	@State var alertIndex: UUID? = nil

	@State var saveFailed = false

	init(tblIndex: Int = 0) {
		self.tblIndex = tblIndex
		self.localCourses = Storage.shared.timetables[tblIndex].courses
	}

	@State var discardConfirmation = false
	@Environment(\.dismiss) var dismiss

	private func confirmDelete() {
		let deletedName = alertIndex.flatMap { localCourses[$0]?.name } ?? "Error \(#line)"
		guard let id = alertIndex else { return }
		let change = Change.course_delete(index: id, timetable: tblIndex)
		pendingChanges = [change] + (pendingChanges ?? [])
		localCourses.applyCourseChanges([change])
		let logMessage: String = "Unconfirmedly removed \"\(deletedName)\" from UI courses"
		Logger.editCourses.log("\(logMessage, privacy: .public)")
	}

	private var sortedCourseIDs: [UUID] {
		let pairs: [(UUID, Course2)] = localCourses.map { (key: UUID, value: Course2) in (key, value) }
		let sortedPairs: [(UUID, Course2)] = pairs.sorted { (lhs: (UUID, Course2), rhs: (UUID, Course2)) -> Bool in
			lhs.1.name < rhs.1.name
		}
		let keys: [UUID] = sortedPairs.map { (key: UUID, _ : Course2) in key }
		return keys
	}


	var body: some View {
		NavigationStack {
			let alertTitle: String = {
				if let id = alertIndex, let name = localCourses[id]?.name {
					return "Delete \"\(name)\"?"
				} else {
					return "Delete \"Error \(#line)\"?"
				}
			}()

			List {

				CoursesListRows(sortedIDs: sortedCourseIDs,
								localCourses: $localCourses,
								tblIndex: tblIndex,
								pendingChanges: $pendingChanges)

				Button("Add Course", systemImage: "plus") {
					newCourse_fakePending = []
					newCourse_fakeNewCourse = Course2("\u{0000}\u{0001}\u{0002}\u{0003}\u{0004}\u{0005}", icon: "book.closed", rooms: [], colour: "Graphite", identifier: .standard)

					newCourseSheet.toggle()
				}
				.sheet(isPresented: $newCourseSheet) {
					//ondismiss
					if newCourse_fakeNewCourse.name != "\u{0000}\u{0001}\u{0002}\u{0003}\u{0004}\u{0005}\u{0006}\u{0007}" {
						let id = UUID()
						pendingChanges = [Change.course_create(index: id, newCourse_fakeNewCourse, timetable: tblIndex)] + (pendingChanges ?? [])
						localCourses.applyCourseChanges([Change.course_create(index: id, newCourse_fakeNewCourse, timetable: tblIndex)])
					}
				} content: {
					courseEdit(tblIndex: 0, pos: UUID(), isNewCourse: true, parentCourse: $newCourse_fakeNewCourse, course: Course2("Course", icon: "book.closed", rooms: [], colour: "Graphite", identifier: .standard), pendingChanges: $newCourse_fakePending)
						.presentationDetents([.medium])
				}



			}
			.toolbar {

				//MARK: Save
				ToolbarItem(placement: .confirmationAction) {
					if !(pendingChanges?.isEmpty ?? true) {
						Button("Save", systemImage: "checkmark") {

							do {
								try store.distributeChanges(pendingChanges!)
								store.applyChanges(pendingChanges!)
								withAnimation {
									pendingChanges = []
								}
							} catch {
								Logger.editCourses.fault("Could not json-encode \(pendingChanges?.count ?? -1) changes")
								saveFailed = true
							}

						}
					}

				}
				//MARK: Back
				ToolbarItem(placement: .topBarLeading) {
					Button(
						"Back", systemImage:
							(pendingChanges?.isEmpty ?? true) ? "chevron.left" : "xmark"
					) {
						if !(pendingChanges?.isEmpty ?? true) {
							discardConfirmation = true
						} else {
							dismiss()
						}
					}
					.confirmationDialog(
						Text("Error \(#line)"),
						isPresented: $discardConfirmation
					) {
						Button("Discard Changes", role: .destructive) {
							withAnimation {
								pendingChanges = nil
								localCourses = store.timetables[tblIndex].courses
							}
							Logger.views.info("Discarded changes to courses")
						}
					} message: {
						Text("Are you sure you want to discard your changes?")
					}
				}

			}
			.alert(alertTitle, isPresented: $showingDeleteConfirmation) {
				Button("Delete", role: .destructive) { confirmDelete() }
				Button("Cancel", role: .cancel) { }
			}
		}
		.alert("Couldn't send changes to watch.", isPresented: $saveFailed) {
			Button("OK") {
				saveFailed = false
			}
		}
		.navigationTitle("All Courses")
		.onAppear {
			localCourses = store.timetables[tblIndex].courses
			Logger.editCourses.log("Started editing courses")
		}
		.navigationBarBackButtonHidden()
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	CoursesEditor(tblIndex: 0)
}

