//
//  ListView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI


struct listTemplate: View {
    
    var listedCourse: Course = failCourse(feedback: "lT.12")
    var courseTime: String = ""
    
    
    init(course: Course, courseTime: String) {
        self.courseTime = courseTime
        self.listedCourse = course
    }
    
    
    var body: some View {
        let localroom = if listedCourse.room == "None" {
            "" } else { listedCourse.room }
        let image = if listedCourse.listIcon == "custom1" {
            Image(.paintbrushPointedCircleFill)
        } else { Image(systemName: listedCourse.listIcon) }
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
        .background(currentCourse.name==listedCourse.name ? Color(listedCourse.colour).colorInvert(): nil)
        
    }
}


struct listedDay: View {
    let day: Dictionary<Int, Course>
    var body: some View {
        let dayKeys = Array(day.keys).sorted(by: <)
        VStack(alignment: .leading) {
            ForEach((0...dayKeys.count-2), id: \.self) {
                let num = $0
                listTemplate(course: day[dayKeys[num]] ?? failCourse(feedback: "lD.53"), courseTime: time24toNormal(time24: dayKeys[num]))
            }
        }
        
    }
}




struct ListView: View {
    var body: some View {
        
        if storage.shared.termRunningGB && weekdayFunc(inDate: .now) != 1
            && weekdayFunc(inDate: .now) != 7 {
            
            ScrollView {
                listedDay(
                    day: getTimetableDay(
                        isWeekA:
                            getIfWeekIsA_FromDateAndGhost(
                                originDate: .now,
                                ghostWeek: storage.shared.ghostWeekGB
                            ),
                     
                        weekDay: weekdayFunc(inDate: .now)
                    )
                )
            }
            
            
        } else if !storage.shared.termRunningGB {
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


#Preview {
    ListView()
}
    
