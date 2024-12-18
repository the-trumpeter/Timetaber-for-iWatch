//
//  ListViews.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 3/11/2024.
//

import SwiftUI

struct CheckInList: View {
    var body: some View {
        HStack{
            Image(systemName: "face.smiling.inverse")
                .foregroundColor(Color("Graphite"))
                .font(.system(size: 15))
            Text("Check In")
                .font(.system(size: 15).bold())
            Spacer()
            Text("9:00")
            Text("HG4").bold()
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct MathList: View {
    var body: some View {
        HStack{
            Image(systemName: "number.circle.fill")
                .foregroundColor(Color("Rose"))
                .font(.system(size: 15))
            Text("Math")
                .font(.system(size: 15).bold())
            Spacer()
            Text("9:10")
            Text("FT3").bold()
                
                
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
                .font(.system(size: 15))
            Text("English")
                .font(.system(size: 15).bold())
            Spacer()
            Text("10:10")
            Text("BT4").bold()
                
                
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}

struct RecessList: View {
    var body: some View {
        HStack{
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 15))
            Text("Recess")
                .font(.system(size: 15).bold())
            Spacer()
            Text("11:10")
            
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct LunchList: View {
    var body: some View {
        HStack{
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 15))
            Text("Lunch")
                .font(.system(size: 15).bold())
            Spacer()
            Text("1:30")
            
            
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
                .font(.system(size: 15))
            Text("HSIE")
                .font(.system(size: 15).bold())
            Spacer()
            Text("11:30")
            Text("BG4").bold()
            
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
                .font(.system(size: 15))
            Text("TAS")
                .font(.system(size: 15).bold())
            Spacer()
            Text("12:30")
            Text("GG3").bold()
            
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
                .font(.system(size: 15))
            Text("PDHPE")
                .font(.system(size: 15).bold())
            Spacer()
            Text("2:10")
            Text("HALL").bold()
            
        }
        .padding(.bottom,1)
        .background(Color.black)
    }
}
struct LanguageList: View {
    var body: some View {
        HStack{
            Image(systemName: "bubble.left.circle.fill")
                .foregroundColor(Color("Apricot"))
                .font(.system(size: 15))
            Text("French")
                .font(.system(size: 15).bold())
            Spacer()
            Text("12:30")
            Text("FT8").bold()
            
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
                .font(.system(size: 15))
            Text("Theatre Crew")
                .font(.system(size: 15).bold())
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
                .font(.system(size: 15))
            Text("Marching B.")
                .font(.system(size: 15).bold())
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
                .font(.system(size: 15))
            Text("Concert Band")
                .font(.system(size: 15).bold())
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
                .font(.system(size: 15))
            Text("Sciecne")
                .font(.system(size: 15).bold())
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
                CheckInList()
                MathList()
                EnglishList()
                RecessList()
                HSIEList()
                LanguageList()
                LunchList()
                PDHPEList()
                TASList()
                TheatreList()
                MSBList()
                ConcertList()
            }
        }
    }
}
#Preview {
    ListView()
}
    
