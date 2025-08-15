//
//  ContentView.swift
//  Timetaber
//
//  Created by Gill Palmer on 14/8/2025.
//

import SwiftUI
import UIKit

let brightnessModifier = -0.6

extension Color {
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

struct currentCard: View {
    @EnvironmentObject var data: GlobalData; @Environment(\.colorScheme) var colourScheme
    let course = ScienceCourse //TODO: Tempoary, refactor to data.currentcourse
    var body: some View { HStack {
            Image(systemName: course.icon)
                .font(.system(size: 60).weight(.semibold))
                .foregroundStyle(Colour(course.colour))
            Spacer()
            VStack(alignment: .trailing) {
                Text(course.name)
                    .font(.system(size: 35).weight(.semibold))
                    .foregroundStyle(Colour(course.colour))
                Text(roomOrBlank(course))
                    .font(.system(size: 25).weight(.regular))
                    .foregroundStyle(Colour(course.colour))
            }}.brightness((colourScheme == .dark) ? 0: brightnessModifier)
    }
}

struct nextCard: View {
    @EnvironmentObject var data: GlobalData; @Environment(\.colorScheme) var colourScheme
    var body: some View {
        HStack {
        
            let course = data.nextCourse
            let colour = if data.nextCourse.name != "No school" {
                Colour(course.colour) } else {
                    Colour("Black") }
        
            VStack(alignment: .leading) {
                Text(course.name != "No school" ? "Next up • "+roomOrBlank(course): "Next up:")
                    .font(.system(size: 25).weight(.regular))
                    .foregroundStyle(colour)
                Text(course.name)
                    .font(.system(size: 35).weight(.semibold))
                    .foregroundStyle(colour)
            }
            Spacer()
            Image(systemName: course.icon)
                .font(.system(size: 60).weight(.semibold))
                .foregroundStyle(colour)
        }.brightness((colourScheme == .light && data.nextCourse.name != "No school") ? brightnessModifier: 0 )
    }
}


struct HomeView: View {
    
    @EnvironmentObject var data: GlobalData
    @Environment(\.colorScheme) var colourScheme
    let course = ScienceCourse //TODO: Tempoary, refactor to data.currentCourse
    
    var body: some View {
        
        List {
            currentCard().environmentObject(GlobalData.shared)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Colour(course.colour).adjustBrightness(colourScheme == .dark ? brightnessModifier: 0))
                )
            nextCard().environmentObject(GlobalData.shared)
                .listRowBackground(Colour("NoCol"))
        }.listRowSpacing(15)
         
    }
    
}

#Preview {
    HomeView()
        .environmentObject(GlobalData.shared)
}
