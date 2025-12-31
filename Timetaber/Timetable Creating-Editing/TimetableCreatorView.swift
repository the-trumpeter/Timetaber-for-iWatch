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
	mutating func applyCourseChanges(_ changes: [Change]) {
		for change in changes {

			switch change {
				case .course_create(index: let index, let value, timetable: _):
				self.updateValue(value, forKey: index ?? self.count)

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
					print("\(#fileID):\(#line) @ \(#function) Couldn't apply change \(change) to value of type Binding<[Int: Course2]>\n\tself = \(self)")
			}

		}
	}
}

extension Binding where Value == [Int: Course2] {
	mutating func applyCourseChanges(_ changes: [Change]) {
		self.wrappedValue.applyCourseChanges(changes)
	}
}

extension Times {
	mutating func applyTimesChanges(_ changes: [Change]) {
		for change in changes {

			switch change {

				case .times_variants_add(named: let name, let value, timetable: _):
					self.variants.updateValue(value, forKey: name)

				case .times_variant_modifyEntry(in: let name, toModify: let target, let value, timetable: _):
					guard self.variants[name] != nil else {
						print("\(#fileID):\(#line) @ \(#function) \(name) not present in Times")
						break
					}
					self.variants[name]![target] = value

				case .times_variants_deleteEntry(in: let name, toDelete: let target, timetable: _):
					self.variants[name]?.remove(at: target)

				case .times_variant_key(weekday: let key, variant: let value, timetable: _):
					guard let value else {
						self.mapping.removeValue(forKey: key)
						break
					}
					print("dbg \(#line) @ \(#function) updating map \(key) to \(value)")
					self.mapping.updateValue(value, forKey: key)

				default:
				print("\(#fileID):\(#line) @ \(#function) Couldn't apply change \(change) to value of type Times")
			}

		}
		print("\(#fileID):\(#line) @ \(#function) Applied changes \(changes) to self")
	}
}

//MARK: - TimetablesListEditor/timetableOptions
fileprivate struct timetableOptions: View {

	@Binding var timetable: Timetable
	let tblIndex: Int
	@State var icon: String
	@State var name: String

	@State var timesSheet = false

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


				NavigationLink { CoursesEditor(tblIndex: tblIndex) } label: {
					HStack { Image(systemName: "checkmark.diamond.fill").foregroundStyle(.green); Text("Courses").foregroundStyle(.primary); Spacer();
						Text(String(timetable.courses.count)).foregroundStyle(.secondary) }
				}

				NavigationLink {
					TimesEditor(tblIndex: tblIndex)
				} label: { HStack { Image(systemName: "xmark.square.fill").foregroundStyle(.orange); Text("Day Structure").foregroundStyle(.primary); Spacer(); Text(String(timetable.times.variants.count+1)).foregroundStyle(.secondary) }
				}.buttonStyle(.plain)
				NavigationLink {
					TimesMapping(tblIndex: tblIndex)
				} label: {
					Image(systemName: "checkmark.diamond.fill").foregroundStyle(.green); Text("Week Structure").foregroundStyle(.primary)
				}


				NavigationLink { } label: { HStack { Image(systemName: "xmark.square.fill").foregroundStyle(.red); Text("Timetable").foregroundStyle(.primary); Spacer(); Text("\(timetable.timetable.count) week\( timetable.timetable.count != 1 ? "s":"")").foregroundStyle(.secondary) } }

				// Button("Delete \"\(name)\"", systemImage: "trash", role: .destructive) { }

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
