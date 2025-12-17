//
//  FiniteWidget.swift
//  FiniteWidget
//
//  Created by Jwala Kompalli on 12/16/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct FiniteTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> FiniteEntry {
        FiniteEntry(date: Date(), weeksRemaining: 2647, weeksLived: 1513, totalWeeks: 4160)
    }

    func getSnapshot(in context: Context, completion: @escaping (FiniteEntry) -> Void) {
        let entry = makeEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FiniteEntry>) -> Void) {
        let entry = makeEntry()

        // Update weekly - calculate next Monday at midnight
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        components.weekday = 2 // Monday
        components.hour = 0
        components.minute = 0

        let nextUpdate: Date
        if let nextMonday = calendar.date(from: components) {
            // If next Monday is in the past, add a week
            if nextMonday <= now {
                nextUpdate = calendar.date(byAdding: .weekOfYear, value: 1, to: nextMonday) ?? now.addingTimeInterval(604800)
            } else {
                nextUpdate = nextMonday
            }
        } else {
            // Fallback: update in 1 week
            nextUpdate = now.addingTimeInterval(604800)
        }

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func makeEntry() -> FiniteEntry {
        let provider = WidgetDataProvider.shared

        if provider.hasValidData {
            return FiniteEntry(
                date: Date(),
                weeksRemaining: provider.weeksRemaining,
                weeksLived: provider.weeksLived,
                totalWeeks: provider.totalWeeks
            )
        } else {
            // No data yet - show placeholder
            return FiniteEntry(date: Date(), weeksRemaining: 0, weeksLived: 0, totalWeeks: 0)
        }
    }
}

// MARK: - Timeline Entry

struct FiniteEntry: TimelineEntry {
    let date: Date
    let weeksRemaining: Int
    let weeksLived: Int
    let totalWeeks: Int

    var hasData: Bool {
        totalWeeks > 0
    }
}

// MARK: - Widget View

struct FiniteWidgetEntryView: View {
    var entry: FiniteEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if entry.hasData {
                switch family {
                case .systemSmall:
                    SmallWidgetView(weeksRemaining: entry.weeksRemaining)
                case .systemMedium:
                    MediumWidgetView(
                        weeksRemaining: entry.weeksRemaining,
                        weeksLived: entry.weeksLived,
                        totalWeeks: entry.totalWeeks
                    )
                default:
                    SmallWidgetView(weeksRemaining: entry.weeksRemaining)
                }
            } else {
                NoDataView()
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let weeksRemaining: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(weeksRemaining.formatted())")
                .font(.system(size: 42, weight: .light, design: .rounded))
                .minimumScaleFactor(0.5)
                .foregroundStyle(.primary)

            Text("weeks")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let weeksRemaining: Int
    let weeksLived: Int
    let totalWeeks: Int

    private var progress: Double {
        guard totalWeeks > 0 else { return 0 }
        return Double(weeksLived) / Double(totalWeeks)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Left side: Number
            VStack(spacing: 4) {
                Text("\(weeksRemaining.formatted())")
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(.primary)

                Text("weeks remaining")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            // Right side: Progress bar
            VStack(alignment: .leading, spacing: 8) {
                // Mini progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.quaternary)
                            .frame(height: 6)

                        // Progress
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.primary.opacity(0.7))
                            .frame(width: geometry.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(weeksLived.formatted()) lived")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - No Data View

struct NoDataView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.circle")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("Open Finite")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Widget Configuration

struct FiniteWidget: Widget {
    let kind: String = "FiniteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FiniteTimelineProvider()) { entry in
            FiniteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Finite")
        .description("Your weeks remaining.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    FiniteWidget()
} timeline: {
    FiniteEntry(date: Date(), weeksRemaining: 2647, weeksLived: 1513, totalWeeks: 4160)
}

#Preview("Medium", as: .systemMedium) {
    FiniteWidget()
} timeline: {
    FiniteEntry(date: Date(), weeksRemaining: 2647, weeksLived: 1513, totalWeeks: 4160)
}

#Preview("No Data", as: .systemSmall) {
    FiniteWidget()
} timeline: {
    FiniteEntry(date: Date(), weeksRemaining: 0, weeksLived: 0, totalWeeks: 0)
}
