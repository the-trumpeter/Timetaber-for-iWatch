//
//  HomeView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var data: LocalData
    
    var body: some View {

		let current = ScienceCourse//data.currentCourse
		let next = if current.name != "Error" { data.nextCourse } else { current }

        VStack {
            
            
            // CURRENT CLASS
			Image(systemName: current.icon)//data.currentCourse.icon)
				.foregroundStyle(Colour(current.colour))
                .imageScale(.large)
                .font(.system(size: 25).weight(.semibold))
            
				  Text(current.name)//data.currentCourse.name)
                .font(.system(size:23).weight(.bold))
				.foregroundStyle(Colour(current.colour))
                .padding(.bottom, 0.1)
            
            // ROOM
            Text(roomOrBlank(current) ?? "")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.system(size: 15))
                
			if next.name != "No school" {
                Spacer()
                // NEXT CLASS
                Text(nextPrefix(next))
                    .font(.system(size: 15))
                    .bold()
                
                Text(getNextString(next))
                    .foregroundStyle(Colour(next.colour))
                    .font(.system(size: 15))
                
            }
        }
        .padding()
        .onAppear() { print("HomeView Updated")}
    }
    
}

#Preview {
    HomeView()
        .environmentObject(LocalData.shared)
}
