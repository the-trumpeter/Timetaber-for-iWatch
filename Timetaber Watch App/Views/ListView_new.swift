//
//  ListView_new.swift
//  Timetaber
//
//  Created by Gill Palmer on 4/3/2026.
//


import SwiftUI
import OSLog
import UIKit

fileprivate struct DisplayEntry: View {

	let listedCourse: Course2
	let course: DisplayCourse
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
			Logger.views.fault("Invalid UUID \(tP, privacy: .public) in day")
			return nil
		}
		self.properties = prop


		guard let course = courses[ prop.courseID ] else {
			Logger.views.fault("Missing course for UUID \(prop.courseID, privacy: .public)")
			return nil
		}
		self.listedCourse = course
		let room = course.rooms[prop.roomIndex]
		self.course = DisplayCourse(course, room: room)


		self.room = if listedCourse.rooms.isEmpty { nil } else { listedCourse.rooms[properties.roomIndex] }
		//Logger.<#logger#>.<#action#>("DisplayEntry Initialised,\n\tCourse: \(listedCourse.name, privacy: .public)\n\tTime: \(timeslotIdentifier.time, privacy: .public)\n\tRoom: \(String(describing: room), privacy: .public)\n")
	}

	var body: some View {

		HStack{
			if UIImage(systemName: course.listIcon) != nil {
				Image(systemName: course.listIcon)
					.resizable()
					.foregroundStyle(Colour(course.colour))
					.frame(maxWidth: 25, maxHeight: 25)
					.aspectRatio(contentMode: .fit)
					.padding(.leading, 2)
					.padding(.trailing, 3)
					.if(course.listIcon == "black") {
						$0.foregroundStyle(.primary)
					}
			} else {
				Image(systemName: course.icon)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.symbolVariant(.circle)
					.symbolVariant(.fill)
					.foregroundStyle(Colour(course.colour))
					.frame(maxWidth: 25, maxHeight: 25)
					.padding(.leading, 2)
					.padding(.trailing, 3)
					.if(course.listIcon == "black") {
						$0.foregroundStyle(.primary)
					}
			}

			VStack {
				HStack {
					Text(course.listName)
						.bold()
					Spacer()

				}
				HStack {

					Text( timeslotIdentifier.time.display() )
						.foregroundStyle(.secondary)
					if let room = course.room {
						Text(room).bold()
							.foregroundStyle(.secondary)
					}
					Spacer()
				}
			}

		}
		.padding(.bottom, 1)
	}
}


///"List view" of today's classes
struct TimetableView: View {

	@EnvironmentObject var data: LocalData
	@ObservedObject var storage: Storage = Storage.shared
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
		let suffix = if week == .a { " A" } else { " B" }
		return switch weekdayNumber(.now) {
			case 2: "Monday"+suffix
			case 3: "Tuesday"+suffix
			case 4: "Wednesday"+suffix
			case 5: "Thursday"+suffix
			case 6: "Friday"+suffix
			default: "Error \(#line)"
		}
	}


	@State var error = false
	@State var fail: DisplayCourse? = nil

//		init(week _week: WeekAB = { if getIfWeekIsA_FromDateAndGhost(originDate: Storage.shared.startDateGB, ghostWeek: Storage.shared.ghostWeekGB) { WeekAB.a } else { ˆWeekAB.b } }(),
//		 day _day: Int = weekdayNumber(.now),
//		 tblIndex: Int = 0
//	) {
//		//May need to return early in case of weekend or no term
//		//Logger._.("Start TimetableView init")
//		let wkday = _day
//		let wk = _week
//		let tbl = Storage.shared.timetables[tblIndex]
//
//		self.weekday = wkday
//		self.week = wk
//
//		self.day = if wkday >= 2 && wkday <= 6 {
//			getTimetableDay2(isWeekA: { if(wk == .a){true}else{false} }(), weekDay: wkday, timetable: tbl)
//		} else { [:] }
//
//		self.courses = Binding(get: {
//			Storage.shared.timetables[tblIndex].courses
//			}, set:{_ in}
//			)
//
//		self.tblIndex = tblIndex
//
//		let suffix =  if week == .a { " A" } else { " B" }
//		self.sectionHeader = switch weekday {
//			case 2: "Monday"+suffix
//			case 3: "Tuesday"+suffix
//			case 4: "Wednesday"+suffix
//			case 5: "Thursday"+suffix
//			case 6: "Friday"+suffix
//			default: "Error \(#line)"
//		  }
//		//Logger.<#logger#>.<#action#>("End TimetableView init")
//	}

	@State var times: [(Time24, UUID?)] = []
//	@State var dayKeys: [(Time24)] = []

	var body: some View {
		NavigationStack {

			if weekday != 1 && weekday != 7 &&
				Storage.shared.termRunningGB == true &&
				error == false
			{


				List {
					
					ForEach(times, id: \.0) { pair in
						let timeslot = Timeslot(week: week, day: weekday, time: pair.0)
						if let entry = DisplayEntry(
							timetableDay: day,
							timeslot: timeslot,
							courses: courses.wrappedValue,
							timesPair: pair
						) {
							let bG: Colour? = (data.currentTime == timeslot) ? Colour(entry.listedCourse.colour) : nil
							entry
								.listRowBackground(
									(bG ?? .clear)
										.opacity(0.2)
										.clipShape(RoundedRectangle(cornerRadius: 10))
								)
						} else {
							Text("Error \(#line):\(pair.0)")
						}
					}
				}
//				.listStyle(.inset)
//				.toolbar {
//					ToolbarItem(placement: .principal) { Text(sectionHeader) }
//				}
			} else if error {
//				Image(systemName: "exclamationmark.triangle").foregroundStyle(.secondary).font(.title).bold(false)
				Text("Error \(#line)").foregroundStyle(.secondary).multilineTextAlignment(.center).bold()
//				Text(String(describing: fail?.room)).foregroundStyle(.secondary).multilineTextAlignment(.center)
//			} else if Storage.shared.termRunningGB == false {
//				Text("No school right now.\nIt's the holidays.").foregroundStyle(.secondary).multilineTextAlignment(.center).padding()
//				Text("The day's classes will appear here.").foregroundStyle(.secondary).multilineTextAlignment(.center)
//			} else if weekdayNumber(.now) != 1 || weekdayNumber(.now) != 7 {
//				Text("No school right now.\nIt's the weekend.").foregroundStyle(.secondary).multilineTextAlignment(.center).padding()
//				Text("The day's classes will appear here.").foregroundStyle(.secondary).multilineTextAlignment(.center)
//
			} else {
				//Text("No school right now.").foregroundStyle(.secondary).multilineTextAlignment(.center).padding()
				Text("The day's classes will appear here.").foregroundStyle(.secondary).multilineTextAlignment(.center)
			}

//			.toolbar {
//				ToolbarItem(placement: .primaryAction) {
//					NavigationLink {
//						EditDayView(timetable: Storage.shared.timetable, week: week)
//							} label: { 						Label("Edit", systemImage: "pencil")
//					}
//				}
//			}
		}.onAppear {
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


//
//#Preview {
//	TimetableView(week: .a, day: 2).environmentObject(LocalData.shared)
//}
//
