//
//  ClearStateWidgetsLiveActivity.swift
//  ClearStateWidgets
//
//  Created by Abhideep Maity on 15/01/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ClearStateWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ClearStateWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ClearStateWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ClearStateWidgetsAttributes {
    fileprivate static var preview: ClearStateWidgetsAttributes {
        ClearStateWidgetsAttributes(name: "World")
    }
}

extension ClearStateWidgetsAttributes.ContentState {
    fileprivate static var smiley: ClearStateWidgetsAttributes.ContentState {
        ClearStateWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ClearStateWidgetsAttributes.ContentState {
         ClearStateWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ClearStateWidgetsAttributes.preview) {
   ClearStateWidgetsLiveActivity()
} contentStates: {
    ClearStateWidgetsAttributes.ContentState.smiley
    ClearStateWidgetsAttributes.ContentState.starEyes
}
