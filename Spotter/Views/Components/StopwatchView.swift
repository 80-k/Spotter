// StopwatchView.swift
// 스톱워치 시간 표시 컴포넌트
//  Created by woo on 3/29/25.

import SwiftUI

struct StopwatchView: View {
    let elapsedTime: TimeInterval
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "stopwatch")
                .foregroundColor(.blue)
            
            Text(formattedElapsedTime)
                .monospacedDigit()
        }
    }
    
    var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) % 3600 / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
