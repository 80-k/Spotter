//
//  CompletionStatsView.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI
import SwiftData

struct CompletionStatsView: View {
    let session: WorkoutSession
    
    // 포맷터
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 24) {
            // 운동 이름
            if let templateName = session.template?.name {
                Text(templateName)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            // 세부 정보
            HStack(spacing: 24) {
                // 총 운동 시간
                StatItem(
                    value: formatDuration(session.totalDuration ?? 0),
                    label: "총 시간"
                )
                
                // 세로 구분선
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                // 총 세트 수
                StatItem(
                    value: "\(session.sets?.count ?? 0)",
                    label: "세트"
                )
                
                // 세로 구분선
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                // 운동 종류 수
                let uniqueExercises = Set(session.sets?.compactMap { $0.exercise?.name } ?? [])
                StatItem(
                    value: "\(uniqueExercises.count)",
                    label: "운동"
                )
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            // 운동 시간
            HStack {
                VStack(alignment: .leading) {
                    Text("시작")
                    Text("종료")
                    Text("저장")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(timeFormatter.string(from: session.startTime))
                    if let endTime = session.endTime {
                        Text(timeFormatter.string(from: endTime))
                    }
                    if let endTime = session.endTime {
                        Text(timeFormatter.string(from: endTime))
                    }
                }
                .font(.subheadline)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    // 세션 지속 시간 포맷팅
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// 통계 항목 컴포넌트
struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.system(size: 24, weight: .bold))
            Text(label)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 80)
    }
}
