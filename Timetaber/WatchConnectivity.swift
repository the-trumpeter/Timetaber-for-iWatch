//
//  WatchConnectivity.swift
//  Timetaber
//
//  Created by Gill Palmer on 2/3/2026.
//
import Foundation
import OSLog

import WatchConnectivity


class WatchConnectivityManager_iOS: NSObject, WCSessionDelegate, ObservableObject {

	private var session = WCSession.default
	@Published var lastRecievedData: [String: Any] = [:]

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
		Logger.connectivity.notice("WCSession activated. | State: \(String(reflecting: activationState), privacy: .public) | Error: \(String(describing: error), privacy: .public)")
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
			@unknown default:	Logger.connectivity.fault("WCSession unknown state \(String(describing: activationState), privacy: .public)")
		}
	}

	func sessionDidBecomeInactive(_ session: WCSession) {
		Logger.connectivity.notice("WCSession became inactive")
	}
	
	func sessionDidDeactivate(_ session: WCSession) {
		Logger.connectivity.notice("WCSession deactivated")
		session.activate()
	}


	func session(_ session: WCSession, didFinish: WCSessionUserInfoTransfer, error: (any Error)?) {
		Logger.connectivity.notice("Finished transferring \(didFinish.userInfo.count, privacy: .public) data entries with error \(String(reflecting: error), privacy: .public)")
	}



	//MARK: -
	//MARK: - SEND


	private let changeKeyFormat:(Int	) -> String = { "change-\($0)"	}
	private let termKeyFormat:	(String	) -> String = { "term-\($0)"	}



	//MARK: transferUserInfo
	/// Queue an array of changes to be sent to a connected Apple Watch, using `WCSession.transferUserInfo(_:)`
	/// - Parameter changes: an array of changes to be queued for distribution
	func queueChanges(_ changes: [Change]) {
		guard session.isWatchAppInstalled else {
			Logger.connectivity.notice("Watch counterpart app not installed, will not queue changes")
			return
		}
		let mappedChanges: [String: Change] = Dictionary(uniqueKeysWithValues:
										zip(
											changes.indices.map { changeKeyFormat($0) },	changes
										)
		)
		session.transferUserInfo(mappedChanges)
		Logger.connectivity.notice("Queued \(changes.count, privacy: .public) Changes for sending to watch via WCSession.transferUserInfo(_:)")
	}

	func transferFullTimetable(_ ttbl: Timetable) {

		guard session.isWatchAppInstalled else {
			Logger.connectivity.info("Watch counterpart app not installed, will not queue changes")
			return
		}
		session.transferUserInfo( ["importTimetable": ttbl] )
	}




	//MARK: updateApplicationContext
	func updateTermContext(_ termRunning: Bool, startDate: Date? = nil, ghostWeek: Bool? = nil) throws {
		guard session.isWatchAppInstalled else {
			Logger.connectivity.info("Watch counterpart app not installed, will not update context")
			return
		}
		if termRunning {
			guard let startDate, let ghostWeek else {
				Logger.connectivity.critical("Cannot start term without a start date!! What idiot made them optionals?")
				return
			}
			// Term started
			try session.updateApplicationContext( [
					termKeyFormat("running"): termRunning,
					termKeyFormat("startDate"): startDate,
					termKeyFormat("ghostWeek"): ghostWeek
				]
			)
		} else {
			// Term stopped
			try session.updateApplicationContext([termKeyFormat("running"): termRunning])
		}
	}
}
