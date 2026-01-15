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

struct BioStateProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> BioStateEntry {
        BioStateEntry(
            date: Date(),
            label: "Rest Score",
            value: 0.72
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BioStateEntry) -> Void) {
        let entry = BioStateEntry(
            date: Date(),
            label: SharedData.biostateLabel,
            value: SharedData.biostateValue
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BioStateEntry>) -> Void) {
        let currentDate = Date()
        let entry = BioStateEntry(
            date: currentDate,
            label: SharedData.biostateLabel,
            value: SharedData.biostateValue
        )
        
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct BioStateEntry: TimelineEntry {
    let date: Date
    let label: String
    let value: Double
    
    var percentage: Int {
        Int(value * 100)
    }
}

// MARK: - Widget View

struct BioStateWidgetEntryView: View {
    var entry: BioStateEntry
    @Environment(\.widgetFamily) var family
    
    private var labelFontSize: CGFloat {
        switch family {
        case .systemSmall:
            return 11
        case .systemMedium:
            return 13
        default:
            return 12
        }
    }
    
    private var valueFontSize: CGFloat {
        switch family {
        case .systemSmall:
            return 32
        case .systemMedium:
            return 40
        default:
            return 36
        }
    }
    
    private var barHeight: CGFloat {
        switch family {
        case .systemSmall:
            return 6
        case .systemMedium:
            return 8
        default:
            return 6
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                WidgetColors.void_
                
                if family == .systemSmall {
                    smallLayout(geometry: geometry)
                } else {
                    mediumLayout(geometry: geometry)
                }
            }
        }
        .containerBackground(WidgetColors.void_, for: .widget)
    }
    
    // MARK: - Small Widget Layout
    
    @ViewBuilder
    private func smallLayout(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            
            // Stealth label
            Text(entry.label.uppercased())
                .font(.system(size: labelFontSize, weight: .medium, design: .rounded))
                .foregroundColor(WidgetColors.smoke)
                .kerning(1.2)
            
            // Percentage value
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(entry.percentage)")
                    .font(.system(size: valueFontSize, weight: .bold, design: .rounded))
                    .foregroundColor(WidgetColors.bone)
                
                Text("%")
                    .font(.system(size: valueFontSize * 0.5, weight: .medium, design: .rounded))
                    .foregroundColor(WidgetColors.smoke)
            }
            
            // Progress bar
            progressBar(width: geometry.size.width - 32)
            
            Spacer()
        }
        .padding(16)
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
    }
    
    // MARK: - Medium Widget Layout
    
    @ViewBuilder
    private func mediumLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 20) {
            // Left side - Label and value
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.label.uppercased())
                    .font(.system(size: labelFontSize, weight: .medium, design: .rounded))
                    .foregroundColor(WidgetColors.smoke)
                    .kerning(1.2)
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(entry.percentage)")
                        .font(.system(size: valueFontSize, weight: .bold, design: .rounded))
                        .foregroundColor(WidgetColors.bone)
                    
                    Text("%")
                        .font(.system(size: valueFontSize * 0.5, weight: .medium, design: .rounded))
                        .foregroundColor(WidgetColors.smoke)
                }
            }
            
            Spacer()
            
            // Right side - Mini graph visualization
            miniGraph(height: 60)
                .frame(width: geometry.size.width * 0.4)
        }
        .padding(20)
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
    
    // MARK: - Progress Bar
    
    @ViewBuilder
    private func progressBar(width: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            // Track
            RoundedRectangle(cornerRadius: barHeight / 2)
                .fill(WidgetColors.smoke.opacity(0.3))
                .frame(width: width, height: barHeight)
            
            // Progress
            RoundedRectangle(cornerRadius: barHeight / 2)
                .fill(WidgetColors.signal)
                .frame(width: max(0, width * CGFloat(entry.value)), height: barHeight)
        }
    }
    
    // MARK: - Mini Graph
    
    @ViewBuilder
    private func miniGraph(height: CGFloat) -> some View {
        GeometryReader { geo in
            let barCount = 7
            let spacing: CGFloat = 4
            let barWidth = (geo.size.width - (CGFloat(barCount - 1) * spacing)) / CGFloat(barCount)
            
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    let isLast = index == barCount - 1
                    let simulatedHeight = simulatedBarHeight(for: index, current: entry.value)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isLast ? WidgetColors.signal : WidgetColors.smoke.opacity(0.5))
                        .frame(width: barWidth, height: max(4, height * simulatedHeight))
                }
            }
            .frame(height: height, alignment: .bottom)
        }
    }
    
    /// Generate simulated historical bar heights for visual effect
    private func simulatedBarHeight(for index: Int, current: Double) -> CGFloat {
        // Create a natural-looking progression toward current value
        let baseVariance: [Double] = [0.4, 0.5, 0.45, 0.6, 0.55, 0.7, 1.0]
        let variance = baseVariance[index % baseVariance.count]
        return CGFloat(current * variance)
    }
}

// MARK: - Widget Configuration

struct BioStateWidget: Widget {
    let kind: String = "BioStateWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BioStateProvider()) { entry in
            BioStateWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Bio State")
        .description("Monitor your recovery metrics")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    BioStateWidget()
} timeline: {
    BioStateEntry(date: .now, label: "Rest Score", value: 0.72)
}

#Preview(as: .systemMedium) {
    BioStateWidget()
} timeline: {
    BioStateEntry(date: .now, label: "Rest Score", value: 0.72)
}
