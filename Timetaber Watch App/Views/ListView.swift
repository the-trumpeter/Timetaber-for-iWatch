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
        HStack{
            
            Image(systemName: listedCourse.listIcon)
                .foregroundColor(Color(listedCourse.colour))
                .padding(.leading, 5)
            
            Text(listedCourse.name)
                .bold()
            
            Spacer()
            
            Text(courseTime)
            Text(listedCourse.room).bold().padding(.trailing, 5)
            
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
                listTemplate(course: day[dayKeys[num]] ?? failCourse(feedback: "lD.53"), courseTime: "")
            }
        }
    }
}




struct ListView: View {
    var body: some View {
        
        ScrollView {
            listedDay(day: tueA)
        }
        
    }
}


#Preview {
    ListView()
}
    
