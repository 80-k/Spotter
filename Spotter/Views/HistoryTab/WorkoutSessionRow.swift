//
//  WorkoutSessionRow.swift
//  Spotter
//  다크 모드 지원 개선
//  Created by woo on 3/29/25.
//

import SwiftUI
import SwiftData

struct WorkoutSessionRow: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let session: WorkoutSession
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.template?.name ?? "운동 세션")
                    .font(.headline)
                
                Spacer()
                
                if let endTime = session.endTime {
                    Text(formatDuration(from: session.startTime, to: endTime))
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            
            Text(dateFormatter.string(from: session.startTime))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let sets = session.sets, !sets.isEmpty {
                Text("\(sets.count) 세트 완료")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // 카드 배경색 - 다크 모드 대응
    private var cardBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.systemGray6)
        default:
            return Color.white
        }
    }
    
    // 세션 지속 시간 포맷팅
    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
}
