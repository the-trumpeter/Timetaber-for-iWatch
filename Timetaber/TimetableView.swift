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

struct TimetableView: View {
	let day: Dictionary<Int, Course>
	@EnvironmentObject var data: LocalData
    var body: some View {
		NavigationStack {
			let dayKeys = Array(day.keys).sorted(by: <).dropLast()
			List {
				ForEach(dayKeys, id: \.self) { key in

					let listedCourse = day[key] ?? failCourse(feedback: "TtView@\(#line)")

					ListEntry(course: listedCourse)
						.listRowBackground(/*data.currentCourse.name*/English9.name == listedCourse.name ? ( Color(listedCourse.colour)
							.opacity(0.2)
						): nil
						)
				}
			}
			.toolbar {
				NavigationLink {
					EditDayView(timetable: data.timetable).environmentObject(LocalData.shared)
				} label: {
					Label("Edit", systemImage: "pencil")
				}
			}
		}
    }
}

#Preview {
	TimetableView(day: monA).environmentObject(LocalData.shared)
}
