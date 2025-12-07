//
//  TimetableView.swift
//  Timetaber
//
//  Created by Gill Palmer on 16/10/2025.
//

import SwiftUI


struct DisplayEntry: View {
	
	let listedCourse: Course2
	let timeslotIdentifier: Timeslot

    private let day: [Int: [Int]]
    private let courses: [Int: Course2]
	private let room: String?
    private let properties: [Int]

	@State var isBold: Bool


    init(
		timetableDay: [Int: [Int] ],
		timeslot: Timeslot,
        courses: [Int : Course2],
    )
    {
		self.isBold = (LocalData.shared.currentTime == timeslot) ? true : false

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

		HStack(spacing: 12) {
			if LocalData.shared.currentTime == timeslotIdentifier {
				RoundedRectangle(cornerRadius: 2, style: .continuous)
					.fill(Colour(listedCourse.colour))
					.frame(width: 4, height: 32)
					.transition(.opacity.combined(with: .move(edge: .leading)))
			}

			Image(systemName: listedCourse.icon)
				.font(.title)
				.frame(width: 30)
				.bold(isBold)

			Text(time24toNormal(timeslotIdentifier.time))
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


struct TimetableView: View {
    var day: [Int: [Int]]
    var courses: [Int: Course2]
    var week: WeekAB
    var weekday: Int
    @EnvironmentObject var data: LocalData

	@State var sectionHeader: String

    init(timetable: Timetable,
		 week _week: WeekAB = { if getIfWeekIsA_FromDateAndGhost(originDate: Storage.shared.startDateGB, ghostWeek: Storage.shared.ghostWeekGB) { WeekAB.a } else { WeekAB.b } }(),
		 day _day: Int = weekdayNumber(.now)
	) {
		//May need to return early in case of weekend or no term

		let wkday = _day
        let wk = _week
        
		self.weekday = wkday
		self.week = wk

		self.day = getTimetableDay2(isWeekA: { if(wk == .a){true}else{false} }(), weekDay: wkday, timetable: timetable)

        self.courses = timetable.courses

		let suffix =  if week == .a { " A" } else { " B" }
		self.sectionHeader = switch weekday {
			case 2: "Monday"+suffix
			case 3: "Tuesday"+suffix
			case 4: "Wednesday"+suffix
			case 5: "Thursday"+suffix
			case 6: "Friday"+suffix
			default: "Error \(#line)"
		  }
    }
    
    var body: some View {
        NavigationStack {
            let dayKeys = Array(day.keys).sorted(by: <).dropLast()
			List {
					ForEach(dayKeys, id: \.self) { key in
                        let timeslot = Timeslot(week: week, day: weekday, time: key)
                        let entry = DisplayEntry(
                            timetableDay: day,
                            timeslot: timeslot,
                            courses: courses
                        )
                        let bG: Colour? = (data.currentTime == timeslot) ? Colour(entry.listedCourse.colour) : nil
                        entry
                            .listRowBackground(bG)
				}
			}
            .toolbar {
				ToolbarItem(placement: .principal) { Text(sectionHeader) }
				ToolbarItem(placement: .primaryAction) {
					NavigationLink {
						EditDayView(timetable: data.timetable, week: .a).environmentObject(LocalData.shared)
					} label: {
						Label("Edit", systemImage: "pencil")
					}
				}
            }
        }
    }
}



#Preview {
	TimetableView(timetable: chaos, week: .a, day: 2).environmentObject(LocalData.shared)
}

