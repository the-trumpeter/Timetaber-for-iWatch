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
			session.delegate = self
			session.activate()
		} else {
			Logger.connectivity.warning("WCSession not supported")
		}
	}


	func session(
		_ session: WCSession,
		activationDidCompleteWith activationState: WCSessionActivationState,
		error: (any Error)?
	) {
		Logger.connectivity.notice("WCSession activated.\nState \(activationState.rawValue)\nError \(String(describing: error))")
		switch activationState {
			case .activated:
				isActivated = true
				Logger.connectivity.notice("WCSession activated")

				/* ?
				for message in pendingMessages {
					send(message: message)
				}
				pendingMessages.removeAll()
				 */
			case .inactive:		Logger.connectivity.warning("WCSession inactive")
			case .notActivated:	Logger.connectivity.fault("WCSession not activ(e/ated)")
			@unknown default:	Logger.connectivity.fault("WCSession unknown state \(String(describing: activationState))")
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
						Logger.connectivity.critical("Invalid value \(String(describing: val) ) given to key 'term-running'")
						return
					}
					guard assembly.running == nil ||
							assembly.running == run else { //Ensure not contradicting other values of same purpose
						Logger.connectivity.critical("Multiple contradicting 'term-running' declarations in recieved applicationContext")
						return
					}
					assembly.running = run



				case "term-startDate":

					guard let start = val as? Date else { //Ensure is correct value
						Logger.connectivity.critical("Invalid value \(String(describing: val) ) given to key 'term-startDate'")
						return
					}
					guard assembly.startDate == nil ||
							assembly.startDate == start else { //Ensure not contradicting other values of same purpose
						Logger.connectivity.critical("Multiple contradicting 'term-startDate' declarations in recieved applicationContext")
						return
					}
					assembly.startDate = start



				case "term-ghostWeek":

					guard let ghost = val as? Bool else { //Ensure is correct value
						Logger.connectivity.critical("Invalid value \(String(describing: val) ) given to key 'term-ghostWeek'")
						return
					}
					guard assembly.ghostWeek == nil ||
							assembly.ghostWeek == ghost else { //Ensure not contradicting other values of same purpose
						Logger.connectivity.critical("Multiple contradicting 'term-ghostWeek' declarations in recieved applicationContext")
						return
					}
					assembly.ghostWeek = ghost



				default: invalid[key] = val

				}//switch

			}//for k,v

			guard let running = assembly.running else {
				Logger.connectivity.fault("Recieved application context, but missing 'term-running' value. All \(context.count) context will be discarded")
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
		Logger.connectivity.notice("Recieved user info. Sending to DispatchQueue.main for asynchronous processing")

		DispatchQueue.main.async {

			var changes: [Change] = []
			var invalid: [String: Any] = [:]

			for (key, val) in info {
				if let chg = val as? Change {
					changes.append(chg)
				} else {
					invalid[key] = val
				}
			}


			if !(changes.isEmpty) {
				//Logger.connectivity.notice("Recieved \(changes.count) Changes from iOS via WatchConnectivity; applying...")
				Storage.shared.applyChanges(changes)
			}
			if !(invalid.isEmpty) {
				Logger.connectivity.critical("\(invalid.count)/\(info.count) unexpected userInfo recieved:\n\(invalid)")
			}

			Logger.connectivity.notice("Parsed \(changes.count) messages out of \(info.count) total recieved.")
		}
	}



	/*
	//MARK: - My mess

	#if os(iOS)
	enum ConnectivityError: Error {
		case couldntDistribute([Change])
		case couldntDistributeTerm(running: Bool, startDate: Date, ghostWeek: Bool)
	}

	///Send a set of `Change`s to a connected Apple Watch.
	///
	///Do not apply changes via `applyChanges` unless `distributeChanges` has first successfully sent them to the Apple Watch.
	///
	///If no Apple Watch is connected to the iPhone, `distributeChanges` will return success.
	///
	///In the case that the changes cannot be sent to the watch and `ConnectivityError.couldntDistribute` is thrown, give the user a choice to send those changes to a sort of waiting-list timetable (yet to be implemented)
	func distributeChanges(_ changes: [Change]) throws {
		///send changes to watch here
		///if we can't get it to the watch, maybe offer to save it to another timetable instead of desyncing the two


	}

	func distributeToggleTerm(_ running: Bool, startDate date: Date, ghostWeek ghost: Bool) throws {

	}

	#endif


	#if os(watchOS)
	func pingPhone() {

	}
	#endif
	*/
}

