//
//  ContentView.swift
//  Timetaber
//
//  Created by Gill Palmer on 14/8/2025.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var data: GlobalData
    
    var body: some View {
        
        let colour = data.currentCourse.colour
        let room = roomOrBlank(data.currentCourse)
        
        let next = data.nextCourse
        
        let iconSize = 60.0 //name size 92% of icon, room size 60%
        
        VStack {
            
            
            // CURRENT CLASS
            Image(systemName: data.currentCourse.icon)
                .foregroundStyle(Color(colour))
                .imageScale(.large)
                .font(.system(size: iconSize).weight(.semibold))
                //.padding(.bottom, 0.1)
            
            Text(data.currentCourse.name)
                .font(.system(size: iconSize*0.92).weight(.bold))
                .foregroundStyle(Color(colour))
                //.padding(.bottom, 0.01)
            
            // ROOM
            Text(room)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.system(size: iconSize*0.55))
                
            if next.name != "No school" {
                Spacer()
                
                // NEXT CLASS
                Text(nextPrefix(data.nextCourse))
                    .font(.system(size: 15))
                    .bold()
                
                Text(getNextString(data.nextCourse))
                    .foregroundStyle(Color(data.nextCourse.colour))
                    .font(.system(size: 15))
                
            }
        }
        .padding()
        .onAppear() { print("HomeView Updated")}
    }
    
}

#Preview {
    HomeView()
        .environmentObject(GlobalData.shared)
}
