//
//  TimetableView.swift
//  Timetaber
//
//  Created by Gill Palmer on 16/10/2025.
//

import SwiftUI
import OSLog


fileprivate struct DisplayEntry: View {

	let listedCourse: Course2
	let timeslotIdentifier: Timeslot

	private let day: [UUID: Times.Period.Contents]
    private let courses: [UUID: Course2]
	private let room: String?
	private let properties: Times.Period.Contents

	@State var isBold: Bool


    init?(
		timetableDay: [UUID: Times.Period.Contents ],
		timeslot: Timeslot,
        courses: [UUID : Course2],
		timesPair: (Time24, UUID?)
    )
    {
		//Logger.<#logger#>.<#action#>("Start DisplayEntry init")
		self.isBold = (LocalData.shared.currentTime == timeslot) ? true : false

		self.day = timetableDay
		self.timeslotIdentifier = timeslot
        self.courses = courses
		
		// let key: Int = timeslot.time


		guard let tP = timesPair.1 else {
			Logger.views.fault("Missing UUID in tuple (Time24, UUID?)")
			return nil
		}
		guard let prop = day[tP] else {
			Logger.views.error("Could not find UUID in day")
			return nil
		}
		self.properties = prop


		guard let course = courses[ prop.courseID ] else {
			Logger.views.fault("Missing course for UUID \(prop.courseID, privacy: .public)")
			return nil
		}
		self.listedCourse = course


		self.room = if listedCourse.rooms.isEmpty { nil } else { listedCourse.rooms[properties.roomIndex] }
        //Logger.<#logger#>.<#action#>("DisplayEntry Initialised,\n\tCourse: \(listedCourse.name, privacy: .public)\n\tTime: \(timeslotIdentifier.time, privacy: .public)\n\tRoom: \(String(describing: room), privacy: .public)\n")
		//Logger.views.debug("Listing: \(course.name, privacy: .public)")
    }

    var body: some View {

		HStack(spacing: 12) {

/*			 if LocalData.shared.currentTime == timeslotIdentifier {
				RoundedRectangle(cornerRadius: 2, style: .continuous)
					.fill(Colour(listedCourse.colour))
					.frame(width: 4, height: 32)
					.transition(.opacity.combined(with: .move(edge: .leading)))
			}
*/
			Image(systemName: listedCourse.iOSListIcon ?? listedCourse.icon)
				.bold(isBold)
				.font(.title)
				.frame(width: 30)

			Text(timeslotIdentifier.time.display())
				.bold()

			Spacer()

			VStack(alignment: .trailing) {
				if room != nil { Text(room!).font(.caption) }
				Text(listedCourse.name).bold(isBold)
			}
		}
		.animation(.easeInOut(duration: 0.25), value: LocalData.shared.currentTime)
    }
}


///"List view" of today's classes
struct TimetableView: View {
	@EnvironmentObject var data: LocalData
	@ObservedObject var storage: Storage = Storage.shared
	@Environment(\.colorScheme) var colourScheme

	var tblIndex: Int { Storage.shared.ActiveTimetable }
	var week: WeekAB {
		if getIfWeekIsA_FromDateAndGhost(originDate: Storage.shared.startDateGB, ghostWeek: Storage.shared.ghostWeekGB) {
			return WeekAB.a
		} else {
			return WeekAB.b
		}
	}
	var weekday: Int { weekdayNumber(.now) }

	var courses: Binding< [UUID: Course2] > {
		Binding(get: {
			Storage.shared.timetables[tblIndex].courses
		}, set:{_ in}
		)
	}

	var day: [UUID: Times.Period.Contents] {
		return if weekday >= 2 && weekday <= 6 {
			getTimetableDay2(isWeekA: { if(week == .a){true}else{false} }(), weekDay: weekday, timetable: Storage.shared.timetables[tblIndex])
		} else { [:] }
	}


	var sectionHeader: String {
		if times.isEmpty || !Storage.shared.termRunningGB { return "" }
		let suffix = if week == .a { " A" } else { " B" }
		return switch weekdayNumber(.now) {
			case 1: "Sunday"
			case 2: "Monday"+suffix
			case 3: "Tuesday"+suffix
			case 4: "Wednesday"+suffix
			case 5: "Thursday"+suffix
			case 6: "Friday"+suffix
			case 7: "Saturday"
			default: ""
		}
	}

	@State var error = false
	@State var fail: DisplayCourse? = nil

	@State var times: [(Time24, UUID?)] = []
	//@State var dayKeys: [(Time24)] = []



	private func pair_getPrevNextColours(currentPair pair: (Time24, UUID?) ) -> (previous: Colour, next: Colour) {
		let myTime = pair.0
		let prevPair = times.last(where: { $0.0 < myTime } )
		let nextPair = times.first(where: { $0.0 > myTime } )
		let previousProperties: Times.Period.Contents? = if let id = prevPair?.1 { day[id] } else { nil }
		let nextProperties: Times.Period.Contents? = if let id = nextPair?.1 { day[id] } else { nil}
		let prevColour = if let id = previousProperties?.courseID, let course = courses[id].wrappedValue { course.colour } else { Colour(.systemBackground) }
		let nextColour = if let id = nextProperties?.courseID,     let course = courses[id].wrappedValue { course.colour } else { Colour(.systemBackground) }
		return (prevColour, nextColour)
	}
    var body: some View {
        NavigationStack {
			Group {
				if weekday != 1 && weekday != 7 &&
					Storage.shared.termRunningGB == true &&
					error == false &&
					!times.isEmpty
				{


					List {
						ForEach(times, id: \.0) { pair in
							Group {
								let timeslot = Timeslot(week: week, day: weekday, time: pair.0)
								if let entry = DisplayEntry(
									timetableDay: day,
									timeslot: timeslot,
									courses: courses.wrappedValue,
									timesPair: pair
								) {

									var backgroundColour: Colour? {
										if (data.currentTime == timeslot) {

											let colour: Colour = entry.listedCourse.colour
											let colourSchemeIsLight: Bool = (colourScheme == ColorScheme.light)

											if colourSchemeIsLight && colour == Colour("white") {
												return Colour("black")
											}
											if !colourSchemeIsLight && colour == Colour("black") {
												return Colour("white")
											}
											return colour
										} else {
											return nil
										}
									}

									var foregroundColour: Colour {
										var isCurrent: Bool = (data.currentTime == timeslot)
										let colour: Colour = entry.listedCourse.colour

										if backgroundColour == Colour("black") ||
											coloursNeedWhiteForeground.contains(colour) && isCurrent
										{
											return Colour.white
										}
										if backgroundColour == Colour("white") ||
											coloursNeedBlackForeground.contains(colour) && isCurrent
										{
											return Colour.black
										}

										return .primary
									}

									entry
										.listRowBackground(
											HStack(spacing: 0) {
												Rectangle()
													.foregroundStyle(Colour(entry.listedCourse.colour))
													.frame(width: 5.0)
												Spacer(minLength: 0)
											}
											.background(
												Group {
													if let backgroundColour {
														backgroundColour
													}
												}
											)
										)
										.foregroundStyle(foregroundColour)


								} else {
									HStack {
										Spacer()
											.frame(width: 30)

										Text(timeslot.time.display())
											.bold()

										Spacer()

										VStack(alignment: .trailing) {
											let isBold = (LocalData.shared.currentTime == timeslot) ? true : false
											Text("Free Period")
												.bold(isBold)

										}
									}
									.foregroundStyle(.secondary)
									.listRowBackground(
										{
											let prevNextColours = pair_getPrevNextColours(currentPair: pair)
											let gradient = LinearGradient(
												stops: [
													Gradient.Stop(color: Colour(prevNextColours.previous), location: 0),
													Gradient.Stop(color: Colour(.systemBackground), location: 0.1),
													Gradient.Stop(color: Colour(.systemBackground), location: 0.9),
													Gradient.Stop(color: Colour(prevNextColours.next), location: 1)
												],
												startPoint: .top,
												endPoint: .bottom
											)
											return HStack(spacing: 0) {
												Rectangle()
													.foregroundStyle(AnyShapeStyle(gradient))
													.frame(width: 5.0)
												Spacer(minLength: 0)
											}
										}()
									)
								}
							}//.frame(height: 67)
						}
					}
					.listStyle(.inset)
				} else if error {
					Image(systemName: "exclamationmark.triangle").foregroundStyle(.secondary).font(.title).bold(false)
					Text("Error \(#line)").foregroundStyle(.secondary).multilineTextAlignment(.center).bold()
					Text(String(describing: fail?.room)).foregroundStyle(.secondary).multilineTextAlignment(.center)
				} else {
					Text("The day's classes will appear here.").foregroundStyle(.secondary).multilineTextAlignment(.center)
				}

			}
			.navigationTitle(sectionHeader)
			.navigationBarTitleDisplayMode(.inline)
		}
		.onAppear {
			do {
				times = try findTimes(weekday, storage.timetables[tblIndex], includeFinishTime: false)//.map({$0.0})
			} catch findTimesError.invalidMapping(let failDisp) {
				error = true
				fail = failDisp
			} catch {
				fatalError("findTimes threw other than findTimesError.invalidMapping")
			}
		}


    }//body


}



#Preview {
	TimetableView().environmentObject(LocalData.shared)
}

