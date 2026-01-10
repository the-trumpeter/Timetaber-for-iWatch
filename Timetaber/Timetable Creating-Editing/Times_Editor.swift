//
//  TimesEditor.swift
//  Timetaber
//
//  Created by Gill Palmer on 30/12/2025.
//

import SwiftUI
import OSLog



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
					.frame(width: 150)
			}.padding(.top, 3)//name
		}
	}
}







//MARK: TimesSheetView
fileprivate struct TimesSheetView: View {
	//var startBinding: Binding<Date>
	//var durationBinding: Binding<Date>

	var parent: Binding<Times.Period>
	@State var period: Times.Period

	@Environment(\.dismiss) var dismiss

	init(period: Binding<Times.Period>) {
		//self.startBinding = startBinding
		//self.durationBinding = durationBinding
		self.parent = period
		self.period = period.wrappedValue
	}

	var body: some View {

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
						set: { newDate in
							period.startTime = Time24(from: newDate)
						}
					)
		NavigationStack {
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

					Button {} label: { Text("\(period.duration/60):\(period.duration % 60 < 10 ? "0":"")\(period.duration%60)") }
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

					TextField("Period name or numer", text: $period.name)
						.multilineTextAlignment(.trailing)
						.textFieldStyle(.roundedBorder)
						.frame(width: 100)

				}.padding(.top, 3)//name



			}.padding()
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Save", systemImage: "checkmark") {
						parent.wrappedValue = period
						Logger.editTimes.log("Saved changes to UI period")
						dismiss()
					}
				}
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", systemImage: "xmark") {
						dismiss()
					}
				}
			}
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

	/*init(localTimes: Binding<Times>, editing: Times.Set, index: Int, period: Binding<Times.Period>, isNewPeriod: Bool = false) {#warning("TODO remove custom initialiser")
		self.localTimes = localTimes
		self.editing = editing
		self.index = index
		self.period = period
		self.sheet = isNewPeriod
	}
	*/

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
								if var arr = localTimes.wrappedValue.variants[target]?.variant {
									arr[index]!.startTime = newValue
									localTimes.wrappedValue.variants[target]!.variant = arr
								}
							}
						}
					)

	/*	let durationBinding = Binding<Date>(
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
*/
		
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
			TimesSheetView(period: period)
				.presentationDetents([.height(250.0)])
		}//sheet
	}
}












//MARK: TimesVariantEditor
///Edit the structure of a timing set.
fileprivate struct TimesVariantEditor: View {

	@ObservedObject var store = Storage.shared

	let debugID: String

	//Standard setup
	let tblIndex: Int
	@State var localTimes: Times
	@State var editing: Times.Set
//	@State var sheetNo: Int = -1

	//New Period
	@State private var newPeriod = Times.Period("", startTime: 0000, duration: 0000)
	@State private var newPeriodSheet = false

//	@State private var alertIndex = 0
//	@State private var showingAlert = false
	//Changes/UI
	@State private var hasPendingChanges = false

	private func syncPendingFlag() {
		hasPendingChanges = (localTimes != store.timetables[tblIndex].times)
	}

	/// Edit existing variant
	init(_ editing: Times.Set, tblIndex: Int = 0) {
		self.tblIndex = tblIndex
		self.editing = editing
		self.localTimes = Storage.shared.timetables[tblIndex].times
		self.debugID = switch editing {
			case .standard: "Standard"
			case .variant(let key): "Variant \(key)"
		}
	}


	private var isNewVariant: Bool = false
	private var originalNew: Times.Variant? = nil
	private var newIndex: Int? = nil

	enum NewVariantError: Error { case couldntGetNextKey(keys: Dictionary<Int, Times.Variant>.Keys, attempt: Int) }

	/// New variant
	init(blank fromBlank: Bool = true, tblIndex: Int = 0) {

		self.tblIndex = tblIndex
		self.isNewVariant = true

		var tobelocaltimes = Storage.shared.timetables[tblIndex].times


		let nextKey: Int = (tobelocaltimes.variants.keys.max() ?? 0) + 1
		guard tobelocaltimes.variants[nextKey] == nil else {
			fatalError("Couldn't find empty value in \(tobelocaltimes.variants.keys) for key \(nextKey)")
			#warning("TODO fatalError not good idea in long run. Will suffice for quick test.")
		}

		if fromBlank {
			tobelocaltimes.variants[nextKey] = Times.Variant("Variant", variant: [:])
			Logger.editTimes.debug("Built blank variant of \(String(describing: tobelocaltimes.variants[nextKey]))")
		} else {
			tobelocaltimes.variants[nextKey] = Times.Variant("Variant", variant: tobelocaltimes.standard)
		}

		self.editing = .variant(nextKey)
		self.localTimes = tobelocaltimes
		self.originalNew = tobelocaltimes.variants[nextKey]
		self.newIndex = nextKey
		self.debugID = if fromBlank { "New from Blank" } else { "New from Standard" }

		let tempSelf = self
		Logger.editTimes.debug("Variant \(tempSelf.debugID) localTimes variants init as \(tobelocaltimes.variants.keys)")
		//Logger.editTimes.debug("Variant \(tempSelf.debugID) localTimes variants \(tempSelf.localTimes.variants.keys)")
	}


	//MARK: compileChanges
	private func compileChanges() -> [Change] {

		let origin = store.timetables[tblIndex].times
		var changes: [Change] = []

		if isNewVariant {
			let key = switch editing {
			case .standard: {Logger.editTimes.fault("Desync between editing=\(String(reflecting: editing)) and isNewVariant=\(isNewVariant)"); return -1}()
			case .variant(let vkey): vkey
			}
			guard key != -1 else { return [] }
			return [.times_variants_add(key: key, localTimes.variants[key]!, timetable: tblIndex)]
		}

		func theloop(local AnyLocal: Any, original AnyOrigin: Any, for timeschange: Times.Set ) {

		//				Local/Origin Existence & Value combinations:
		//
		//  Local value || A  B  ~ | A  B    ~  ~ | A  B
		// Origin value || A  B  ~ | ~  ~    A  B | B  A
		//      Handler ||..none...|..#1..  ..#3..|..#2..

			let local = switch timeschange {
					case .standard: AnyLocal as! [Int: Times.Period]
					default: (AnyLocal as! Times.Variant).variant
				}
			let origin = switch timeschange {
					case .standard: AnyOrigin as! [Int: Times.Period]
					default: (AnyOrigin as! Times.Variant).variant
				}

			guard type(of: local) == type(of: origin) else {
				Logger.editTimes.fault("compiler theloop input types do not match. local: \(type(of: local)), origin: \(type(of: origin))")
				return
			}

			if timeschange != .standard {
				if let localVariant = AnyLocal as? Times.Variant, let originVariant = AnyOrigin as? Times.Variant {

					if localVariant.name != originVariant.name {
						changes.append(.times_variant_modify(target: timeschange, .rename(localVariant.name), timetable: tblIndex))
					}

				}
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
						return localTimes.variants[key]?.variant ?? localTimes.standard
				}
			}()

			let starttimesortedTimeset = Array(timesets.keys).sorted(by: { timesets[$0]!.startTime < timesets[$1]!.startTime } )






			List {

				Section {
					if editing != .standard {
						let namebinding = Binding<String>(get: {
							switch editing {
							case .standard:
								fatalError("Variant \(debugID) [get] Editing changed values between 'if' and 'switch' switch returned standard inside if editing != .standard")
							case .variant(let key):
								guard let variant = localTimes.variants[key] else {
									Logger.editTimes.fault("Variant \(debugID) Given variant key \(key) not available in local times [TimesVariantEditor]")
									return "Error \(#line)"
								}
								return variant.name
							}
						}, set: { name in
							switch editing {
							case .standard:
								fatalError("Variant \(debugID) [set] Editing changed values between 'if' and 'switch' switch returned standard inside if editing != .standard")
							case .variant(let key):
								guard localTimes.variants[key] != nil else {
									Logger.editTimes.fault("Variant \(debugID) Given variant key not available in local times")
									return
								}
								localTimes.variants[key]!.name = name
							}
						})
						HStack {
							Text("Variant name")
							TextField("Name", text: namebinding).foregroundStyle(.blue)
								.multilineTextAlignment(.trailing)
						}
					}
				}

				ForEach(starttimesortedTimeset, id: \.self) { index in

					TimesRowView(localTimes: $localTimes, editing: editing, index: index, period: Binding(
						get: {
							switch editing {
								case .standard: return localTimes.standard[index]!
								case .variant(let key):
									return localTimes.variants[key]?.variant[index] ?? localTimes.standard[index]!
							}
						}, //Binding(get: )
						set: { new in
							switch editing {
								case .standard: localTimes.standard[index] = new
								case .variant(let target):
									if var variant = localTimes.variants[target]?.variant {
										variant[index] = new
										localTimes.variants[target]!.variant = variant
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
							Logger.editTimes.log("Variant \(debugID) Unconfirmedly removed period from UI timesvariant")
						}.labelStyle(.iconOnly)
							.tint(.red)
					}

				}// ForEach( starttimesortedTimeset )



			//	MARK: New Period
				HStack {
					if !timesets.isEmpty {
						Text("End: \( Time24( from: Date(time24: timesets.sorted { $0.value.startTime < $1.value.startTime }.last?.value.startTime ?? 0900).addingTimeInterval(TimeInterval((timesets.sorted { $0.value.startTime < $1.value.startTime }.last?.value.duration ?? 0) * 60 )) ).display() )").foregroundStyle(.secondary)
						Spacer()
					}
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
				}
				.sheet(isPresented: $newPeriodSheet) {

					NavigationStack {
						NewPeriodView(period: $newPeriod)
							.padding()
							.presentationDetents([.height(250.0)])
							.toolbar {
								ToolbarItem(placement: .confirmationAction) {
									Button("Save", systemImage: "checkmark") {
										switch editing {
										case .standard:
											localTimes.standard.updateValue(newPeriod, forKey: localTimes.standard.count)
										case .variant(let key):
											let nextIndex = (localTimes.variants[key]?.variant.keys.max() ?? -1) + 1
											localTimes.variants[key]!.variant.updateValue(newPeriod, forKey: nextIndex)
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
				if !isNewVariant {
					localTimes = store.timetables[tblIndex].times
					syncPendingFlag()
				}
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
					Logger.<#logger#>.<#action#>("Unconfirmedly removed \"\(deletedName)\" from UI courses (index \(alertIndex))")
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
					if hasPendingChanges || !(localTimes == store.timetables[tblIndex].times) ||
						isNewVariant && localTimes.variants[newIndex!] != originalNew {
						Button("Save", systemImage: "checkmark") {
							let changes = compileChanges()
							do {
								try store.distributeChanges(changes)
							} catch {
								Logger.editTimes.fault("Variant \(debugID)  Couldn't distribute changes \(String(reflecting: changes))")
								return
							}
							store.applyChanges(changes)
							localTimes = store.timetables[tblIndex].times
							hasPendingChanges = (localTimes == store.timetables[tblIndex].times)
							syncPendingFlag()
						}
					}

				}

			}.navigationTitle({switch editing {
				case .standard: "Standard Timing"
				case .variant(_): "Timing Variant"
			}}())


		}// NavigationStack
		.onAppear {
			switch editing {
			case .standard:
				Logger.editTimes.log("Started editing standard Variant \(debugID) ")
			case .variant(let v):
				guard localTimes.variants[v] != nil else {
					Logger.editTimes.fault("\(debugID) Input variant \(v) not found in localtimes variant keys \(localTimes.variants.keys)")
					return
				}
				Logger.editTimes.log("Started editing \(debugID), \(v): \(String(describing: localTimes.variants[v]?.name ))")
			}

		}
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

					Menu {
						NavigationLink("From Standard...") {
							TimesVariantEditor(blank: false, tblIndex: 0)
						}
						NavigationLink("Blank...") {
							TimesVariantEditor(blank: true, tblIndex: 0)
						}
					} label: {
						HStack {
							Label("Add Variant", systemImage: "plus")
								.multilineTextAlignment(.leading)
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
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

		Logger.editTimes.log("Compiling: \n\toriginal: \(origin)\n\tmodified local: \(local)")

		guard origin != local else {
			Logger.editTimes.error("No changes to compile, origin is equal to local. Returning []")
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
		Logger.editTimes.log("Compiled \(changes.count) mapping change(s)")
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
							Logger.editTimes.fault("Couldn't distribute changes \(changes).")
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

