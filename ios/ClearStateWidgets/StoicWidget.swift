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

struct StoicProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> StoicEntry {
        StoicEntry(
            date: Date(),
            quote: "The obstacle is the way.",
            author: "Marcus Aurelius"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StoicEntry) -> Void) {
        let entry = StoicEntry(
            date: Date(),
            quote: SharedData.stoicQuote,
            author: SharedData.stoicAuthor
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StoicEntry>) -> Void) {
        let currentDate = Date()
        let entry = StoicEntry(
            date: currentDate,
            quote: SharedData.stoicQuote,
            author: SharedData.stoicAuthor
        )
        
        // Refresh every hour for quote updates
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct StoicEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
}

// MARK: - Widget View

struct StoicWidgetEntryView: View {
    var entry: StoicEntry
    @Environment(\.widgetFamily) var family
    
    private var quoteFontSize: CGFloat {
        switch family {
        case .systemSmall:
            return 13
        case .systemMedium:
            return 16
        default:
            return 14
        }
    }
    
    private var authorFontSize: CGFloat {
        switch family {
        case .systemSmall:
            return 10
        case .systemMedium:
            return 12
        default:
            return 11
        }
    }
    
    private var padding: CGFloat {
        switch family {
        case .systemSmall:
            return 12
        case .systemMedium:
            return 16
        default:
            return 14
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                WidgetColors.void_
                
                VStack(spacing: 8) {
                    Spacer()
                    
                    // Quote text
                    Text("\"\(entry.quote)\"")
                        .font(.system(size: quoteFontSize, weight: .light, design: .serif))
                        .foregroundColor(WidgetColors.bone)
                        .multilineTextAlignment(.center)
                        .lineLimit(family == .systemSmall ? 4 : 3)
                        .minimumScaleFactor(0.8)
                    
                    // Author attribution (medium size only)
                    if family == .systemMedium {
                        Text("- \(entry.author)")
                            .font(.system(size: authorFontSize, weight: .regular, design: .serif))
                            .foregroundColor(WidgetColors.smoke)
                            .italic()
                    }
                    
                    Spacer()
                }
                .padding(padding)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .containerBackground(WidgetColors.void_, for: .widget)
    }
}

// MARK: - Widget Configuration

struct StoicWidget: Widget {
    let kind: String = "StoicWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StoicProvider()) { entry in
            StoicWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Wisdom")
        .description("Inspiration for the journey")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    StoicWidget()
} timeline: {
    StoicEntry(
        date: .now,
        quote: "The obstacle is the way.",
        author: "Marcus Aurelius"
    )
}
