//
//  HomeView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var data: LocalData
	@Environment(\.self) var env

	private func getNextString(_ course: DisplayCourse) -> String {
/*
		if course.name == "Error" || LocalData.shared.currentCourse.name=="Error" {
			return "bit.ly/ttberError1"
		}*/

		if let room = course.room {
			return switch course.type {
				case .noSchool(.beforeClass(startTime: _)): ""
				default: course.name+" - "+room
			}
		}

		return course.name

	}


	private func nextPrefix(_ course: DisplayCourse) -> String {
		/*
		if course.name == "Error" || LocalData.shared.currentCourse.name=="Error" {
			return "Report this:"
		}*/
		return switch course.type {
			case .noSchool(.beforeClass(startTime: _)): ""
			default: "Next up:"
		}
	}

	private func roomOrBlank(_ course: DisplayCourse) -> String? {
		guard let room = course.room else {
			guard let joke = course.joke else {
				return nil
			}
			return joke
		}
		return room
	}


    var body: some View {

		let current = data.currentCourse //DisplayCourse("LongName", icon: "clock", room: "AB1", colour: "blueberry")
		let next = if current.name != "Error" { data.nextCourse } else { current }

		let colour = if current.colour.resolve(in: env) == Colour("black").resolve(in: env) { Colour("white") } else { current.colour }
		let nextColour = if next.colour.resolve(in: env) == Colour("black").resolve(in: env) { Colour("white") } else { next.colour }

		VStack {
			if Storage.shared.timetables.isEmpty {
				Text("No data. Open Timetaber on your phone to initialise transfer (you may need to relaunch it).").multilineTextAlignment(.center)
					.foregroundStyle(.secondary)
			} else {
				Spacer()
				
				// CURRENT CLASS
				Group {
					if let img = UIImage(named: current.icon) {
						Image(uiImage: img)
							.imageScale(.large)
							.font(.system(size: 27).weight(.semibold))
					} else {
						Image(systemName: current.icon)//data.currentCourse.icon)
							.imageScale(.large)
							.font(.system(size: 27).weight(.semibold))
					}
					Text(current.name)//data.currentCourse.name)
						.font(.system(size:25).weight(.bold))
						.padding(
							EdgeInsets(top: 0, leading: 0, bottom: (current.room != nil) ? -6 : 0, trailing: 0)
						)
				}.foregroundStyle(colour)
				
				// ROOM
				Text(roomOrBlank(current) ?? "")
					.frame(maxWidth: .infinity)
					.multilineTextAlignment(.center)
					.foregroundStyle(.secondary)
					.font(.system(size: 18))
				
				Spacer()
				
				switch next.type {
				case .noSchool(.beforeClass(startTime: _)), .standard:
					// NEXT CLASS
					Text(nextPrefix(next))
						.font(.system(size: 15))
						.bold()
					
					Text(getNextString(next))
						.foregroundStyle(nextColour)
						.font(.system(size: 15))
					
				default: EmptyView()
					
				}
				Spacer()
			}
        }
        //.onAppear() { Logger.<#logger#>.<#action#>("HomeView Updated") }
    }
    
}

#Preview {
    HomeView()
        .environmentObject(LocalData.shared)
}
