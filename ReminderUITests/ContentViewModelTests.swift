//
//  ContentViewModelTests.swift
//  ReminderUITests
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import XCTest
import SwiftData
@testable import Reminder

@MainActor
class ViewModelTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() {
        super.setUp()
        do {
                modelContainer = try ModelContainer(
                    for: Reminder.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )
                modelContext = modelContainer.mainContext
            } catch {
                XCTFail("Failed to create ModelContainer: \(error)")
            }
    }
    
    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        super.tearDown()
    }
    
    func testAddReminderViewModel() {
        let viewModel = AddReminderViewModel(modelContext: modelContext)
        
        XCTAssertFalse(viewModel.isSaveEnabled)
        
        viewModel.text = "Test reminder"
        XCTAssertTrue(viewModel.isSaveEnabled)
        
        viewModel.text = "   "
        XCTAssertFalse(viewModel.isSaveEnabled)
    }
    
    func testEditReminderViewModel() {
        let reminder = Reminder(text: "Test", date: Date(), priority: .medium)
        let viewModel = EditReminderViewModel(reminder: reminder, modelContext: modelContext)
        
        XCTAssertEqual(viewModel.text, "Test")
        XCTAssertEqual(viewModel.selectedPriority, .medium)
        
        viewModel.text = ""
        XCTAssertFalse(viewModel.isSaveEnabled)
    }
    
    func testAudioRecordingViewModel() {
        let viewModel = AudioRecordingViewModel(modelContext: modelContext)
        
        XCTAssertFalse(viewModel.isRecording)
        XCTAssertFalse(viewModel.canProcessRecording)
        XCTAssertEqual(viewModel.formattedDuration, "00:00")
    }
    
    func testSettingsViewModel() {
        let viewModel = SettingsViewModel()
        
        XCTAssertEqual(viewModel.currentTheme, .system)
        XCTAssertFalse(viewModel.showingAbout)
    }
}
