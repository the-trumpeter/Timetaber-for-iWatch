//
//  ListView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI


//MARK: - Template
struct listTemplate: View {
    
    @EnvironmentObject var data: LocalData
    @Environment(\.colorScheme) var colorScheme
    
    var listedCourse: Course
    var courseTime: String
    
    var body: some View {

        let image = customSymbols[listedCourse.listIcon] ?? Image(systemName: listedCourse.listIcon)
        HStack{
            
            image
                .resizable()
                .foregroundStyle(Colour(listedCourse.colour))
                .frame(maxWidth: 25, maxHeight: 25)
                .aspectRatio(contentMode: .fit)
                .padding(.leading, 2)
                .padding(.trailing, 3)
            
            VStack {
                HStack {
                    Text(listedCourse.listName)
                        .bold()
                    Spacer()
                    
                }
                HStack {
                    Text(courseTime)
                        .foregroundStyle(.secondary)
                    if let room = listedCourse.room {
                        Text(room).bold()
                            .foregroundStyle(.secondary)
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
    @EnvironmentObject var data: LocalData
    @Environment(\.colorScheme) var colorScheme
    let day: Dictionary<Int, Course>
    
    var body: some View {
        let dayKeys = Array(day.keys).sorted(by: <).dropLast()
        List {
            ForEach(dayKeys, id: \.self) { key in
                
                let listedCourse = day[key] ?? failCourse(feedback: "LV.lD@56")
				let isCurrent = {
					guard data.currentCourse.identifier != nil && listedCourse.identifier != nil else {
						return (data.currentCourse.name == listedCourse.name)
					}
					return (data.currentCourse.identifier == listedCourse.identifier)
				}()

                listTemplate(listedCourse: listedCourse, courseTime: time24toNormal(key))
                    .environmentObject(LocalData.shared)
                    .listRowBackground(isCurrent ? ( Colour(listedCourse.colour)
                        .opacity(0.2)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    ): nil
                    )
            }
        }
    }
}



// MARK: - Master
struct ListView: View {
    @ObservedObject var data = Storage.shared
    var body: some View {
        
        
        
        //MARK: IF
        if data.termRunningGB && weekdayNumber(.now) > 1 && weekdayNumber(.now) < 7 {
            
            let day = getTimetableDay(
                isWeekA:
                    getIfWeekIsA_FromDateAndGhost(
                        originDate: .now,
                        ghostWeek: data.ghostWeekGB
                    ),
             
                weekDay: weekdayNumber(.now)
            )

            if Array(day.keys).sorted(by: <).last! >= time24() { //if not after last class of day
                listedDay(day: day)
                    .environmentObject(LocalData.shared)
            } else {
                Text("No school right now.\nThe day's classes will be displayed here.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .font(.system(size: 13))
            }
            
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
        .environmentObject(LocalData.shared)
}
