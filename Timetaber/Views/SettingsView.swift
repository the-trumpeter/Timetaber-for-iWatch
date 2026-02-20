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
import OSLog

//MARK: Processes
fileprivate func startTermProcess(ghostWeek: Bool) throws {
	// process to start a term
	
	// ! Need to store that a term is running!!
	Storage.shared.ghostWeekGB = ghostWeek
	Storage.shared.startDateGB = Date.now
	Storage.shared.termRunningGB = true
	reload()
	log()

}

fileprivate func endTermProcess() throws {
	//processes to end a term, local 'termrunning' should be changed externally
	
	Storage.shared.termRunningGB = false
	reload()
	log()

}


// MARK: Sheet
fileprivate struct NewTermSheet: View {
	@State var isGhostWeek = false
	@Environment(\.dismiss) var dismiss
	//@Binding var termRunning: Bool
	
	@ObservedObject var data = Storage.shared
	
	var body: some View {
		ScrollView{
			VStack{
				
				Button("Start") {
					do {
						try startTermProcess(ghostWeek: isGhostWeek)
						Logger.term.log("Started term")
						reload()
						
					} catch {
						//call an error if function returns error
						Logger.term.fault("startTermProcess threw unexpected error")
					}
					
					dismiss()
					
				}
				
					.padding(.bottom, 30.0)
				
				Toggle("Ghost Week", isOn: $isGhostWeek)
				Label("If ghost week is on, the term will start at Week B instead.", systemImage: "info.circle")
					.foregroundStyle(.gray)
					.font(.system(size: 13))
				
			}.background(Colour.clear)
		}
	}
	
}



//MARK: View
///From here, start/stop the term, edit the timetable, etc.
struct SettingsView: View {
	@ObservedObject var data = Storage.shared
	
	@State var showingSheet = false
//	@State var isTermRunning: Bool = false
	@State private var alerting = false


	var body: some View {

		NavigationStack {




		 /*
			Link(destination: URL(string: "https://github.com/the-trumpeter/Timetaber-for-iWatch/issues/new?template=bug_report.md")!, label: {
				Label("Bug Report", systemImage: "exclamationmark.bubble")
			}).padding()
		  */

		 /*
            Link(destination: URL(string: "tel://0481177077")!, label: {
                Label("Phone Gill", systemImage: "phone")
            })
		 */

			TimetablesListEditor()

			Spacer()

			Link(destination: URL(string: "https://github.com/the-trumpeter/Timetaber-for-iWatch")!, label: {
				Label("GitHub Repository", systemImage: "arrowshape.turn.up.right")
			}).padding()

			/*
			NavigationLink {

			} label: { Text("Edit Timetable").padding(5) }
			.foregroundStyle(.primary)
			.font(.title2)
			.buttonStyle(.bordered)
			 */
			//Spacer()

			VStack {
				Label("Certified 100% Digitech Didn't Help", systemImage: "checkmark.seal")
					.font(.system(size: 15))
					.padding(1)
				
				Text("Timetaber • Gill Palmer, 2024-25")
				
					.foregroundStyle(.secondary)
					.font(.system(size: 15))
			}.padding()
			
		}
		.multilineTextAlignment(.center)
		//.onAppear { Logger.<#logger#>.<#action#>("SettingsView Updated") }
		//.padding()
	}
}





#Preview {
	SettingsView()
		.environmentObject(Storage.shared)
}

