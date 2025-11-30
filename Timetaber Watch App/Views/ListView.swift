//
//  ListView.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI


//MARK: - Template
struct listTemplate: View {
    
    let listedCourse: Course2
    let timeslotIdentifier: Timeslot
    
    private let day: [Int: [Int]]
    private let courses: [Int: Course2]
    private let room: String
    private let properties: [Int]



    init(
        timetableDay: [Int: [Int] ],
        timeslot: Timeslot,
        courses: [Int : Course2],
    )
    {
        self.day = timetableDay
        self.timeslotIdentifier = timeslot
        self.courses = courses
        
        let key: Int = timeslot.time
        self.properties = day[key]!
        self.listedCourse = courses[ day[key]![0] ]!
        self.room = listedCourse.rooms[properties[1]]
    }
    
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
                    Text(listedCourse.listName ?? listedCourse.name)
                        .bold()
                    Spacer()
                    
                }
                HStack {
                    
                    Text( String(timeslotIdentifier.time) )
                        .foregroundStyle(.secondary)
                    
                    Text(room).bold()
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
            
        }
        .padding(.bottom, 1)
    }
}

//MARK: - Day
struct listedDay: View {
    
    var day: [Int: [Int]]
    var courses: [Int: Course2]
    var week: WeekAB
    var weekday: Int
    @EnvironmentObject var data: LocalData
    
    init(timetable: Timetable,
         week _week: WeekAB? = nil,
         day _day: Int? = nil
    ) {
        let wkday = _day ?? weekdayNumber(.now)
        let wk = _week ?? { if getIfWeekIsA_FromDateAndGhost(originDate: Storage.shared.startDateGB, ghostWeek: Storage.shared.ghostWeekGB) { WeekAB.a } else { WeekAB.b } }()
        
        self.weekday = wkday
        self.week = wk

        self.day = getTimetableDay2(isWeekA: { if(wk == .a){true}else{false} }(), weekDay: wkday, timetable: timetable)

        self.courses = timetable.courses
    }
    
    var body: some View {
        let dayKeys = Array(day.keys).sorted(by: <).dropLast()
        List {
            ForEach(dayKeys, id: \.self) { key in
                
                
                let entry = listTemplate(timetableDay: day, timeslot: Timeslot(week: week, day: weekday, time: key), courses: courses)
                let bG: Colour? = (data.currentTime==entry.timeslotIdentifier) ? Colour(entry.listedCourse.colour): nil
                entry
                    .listRowBackground(
                        bG
                            .opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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
            
            let wk = getIfWeekIsA_FromDateAndGhost(originDate: data.startDateGB, ghostWeek: data.ghostWeekGB)
            let day = getTimetableDay2(isWeekA: wk, weekDay: weekdayNumber(.now), timetable: chaos)
            
            if Array(day.keys).sorted(by: <).last! >= time24() { //if not after last class of day
                listedDay(timetable: chaos,
                          week: {if wk {.a}else{.b}}(),
                          day: weekdayNumber(.now)
                )
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
