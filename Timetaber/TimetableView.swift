//
//  TimetableView.swift
//  Timetaber
//
//  Created by Gill Palmer on 16/10/2025.
//

import SwiftUI

/*
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
*/

struct DisplayEntry: View {
	
	let listedCourse: Course2
	let timeslotIdentifier: Timeslot
    @Binding var activeCourse: Binding<Bool>
	
    private let day: [Int: [Int]]
    private let courses: [Int: Course2]
	private let room: String?
    private let properties: [Int]



    init(
		timetableDay: [Int: [Int] ],
		timeslot: Timeslot,
        courses: [Int : Course2],
        activeCourse: Binding<Bool>
    )
    {
        self.activeCourse = activeCourse
        
		self.day = timetableDay
		self.timeslotIdentifier = timeslot
        self.courses = courses
		
		let key: Int = timeslot.time
        self.properties = day[key]!
        self.listedCourse = courses[ day[key]![0] ]!
        self.room = if listedCourse.rooms.isEmpty { nil } else { listedCourse.rooms[properties[1]] }
        print("DisplayEntry Initialised,\n\tCourse: \(listedCourse.name)\n\tTime: \(timeslotIdentifier.time)\n\tRoom: \(String(describing: room))")
    }

    var body: some View {

        HStack {
            Image(systemName: listedCourse.icon)
                .font(.title).frame(width: 30)


			Text(time24toNormal(timeslotIdentifier.time)).bold()
            Spacer()
            
            VStack(alignment: .trailing) {
                if room != nil { Text(room!).font(.caption) }
                Text(listedCourse.name).bold()
            }
        }
    }
}


struct TimetableView: View {
    var day: [Int: [Int]]
    var courses: [Int: Course2]
    var week: WeekAB
    var weekday: Int
    @EnvironmentObject var data: LocalData
    
    init(timetable: Timetable,
		 week _week: WeekAB = { if getIfWeekIsA_FromDateAndGhost(originDate: Storage.shared.startDateGB, ghostWeek: Storage.shared.ghostWeekGB) { WeekAB.a } else { WeekAB.b } }(),
		 day _day: Int = weekdayNumber(.now)
	) {
		let wkday = _day
        let wk = _week
        
		self.weekday = wkday
		self.week = wk

		self.day = getTimetableDay2(isWeekA: { if(wk == .a){true}else{false} }(), weekDay: wkday, timetable: timetable)

        self.courses = timetable.courses
        
        let dayKeys = Array(day.keys).sorted(by: <).dropLast()//temp
        print("TimetableView.swift:\(#line) TimetableView Initialised,\n\tDay: \(day),\n\tSecond Course: \(String(describing: courses[ (day[dayKeys[1]])![1] ]))")
    }
    
    var body: some View {
        NavigationStack {
            let dayKeys = Array(day.keys).sorted(by: <).dropLast()
			List {
				Section("Monday A") {
					ForEach(dayKeys, id: \.self) { key in
                        @State var current = { data.currentTime==entry.timeslotIdentifier }()
						let entry = DisplayEntry(
                            timetableDay: day,timeslot: Timeslot(week: week, day: weekday, time: key), courses: courses, activeCourse: $current
                        )
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
