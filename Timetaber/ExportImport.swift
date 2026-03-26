//
//  ExportImport.swift
//  Timetaber
//
//  Created by Gill Palmer on 26/2/2026.
//

import SwiftUI
import OSLog
import UniformTypeIdentifiers

struct JsonDocument: FileDocument {

	static var readableContentTypes: [UTType] { [.json] }
	var json: Data

	init(configuration: ReadConfiguration) throws {
		guard
			let data = configuration.file.regularFileContents
		else { throw NSError() }
		self.json = data
	}

	init(json: Data) {
		self.json = json
	}

	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		FileWrapper(regularFileWithContents: self.json)
	}
}




struct ExportView: View {
	@ObservedObject var store = Storage.shared

	@State private var exporting = false
	@State private var exportData = JsonDocument(json: Data())

	@State private var exportFailed = false

	@State private var importing = false
	@State private var importFailed: FileImportError? = nil
	@State private var importSuccess: Timetable? = nil

	private enum FileImportError {
		case decodeFailed
		case fileImportFailed
		case couldntRead
		case watchConnectivityFailed
	}


	enum ImportStatus { case replace, add, ignore }
	@State var importOptions: (courses: ImportStatus, timingVariants: ImportStatus, wkAndTimetable: ImportStatus) = (.replace, .replace, .replace)
	@State var import_ReplaceAll = false


	func numericPluralSuffix(_ number: Int) -> String {
		if number == 1 { return "" }; return "s"
	}

	var body: some View {
		Menu("Export/Import...") {


			//MARK: Export
			Button("Export Timetable...", systemImage: "square.and.arrow.up") {
				Logger.files.notice("Importing timetable...")
				do { exportData = JsonDocument(
						json:
							try store.timetables[store.ActiveTimetable].encode()
					)
					exporting = true
				} catch {
					Logger.files.critical("Could not export timetable! The timetable is as follows (sorry):\n\(String(reflecting: store.timetables[store.ActiveTimetable]), privacy: .public)")
					exportFailed = true
				}
			}.padding(.bottom, 2)

			.fileExporter(
				isPresented: $exporting,
				document: exportData,
				contentType: .json,
				defaultFilename: "Timetable",
				onCompletion: { result in
					Logger.files.notice("Exported timetable to \( String(reflecting: result), privacy: .public )")
				}
			)

			//MARK: Export Failed
			.alert("Couldn't export timetable", isPresented: $exportFailed) {
				Button("OK", role: .cancel) { exportFailed = false }
			} message: {
				Text("JSON encoding failed.\nDon't edit your timetable. Show a/the developer your in-app timetable, in person.\nYou can safely continue using this app.")
			}




			//MARK: Import
			Button("Import Timetable...", systemImage: "square.and.arrow.down") {
				Logger.files.notice("Importing timetable...")
				importing = true
			}
			.fileImporter(
				isPresented: $importing,
				allowedContentTypes: [.json],
				onCompletion: { result in

					guard
						let url = try? result.get(),
						url.startAccessingSecurityScopedResource()
					else { return }

					defer { url.stopAccessingSecurityScopedResource() }

					if let jsonData = try? Data(contentsOf: url) {
						if let decoded = Timetable(jsonData) {
							importSuccess = decoded
						} else {
							importFailed = .decodeFailed
						}
					}

				//	if let jsonString = try? String(contentsOf: url, encoding: .utf8) { }

				}
			)
				//MARK: Import Failed
			.alert("Importing failed", isPresented: Binding(get: {importFailed != nil},set:{_ in} ) ) {
				Button("OK", role: .cancel) { importFailed = nil }
			} message: {
				switch importFailed {
					case .decodeFailed: Text("Couldn't decode the file. Is it in a valid format?\nIf you think something is wrong, please upload the file in a TestFlight report.")
					case .fileImportFailed: Text("Failed to retrieve the file.\nTry moving it to a different location.")
					case .couldntRead: Text("Couldn't read the file.\nIf you think something is wrong, please upload the file in a TestFlight report.")
					default: Text("Something went wrong with this alert.\nError \(#line)")
				}
			}

			//MARK: Import Success
			.alert("Import timetable", isPresented: Binding(get:{importSuccess != nil},set:{_ in}) ) {

				Button("Import", role: .destructive) {
					guard let new = importSuccess else {
						Logger.files.critical("Timetable import closure executed with nil importSuccess result value.")
						return
					}
					do {
						try Storage.shared.sendFullTimetable(new)
					} catch {
						importSuccess = nil
						importFailed = .watchConnectivityFailed
					}

					Storage.shared.timetables[Storage.shared.ActiveTimetable] = new
					Logger.files.notice("Imported timetable! Hopefully it syncs to watch")
					importSuccess = nil
				}//.tint(.accentColor)
				Button("Cancel", role: .cancel) {
					importSuccess = nil
				}

			} message: {
				if let tbl = importSuccess {

					let counts: (courses: Int, timesVariants: Int, weeks: Int) = (
						courses: tbl.courses.count,
						timesVariants: tbl.times.variants.count+1,
						weeks: tbl.timetable.count
					)
					let courses = String(counts.0)+" course"+numericPluralSuffix(counts.0)
					let timingVariants = String(counts.1)+" timing variant"+numericPluralSuffix(counts.1)
					let weeks = String(counts.2)+" timetabled week"+numericPluralSuffix(counts.2)
					Text("\(courses)\n\(timingVariants)\n\(weeks)"
					)

				} else {
					Text("Error \(#line)")
						.onAppear {
							Logger.files.warning("Import alert rendered without valid timetable to import")
						}
				}
			}



		}
	}
}

#Preview {
	ExportView()
}
