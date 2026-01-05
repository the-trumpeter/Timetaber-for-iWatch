//
//  TimesEditor.swift
//  Timetaber
//
//  Created by Gill Palmer on 30/12/2025.
//

import SwiftUI





//MARK: NewPeriodView
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







//MARK: TimesSheetView
fileprivate struct TimesSheetView: View {
	var startBinding: Binding<Date>
	var durationBinding: Binding<Date>

	var period: Binding<Times.Period>
	let editing: Times.Set
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
						switch editing {
						case .standard:
							if index < localTimes.wrappedValue.standard.count {
								return localTimes.wrappedValue.standard[index]!.name
							} else {
								return ""
							}
						case .variant(let target):
							if let arr = localTimes.wrappedValue.variants[target]?.variant, index < arr.count {
								return arr[index]!.name
							} else {
								return ""
							}
						}
					},
					set: { newValue in
						switch editing {
						case .standard:
							if index < localTimes.wrappedValue.standard.count {
								localTimes.wrappedValue.standard[index]!.name = newValue
							}
						case .variant(let target):
							if var arr = localTimes.wrappedValue.variants[target]?.variant, index < arr.count {
								arr[index]!.name = newValue
								localTimes.wrappedValue.variants[target]!.variant = arr
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









//MARK: TimesRowView
fileprivate struct TimesRowView: View {
	var localTimes: Binding<Times>
	let editing: Times.Set
	let index: Int
	var period: Binding<Times.Period>

	@State private var sheet = false

	@State private var hourText = "0"
	@State private var minuteText = "0"

	init(localTimes: Binding<Times>, editing: Times.Set, index: Int, period: Binding<Times.Period>, isNewPeriod: Bool = false) {
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
							switch editing {
							case .standard:
								if index < localTimes.wrappedValue.standard.count {
									localTimes.wrappedValue.standard[index]!.startTime = newValue
								}
							case .variant(let target):
								if var arr = localTimes.wrappedValue.variants[target]?.variant, index < arr.count {
									arr[index]!.startTime = newValue
									localTimes.wrappedValue.variants[target]!.variant = arr
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












//MARK: TimesVariantEditor
///Edit the structure of a timing set.
fileprivate struct TimesVariantEditor: View {

	@ObservedObject var store = Storage.shared

	let tblIndex: Int
	@State var localTimes: Times
	@State var editing: Times.Set
	//@State var sheetNo: Int = -1


	@State private var newPeriod = Times.Period("", startTime: 0000, duration: 0000)
	@State private var newPeriodSheet = false

//	@State private var alertIndex = 0
//	@State private var showingAlert = false

	@State private var hasPendingChanges = false

	private func syncPendingFlag() {
		hasPendingChanges = (localTimes != store.timetables[tblIndex].times)
	}

	init(_ editing: Times.Set, tblIndex: Int = 0) {
		self.tblIndex = tblIndex
		self.editing = editing
		self.localTimes = Storage.shared.timetables[tblIndex].times
	}




	//MARK: compileChanges
	private func compileChanges() -> [Change] {

		let origin = store.timetables[tblIndex].times
		var changes: [Change] = []


		func theloop(local localVariant: Any, original: Any, for timeschange: Times.Set ) {

		//				Local/Origin Existence & Value combinations:
		//
		//  Local value || A  B  ~ | A  B    ~  ~ | A  B
		// Origin value || A  B  ~ | ~  ~    A  B | B  A
		//      Handler ||..none...|..#1..  ..#3..|..#2..


			let local = switch timeschange {
					case .standard: localVariant as! [Int: Times.Period]
					default: (localVariant as! Times.Variant).variant
				}
			let origin = switch timeschange {
					case .standard: original as! [Int: Times.Period]
					default: (original as! Times.Variant).variant
				}
			// Go through local periods and correct the corresponding ones
			for p in local.keys {

			//	#1 –– LOCAL HAS value, ORIGIN does NOT –––––––––––––––––––––––––––
				if let period = local[p], origin[p] == nil {
					changes.append( .times_variant_modify(target: timeschange, .modifyEntry(p, to: period), timetable: tblIndex) )
					// the decoders use updateValue, so it's the same syntax for addition as mutation
				}


			//	#2 –– Both have DIFFERENT VALUES ––––––––––––––––––––––––––––––––
				if let period = local[p], let oPeriod = origin[p] { //both have value
					if period != oPeriod { //and they are not the same
						changes.append( .times_variant_modify(target: timeschange, .modifyEntry(p, to: period), timetable: tblIndex) )
					}
				}

			}

			// Go through original periods and remove if there's not corresponding local one
			for p in origin.keys {

			//	#3 –– Origin HAS value, local does NOT ––––––––––––––––––––––————
				if local[p] == nil {
					changes.append( .times_variant_modify(target: timeschange, .deleteEntry(p), timetable: tblIndex))
				}
			}

		}

		// – Mapping ––––––––––––––––––––––––––––––––––––––––––––––––––––
		// Don't need to do mapping since it is seperated into Week Structure (TimesMapping)

		// – Standard –––––––––––––––––––––––––––––––––––––––––––––––––––

		theloop(local: localTimes.standard, original: origin.standard, for: .standard)

		// – Variants –––––––––––––––––––––––––––––––––––––––––––––––––––

		// – Identifying changes to variants (Times.Variant) themselves –

		for ovk in origin.variants.keys {
			if !localTimes.variants.keys.contains(ovk) {
				changes.append(.times_variants_delete(ovk, timetable: tblIndex))
			}
		}

		for vk in localTimes.variants.keys {
			if let lVariant = localTimes.variants[vk] {

				if origin.variants[vk] == nil {
					changes.append(.times_variants_add(key: vk, lVariant, timetable: tblIndex))
				} else {
					theloop(local: localTimes.variants[vk]!, original: origin.variants[vk]!, for: .variant(vk) )
				}

			}
		}

		// – Return –––––––––––––––––––––––––––––––––––––––––––––––––––––
		return changes
	}







	//MARK: TimesVariantEditor.body
	var body: some View {
		NavigationStack {



		//	Precompute the timesets for the current editing selection
			let timesets: [Int: Times.Period] = {
				switch editing {
					case .standard: return localTimes.standard
					case .variant(let key):
						let keys = Array(localTimes.variants.keys)
						if key >= 0 && key < keys.count, let variant = localTimes.variants[keys[key]]?.variant {
							return variant
						} else {
							return localTimes.standard
						}
				}
			}()

			let starttimesortedTimeset = Array(timesets.keys).sorted(by: { timesets[$0]!.startTime < timesets[$1]!.startTime } )






			List {
				ForEach(starttimesortedTimeset, id: \.self) { index in

					TimesRowView(localTimes: $localTimes, editing: editing, index: index, period: Binding(
						get: {
							switch editing {
								case .standard: return localTimes.standard[index]!
								case .variant(let key):
									let keys = Array(localTimes.variants.keys)
									if key >= 0 && key < keys.count, let variant = localTimes.variants[keys[key]]?.variant {
										return variant[index]!
									} else {
										return localTimes.standard[index]!
									}
							}
						}, //Binding(get: )
						set: { new in
							switch editing {
								case .standard: localTimes.standard[index] = new
								case .variant(let target):
									let keys = Array(localTimes.variants.keys)
									if target >= 0 && target < keys.count {
										let key = keys[target]
										if var variant = localTimes.variants[key]?.variant {
											variant[index] = new
											localTimes.variants[key]!.variant = variant
										}
									}
							}
						}//Binding(set: )
						)
					).swipeActions(allowsFullSwipe: false) {
						Button("Delete", systemImage: "trash", role: .destructive) {
							switch editing {
							case .standard: localTimes.standard.removeValue(forKey: index)
							case .variant(let target):
								localTimes.variants[target]!.variant.removeValue(forKey: index)//TODO: Got to fix others like this to use target as the key, not the index
							}
							hasPendingChanges = (localTimes != store.timetables[tblIndex].times)
							//alertIndex = index
							//showingAlert = true
						}.labelStyle(.iconOnly)
							.tint(.red)
					}

                }// ForEach( starttimesortedTimeset )



			//	MARK: New Period
				Button("Add Period", systemImage: "plus") {
			///**	Calculate new period template from existing ones
					let lastPeriod = timesets.sorted { $0.key < $1.key }.last?.value
					let existingEnd = Date(time24: lastPeriod?.startTime ?? 0900) //fetch start time of last period
					let templateStart = existingEnd.addingTimeInterval(TimeInterval((lastPeriod?.duration ?? 0) * 60 )) // calculate end time of last period; use end time as default starttime for next period
					newPeriod.startTime = Time24(from: templateStart)
					newPeriod.duration = 60
					var existingNumbers: [Float] = []
					for (_, p) in timesets {
						if let n = Float(p.name) {
							existingNumbers.append(n)
						}
					}
					if let last = existingNumbers.sorted().last {
						newPeriod.name = String( Int(last)+1 )
					} else {
						newPeriod.name = "Period"
					}

					newPeriodSheet = true

				}// 'Add Period' new period button
				.sheet(isPresented: $newPeriodSheet) {

					NavigationStack {
						NewPeriodView(period: $newPeriod)
							.padding()
							.presentationDetents([.height(250.0)])
							.toolbar {
								ToolbarItem(placement: .confirmationAction) {
									Button("Save", systemImage: "checkmark") {
										switch editing {
										case .standard: localTimes.standard.updateValue(newPeriod, forKey: localTimes.standard.count)
										case .variant(let key):
											localTimes.variants[key]!.variant.updateValue(newPeriod, forKey: localTimes.standard.count)
										}
										newPeriodSheet = false
									}
								}
								ToolbarItem(placement: .cancellationAction) {
									Button("Cancel", systemImage: "xmark") {
										newPeriodSheet = false
									}
								}
							}// sheet toolbar
					}// sheet NavStack

				}// New period sheet


			}//list

			.onAppear {
				localTimes = store.timetables[tblIndex].times
				syncPendingFlag()
			}


		//	MARK: 'Delete?' alert
		/*
			.alert("Delete period \(Float(timesets[alertIndex]?.name ?? "1.0") == nil ? "\"\(timesets[alertIndex]?.name ?? "")\"" : timesets[alertIndex]?.name ?? "")?", isPresented: $showingAlert) {
				Button("Delete", role: .destructive) {
					let deletedName = timesets[alertIndex]!.name
					if editing == -1 {
						localTimes.standard.removeValue(forKey: alertIndex)
					} else {
						let keys = Array(localTimes.variants.keys)
						if editing >= 0 && editing < keys.count {
							let key = keys[editing]
							localTimes.variants[key]!.variant.removeValue(forKey: alertIndex)
						}
					}
					print("\(#fileID):\(#line) Unconfirmedly removed \"\(deletedName)\" from UI courses (index \(alertIndex))")
				}
				Button("Cancel", role: .cancel) {}
			}
		 */

		//	MARK: Toolbar • Editing set, Save

			.toolbar {

				/*
				ToolbarItem(placement: .navigation) {
					Menu({
						if editing < 0 { return "Standard" }
						let keys = Array(localTimes.variants.keys)
						if editing >= 0 && editing < keys.count {
							let key = keys[editing]
							if let name = localTimes.variants[key]?.name {
								return name
							}
						}
						return "Standard"
					}()) {
						Picker("Time Set", selection: Binding(get: {editing}, set: {editing = Int($0)}) ) {
							Text("Standard").tag("-1")
							Divider()
							let keys = Array(localTimes.variants.keys)
							ForEach(keys, id: \.self) { key in
								if let tag = keys.firstIndex(of: key), let name = localTimes.variants[key]?.name {
									Text(name).tag(String(tag))
								}
							}
						}
						Button("(Add variation)", systemImage: "plus") { }
					}
				}
				 */

				ToolbarItem(placement: .confirmationAction) {
					if hasPendingChanges || !(localTimes == store.timetables[tblIndex].times) {
						Button("Save", systemImage: "checkmark") {
							let changes = compileChanges()
							do {
								try store.distributeChanges(changes)
							} catch {
								print("Couldn't distribute changes")
								return
							}
							store.applyChanges(changes)
							localTimes = store.timetables[tblIndex].times
							hasPendingChanges = (localTimes == store.timetables[tblIndex].times)
							syncPendingFlag()
						}
					}

				}

			}



		}// NavigationStack

	}// body
} // TimesVariantEditor











struct TimesEditor: View {
	@ObservedObject var store = Storage.shared
	let tblIndex: Int
	var body: some View {
		let times = store.timetables[tblIndex].times
		NavigationStack {
			List {
				Section {
					NavigationLink("Standard Timing") { TimesVariantEditor(.standard, tblIndex: tblIndex) }
				}

				Section {
					let variantKeys: [Int] = Array(times.variants.keys)
					ForEach(variantKeys, id: \.self) { vKey in
						NavigationLink(times.variants[vKey]!.name) { TimesVariantEditor(.variant(vKey), tblIndex: tblIndex) }
					}
				}
				Menu("Add Variant") {
					NavigationLink("From Standard...") {
						//TODO: Configure TimesEditor for variant creation
						//TODO: Create Variant
					}
					NavigationLink("Blank...") {
						//TODO: Configure TimesEditor for variant creation
						//TODO: Create Variant
					}
				}

			}
		}
	}
}
















//MARK: - TimesMapping
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
				if loc != -1 &&//not standard
					origin[wkd] != loc  {
					changes.append( .times_variant_key(weekday: wkd, variant: loc,	timetable: tblIndex) )
				} else if loc == -1 && origin[wkd] != nil && origin[wkd] != -1 {
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
					Picker(day, selection: Binding<Int>(
						get: { localTimes.mapping[key] ?? -1 },
						set: { new in
							if new == -1 {
								localTimes.mapping[key] = nil
							} else {
								localTimes.mapping[key] = new
							}
							bool_pendingChanges = (localTimes != origin)
						}
					)) {
						Text("Standard times").tag(-1)
						Divider()
						ForEach(Array(localTimes.variants.keys), id: \.self) { variantKey in
							Text(localTimes.variants[variantKey]!.name).tag(variantKey)
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
							//TODO: Distribution Fallback
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





//MARK: #Preview
#Preview {
	TimesEditor(tblIndex: 0)
}

