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
                .padding(.leading, 5)
            
            Text(listedCourse.name)
                .bold()
            
            Spacer()
            
            Text(courseTime)
            Text(localroom).bold().padding(.trailing, 5)
            
        }
        .padding(.bottom, 1)
        .background(data.currentCourse.name==listedCourse.name ? Color(listedCourse.colour).colorInvert(): nil)
        
    }
}

//MARK: - Day
struct listedDay: View {
    let day: Dictionary<Int, Course>
    var body: some View {
        let dayKeys = Array(day.keys).sorted(by: <).dropLast()
        List {
            ForEach(dayKeys, id: \.self) { key in
                listTemplate(listedCourse: day[key] ?? failCourse(feedback: "LV.lD@56"), courseTime: time24toNormal(time24: key))
                    .environmentObject(GlobalData.shared)
            }
        }
    }
}



// MARK: - Master
struct ListView: View {
    @ObservedObject var storageLocal = storage.shared
    var body: some View {
        
        if storageLocal.termRunningGB && weekdayNumber(ofDate: .now) > 1 && weekdayNumber(ofDate: .now) < 7 {

            listedDay(
                day: getTimetableDay(
                    isWeekA:
                        getIfWeekIsA_FromDateAndGhost(
                            originDate: .now,
                            ghostWeek: storageLocal.ghostWeekGB
                        ),
                 
                    weekDay: weekdayNumber(ofDate: .now)
                )
            )
            
            
        } else if !storageLocal.termRunningGB {
            Text("There's no term running.\nThe day's classes will be displayed here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.system(size: 13))
            
        } else {
            Text("No school today.\nThe day's classes will be displayed here.")
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
    
