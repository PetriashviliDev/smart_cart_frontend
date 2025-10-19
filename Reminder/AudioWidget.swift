//
//  AudioWidget.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import WidgetKit
import SwiftUI

struct AudioWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> AudioWidgetEntry {
        AudioWidgetEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AudioWidgetEntry) -> ()) {
        let entry = AudioWidgetEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AudioWidgetEntry>) -> ()) {
        let currentDate = Date()
        let entry = AudioWidgetEntry(date: currentDate)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct AudioWidgetEntry: TimelineEntry {
    let date: Date
}

struct AudioWidgetEntryView: View {
    var entry: AudioWidgetProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "mic.fill")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("Записать")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AudioWidget: Widget {
    let kind: String = "AudioWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AudioWidgetProvider()) { entry in
            AudioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Запись аудио")
        .description("Быстрая запись напоминания")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    AudioWidget()
} timeline: {
    AudioWidgetEntry(date: .now)
}
