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
//	@State var isTermRunning: Bool = false
	@State private var alerting = false


	var body: some View {
		
		VStack {

			Link(destination: URL(string: "https://github.com/the-trumpeter/Timetaber-for-iWatch")!, label: {
				Label("GitHub Repository", systemImage: "arrowshape.turn.up.right")
			}).padding(.bottom)

			Link(destination: URL(string: "https://github.com/the-trumpeter/Timetaber-for-iWatch/issues/new?template=bug_report.md")!, label: {
				Label("Bug Report", systemImage: "exclamationmark.bubble")
			}).padding(.bottom)

			Button("Phone Gill", systemImage: "phone") {
				alerting = true
			}
			.alert("0481 177 077", isPresented: $alerting) {
				Button("Cancel") { alerting = false }
				Button("Call") { UIApplication.shared.open(URL(string: "tel://0481177077")!) }
			}

			Spacer()

			Label("Certified 100% Digitech Didn't Help", systemImage: "checkmark.seal")
				.font(.system(size: 15))
				.padding(5)

			Text("Timetaber • Gill Palmer, 2024")

				.foregroundStyle(.gray)
				.font(.system(size: 18))
				
			
		}
		.multilineTextAlignment(.center)
		.onAppear { print("SettingsView Updated") }
		.padding()
	}
}





#Preview {
	SettingsView()
		.environmentObject(Storage.shared)
}

