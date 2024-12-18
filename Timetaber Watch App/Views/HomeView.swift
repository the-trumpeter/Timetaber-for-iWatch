//
//  HomeView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI


private var icon = currentClass.icon
private var name = currentClass.name
private var colour = currentClass.colour
private var room = roomOrNil()



struct HomeView: View {
    var body: some View {
        
        VStack {
            
            /// PERIOD
            Text(isPeriodNothing())//add a text element
                .foregroundStyle(.gray)//foreground properties: 1. grey text; 2. size 15 font; 3. 0.2 padding
                .font(.system(size: 15))
                .padding(0.2)
            
            
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
        .onAppear {
            trySetup(dataKey: standardKey)
        }
    }
    
}

#Preview {
    HomeView()
}
