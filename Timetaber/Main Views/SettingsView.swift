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
	let start = Date.now

	try Storage.shared.WCManager.updateTermContext(
		true, startDate: start, ghostWeek: ghostWeek
	)

	// ! Need to store that a term is running!!
	Storage.shared.ghostWeekGB = ghostWeek
	Storage.shared.startDateGB = start
	Storage.shared.termRunningGB = true
	reload()
	log()

}

fileprivate func endTermProcess() throws {
	//processes to end a term, local 'termrunning' should be changed externally
	try Storage.shared.WCManager.updateTermContext(false)
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
						Logger.general.log("Started term")
						reload()
						
					} catch {
						//call an error if function returns error
						Logger.general.fault("startTermProcess threw")
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
	@State private var alertingFail: Optional<Int> = nil


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




			Button {
				alerting = true
			} label: {
				if data.termRunningGB {
					Label("End Term", systemImage: "pause.circle")
				} else {
					Label("Start Term", systemImage: "play.circle")
				}

			}
			.disabled(data.timetables[data.ActiveTimetable].isNew)
			.font(.title3)
			.if(data.termRunningGB) { $0.buttonStyle(.bordered			) }
			.if(!data.termRunningGB){ $0.buttonStyle(.borderedProminent	) }

			.alert(data.termRunningGB ? "End the term?" : "Start a term?", isPresented: $alerting) {
				if !data.termRunningGB {
					Button("Start Week A") {
						withAnimation {
							do {
								try startTermProcess(ghostWeek: false)
							} catch {
								alerting = false
								alertingFail = #line
							}
						}
					}
					Button("Start Week B") {
						withAnimation {
							do {
								try startTermProcess(ghostWeek: true)
							} catch {
								alerting = false
								alertingFail = #line
							}
						}
					}
				} else {
					Button("End Term", role: .destructive) {
						withAnimation {
							do {
								try endTermProcess()
							} catch {
								alerting = false
								alertingFail = #line
							}
						}
					}
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text(data.termRunningGB ? "Make it holidays" : "Start a term of classes")
			}
			.alert(data.termRunningGB ? "Couldn't end term" : "Couldn't start term", isPresented: Binding(get:{alertingFail != nil},set:{_,_ in}) ) {
				Button("OK") {
					alertingFail = nil
				}
			} message: {
				Text("Error \(#line)")
			}

			.padding(.bottom, 20)

			//Spacer() //FIXME: List prioritising over Spacer

			//Import/Export options moved to TimetableCreatorView

			Link(destination: URL(string: "https://github.com/the-trumpeter/Timetaber-for-iWatch")!, label: {
				Label("GitHub Repository", systemImage: "arrowshape.turn.up.right")
			})

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

