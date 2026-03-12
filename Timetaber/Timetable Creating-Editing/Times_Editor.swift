//
//  TimesEditor.swift
//  Timetaber
//
//  Created by Gill Palmer on 30/12/2025.
//

import SwiftUI
import OSLog

// MARK: - Period Time Utilities
private extension Times.Period {
    var endTime: Time24 {
        let endDate = Date(time24: startTime).addingTimeInterval(TimeInterval(duration * 60))
        return Time24(from: endDate)
    }
}

private func sortedIndicesByStart(_ periods: [UUID: Times.Period]) -> [UUID] {
    periods.keys.sorted { lhs, rhs in
        guard let l = periods[lhs], let r = periods[rhs] else { return lhs < rhs }
        return l.startTime < r.startTime
    }
}

private func hasOverlap(in periods: [UUID: Times.Period]) -> Bool {
    let sorted = sortedIndicesByStart(periods)
    for (prevIdx, nextIdx) in zip(sorted, sorted.dropFirst()) {
        guard let prev = periods[prevIdx], let next = periods[nextIdx] else { continue }
        if prev.endTime > next.startTime { return true }
    }
    return false
}

private func overlapsNeighbors(index: UUID, period: Times.Period, in periods: [UUID: Times.Period]) -> Bool {
    let sorted = sortedIndicesByStart(periods)
    guard let pos = sorted.firstIndex(of: index) else { return false }
    // Previous neighbor
    if pos > 0 {
        let prevKey = sorted[pos - 1]
        if let prev = periods[prevKey] {
            if prev.endTime > period.startTime { return true }
        }
    }
    // Next neighbor
    if pos < sorted.count - 1 {
        let nextKey = sorted[pos + 1]
        if let next = periods[nextKey] {
            if period.endTime > next.startTime { return true }
        }
    }
    return false
}



//MARK: - New Period view
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

				Button {} label: { Text("\(period.duration/60, privacy: .public):\(period.duration % 60 < 10 ? "0":"", privacy: .public)\(period.duration%60)") }
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







//MARK: - Edit Period sheet
fileprivate struct TimesSheetView: View {
	//var startBinding: Binding<Date>
	//var durationBinding: Binding<Date>

	var parent: Binding<Times.Period>
	@State var period: Times.Period

	var allTimes: Binding<Times>?
	var editingSet: Times.TimingSet?
	var periodIndex: UUID?

	@Environment(\.dismiss) var dismiss

	init(period: Binding<Times.Period>, allTimes: Binding<Times>? = nil, editingSet: Times.TimingSet? = nil, periodIndex: UUID? = nil) {
		//self.startBinding = startBinding
		//self.durationBinding = durationBinding
		self.parent = period
		self.period = period.wrappedValue
		self.allTimes = allTimes
		self.editingSet = editingSet
		self.periodIndex = periodIndex
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

		let showsOverlapWarning: Bool = {
			guard let allTimes, let editingSet, let idx = periodIndex else { return false }
			var candidate: [UUID: Times.Period] = {
				switch editingSet {
				case .standard: return allTimes.wrappedValue.standard
				case .variant(let key): return allTimes.wrappedValue.variants[key]?.variant ?? [:]
				}
			}()
			candidate[idx] = period
			return overlapsNeighbors(index: idx, period: period, in: candidate)
		}()

		NavigationStack {
			VStack {

				if showsOverlapWarning { HStack(spacing: 8) { Image(systemName: "exclamationmark.triangle.fill"); Text("This period overlaps another."); Spacer() }.foregroundStyle(.yellow) }

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

					Button {} label: { Text("\(period.duration/60, privacy: .public):\(period.duration % 60 < 10 ? "0":"")\(period.duration%60, privacy: .public)") }
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
						withAnimation {
							parent.wrappedValue = period
							Logger.editTimes.log("Saved changes to times sheet")
							dismiss()
						}
					}
				}
				/*
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", systemImage: "xmark") {
						dismiss()
					}
				}
				 */
			}
		}
	}
}









//MARK: - Period row template
fileprivate struct TimesRowView: View {
	var localTimes: Binding<Times>
	let editing: Times.TimingSet
	let index: UUID
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
		let startDate = Date(time24: period.wrappedValue.startTime)

		let timeset: [UUID: Times.Period] = {
			switch editing {
			case .standard: return localTimes.wrappedValue.standard
			case .variant(let key): return localTimes.wrappedValue.variants[key]?.variant ?? [:]
			}
		}()
		let isOverlapping: Bool = {
			var candidate = timeset
			candidate[index] = period.wrappedValue
			return overlapsNeighbors(index: index, period: period.wrappedValue, in: candidate)
		}()

		Button {
			sheet.toggle()
		} label: {
			HStack {
				if isOverlapping { Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow) }
				if Float(period.wrappedValue.name) != nil {
					Text("Pd.").foregroundStyle(.secondary)
				}
				Text(period.wrappedValue.name)
				Spacer()
				Text("\(startDate.formatted(Date.FormatStyle().hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)), privacy: .public)")
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)

		.sheet(isPresented: $sheet) {
			TimesSheetView(period: period, allTimes: localTimes, editingSet: editing, periodIndex: index)
				.interactiveDismissDisabled()
				.presentationDetents([.height(250.0)])
		}//sheet
	}
}












//MARK: - Edit Variant
///Edit the structure of a timing set.
fileprivate struct TimesVariantEditor: View {

	@ObservedObject var store = Storage.shared

	let debugID: String

	//Standard setup
	let tblIndex: Int
	@State var localTimes: Times
	@State var editing: Times.TimingSet
//	@State var sheetNo: Int = -1

	//New Period
	@State private var newPeriod = Times.Period("", startTime: 0000, duration: 0000)
	@State private var newPeriodSheet = false

//	@State private var alertIndex = 0
//	@State private var showingAlert = false
	//Changes/UI
	@State private var hasPendingChanges = false
	@State private var discardConfirmation = false


	@Environment(\.dismiss) private var dismiss

	private func syncPendingFlag() {
		hasPendingChanges = (localTimes != store.timetables[tblIndex].times)
	}

	/// Edit existing variant
	init(_ editing: Times.TimingSet, tblIndex: Int = 0) {
		self.tblIndex = tblIndex
		self.editing = editing
		self.localTimes = Storage.shared.timetables[tblIndex].times
		self.debugID = switch editing {
			case .standard: "Standard"
			case .variant(let key): "Variant \(key, privacy: .public)"
		}
	}


	private var isNewVariant: Bool = false
	private var originalNew: Times.Variant? = nil
	private var newIndex: UUID? = nil

	enum NewVariantError: Error { case couldntGetNextKey(keys: Dictionary<Int, Times.Variant>.Keys, attempt: [Int]) }

	/// New variant
	init(blank fromBlank: Bool = true, tblIndex: Int = 0) throws {

		self.tblIndex = tblIndex
		self.isNewVariant = true

		let tobelocaltimes = Storage.shared.timetables[tblIndex].times
/*
		var attempts: [Int] = []
		var nextKey: Int = (tobelocaltimes.variants.keys.max() ?? 0) + 1
		var loopedTimes = 0
		while tobelocaltimes.variants[nextKey] != nil && loopedTimes <= 5 {
			attempts.append(nextKey)
			Logger.dateTime.fault("Couldn't find empty value in \(tobelocaltimes.variants.keys, privacy: .public) for key \(nextKey, privacy: .public). Trying again with \(nextKey+1, privacy: .public)...")
			nextKey += 1
			loopedTimes += 1
		}
		if loopedTimes >= 5 {
			Logger.dateTime.fault("Couldn't find empty value in \(tobelocaltimes.variants.keys, privacy: .public) in five tries.")
			throw NewVariantError.couldntGetNextKey(keys: tobelocaltimes.variants.keys, attempt: attempts)
		}

		if fromBlank {
			tobelocaltimes.variants[nextKey] = Times.Variant("Variant", variant: [:])
			Logger.editTimes.debug("Built blank variant of \(String(describing: tobelocaltimes.variants[nextKey]), privacy: .public)")
		} else {
			tobelocaltimes.variants[nextKey] = Times.Variant("Variant", variant: tobelocaltimes.standard)
		}
*/		let newkey = UUID()
		self.editing = .variant(newkey)
		self.localTimes = tobelocaltimes
		self.originalNew = tobelocaltimes.variants[newkey]
		self.newIndex = newkey
		self.debugID = if fromBlank { "New from Blank" } else { "New from Standard" }

		let tempSelf = self
		Logger.editTimes.debug("Variant \(tempSelf.debugID, privacy: .public) localTimes variants init as \(tobelocaltimes.variants.keys, privacy: .public)")
		//Logger.editTimes.debug("Variant \(tempSelf.debugID, privacy: .public) localTimes variants \(tempSelf.localTimes.variants.keys, privacy: .public)")
	}


	//MARK: compileChanges
	private func compileChanges() -> [Change] {

		let origin = store.timetables[tblIndex].times
		var changes: [Change] = []

		if isNewVariant {
			guard let key: UUID = switch editing {
			case .standard: { Logger.editTimes.fault("Desync between editing=\(String(reflecting: editing), privacy: .public) and isNewVariant=\(isNewVariant, privacy: .public)"); return nil }()
			case .variant(let vkey): vkey
			} else { return [] }
			//guard key != -1 else { return [] }
			return [.times_variants_add(key: key, localTimes.variants[key]!, timetable: tblIndex)]
		}

		func theloop(local AnyLocal: Any, original AnyOrigin: Any, for timeschange: Times.TimingSet ) {

		//				Local/Origin Existence & Value combinations:
		//
		//  Local value || A  B  ~ | A  B    ~  ~ | A  B
		// Origin value || A  B  ~ | ~  ~    A  B | B  A
		//      Handler ||..none...|..#1..  ..#3..|..#2..

			let local: [UUID: Times.Period] = {
				switch timeschange {
				case .standard:
					return AnyLocal as! [UUID: Times.Period]
				case .variant:
					return (AnyLocal as! Times.Variant).variant
				}
			}()
			let origin: [UUID: Times.Period] = {
				switch timeschange {
				case .standard:
					return AnyOrigin as! [UUID: Times.Period]
				case .variant:
					return (AnyOrigin as! Times.Variant).variant
				}
			}()

			guard type(of: local) == type(of: origin) else {
				Logger.editTimes.fault("compiler theloop input types do not match. local: \(type(of: local, privacy: .public)), origin: \(type(of: origin, privacy: .public))")
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







	//MARK: Edit Variant body
	var body: some View {
		NavigationStack {



		//	Precompute the timesets for the current editing selection
			let timesets: [UUID: Times.Period] = {
				switch editing {
					case .standard: return localTimes.standard
					case .variant(let key):
						return localTimes.variants[key]?.variant ?? localTimes.standard
				}
			}()

			let starttimesortedTimeset = Array(timesets.keys).sorted(by: { timesets[$0]!.startTime < timesets[$1]!.startTime } )

			let invalidOrderingOrOverlap: Bool = { let set = timesets; return hasOverlap(in: set) }()


			List {

				if invalidOrderingOrOverlap { HStack(spacing: 8) { Image(systemName: "exclamationmark.triangle.fill"); Text("Periods overlap. Adjust start times or durations."); Spacer() }.foregroundStyle(.yellow).listRowBackground(Color.yellow.opacity(0.15)) }

				Section {
					if editing != .standard {
						let namebinding = Binding<String>(get: {
							switch editing {
							case .standard:
								fatalError("Variant \(debugID, privacy: .public) [get] Name binding | Editing changed values between 'if' and 'switch', switch returned standard inside 'if editing != .standard'")
							case .variant(let key):
								guard let variant = localTimes.variants[key] else {
									Logger.editTimes.fault("Variant \(debugID, privacy: .public) Given variant key \(key, privacy: .public) not available in local times [TimesVariantEditor]")
									return "Error \(#line)"
								}
								return variant.name
							}
						}, set: { name in
							switch editing {
							case .standard:
								fatalError("Variant \(debugID, privacy: .public) [get] Name binding | Editing changed values between 'if' and 'switch', switch returned standard inside 'if editing != .standard'")
							case .variant(let key):
								guard localTimes.variants[key] != nil else {
									Logger.editTimes.fault("Variant \(debugID, privacy: .public) Given variant key not available in local times")
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
							Logger.editTimes.log("Variant \(debugID, privacy: .public) Unconfirmedly removed period from UI timesvariant")
						}.labelStyle(.iconOnly)
							.tint(.red)
					}

				}// ForEach( starttimesortedTimeset )



			//	MARK: New Period
				HStack {
					if let lastKey = sortedIndicesByStart(timesets).last, let last = timesets[lastKey] {
						Text("End: \(last.endTime.display(), privacy: .public)").foregroundStyle(.secondary)
						Spacer()
					}
					Button("Add Period", systemImage: "plus") {
						///**	Calculate new period template from existing ones
						let lastPeriod = timesets.sorted { $0.value.startTime < $1.value.startTime }.last?.value
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
											let newID = UUID()
											localTimes.standard.updateValue(newPeriod, forKey: newID)
										case .variant(let key):
											let newID = UUID()
											localTimes.variants[key]!.variant.updateValue(newPeriod, forKey: newID)
										}
										newPeriodSheet = false
									}
								}
								/*ToolbarItem(placement: .cancellationAction) {
									Button("Cancel", systemImage: "xmark") {
										newPeriodSheet = false
									}
								}*/

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
					if (hasPendingChanges || !(localTimes == store.timetables[tblIndex].times) || (isNewVariant && localTimes.variants[newIndex!] != originalNew)) {
						Button("Save", systemImage: "checkmark") {
							let changes = compileChanges()

							store.distributeChanges(changes)
							store.applyChanges(changes)

							localTimes = store.timetables[tblIndex].times
							hasPendingChanges = (localTimes == store.timetables[tblIndex].times)
							syncPendingFlag()
						}.disabled(invalidOrderingOrOverlap)
					}

				}

				ToolbarItem(placement: .topBarLeading) {
					Button {
						if (hasPendingChanges || !(localTimes == store.timetables[tblIndex].times) || (isNewVariant && localTimes.variants[newIndex!] != originalNew)) {
							discardConfirmation = true
						} else {
							dismiss()
						}
					} label: {
						if (hasPendingChanges || !(localTimes == store.timetables[tblIndex].times) || (isNewVariant && localTimes.variants[newIndex!] != originalNew)) {
							Text("Discard")
						} else {
							Label("Back", systemImage: "chevron.left")
						}
					}
				}

			}
			.alert("Discard changes?", isPresented: $discardConfirmation) {
				Button("Discard", role: .destructive) {
					withAnimation {
						localTimes = store.timetables[tblIndex].times
						hasPendingChanges = (localTimes == store.timetables[tblIndex].times)
						syncPendingFlag()
					}
				}
				Button("Cancel", role: .cancel) {
					discardConfirmation = false
				}
			}
			.navigationBarBackButtonHidden(true)


		}// NavigationStack
		.onAppear {
			switch editing {
			case .standard:
				Logger.editTimes.log("Started editing standard Variant \(debugID) ")
			case .variant(let v):
				guard localTimes.variants[v] != nil else {
					Logger.editTimes.fault("\(debugID, privacy: .public) Input variant \(v, privacy: .public) not found in localtimes variant keys \(localTimes.variants.keys, privacy: .public)")
					return
				}
				Logger.editTimes.log("Started editing \(debugID, privacy: .public), \(v, privacy: .public): \(String(describing: localTimes.variants[v]?.name ), privacy: .public)")
			}

		}
	}// body
} // TimesVariantEditor










//MARK: Public access variant editor
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
					let variantKeys: [UUID] = Array(times.variants.keys)
					ForEach(variantKeys, id: \.self) { vKey in
						NavigationLink(times.variants[vKey]!.name) { TimesVariantEditor(.variant(vKey), tblIndex: tblIndex) }
					}

					Menu {
						NavigationLink("From Standard...") {
							{
								do {
									return try AnyView( TimesVariantEditor(blank: false, tblIndex: 0) )
								} catch TimesVariantEditor.NewVariantError.couldntGetNextKey(keys: let keys, attempt: let attempts) {
									Logger.editTimes.fault("Couldn't get a blank opening for a new variant in \(keys, privacy: .public). Tried \(attempts, privacy: .public)")
									return AnyView( VStack {
										Image(systemName: "exclamationmark.triangle").font(.title).bold(false)
										Text("Error \(#line)").bold()
										Text(String(describing: keys))
										Text(String(describing: attempts))
									}.foregroundStyle(.secondary).multilineTextAlignment(.center) )
								} catch {
									Logger.editTimes.fault("TimesVariantEditor threw other than TimesVariantEditor.NewVariantError.couldntGetNextKeys")
									return AnyView( VStack {
										Image(systemName: "exclamationmark.triangle").font(.title).bold(false)
										Text("Catastrophic Error (\(#line))").bold()
										Text("Variant editor threw other than .couldntGetNextKeys")
									}.foregroundStyle(.secondary).multilineTextAlignment(.center) )
								}
							}()
						}
						NavigationLink("Blank...") {
							{
								do {
									return try AnyView( TimesVariantEditor(blank: true, tblIndex: 0) )
								} catch TimesVariantEditor.NewVariantError.couldntGetNextKey(keys: let keys, attempt: let attempts) {
									Logger.editTimes.fault("Couldn't get a blank opening for a new variant in \(keys, privacy: .public). Tried \(attempts, privacy: .public)")
									return AnyView( VStack {
										Image(systemName: "exclamationmark.triangle").font(.title).bold(false)
										Text("Error \(#line)").bold()
										Text(String(describing: keys))
										Text(String(describing: attempts))
									}.foregroundStyle(.secondary).multilineTextAlignment(.center) )
								} catch {
									Logger.editTimes.fault("TimesVariantEditor threw other than TimesVariantEditor.NewVariantError.couldntGetNextKeys")
									return AnyView( VStack {
										Image(systemName: "exclamationmark.triangle").font(.title).bold(false)
										Text("Catastrophic Error (\(#line))").bold()
										Text("Variant editor threw other than .couldntGetNextKeys")
									}.foregroundStyle(.secondary).multilineTextAlignment(.center) )
								}
							}()
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













//MARK: -
//MARK: -









//MARK: Public access mapping editor
///Edit the structure of each week.
struct TimesMapping: View {

	@Environment(\.dismiss) var dismiss

	@ObservedObject var store = Storage.shared
	var tblIndex: Int

	@State var localTimes: Times
	@State var origin: Times

	@State var bool_pendingChanges = false
	@State var discardConfirmation = false

	init(tblIndex: Int = 0) {
		self.tblIndex 	= tblIndex
		self.localTimes = Storage.shared.timetables[tblIndex].times
		self.origin 	= Storage.shared.timetables[tblIndex].times
	}

	
	func compileChanges() -> [Change] {

		let origin = store.timetables[tblIndex].times.mapping
		let local = localTimes.mapping

		Logger.editTimes.log("Compiling: \n\toriginal: \(origin, privacy: .public)\n\tmodified local: \(local, privacy: .public)")

		guard origin != local else {
			Logger.editTimes.error("No changes to compile, origin is equal to local. Returning []")
			bool_pendingChanges = false
			return []
		}
		if !bool_pendingChanges { bool_pendingChanges = true }

		var changes: [Change] = []

		for wkd in 2...6 {
			let loc = local[wkd]
			let orig = origin[wkd]
			if loc != orig {
				changes.append(.times_variant_key(weekday: wkd, variant: loc,	timetable: tblIndex))
			}
		}
		
		bool_pendingChanges = false
		Logger.editTimes.log("Compiled \(changes.count, privacy: .public) mapping change(s)")
		return changes
	}

	let week_days = [2: "Monday", 3: "Tuesday", 4: "Wednesday", 5: "Thursday", 6: "Friday"]

	var body: some View {
		NavigationStack {
			List {

				ForEach(Array(week_days.keys.sorted()), id: \.self) { day in

					Picker(week_days[day]!, selection: Binding<UUID?>(
						get: {
							switch localTimes.mapping[day] {
								case .variant(let key): return key
								case .standard: return nil
								case .none: return nil
							} },
						set: { new in
							if let newID = new {
								localTimes.mapping[day] = .variant(newID)
							} else { localTimes.mapping[day] = .standard }
							bool_pendingChanges = (localTimes != origin)
						}
					)) {
						Text("Standard times").tag(UUID?.none)
						Divider()
						ForEach(Array(localTimes.variants.keys), id: \.self) { variantKey in
							Text(localTimes.variants[variantKey]!.name).tag(UUID?.some(variantKey))
						}
					}

				}.onChange(of: localTimes) { _, _ in
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

						store.distributeChanges(changes)
						store.applyChanges(changes)
						
						withAnimation {
							let t = store.timetables[tblIndex].times
							localTimes = t; origin = t
						}
					}
				}
			}
			ToolbarItem(placement: .topBarLeading) {
				Button {
					if bool_pendingChanges {
						discardConfirmation = true
					} else {
						dismiss()
					}
				} label: {
					if bool_pendingChanges {
						Text("Discard")
					} else {
						Label("Back", systemImage: "chevron.left")
					}
				}
			}

		}
		.alert("Discard changes?", isPresented: $discardConfirmation) {
			Button("Discard", role: .destructive) {
				withAnimation {
					localTimes = store.timetables[tblIndex].times
					origin = store.timetables[tblIndex].times
					bool_pendingChanges = false
				}
			}
			Button("Cancel", role: .cancel) {
				discardConfirmation = false
			}
		}
		.navigationBarBackButtonHidden(true)

	}
}





//MARK: #Preview
#Preview {
	TimesEditor(tblIndex: 0)
}

