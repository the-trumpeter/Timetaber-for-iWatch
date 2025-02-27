//
//  HomeView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI


private var icon = currentCourse.icon
private var name = currentCourse.name
private var colour = currentCourse.colour
private var room = roomOrNil()



struct HomeView: View {
    var body: some View {
        VStack {
            
            
            // CURRENT CLASS
            Image(systemName: icon)
                .foregroundColor(Color(colour))//add an SF symbol element
                .imageScale(.large)
                .font(.system(size: 25).weight(.semibold))
            
            Text(name)
                .font(.system(size:23).weight(.bold))
                .foregroundColor(Color(colour))
            
            // ROOM
            Text(room)
                .foregroundStyle(.gray)
                .font(.system(size: 15))
                .padding(.top, 0.1)
                .padding(.bottom, 8)
            
            // NEXT CLASS
            Text(isNextNothing())
                .font(.system(size: 15))
            
            Text(getNextString())
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
            
        }
        .padding()
    }
    
}

#Preview {
    HomeView()
}
