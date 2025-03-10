//
//  HomeView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI


struct HomeView: View {
    
    @Environment(GlobalData.self) private var data
    
    var body: some View {
        
        let icon = data.currentCourse.icon
        let name = data.currentCourse.name
        let colour = data.currentCourse.colour
        let room = roomOrBlank(course: data.currentCourse)
        
        let next = data.nextCourse
        
        VStack {
            
            
            // CURRENT CLASS
            Image(systemName: icon)
                .foregroundColor(Color(colour))//add an SF symbol element
                .imageScale(.large)
                .font(.system(size: 25).weight(.semibold))
            
            Text(name)
                .font(.system(size:23).weight(.bold))
                .foregroundColor(Color(colour))
                .padding(.bottom, 0.1)
            
            // ROOM
            Text(room+"\n")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.system(size: 15))
                
            if next.name != noSchool.name {
                Spacer()
                
                // NEXT CLASS
                Text(nextPrefix(course: next))
                    .font(.system(size: 15))
                
                Text(getNextString(course: next))
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
    
}

#Preview {
    HomeView()
        .environment(GlobalData())
}
