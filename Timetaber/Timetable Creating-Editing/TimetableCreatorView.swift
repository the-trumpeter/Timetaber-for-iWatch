//
//  TimetableCreatorView.swift
//  Timetaber
//
//  Created by Gill Palmer on 7/11/2025.
//
import SwiftUI
import OSLog

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

extension Dictionary where Key == UUID, Value == Course2 {
	mutating func applyCourseChanges(_ changes: [Change]) {
		for change in changes {

			switch change {
				case .course_create(index: let index, let value, timetable: _):
				self.updateValue(value, forKey: index)

				case .course_delete(index: let index, timetable: _):
				self.removeValue(forKey: index)

				case .course_modify(index: let index, let coursechange, timetable: _):
					switch coursechange {
						case .colour(let new): self[index]?.colour = new
						case .rooms(let new): self[index]?.rooms = new
						case .icon(let new): self[index]?.icon = new
						case .name(let new): self[index]?.name = new
					}

				default:
				let me = self
				Logger.timetableChanges.fault("Dictionary extension - Couldn't apply change \(String(reflecting: change), privacy: .public) to value of type Binding<[Int: Course2]>\n\tself = \(me, privacy: .public)")
			}

		}
	}
}

extension Binding where Value == [UUID: Course2] {
	mutating func applyCourseChanges(_ changes: [Change]) {
		self.wrappedValue.applyCourseChanges(changes)
	}
}

extension Times {
	mutating func applyTimesChanges(_ changes: [Change]) {
		for change in changes {

			switch change {

				case .times_variants_add(key: let name, let value, timetable: _):
					self.variants.updateValue(value, forKey: name)

				case .times_variant_modify(target: let target, let variantChange, timetable: _):
					switch variantChange {

						case .rename(let name):
							switch target {
							case .standard: continue
							case .variant(let key):
								self.variants[key]?.name = name
							}

						case .modifyEntry(let setIdx, to: let value):
							switch target {
								case .standard: self.standard[setIdx] = value
								case .variant(let key): self.variants[key]?.variant[setIdx] = value
							}

						case .deleteEntry(let deletee):
							switch target {
								case .standard: self.standard.removeValue(forKey: deletee)
								case .variant(let key): self.variants[key]?.variant.removeValue(forKey: deletee)
							}
					}

				case .times_variant_key(weekday: let key, variant: let value, timetable: _):
					guard let value else {
						self.mapping.removeValue(forKey: key)
						break
					}
				Logger.editTimes.debug("Updating map \(key, privacy: .public) to \(String(reflecting: value), privacy: .public )")
					self.mapping.updateValue(value, forKey: key)

				default:
				Logger.editTimes.fault("Couldn't apply change \(String(reflecting: change), privacy: .public) to value of type Times")
			}

		}
		Logger.editTimes.notice("Applied changes \(changes, privacy: .public) to a (instance of) Times")
	}
}

//MARK: - TimetablesListEditor/timetableOptions
fileprivate struct timetableOptions: View {

	@Binding var timetable: Timetable
	let tblIndex: Int
	@State var icon: String
	@State var name: String

	@State var timesSheet = false

	@State var sendFullFailed = false

	init(_ timetable: Binding<Timetable>, index: Int) {
		self.tblIndex = index
		self._timetable = timetable
		self._icon = State(initialValue: timetable.wrappedValue.icon)
		self._name = State(initialValue: timetable.wrappedValue.name)
	}

	var body: some View {
		NavigationStack {
			List {
			/*	HStack {
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
				} */


				NavigationLink {
					CoursesEditor(tblIndex: tblIndex)
						.toolbar(.hidden, for: .tabBar)
				} label: {
					HStack {
						Text("Courses").foregroundStyle(.primary); Spacer();
						Text(String(timetable.courses.count)).foregroundStyle(.secondary) }
				}

				NavigationLink {
					TimesEditor(tblIndex: tblIndex)
						.toolbar(.hidden, for: .tabBar)
				} label: {
					HStack {

						Text("Day Structure").foregroundStyle(.primary); Spacer()
						Text(String(timetable.times.variants.count+1)).foregroundStyle(.secondary)
					}
				}.buttonStyle(.plain)
				NavigationLink {
					TimesMapping(tblIndex: tblIndex)
						.toolbar(.hidden, for: .tabBar)
				} label: {
					Text("Week Structure")
				}


				NavigationLink {
					EditTimetableView()
						.toolbar(.hidden, for: .tabBar)
				} label: {
					HStack {
						Text("Timetable").foregroundStyle(.primary); Spacer();
						Text("\(timetable.timetable.count) week\( timetable.timetable.count != 1 ? "s":"")").foregroundStyle(.secondary)
					}
				}

				// Button("Delete \"\(name, privacy: .public)\"", systemImage: "trash", role: .destructive) { }

				HStack {

					if Storage.shared.WCManager.session.isWatchAppInstalled {
						Menu("Debug...", systemImage: "ladybug") {
							Button("Send Full Timetable To Watch...", systemImage: "applewatch") {
								do {
									try Storage.shared.WCManager.transferFullTimetable(Storage.shared.timetables[tblIndex])
									Storage.shared.WCManager.updateTermContext(Storage.shared.termRunningGB, startDate: Storage.shared.startDateGB, ghostWeek: Storage.shared.ghostWeekGB)
								} catch {
//									Commented out because this I think just fully reloads and is redundant
//
//									let isweekA = getIfWeekIsA_FromDateAndGhost(
//										originDate: Storage.shared.startDateGB,
//										ghostWeek: Storage.shared.ghostWeekGB
//									)
//									var now: (current: DisplayCourse, next: DisplayCourse, timeslot: Timeslot)
//									= (noSchool(.noTimetable), noSchool(.noTimetable), Timeslot(week: isweekA ? .a : .b, day: weekdayNumber(.now), time: -1))
//
//									let activeIndex = Storage.shared.ActiveTimetable
//									if Storage.shared.timetables.indices.contains(activeIndex) {
//										let timetable = Storage.shared.timetables[activeIndex]
//										now = getCurrentClass2(date: .now, timetable: timetable)
//									}
									Logger.general.critical("Could not send full timetable to watch!!")
									sendFullFailed = true
								}
							}
						}
						Spacer()
					}

					ExportView()
				}
				.alert("Couldn't export timetable", isPresented: $sendFullFailed) {
					Button("OK", role: .cancel) { sendFullFailed = false }
				} message: {
					Text("JSON encoding failed. The watch app's data may also be outdated.")
				}



			}.listStyle(.inset)
			.navigationTitle("Settings")
			.scrollDisabled(true)


		}

	}
}


//MARK: TimetablesListEditor
///Edit the timetable!
struct TimetablesListEditor: View {

	@ObservedObject var store: Storage = Storage.shared
	@State var timetableIndex = Storage.shared.ActiveTimetable

	var body: some View {
		//NavigationStack {

			//let editingTimetable = store.timetables[timetableIndex]

			timetableOptions($store.timetables[timetableIndex], index: timetableIndex)

			/*.toolbar {
				ToolbarItem(placement: .navigation) {

					Picker(editingTimetable.name, selection: $timetableIndex) {
						let indicies = store.timetables.indices.sorted()
						ForEach(indicies, id: \.self) { index in
							let tble = store.timetables[index]
							Label(tble.name, systemImage: tble.icon).tag(index)
						}

					}.labelStyle(.titleOnly)
				}
			}*/
		//}
	}
}


#Preview {
/*	EditDayView(
	 timetable: chaos,
	 week: .a
	 ).environmentObject(LocalData.shared)
*/

	TimetablesListEditor()

//	CoursesEditor(tblIndex: 0)

//	TimesEditor(tblIndex: 0)
}
