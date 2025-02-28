//
//  ListViews.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI

struct CheckInList: View {
    var highlighted: Bool
    var body: some View {
        HStack{
            Image(systemName: "face.smiling.inverse")
                .foregroundColor(Color("Graphite"))
                .padding(.leading, 5)
            Text("Check In")
                .bold()
            Spacer()
            Text("9:00")
            Text("HG4").bold().padding(.trailing, 5)
        }
        .padding(.bottom, 1)
        .background(Color("Graphite").colorInvert())
    }
}
struct MathList: View {
    var body: some View {
        HStack{
            Image(systemName: "number.circle.fill")
                .foregroundColor(Color("Rose"))
                .padding(.leading, 5)
            Text("Math")
                .bold()
            Spacer()
            Text("9:10")
            Text("FT3").bold().padding(.trailing, 5)
                
                
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}

struct EnglishList: View {
    var body: some View {
        HStack{
            Image(systemName: "book.closed.circle.fill")
                .foregroundColor(Color("Lemon"))
                .padding(.leading, 5)
            Text("English")
                .bold()
            Spacer()
            Text("10:10")
            Text("BT4").bold().padding(.trailing, 5)
                
                
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}

struct RecessList: View {
    var body: some View {
        HStack{
            Image(systemName: "fork.knife.circle")
                .padding(.leading, 5)
            Text("Recess")
                .bold()
            Spacer()
            Text("11:10").padding(.trailing,5)
            
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct LunchList: View {
    var body: some View {
        HStack{
            Image(systemName: "fork.knife.circle")
                .padding(.leading, 5)
            Text("Lunch")
                .bold()
            Spacer()
            Text("1:30").padding(.trailing,5)
            
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct HSIEList: View {
    var body: some View {
        HStack{
            Image(systemName: "clock.circle.fill")
                .foregroundColor(Color("Rees"))
                .padding(.leading, 5)
            Text("HSIE")
                .bold()
            Spacer()
            Text("11:30")
            Text("BG4").bold().padding(.trailing, 5)
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct TASList: View {
    var body: some View {
        HStack{
            Image(systemName: "hammer.circle.fill")
                .foregroundColor(Color("Blueberry"))
                .padding(.leading, 5)
            Text("TAS")
                .bold()
            Spacer()
            Text("12:30")
            Text("GG3").bold().padding(.trailing, 5)
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct PDHPEList: View {
    var body: some View {
        HStack{
            Image(systemName: "figure.run.circle.fill")
                .foregroundColor(Color("Lime"))
                .padding(.leading, 5)
            Text("PDHPE")
                .bold()
            Spacer()
            Text("2:10")
            Text("HALL").bold().padding(.trailing, 5)
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct TheatreList: View {
    var body: some View {
        HStack{
            Image(systemName: "headset.circle.fill")
                .foregroundColor(Color("Peach"))
                .padding(.leading, 5)
            Text("Theatre Crew")
                .bold()
            Spacer()
            Text("1:30")
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct MSBList: View {
    var body: some View {
        HStack{
            Image(systemName: "flag.circle.fill")
                .foregroundColor(Color("Cherry"))
                .padding(.leading, 5)
            Text("Marching B.")
                .bold()
            Spacer()
            Text("3:30")
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct ConcertList: View {
    var body: some View {
        HStack{
            Image(systemName: "pencil.circle.fill")
                .foregroundColor(Color("Cherry"))
                .padding(.leading, 5)
            Text("Concert Band")
                .bold()
            Spacer()
            Text("3:30")
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct ScienceList: View {
    var body: some View {
        HStack{
            Image(systemName: "flame.circle.fill")
                .foregroundColor(Color("Ice"))
                .padding(.leading, 5)
            Text("Sciecne")
                .bold()
            Spacer()
            Text("3:30")
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct VisArtsList: View {
    var body: some View {
        HStack{
            Image("paintbrush.pointed.circle.fill")
                .foregroundColor(Color("Ice"))
                .padding(.leading, 5)
            Text("Art")
                .bold()
            Spacer()
            Text("3:30")
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}


struct ListView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                CheckInList(highlighted: false)
                MathList()
                EnglishList()
                RecessList()
                HSIEList()
                LunchList()
                PDHPEList()
                TASList()
                ScienceList()
                TheatreList()
                MSBList()
                ConcertList()
                VisArtsList()
            }
        }
    }
}
#Preview {
    ListView()
}
    
