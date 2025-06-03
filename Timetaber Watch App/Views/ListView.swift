//
//  ListView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI


//MARK: - Template
struct listTemplate: View {
    
    @EnvironmentObject var data: GlobalData
    
    var listedCourse: Course
    var courseTime: String
    
    var body: some View {
        
        let localroom = listedCourse.room == "None" ? "": listedCourse.room
        let image = validateIcon(listedCourse.listIcon)

        HStack{
            
            image
                .foregroundColor(Color(listedCourse.colour))
                .padding(.leading, 2)
                .padding(.trailing, 2)
            
            VStack {
                HStack {
                    Text(listedCourse.listName)
                        .bold()
                    Spacer()
                }
                HStack {
                    Text(courseTime)
                    if localroom != "" {
                        Text(localroom).bold().padding(.trailing, 5)
                    }
                    Spacer()
                }
            }
            
        }
        .padding(.bottom, 1)
    }
}

//MARK: - Day
struct listedDay: View {
    @EnvironmentObject var data: GlobalData
    @Environment(\.colorScheme) var colorScheme
    let day: Dictionary<Int, Course>
    
    var body: some View {
        let dayKeys = Array(day.keys).sorted(by: <).dropLast()
        List {
            ForEach(dayKeys, id: \.self) { key in
                
                let listedCourse = day[key] ?? failCourse(feedback: "LV.lD@56")
                
                listTemplate(listedCourse: listedCourse, courseTime: time24toNormal(time24: key))
                    .environmentObject(GlobalData.shared)
                    .listRowBackground(data.currentCourse.name == listedCourse.name ? ( Color(listedCourse.colour)
                        .opacity(colorScheme == .dark ? 0.2 : 1.0)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    ): nil
                    )
            }
        }
    }
}



// MARK: - Master
struct ListView: View {
    @ObservedObject var data = storage.shared
    var body: some View {
        
        let day = getTimetableDay(
            isWeekA:
                getIfWeekIsA_FromDateAndGhost(
                    originDate: .now,
                    ghostWeek: data.ghostWeekGB
                ),
         
            weekDay: weekdayNumber(ofDate: .now)
        )
        
        if data.termRunningGB &&
            weekdayNumber(ofDate: .now) > 1 && weekdayNumber(ofDate: .now) < 7 &&
            Array(day.keys).sorted(by: <).last ?? 1510 <= time24() {

            listedDay(day: day)
            .environmentObject(GlobalData.shared)
            
            
        } else if !data.termRunningGB {
            Text("There's no term running.\nThe day's classes will be displayed here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.system(size: 13))
            
        } else {
            Text("No school right now.\nThe day's classes will be displayed here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.system(size: 13))
        }
        
    }
}

//MARK: -
#Preview {
    ListView()
        .environmentObject(GlobalData.shared)
}
    
