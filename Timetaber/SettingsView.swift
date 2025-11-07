//
//  SettingsView.swift
//  Timetaber
//
//  Created by Gill Palmer on 14/8/2025.
//

//
//  SettingsView.swift
//  Timetaber Watch App
//
//  Created by Gill Palmer on 6/11/2024.
//
//  NB: While this is a view, it also generally handles all data and processes related to starting and stopping a term process.

import SwiftUI

//MARK: Processes
func startTermProcess(ghostWeek: Bool) -> Bool {
    // process to start a term
    
    // ! Need to store that a term is running!!
    Storage.shared.ghostWeekGB = ghostWeek
    Storage.shared.startDateGB = Date.now
    Storage.shared.termRunningGB = true
    reload()
    log()
    
    return true //return true if all processes are as expected, otherwise call false so we can deal with a fail in order not to disrupt the application flow.
    
}

func endTermProcess() -> Bool {
    //processes to end a term, local 'termrunning' should be changed externally
    
    Storage.shared.termRunningGB = false
    reload()
    log()
    
    return true //return true if all processes are as expected, otherwise call false so we can deal with a fail in order not to disrupt the application flow.
}


// MARK: Sheet
struct NewTermSheet: View {
    @State var isGhostWeek = false
    @Environment(\.dismiss) var dismiss
    //@Binding var termRunning: Bool
    
    @ObservedObject var data = Storage.shared
    
    var body: some View {
        ScrollView{
            VStack{
                
                Button("Start") {
                    if startTermProcess(ghostWeek: isGhostWeek) {
                        print("Started term")
                        reload()
                        
                    } else {
                        //call an error if function returns error
                        print("SettingsView, line 55: Error!")
                    }
                    
                    dismiss()
                    
                }
                
                    .padding(.bottom, 30.0)
                
                Toggle("Ghost Week", isOn: $isGhostWeek)
                Label("If ghost week is on, the term will start at Week B instead.", systemImage: "info.circle")
                    .foregroundStyle(.gray)
                    .font(.system(size: 13))
                
            }.background(Color("NoCol"))
        }
    }
    
}



//MARK: View
struct SettingsView: View {
    
    @ObservedObject var data = Storage.shared
    
    @State var showingSheet = false
//    @State var isTermRunning: Bool = false
    @State private var showConf = false
    
    var body: some View {
        
        VStack {

            Spacer()
        
            
            Text("Timetaber\nGill Palmer, 2024")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.system(size: 20))
                
            
        }.onAppear { print("SettingsView Updated") }
    }
}





#Preview {
    SettingsView()
        .environmentObject(GlobalData.shared)
}
