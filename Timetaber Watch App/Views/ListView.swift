//
//  ListView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI



func getListView(course: Course, time: String) -> some View {
    
    struct ListView: View {
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
    
    return ListView(localCourse: course, localTimeValue: time)
}






struct ListView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                getListView(course: MathsCourse, time: "")
                getListView(course: PDHPE3, time: "")
                getListView(course: English6, time: "")
            }
        }
    }
}
#Preview {
    ListView()
}
    
