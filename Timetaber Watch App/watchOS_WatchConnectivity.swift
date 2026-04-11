//
//  WatchConnectivity.swift
//  Timetaber
//
//  Created by Gill Palmer on 2/3/2026.
//
import Foundation
import OSLog

import WatchConnectivity


class WatchConnectivityManager_watchOS: NSObject, WCSessionDelegate, ObservableObject {

	//@Published var lastRecievedData: [String: Any] = [:]
	var session = WCSession.default


	private var isActivated = false
	//private var pendingMessages: [ [String: Any] ] = []


	override init() {
		super.init()
		if WCSession.isSupported() {
			self.session.delegate = self
			self.session.activate()
		} else {
			Logger.connectivity.warning("WCSession not supported")
		}
	}


	func session(
		_ session: WCSession,
		activationDidCompleteWith activationState: WCSessionActivationState,
		error: (any Error)?
	) {
		Logger.connectivity.notice("WCSession activated.\nState \(activationState.rawValue, privacy: .public)\nError \(String(describing: error), privacy: .public)")
		switch activationState {
			case .activated:
				isActivated = true
				Logger.connectivity.notice("WCSession activated")
			case .inactive:		Logger.connectivity.warning("WCSession inactive")
			case .notActivated:	Logger.connectivity.fault("WCSession not activ(e/ated)")
			@unknown default:	Logger.connectivity.fault("WCSession unknown state \(String(describing: activationState), privacy: .public)")
		}
	}
	
	//MARK: Recieve Start/Stop Term [applicationContext]
	func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {

		var invalid: [String: Any] = [:]
		var assembly: (running: Bool?, startDate: Date?, ghostWeek: Bool?) = (nil, nil, nil)

		DispatchQueue.main.async {

			for (key, val) in context {
				switch key {

				case "term-running":

					guard let run = val as? Bool else { //Ensure is correct value
						Logger.connectivity.critical("Invalid value \(String(describing: val), privacy: .public ) given to key 'term-running'")
						Storage.shared.globalErrorMessage = "Error \(#line): WC 'term-running' given invalid type"
						return
					}
					guard assembly.running == nil ||
							assembly.running == run else { //Ensure not contradicting other values of same purpose
						Logger.connectivity.critical("Multiple contradicting 'term-running' declarations in recieved applicationContext")
						Storage.shared.globalErrorMessage = "Error \(#line): WC multiple contradicting 'term-running' values"
						return
					}
					assembly.running = run



				case "term-startDate":

					guard let start = val as? Date else { //Ensure is correct value
						Logger.connectivity.critical("Invalid value \(String(describing: val), privacy: .public ) given to key 'term-startDate'")
						Storage.shared.globalErrorMessage = "Error \(#line): WC 'term-startDate' given invalid type"
						return
					}
					guard assembly.startDate == nil ||
							assembly.startDate == start else { //Ensure not contradicting other values of same purpose
						Logger.connectivity.critical("Multiple contradicting 'term-startDate' declarations in recieved applicationContext")
						Storage.shared.globalErrorMessage = "Error \(#line): WC multiple contradicting 'term-startDate' values"
						return
					}
					assembly.startDate = start



				case "term-ghostWeek":

					guard let ghost = val as? Bool else { //Ensure is correct value
						Logger.connectivity.critical("Invalid value \(String(describing: val), privacy: .public ) given to key 'term-ghostWeek'")
						Storage.shared.globalErrorMessage = "Error \(#line): WC 'term-ghostWeek' given invalid type"
						return
					}
					guard assembly.ghostWeek == nil ||
							assembly.ghostWeek == ghost else { //Ensure not contradicting other values of same purpose
						Logger.connectivity.critical("Multiple contradicting 'term-ghostWeek' declarations in recieved applicationContext")
						Storage.shared.globalErrorMessage = "Error \(#line): WC multiple contradicting 'term-startDate' values"
						return
					}
					assembly.ghostWeek = ghost



				default: invalid[key] = val

				}//switch

			}//for k,v

			guard let running = assembly.running else {
				Logger.connectivity.critical("Recieved application context, but missing 'term-running' value. All \(context.count, privacy: .public) context will be discarded")
				Storage.shared.globalErrorMessage = "Error \(#line): WC applicationContext missing 'term-running' (ignored)"
				return
			}

			if running,
			   let term = (assembly.startDate, assembly.ghostWeek) as? (startDate: Date, ghostWeek: Bool) {
				Logger.connectivity.notice("Recieved term information from iOS, starting term...")
				startTermProcess(ghostWeek: term.ghostWeek, startDate: term.startDate)
			} else {
				Logger.connectivity.notice("Recieved term information from iOS, ending term...")
				guard Storage.shared.termRunningGB else {
					Logger.connectivity.notice("No term running, can't stop any.")
					return
				}
				endTermProcess()
			}

		}//dispatchqueue
	}



	//MARK: Recieve Changes [userInfo]
	func session(_ session: WCSession, didReceiveUserInfo info: [String: Any]) {

		//LOG
		Logger.connectivity.notice("Recieved user info. Sending to DispatchQueue.main for asynchronous processing")

		DispatchQueue.main.async {

			//CHECK FOR FULL TIMETABLE
			if info["importTimetable"] != nil {

				guard let json = info["importTimetable"] as? Data else {
					Logger.connectivity.critical("Value for 'importTimetable' does not conform to Data")
					Storage.shared.globalErrorMessage = "Error \(#line): WC 'importTimetable' does not conform to Data"
					return
				}

				guard let imported = Timetable(json) else {
					Logger.connectivity.critical("'Data' passed as 'importTimetable' cannot be decoded to 'Timetable'")
					Storage.shared.globalErrorMessage = "Error \(#line): WC 'importTimetable' JSON cannot be decoded to Timetable"
					return
				}

				let actvTbl = Storage.shared.ActiveTimetable

				Storage.shared.timetables[actvTbl] = imported
				Logger.connectivity.notice("Recieved & applied new timetable from iOS. Discarded \(info.count-1, privacy: .public) other items")
				return
			}


			//DECODE

			var changes: [Change] = []
//			var invalid: [String: Any] = [:]

			if let raw = info["changes"] {


				guard let data = raw as? Data else {
					Logger.connectivity.critical("Value for 'changes' does not conform to Data")
					Storage.shared.globalErrorMessage = "Error \(#line): WC 'changes' does not conform to Data"
					return
				}
				guard let decoded = try? JSONDecoder().decode([Change].self, from: data) else {
					Logger.connectivity.critical("'Data' passed as 'changes' cannot be decoded to '[Change].self'")
					Storage.shared.globalErrorMessage = "Error \(#line): WC 'changes' JSON cannot be decoded to '[Change]'"
					return
				}
				changes = decoded



				if !(changes.isEmpty) {
					//Logger.connectivity.notice("Recieved \(changes.count, privacy: .public) Changes from iOS via WatchConnectivity; applying...")
					Storage.shared.applyChanges(changes)
				}

				//			if !(invalid.isEmpty) {
				//				Logger.connectivity.critical("\(invalid.count, privacy: .public)/\(info.count, privacy: .public) unexpected userInfo recieved:\n\(invalid, privacy: .public)")
				//			}
			}

			Logger.connectivity.notice("Parsed \(changes.count, privacy: .public) Changes from 1 entry in \(info.count) userInfo key/value pairs.")

		}//DispatchQueue

	}// session(_:didRecieveUserInfo:)





}//WCManager
