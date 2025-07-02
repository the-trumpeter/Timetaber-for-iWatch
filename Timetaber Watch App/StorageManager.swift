//
//  StorageManager.swift
//  Timetaber Watch App
//
//  Created by Gill Palmer on 4/1/2025.
//

import Foundation
import SwiftUI
import Combine

let userDefaults = UserDefaults.standard


let runningKey = "timetaber.userdefalts.termRunning"

let ghostWeekKey = "timetaber.userdefalts.ghostWeek"

let startDateKey = "timetaber.userdefalts.startDate"


/// Representing a class/course in a timetable.
struct Course: Codable {
    let name: String
    let icon: String
    let room: String?
    let colour: String
    let listName: String?
    let listIcon: String?
    let joke: String?

    // Computed fallback values
    var displayedRoom: String {
        room ?? "None"
    }

    var displayedJoke: String {
        joke ?? "None"
    }

    var displayedListName: String {
        listName ?? name
    }

    var displayedListIcon: String {
        listIcon ?? (icon + ".circle.fill")
    }
}

struct DecodedTimetable: Codable {
    var courses: [String: Course]
    var normtimes: [String]

    var monA: [String: String]
    var tueA: [String: String]
    var wedA: [String: String]
    var thuA: [String: String]
    var friA: [String: String]

    var monB: [String: String]
    var tueB: [String: String]
    var wedB: [String: String]
    var thuB: [String: String]
    var friB: [String: String]
}

class TimetableManager: ObservableObject {
    @Published var timetable: DecodedTimetable?
    @Published var errorMessage: String?

    func fetch() {
        guard let url = URL(string: "https://raw.githubusercontent.com/the-trumpeter/Timetaber-for-iWatch/web-service/webtests.json") else {
            self.errorMessage = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Fetch error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(DecodedTimetable.self, from: data)
                    self.timetable = decoded
                } catch {
                    self.errorMessage = "Decoding error: \(error)"
                }
            }
        }.resume()
    }
    
    func setup() {
        if self.timetable == nil {
            fetch()
        }
    }
}


class storage: ObservableObject {
    static let shared = storage()
    
    @AppStorage(runningKey) var termRunningGB = false
    @AppStorage(ghostWeekKey) var ghostWeekGB = false
    @AppStorage(startDateKey) var startDateGB = Date.now
    // 'GB' for 'global'
}



func reload() -> Void {
    
    GlobalData.shared.currentCourse = getCurrentClass(date: .now)[0]
    GlobalData.shared.nextCourse = getCurrentClass(date: .now)[1]
    
    
    print("Setup done\n")
    log()
    
}

