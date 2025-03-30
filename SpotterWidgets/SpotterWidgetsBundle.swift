// SpotterWidgetsBundle.swift

import SwiftUI

@main
struct SpotterWidgetsBundle: WidgetBundle {
    var body: some Widget {
        // Regular widgets if you have any
        SpotterWidgets()
        
        // Live Activity for workout tracking
        WorkoutLiveActivity()
    }
}
