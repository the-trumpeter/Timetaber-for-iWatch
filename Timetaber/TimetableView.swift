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
    @State var showingSheet = false
    let day: [Int: [Int]]
    let key: Int
    let courses: [Int: Course2]

    @State var properties: [Int]

    @State var listedCourse: Course2

    init(
        day: [Int : [Int]],
        time: Int,
        courses: [Int : Course2],
    )
    {
        self.showingSheet = false
        self.day = day
        self.key = time
        self.courses = courses
        self.properties = day[key]!
        self.listedCourse = courses[ day[key]![0] ]!
    }

    var body: some View {

        HStack {
            let roomValid: Bool = listedCourse.rooms.indices.contains(properties[1])
            Image(systemName: listedCourse.icon)
                .font(.title).frame(width: 30)
                .foregroundStyle(.secondary)

            Text(time24toNormal(key)).bold()
            Spacer()
            VStack(alignment: .trailing) {
                if roomValid {
                    Text(listedCourse.rooms[properties[1]]).if(roomValid) { $0.font(.caption) }
                }
                Text(listedCourse.name).bold()
            }
        }
    }
}


struct TimetableView: View {
    let day: [Int: [Int]]
    let courses: [Int: Course2]
    @EnvironmentObject var data: LocalData
    
    init(timetable: Timetable,
         day: [Int : [Int]],//TODO: discard, at some point just calculate from timetable
    ) {
        self.day = day
        self.courses = timetable.courses
    }
    
    var body: some View {
        NavigationStack {
            let dayKeys = Array(day.keys).sorted(by: <).dropLast()
            List {
                Section("Monday A") {
                    ForEach(dayKeys, id: \.self) { key in
                        
                        DisplayEntry(day: day, time: key, courses: courses)

					}
                }
            }.toolbar {
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
    TimetableView(timetable: chaos, day: chaos.timetable[0].monday).environmentObject(LocalData.shared)
}
