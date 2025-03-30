//
//  SpotterWidgetsBundle.swift
//  SpotterWidgets
//
//  Created by woo on 3/30/25.
//

import WidgetKit
import SwiftUI

@main
struct SpotterWidgetsBundle: WidgetBundle {
    var body: some Widget {
        // 기존 위젯들 (있을 경우)
        // SpotterWidget()
        
        // 다이나믹 아일랜드 추가
        WorkoutLiveActivity()
    }
}
