//
//  HomeView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var data: GlobalData
    
    var body: some View {
        
        let colour = data.currentCourse.colour
        let room = roomOrBlank(data.currentCourse)
        
        let next = data.nextCourse
        
        VStack {
            
            
            // CURRENT CLASS
            Image(systemName: data.currentCourse.icon)
                .foregroundColor(Color(colour))//add an SF symbol element
                .imageScale(.large)
                .font(.system(size: 25).weight(.semibold))
            
            Text(data.currentCourse.name)
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
                
                if nextPrefix(data.currentCourse) != "" {
                    // NEXT CLASS
                    Text(nextPrefix(next))
                        .font(.system(size: 15))
                }
                if getNextString(data.currentCourse) != "" {
                    Text(getNextString(next))
                        .font(.system(size: 15))
                }
            }
        }
        .padding()
        .onAppear() { print("HomeView Updated") }
    }
    
}

#Preview {
    HomeView()
        .environmentObject(GlobalData.shared)
}
