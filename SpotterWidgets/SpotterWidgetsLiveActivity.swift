//
//  SpotterWidgetsLiveActivity.swift
//  SpotterWidgets
//
//  Created by woo on 3/30/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SpotterWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SpotterWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SpotterWidgetsAttributes.self) { context in
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

extension SpotterWidgetsAttributes {
    fileprivate static var preview: SpotterWidgetsAttributes {
        SpotterWidgetsAttributes(name: "World")
    }
}

extension SpotterWidgetsAttributes.ContentState {
    fileprivate static var smiley: SpotterWidgetsAttributes.ContentState {
        SpotterWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SpotterWidgetsAttributes.ContentState {
         SpotterWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SpotterWidgetsAttributes.preview) {
   SpotterWidgetsLiveActivity()
} contentStates: {
    SpotterWidgetsAttributes.ContentState.smiley
    SpotterWidgetsAttributes.ContentState.starEyes
}
