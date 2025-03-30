//
//  WorkoutStatisticsWidget.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct WorkoutStatisticsWidget: View {
    let totalWorkouts: Int
    let streakDays: Int
    let totalDuration: TimeInterval
    let averageWorkoutTime: TimeInterval
    
    var body: some View {
        VStack(spacing: 8) {
            // 위젯 헤더
            HStack {
                Text("운동 통계")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 8)
            
            // 통계 그리드
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                // 총 운동 수
                StatisticCell(
                    value: "\(totalWorkouts)",
                    label: "총 운동",
                    icon: "figure.strengthtraining.traditional",
                    iconColor: .blue
                )
                
                // 연속 운동 일수
                StatisticCell(
                    value: "\(streakDays)",
                    label: "연속 일수",
                    icon: "flame.fill",
                    iconColor: .orange
                )
                
                // 총 운동 시간
                StatisticCell(
                    value: formatDuration(totalDuration),
                    label: "총 시간",
                    icon: "timer",
                    iconColor: .purple
                )
                
                // 평균 운동 시간
                StatisticCell(
                    value: formatDuration(averageWorkoutTime),
                    label: "평균 시간",
                    icon: "clock.fill",
                    iconColor: .green
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    // 시간 포맷팅 (예: "1시간 24분")
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
}

// 통계 셀 컴포넌트
struct StatisticCell: View {
    let value: String
    let label: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // 아이콘
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .padding(12)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            // 값
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            // 라벨
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 100)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
