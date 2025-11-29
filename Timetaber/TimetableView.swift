//
//  TimetableView.swift
//  Timetaber
//
//  Created by Gill Palmer on 16/10/2025.
//

import SwiftUI

struct ListEntry: View {
	let course: Course
    @Environment(\.colorScheme) private var colourScheme
	var body: some View {
		HStack {
			Image(systemName: course.icon)
			Spacer()
			Text(course.listName)
		}
		.font(.title)
		.bold()
		.foregroundStyle(Colour(course.colour))
		.brightness((colourScheme == .dark) ? 0: brightnessModifier)
	}
}

struct DisplayEntry: View {
	
	let listedCourse: Course2
	let timeslotIdentifier: Timeslot
	
    private let day: [Int: [Int]]
    private let courses: [Int: Course2]
	private let room: String
    private let properties: [Int]



    init(
		timetableDay: [Int: [Int] ],
		timeslot: Timeslot,
        courses: [Int : Course2],
    )
    {
		self.day = timetableDay
		self.timeslotIdentifier = timeslot
        self.courses = courses
		
		let key: Int = timeslot.time
        self.properties = day[key]!
        self.listedCourse = courses[ day[key]![0] ]!
    }

    var body: some View {

        HStack {
            Image(systemName: listedCourse.icon)
                .font(.title).frame(width: 30)


			Text(time24toNormal(timeslotIdentifier.time)).bold()
            Spacer()
            VStack(alignment: .trailing) {
                Text(room).font(.caption)	// listedCourse.rooms.indices.contains(properties[1]) |  listedCourse.rooms[properties[1]]
                Text(listedCourse.name).bold()
            }
        }
    }
}


struct TimetableView: View {
    let day: [Int: [Int]]
    let courses: [Int: Course2]
	let week: WeekAB
	let weekday: Int
    @EnvironmentObject var data: LocalData
    
    init(timetable: Timetable,
		 week: WeekAB? = nil,
		 day: Int? = nil
	) {
		let wkday = day ?? weekdayNumber(.now)
		let wk = week ?? { if getIfWeekIsA_FromDateAndGhost(originDate: data.storage.startDateGB, ghostWeek: data.storage.ghostWeekGB) { .a } else { .b } }()
		self.weekday = wkday
		self.week = wk

		self.day = getTimetableDay2(isWeekA: { if(wk == .a){true}else{false} }(), weekDay: wkday, timetable: timetable)

        self.courses = timetable.courses
    }
    
    var body: some View {
        NavigationStack {
            let dayKeys = Array(day.keys).sorted(by: <).dropLast()
			List {
				Section("Monday A") {
					ForEach(dayKeys, id: \.self) { key in
						let entry = DisplayEntry(timetableDay: day, timeslot: Timeslot(week: <#T##WeekAB#>, day: <#T##Int#>, time: <#T##Int#>), courses: courses)
						let bG: Colour? = (data.currentTime==entry.timeslotIdentifier) ? Colour(entry.listedCourse.colour): nil
						entry
							.listRowBackground(bG)
					}
				}
			}
            .toolbar {
                NavigationLink {
                    EditDayView(timetable: data.timetable, week: .a).environmentObject(LocalData.shared)
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
    }
}



#Preview {
	TimetableView(timetable: chaos, week: .a, day: 2).environmentObject(LocalData.shared)
}
