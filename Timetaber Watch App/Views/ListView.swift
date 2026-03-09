//
//  ListView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//
//MARK: NO TARGET MEMBERSHIP

import SwiftUI
import OSLog


//MARK: - Template
fileprivate struct listTemplate: View {

    let course: DisplayCourse
	let timeslot: Timeslot

	//private let day: [UUID: Times.Period.Contents]
    //private let courses: [UUID: Course2]
	//let room: String
	//private let properties: Times.Period.Contents
    
    var body: some View {

        let image = Image(systemName: course.listIcon)
        HStack{
            
            image
                .resizable()
                .foregroundStyle(Colour(course.colour))
                .frame(maxWidth: 25, maxHeight: 25)
                .aspectRatio(contentMode: .fit)
                .padding(.leading, 2)
                .padding(.trailing, 3)
            
            VStack {
                HStack {
                    Text(course.listName)
                        .bold()
                    Spacer()
                    
                }
                HStack {
                    
					Text( timeslot.time.display() )
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

//MARK: - Day
fileprivate struct listedDay: View {
	let timetable: Timetable
	var day: [UUID: Times.Period.Contents]
    var courses: [UUID: Course2]
    var week: WeekAB
    var weekday: Int
	let timePairs: [(Time24, UUID?)]
    @EnvironmentObject var data: LocalData
    
    init(timetable: Timetable,
         week _week: WeekAB? = nil,
         day _day: Int? = nil,
		 times: [(Time24, UUID?)],
    ) {
        let wkday = _day ?? weekdayNumber(.now)
        let wk = _week ?? { if getIfWeekIsA_FromDateAndGhost(originDate: Storage.shared.startDateGB, ghostWeek: Storage.shared.ghostWeekGB) { WeekAB.a } else { WeekAB.b } }()

		self.timetable = timetable
		self.timePairs = times

        self.weekday = wkday
        self.week = wk

        self.day = getTimetableDay2(isWeekA: { if(wk == .a){true}else{false} }(), weekDay: wkday, timetable: timetable)

        self.courses = timetable.courses
    }

    var body: some View {
		if timePairs.isEmpty {
			Text("No school today.\nThe day's classes will be displayed here.")
				.multilineTextAlignment(.center)
				.foregroundStyle(.gray)
				.font(.system(size: 13))
        } else {
            List {
                ForEach(timePairs, id: \.0) { pair in
                    let time = pair.0
                    //let uuid = pair.1 //period UUID

					let ts = Timeslot(week: week, day: weekday, time: time)
					if
						let periodContents = (try? timetable.periodContentsFromTimeslot(ts).1), //FIXME: Throwing error
						let course2 = timetable.courses[periodContents.courseID]
					{
						if let room = course2.rooms[periodContents.roomIndex] {
							let displayCourse: DisplayCourse = DisplayCourse(course2, room: room)

							let rowView = listTemplate(course: displayCourse, timeslot: ts)

							let isCurrent: Bool = (data.currentTime == ts)
							let bg: Colour? = isCurrent ? Colour(displayCourse.colour) : nil

							rowView
								.listRowBackground(
									(bg ?? .clear)
										.opacity(0.2)
										.clipShape(RoundedRectangle(cornerRadius: 10))
								)
						} else {
							Text("Error \(#line)") //course2 missing room referenced in period contents
						}

					} else {
						Text("Error \(#line)") //error getting timeslot
						
					}

                }
			}
        }
    }
}



// MARK: - Master
struct ListView: View {
    @ObservedObject var data = Storage.shared
    var body: some View {

        if data.termRunningGB && weekdayNumber(.now) > 1 && weekdayNumber(.now) < 7 {
            
            let wk = getIfWeekIsA_FromDateAndGhost(originDate: data.startDateGB, ghostWeek: data.ghostWeekGB)
			//let day = getTimetableDay2(isWeekA: wk, weekDay: weekdayNumber(.now), timetable: data.timetables[data.ActiveTimetable])
			let times: [(Time24, UUID?)] = {
				do {
					let timing = try findTimes(weekdayNumber(.now), data.timetables[data.ActiveTimetable])
					return timing
				} catch findTimesError.invalidMapping(let failDisplayCourse){
					Logger.views.fault("findTimes threw invalid mapping: \(String(reflecting: failDisplayCourse.room) )")
					return []
				} catch {
					Logger.views.fault("findTimes threw other than invalidMapping")
					return []
				}
			}()
			if times.last?.0 ?? 2400 >= Time24() { //if not after last class of day
				listedDay(timetable: data.timetables[data.ActiveTimetable],
                          week: {if wk {.a}else{.b}}(),
                          day: weekdayNumber(.now),
						  times: times
                )
                    .environmentObject(LocalData.shared)
            } else {
                Text("No school right now.\nThe day's classes will be displayed here.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .font(.system(size: 13))
            }
            
        } else if !data.termRunningGB {
            Text("There's no term running.\nThe day's classes will be displayed here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.system(size: 13))
            
        } else {
            Text("No school right now.\nThe day's classes will be displayed here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.system(size: 13))
        }
        
    }
}

//MARK: -
#Preview {
    ListView()
        .environmentObject(LocalData.shared)
}

