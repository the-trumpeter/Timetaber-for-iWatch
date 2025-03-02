//
//  ListView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI



struct tempView: View {
    var localcourse: Course
    var localtime: String
    
    var body: some View {
        HStack{
            
            Image(systemName: localcourse.listIcon)
                .foregroundColor(Color(localcourse.colour))
                .padding(.leading, 5)
            
            Text(localcourse.name)
                .bold()
            
            Spacer()
            
            Text(localtime)
            Text(roomOrBlank(course: localcourse)).bold().padding(.trailing, 5)
            
        }
        .padding(.bottom, 1)
        .background(currentCourse.name==localcourse.name ? Color(localcourse.colour).colorInvert(): nil)
    }
}






struct ListView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                tempView(localcourse: MathsCourse, localtime: "10:00")
            }
        }
    }
}
#Preview {
    ListView()
}
    
