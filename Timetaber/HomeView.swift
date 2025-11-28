//
//  ContentView.swift
//  Timetaber
//
//  Created by Gill Palmer on 14/8/2025.
//

import SwiftUI
import UIKit

let brightnessModifier = -0.6


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
struct HomeView: View {
	
	@EnvironmentObject var data: LocalData
	@Environment(\.colorScheme) var colourScheme

	var body: some View {
		let course = data.currentCourse
		ZStack {
			Colour(course.colour).ignoresSafeArea()
			VStack {
				Spacer()
				
				//MARK: Current Course
				Image(systemName: course.icon)      //ICON
					.font(.system(size: 80).weight(.semibold))
				
				Text(course.name)                   //NAME
					.font(.system(size: 40).weight(.semibold))
				
				Text(roomOrBlank(course) ?? "")     //ROOM/JOKE
					.font(.system(size: 20))
				
				Spacer()
				
				//MARK: Next Course
				
				Text({
					print(data.nextCourse )
					if case .noSchool = data.nextCourse.identifier { print("Case"); return "" }
					guard let room = roomOrBlank(data.nextCourse) else { return "" }

					return "Next up: \(data.nextCourse.name) • \(room)"
					}()
				)
				.font(.system(size: 20))
				
			}.colorInvert()
		}
	}
}

#Preview {
	HomeView()
		.environmentObject(LocalData.shared)
}
