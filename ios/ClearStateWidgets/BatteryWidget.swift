import WidgetKit
import SwiftUI

// MARK: - Design Colors

private enum WidgetColors {
    static let void_ = Color(red: 5/255, green: 5/255, blue: 5/255)        // #050505
    static let bone = Color(red: 232/255, green: 232/255, blue: 232/255)   // #E8E8E8
    static let signal = Color(red: 255/255, green: 107/255, blue: 53/255)  // #FF6B35
    static let smoke = Color(red: 92/255, green: 92/255, blue: 92/255)     // #5C5C5C
}

// MARK: - Timeline Provider

struct BatteryProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> BatteryEntry {
        BatteryEntry(date: Date(), progress: 0.75)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BatteryEntry) -> Void) {
        let entry = BatteryEntry(
            date: Date(),
            progress: SharedData.batteryProgress
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryEntry>) -> Void) {
        let currentDate = Date()
        let entry = BatteryEntry(
            date: currentDate,
            progress: SharedData.batteryProgress
        )
        
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct BatteryEntry: TimelineEntry {
    let date: Date
    let progress: Double
    
    var percentage: Int {
        Int(progress * 100)
    }
}

// MARK: - Widget View

struct BatteryWidgetEntryView: View {
    var entry: BatteryEntry
    @Environment(\.widgetFamily) var family
    
    private var ringSize: CGFloat {
        switch family {
        case .systemSmall:
            return 100
        case .systemMedium:
            return 120
        default:
            return 100
        }
    }
    
    private var lineWidth: CGFloat {
        switch family {
        case .systemSmall:
            return 10
        case .systemMedium:
            return 12
        default:
            return 10
        }
    }
    
    private var fontSize: CGFloat {
        switch family {
        case .systemSmall:
            return 28
        case .systemMedium:
            return 34
        default:
            return 28
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                WidgetColors.void_
                
                // Circular progress ring
                ZStack {
                    // Background ring (track)
                    Circle()
                        .stroke(
                            WidgetColors.smoke.opacity(0.3),
                            lineWidth: lineWidth
                        )
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.progress))
                        .stroke(
                            WidgetColors.signal,
                            style: StrokeStyle(
                                lineWidth: lineWidth,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: entry.progress)
                    
                    // Percentage text in center
                    Text("\(entry.percentage)")
                        .font(.system(size: fontSize, weight: .bold, design: .rounded))
                        .foregroundColor(WidgetColors.bone)
                }
                .frame(width: ringSize, height: ringSize)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .containerBackground(WidgetColors.void_, for: .widget)
    }
}

// MARK: - Widget Configuration

struct BatteryWidget: Widget {
    let kind: String = "BatteryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryProvider()) { entry in
            BatteryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Battery")
        .description("Track your energy level")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    BatteryWidget()
} timeline: {
    BatteryEntry(date: .now, progress: 0.75)
    BatteryEntry(date: .now, progress: 0.50)
}
