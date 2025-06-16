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
                .foregroundStyle(Color(colour))//add an SF symbol element
                .imageScale(.large)
                .font(.system(size: 25).weight(.semibold))
            
            Text(data.currentCourse.name)
                .font(.system(size:23).weight(.bold))
                .foregroundStyle(Color(colour))
                .padding(.bottom, 0.1)
            
            // ROOM
            Text(room)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.system(size: 15))
                
            if next.name != "No school" {
                Spacer()
                
                // NEXT CLASS
                Text(nextPrefix(data.currentCourse))
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
