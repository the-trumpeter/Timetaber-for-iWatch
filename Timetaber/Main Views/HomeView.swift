//
//  ContentView.swift
//  Timetaber
//
//  Created by Gill Palmer on 14/8/2025.
//

import SwiftUI
import UIKit
import OSLog



extension Colour {
    func adjustBrightness(_ amount: Double) -> Colour {
        let uiColor = UIColor(self)
        
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bright: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard uiColor.getHue(&hue, saturation: &sat, brightness: &bright, alpha: &alpha) else {
            return self
        }
        
        let newBrightness = min(max(bright + CGFloat(amount), 0), 1)
        
        return Colour(hue: Double(hue),
                     saturation: Double(sat),
                     brightness: Double(newBrightness),
                     opacity: Double(alpha))
    }
}

//MARK: HomeView
///The app's landing and main view.
struct HomeView: View {
	
	@EnvironmentObject var data: LocalData
	@Environment(\.colorScheme) var colourScheme

	private func roomOrBlank(_ course: DisplayCourse) -> String? {
		guard let room = course.room else {
			guard let joke = course.joke else {
				return nil
			}
			return joke
		}
		return room
	}

	var nextUp: String {
		if case .noSchool = data.nextCourse.type { return "" }
		guard let room = roomOrBlank(data.nextCourse) else { return "" }
		return "Next up: \(data.nextCourse.name) • \(room)"
	}

	var body: some View {
		let course = data.currentCourse
		ZStack {
			if colourScheme == .light { Colour(course.colour).ignoresSafeArea() }
			VStack {
				Spacer()
				
				//MARK: Current Course
				if UIImage(systemName: course.icon) != nil {
						 Image(systemName: course.icon).font(.system(size: 80))
					 } else {
						 Image(course.icon).font(.system(size: 80))
					 }      // ICON



				Text(course.name)                   // NAME
					.font(.system(size: 40).weight(.semibold))

				Text(roomOrBlank(course) ?? "")     // ROOM/JOKE
					.font(.system(size: 20))

				Spacer()
				
				//MARK: Next Course
				
				Text(nextUp)
				.font(.system(size: 20))
				
			}
			.foregroundColor(course.colour.contrastingTextColor)
//			.foregroundStyle(
//				colourScheme == .light ? (coloursNeedBlackForeground.contains(course.colour) ? Colour.black : .primary)
//							/* dark */	: Colour(course.colour)
//			)
//			.if(!coloursNeedBlackForeground.contains(course.colour) && colourScheme == .light) { $0.colorInvert() }

			.padding()
		}
	}
}

#Preview {
	HomeView()
		.environmentObject(LocalData.shared)
}
