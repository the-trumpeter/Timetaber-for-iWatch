//
//  ListView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI



func getListView(course: Course, time: String) -> some View {
    
    struct listing: View {
        var localCourse: Course
        var localTimeValue: String
        
        var body: some View {
            HStack{
                
                Image(systemName: localCourse.listIcon)
                    .foregroundColor(Color(localCourse.colour))
                    .padding(.leading, 5)
                
                Text(localCourse.name)
                    .bold()
                
                Spacer()
                
                Text(localTimeValue)
                Text(roomOrBlank(course: localCourse)).bold().padding(.trailing, 5)
                
            }
            .padding(.bottom, 1)
            .background(currentCourse.name==localCourse.name ? Color(localCourse.colour).colorInvert(): nil)
        }
        
    }
    
    return listing(localCourse: course, localTimeValue: time)
}






struct ListView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                getListView(course: CheckInCourse, time: "9:00")
                getListView(course: PDHPE3, time: "9:10")
                getListView(course: English6, time: "10:10")
                getListView(course: RecessPeriod, time: "11:10")
                getListView(course: TAS, time: "11:30")
                getListView(course: MathsCourse, time: "12:30")
                getListView(course: LunchPeriod, time: "1:30")
                getListView(course: PACourseBG, time: "2:10")
            }
        }
    }
}
#Preview {
    ListView()
}
    
