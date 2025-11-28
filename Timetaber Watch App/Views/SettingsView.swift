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
    //TODO: These values should sync across iOS and watchOS
    Storage.shared.ghostWeekGB = ghostWeek
    Storage.shared.startDateGB = Date.now
    Storage.shared.termRunningGB = true
    reload()
    log()
    
    return true //return true if all processes are as expected, otherwise call false so we can deal with a fail in order not to disrupt the application flow.
    
}

func endTermProcess() {
    //processes to end a term, local 'termrunning' should be changed externally
    
    Storage.shared.termRunningGB = false
    reload()
    log()
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
                
            }.background(Colour("NoCol"))
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
            
            Button { withAnimation {
                if !data.termRunningGB {
                    showingSheet.toggle()
                } else {
                    showConf = true
                }
                
                }} label: {
                    Label(data.termRunningGB ? "End Term": "Start Term", systemImage: data.termRunningGB ? "stop.circle": "play.circle")}
                        .contentTransition(.symbolEffect(.replace))
                        .background(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(.white, lineWidth: data.termRunningGB ? 1: 0))
            
                        .sheet(isPresented: $showingSheet) {
                            NewTermSheet().environmentObject(LocalData.shared)
                        }
            
                        .padding(10)
            
                        .confirmationDialog("Are you sure you want to end this term?", isPresented: $showConf) {
                            
                            Button("End Term") {
                                //⭐️on term end
                                endTermProcess()
								NSLog("Ended Term")
                            }
                            
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("This will reset weeks and move into holiday mode.")
                        }
            
            Spacer()
        
            
            Text("Timetaber for iWatch\nGill Palmer, 2024")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.system(size: 13))
                
            
        }.onAppear { print("SettingsView Updated") }
    }
}





#Preview {
    SettingsView()
        .environmentObject(LocalData.shared)
}
