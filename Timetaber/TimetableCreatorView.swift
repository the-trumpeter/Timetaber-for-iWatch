//
//  TimetableCreatorView.swift
//  Timetaber
//
//  Created by Gill Palmer on 7/11/2025.
//
import SwiftUI

extension View {
	@ViewBuilder
	func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}

struct EditDayEntryView: View {
	let course: Course2
	let room: Int
	let time: Int
	@Environment(\.colorScheme) private var colourScheme
	var body: some View {
		HStack {
			let roomValid: Bool = course.rooms.indices.contains(room)
			Image(systemName: course.icon)
				.font(.title).frame(width: 30)
				.foregroundStyle(.secondary)

			Text(time24toNormal(time)).bold()
			Spacer()
			VStack(alignment: .trailing) {
				Text(course.name).if(roomValid) { $0.font(.caption) }
				HStack {
					if roomValid {
						Text(course.rooms[room]).bold()
					}
				}
			}
		}
	}
}


struct EntryEditorView: View {
	//@State var course: Binding<Course2>
    var body: some View {

    }
}


struct EditDayView: View {
	//@EnvironmentObject var data: LocalData
	let timetable: Timetable
    @State var showingSheet = false
	@State var pendingChanges = false
	//@State var editingCourse: Course2

	var body: some View {
        
		let day = timetable.timetable[0].monday //getTimetableDay2(isWeekA: <#T##Bool#>, weekDay: <#T##Int#>, timetable: <#T##Timetable#>)
		let courses = timetable.courses
		let dayKeys = Array(day.keys).sorted(by: <).dropLast()
        
		NavigationStack {
			List {
				ForEach(dayKeys, id: \.self) { key in
                    
					let listedCourse = courses[(day[key]![0])] ?? failCourse2(feedback: "TtView@\(#line)")
					EditDayEntryView(course: listedCourse, room: day[key]![1], time: key).swipeActions(allowsFullSwipe: false){
                        Button("Clear", systemImage: "trash") {  }.tint(.red)
						Button("Edit", systemImage: "pencil") {
							showingSheet.toggle()
						}.tint(.orange)
					}
                    
				}
			}.toolbar {
				Button("All") { }
				if pendingChanges {
					Button(action: { /* TODO: implement save */ }) {
						Image(systemName: "checkmark")
					}
					.accessibilityLabel("Save")
				}
            }
        }.sheet(isPresented: $showingSheet) {
			EntryEditorView()
            Button("Dismiss") { showingSheet.toggle() }
				.presentationDetents([.medium])
			}

	}
}

#Preview {
	EditDayView(timetable: chaos).environmentObject(LocalData.shared)
}
