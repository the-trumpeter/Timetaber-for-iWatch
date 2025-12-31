//
//  TimesEditor.swift
//  Timetaber
//
//  Created by Gill Palmer on 30/12/2025.
//

import SwiftUI


fileprivate struct NewPeriodView: View {
	@Binding var period: Times.Period
	var body: some View {
		VStack {
			let durationBinding = Binding<Date>(
				get: {
					Date(time24: (period.duration/60*100 + period.duration%60) )
				},
				set: {
					let t24 = Time24(from: $0)
					let mins = t24%100
					let hours = t24/100
					period.duration = mins+hours*60
				}
			)

			let startBinding = Binding<Date>(
				get: {
					Date(time24: period.startTime)
				},
				set: {
					period.startTime = Time24(from: $0)
				}
			)

			HStack(spacing: 12) {
				Text("Start"); Spacer()
				Button {} label: { Text(startBinding.wrappedValue, format: Date.FormatStyle().hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits))
					.textCase(.lowercase) }
				.foregroundStyle(.primary)
				.padding(.vertical, 6)
				.padding(.horizontal, 8)
				.frame(width: 90, height: 35)
				.background(
					Capsule().fill(.tertiary)
				)
				.overlay {
					DatePicker(
						"Start",
						selection: startBinding,
						displayedComponents: .hourAndMinute
					)
					.labelsHidden()
					.colorMultiply(Colour.clear)
				}
			}

			HStack(spacing: 12) {
				Text("Duration")
				Spacer()

				Button {} label: { Text("\(period.duration/60):\(period.duration % 60 < 10 ? "0":"")\(period.duration%60)") }
					.foregroundStyle(.primary)
					.padding(.vertical, 6)
					.padding(.horizontal, 8)
					.frame(width: 90, height: 35)
					.background(
						Capsule().fill(.tertiary)
					)
					.overlay {
						DatePicker("Start", selection: durationBinding, displayedComponents: .hourAndMinute)
							.environment(\.locale, Locale(identifier: "en_GB"))
							.labelsHidden()
							.colorMultiply(Colour.clear)
					}
			}.padding(.top, 3)//duration
			HStack {
				Text("Name/Number")
				Spacer()
				TextField("Period name or numer", text: $period.name)
					.multilineTextAlignment(.trailing)
					.textFieldStyle(.roundedBorder)
					.frame(width: 100)
			}.padding(.top, 3)//name
		}
	}
}

fileprivate struct TimesSheetView: View {
	var startBinding: Binding<Date>
	var durationBinding: Binding<Date>

	var period: Binding<Times.Period>
	let editing: Int
	var localTimes: Binding<Times>

	@Binding var hourText: String
	@Binding var minuteText: String

	let index: Int

	var body: some View {

		VStack {



			HStack(spacing: 12) {
				/*let apmFormatter = DateFormatter()
				 apmFormatter.locale = Locale(identifier: "en_US_POSIX")
				 apmFormatter.dateFormat = "a"
				 let apmString = apmFormatter.string(from: startBinding.wrappedValue)*/
				Text("Start")
				Spacer()
				Button {} label: { Text(startBinding.wrappedValue, format: Date.FormatStyle().hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits))
					.textCase(.lowercase) }
				.foregroundStyle(.primary)
				.padding(.vertical, 6)
				.padding(.horizontal, 8)
				.frame(width: 90, height: 35)
				.background(
					Capsule().fill(.tertiary)
				)
				.overlay {
					DatePicker(
						"Start",
						selection: startBinding,
						displayedComponents: .hourAndMinute
					)
					.labelsHidden()
					.colorMultiply(Colour.clear)
				}
			}



			HStack(spacing: 12) {
				Text("Duration")
				Spacer()

				Button {} label: { Text("\(period.wrappedValue.duration/60):\(period.wrappedValue.duration % 60 < 10 ? "0":"")\(period.wrappedValue.duration%60)") }
					.foregroundStyle(.primary)
					.padding(.vertical, 6)
					.padding(.horizontal, 8)
					.frame(width: 90, height: 35)
					.background(
						Capsule().fill(.tertiary)
					)
					.overlay {
						DatePicker(
							"Start",
							selection: durationBinding,
							displayedComponents: .hourAndMinute
						)
						.environment(\.locale, Locale(identifier: "en_GB"))
						.labelsHidden()
						.colorMultiply(Colour.clear)
					}

			}.padding(.top, 3)//duration




			HStack {
				Text("Name/Number")
				Spacer()
				TextField("Period name or numer", text: Binding<String>(
					get: {
						if editing == -1 {
							if index < localTimes.wrappedValue.standard.count {
								return localTimes.wrappedValue.standard[index].name
							} else {
								return ""
							}
						} else {
							let key = Array(localTimes.wrappedValue.variants.keys)[editing]
							if let arr = localTimes.wrappedValue.variants[key], index < arr.count {
								return arr[index].name
							} else {
								return ""
							}
						}
					},
					set: { newValue in
						if editing == -1 {
							if index < localTimes.wrappedValue.standard.count {
								localTimes.wrappedValue.standard[index].name = newValue
							}
						} else {
							let key = Array(localTimes.wrappedValue.variants.keys)[editing]
							if var arr = localTimes.wrappedValue.variants[key], index < arr.count {
								arr[index].name = newValue
								localTimes.wrappedValue.variants[key] = arr
							}
						}
					}
				)
				)
				.multilineTextAlignment(.trailing)
				.textFieldStyle(.roundedBorder)
				.frame(width: 100)
				//.padding(.trailing)
			}.padding(.top, 3)//name



		}.padding()
			.presentationDetents([.height(200.0)])
			.onAppear {
				// keep text fields in sync when expanding
				hourText = String(period.wrappedValue.duration / 60)
				minuteText = String(period.wrappedValue.duration % 60)
			}
	}
}


fileprivate struct TimesRowView: View {
	var localTimes: Binding<Times>
	let editing: Int
	let index: Int
	var period: Binding<Times.Period>

	@State private var sheet = false

	@State private var hourText = "0"
	@State private var minuteText = "0"

	init(localTimes: Binding<Times>, editing: Int, index: Int, period: Binding<Times.Period>, isNewPeriod: Bool = false) {
		self.localTimes = localTimes
		self.editing = editing
		self.index = index
		self.period = period
		self.sheet = isNewPeriod
	}

	var body: some View {
		let startBinding = Binding<Date>(
						get: {
							Date(time24: period.wrappedValue.startTime)
						},
						set: { newDate in
							let newValue = Time24(from: newDate)
							if editing == -1 {
								if index < localTimes.standard.count {
									localTimes.wrappedValue.standard[index].startTime = newValue
								}
							} else {
								let key = Array(localTimes.wrappedValue.variants.keys)[editing]
								if var arr = localTimes.wrappedValue.variants[key], index < arr.count {
									arr[index].startTime = newValue
									localTimes.wrappedValue.variants[key] = arr
								}
							}
						}
					)

		let durationBinding = Binding<Date>(
			get: {
				Date(time24: (period.wrappedValue.duration/60*100 + period.wrappedValue.duration%60) )
			},
			set: {
				let t24 = Time24(from: $0)
				let mins = t24%100
				let hours = t24/100
				period.wrappedValue.duration = mins+hours*60
			}
		)

		Button {
			sheet.toggle()
		} label: {
			HStack {
				if Float(period.wrappedValue.name) != nil {
					Text("Pd.").foregroundStyle(.secondary)
				}
				Text(period.wrappedValue.name)
				Spacer()
				Text("\(startBinding.wrappedValue.formatted(Date.FormatStyle().hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)))")
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)

		.sheet(isPresented: $sheet) {

			TimesSheetView(startBinding: startBinding, durationBinding: durationBinding, period: period, editing: editing, localTimes: localTimes, hourText: $hourText, minuteText: $minuteText, index: index)
		}//sheet
	}
}

///Edit the structure of each day.
struct TimesEditor: View {

	@ObservedObject var store = Storage.shared

	let tblIndex: Int
	@State var localTimes: Times
	@State var editing: Int = -1
	//@State var sheetNo: Int = -1


	@State var newPeriod = Times.Period("", startTime: 0000, duration: 0000)
	@State var newPeriodSheet = false

	@State var alertIndex = 0
	@State var showingAlert = false

	init(tblIndex: Int = 0) {
		self.tblIndex = tblIndex
		self.localTimes = Storage.shared.timetables[tblIndex].times
	}


	private func compileChanges() -> [Change] {
		let origin = store.timetables[tblIndex].times
		var changes: [Change] = []

		//mapping
		if !(localTimes.mapping == origin.mapping) {
			for x in 2...6 {
				if localTimes.mapping[x] != origin.mapping[x] {
					changes.append(
						.times_variant_key(weekday: x, variant: localTimes.mapping[x]!, timetable: tblIndex)
					)
				}
			}
		}

		//standard
		

		//variants

		return changes
	}

	var body: some View {
		NavigationStack {
			List {

				let timesets: [Times.Period] = (editing == -1) ? localTimes.standard : localTimes.variants[Array(localTimes.variants.keys)[editing]]!

                ForEach(timesets.indices, id: \.self) { index in

					TimesRowView(localTimes: $localTimes, editing: editing, index: index, period: Binding(
						get: {
							if editing == -1 {
								localTimes.standard[index]
							} else {
								localTimes.variants[Array(localTimes.variants.keys)[editing]]![index]
							}
						},
						set: {
							if editing == -1 {
								localTimes.standard[index] = $0
							} else {
								localTimes.variants[Array(localTimes.variants.keys)[editing]]![index] = $0
							}
						}
						)
					).swipeActions(allowsFullSwipe: false) {
						Button("Delete", systemImage: "trash") {
							alertIndex = index
							showingAlert = true
						}.labelStyle(.iconOnly)
							.tint(.red)
					}

                }//foreach
				.alert("Delete period \(Float(timesets[alertIndex].name) != nil ? "" : "\"" )\(timesets[alertIndex].name)\(Float(timesets[alertIndex].name) != nil ? "" : "\"" )?", isPresented: $showingAlert) {
					Button("Delete", role: .destructive) {
						// Capture the course name before deletion so we can still display/log it after removal
						let deletedName = timesets[alertIndex].name// ?? "Error \(#line)"

						if editing == -1 {
							localTimes.standard.remove(at: alertIndex)
						} else {
							localTimes.variants[Array(localTimes.variants.keys)[editing]]!.remove(at: alertIndex)
						}

						print("\(#fileID):\(#line) Unconfirmedly removed \"\(deletedName)\" from UI courses (index \(alertIndex))")
					}
					Button("Cancel", role: .cancel) {}
				}

				Button("Add Period", systemImage: "plus") {
			///**	Calculate new period template from existing ones
					let existingEnd = Date(time24: timesets.last?.startTime ?? 0900) //fetch start time of last period
					let templateStart = existingEnd.addingTimeInterval(TimeInterval((timesets.last?.duration ?? 0) * 60 )) // calculate end time of last period; use end time as default starttime for next period
					newPeriod.startTime = Time24(from: templateStart)
					newPeriod.duration = 60
					var existingNumbers: [Float] = []
					for set in timesets {
						if let n = Float(set.name) {
							existingNumbers.append(n)
						}
					}
					if let last = existingNumbers.sorted().last {
						newPeriod.name = String( Int(last)+1 )
					} else {
						newPeriod.name = "Period"
					}

					newPeriodSheet = true

				}.sheet(isPresented: $newPeriodSheet) {
					NavigationStack {
						NewPeriodView(period: $newPeriod)
							.padding()
							.presentationDetents([.height(250.0)])
							.toolbar {
								ToolbarItem(placement: .confirmationAction) {
									Button("Save", systemImage: "checkmark") {
										if editing == -1 {
											localTimes.standard.append(newPeriod)
										} else {
											localTimes.variants[Array(localTimes.variants.keys)[editing]]!.append(newPeriod)
										}
										newPeriodSheet = false
									}
								}
								ToolbarItem(placement: .cancellationAction) {
									Button("Cancel", systemImage: "xmark") {
										newPeriodSheet = false
									}
								}
							}
					}
				}

			}


			.toolbar {
				ToolbarItem(placement: .navigation) {
					Menu( {
						if editing < 0 { return "Standard" }
						return [String](localTimes.variants.keys)[editing]
						}()
					) {
						Picker("Time Set", selection: $editing) {
							Text("Standard").tag(-1)
							Divider()
							let keys = Array(localTimes.variants.keys)
							ForEach(keys, id: \.self) { key in
								let tag = keys.firstIndex(of: key)!
								Text(key).tag(tag)
							}
						}
						Button("Add variation", systemImage: "plus") { }
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save", systemImage: "checkmark") {

					}
				}
			}
		}
	}
}








///Edit the structure of each week.
struct TimesMapping: View {
	
	@ObservedObject var store = Storage.shared
	var tblIndex: Int

	@State var localTimes: Times
	@State var origin: Times

	@State var bool_pendingChanges = false

	init(tblIndex: Int = 0) {
		self.tblIndex 	= tblIndex
		self.localTimes = Storage.shared.timetables[tblIndex].times
		self.origin 	= Storage.shared.timetables[tblIndex].times
	}

	
	func compileChanges() -> [Change] {

		let origin = store.timetables[tblIndex].times.mapping
		let local = localTimes.mapping

		print("\(#fileID):\(#line) @ \(#function) Compiling: \n\toriginal: \(origin)\n\tmodified local: \(local)")

		guard origin != local else {
			bool_pendingChanges = false
			return []
		}
		if !bool_pendingChanges { bool_pendingChanges = true }

		var changes: [Change] = []

		for wkd in 2...6 {
			if let loc = local[wkd] {
				if loc != "Standard" &&//not standard
					origin[wkd] != loc  {
					changes.append( .times_variant_key(weekday: wkd, variant: loc,	timetable: tblIndex) )
				} else if loc == "Standard" && origin[wkd] != nil && origin[wkd] != "Standard" {
					changes.append( .times_variant_key(weekday: wkd, variant: nil,	timetable: tblIndex) )
				}
			}
		}
		
		bool_pendingChanges = false
		return changes
	}

	let week_days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

	var body: some View {
		NavigationStack {
			List {

				ForEach(week_days, id: \.self) { day in

					let key = Int(week_days.firstIndex(of: day)!) + 2
					Picker(day, selection: Binding<String>(
						get: { localTimes.mapping[key] ?? "Standard" },
						set: { newVal in
							if newVal == "Standard" {
								localTimes.mapping[key] = nil
							} else {
								localTimes.mapping[key] = newVal
							}
							bool_pendingChanges = (localTimes != origin)
						}
					)) {
						Text("Standard times").tag("Standard")
						Divider()
						ForEach(Array(localTimes.variants.keys), id: \.self) {
							Text($0).tag($0)
						}
					}

				}.onChange(of: localTimes) { old, new in
					if localTimes != origin {
						bool_pendingChanges = true
					} else {
						bool_pendingChanges = false
					}
				}

			}.onAppear {
				let t = store.timetables[tblIndex].times
				localTimes = t
				origin = t
			}

		}.toolbar {
			ToolbarItem(placement: .confirmationAction) {
				if bool_pendingChanges {
					Button("Save", systemImage: "checkmark") {
						let changes = compileChanges()

						do { try store.distributeChanges(changes)
						} catch {
							print("\(#fileID):\(#line) @ \(#function) Couldn't distribute changes \(changes).")
							//TODO: Prompt user to copy changes to new timetable
							return
						}

						store.applyChanges(changes)
						let t = store.timetables[tblIndex].times; localTimes = t; origin = t
					}
				}
			}
		}

	}
}



#Preview {
	TimesEditor()
}

