// TemplateHeaderView.swift
// 템플릿 상세 화면의 헤더 컴포넌트 - 최신 SwiftUI API 적용
// Created by woo on 3/31/25.

import SwiftUI

struct TemplateHeaderView: View {
    let name: String
    let exerciseCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(name)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            HStack(spacing: 12) {
                exerciseCountLabel
                
                if exerciseCount > 0 {
                    // 추가 정보가 있을 경우 구분선
                    Divider()
                        .frame(height: 24)
                    
                    // 운동 시간 예상치
                    estimatedTimeLabel
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Material.bar)
    }
    
    // 운동 개수 레이블
    private var exerciseCountLabel: some View {
        Label {
            Text(exerciseCount > 0 ? "\(exerciseCount)개 운동" : "운동 없음")
                .font(.system(.subheadline, weight: .medium))
                .foregroundColor(.secondary)
        } icon: {
            Image(systemName: exerciseCount > 0 ? "dumbbell.fill" : "xmark.circle")
                .foregroundColor(exerciseCount > 0 ? .blue : .secondary)
        }
    }
    
    // 운동 예상 시간 레이블
    private var estimatedTimeLabel: some View {
        Label {
            Text(estimatedTimeText)
                .font(.system(.subheadline, weight: .medium))
                .foregroundColor(.secondary)
        } icon: {
            Image(systemName: "clock")
                .foregroundColor(.orange)
        }
    }
    
    // 예상 운동 시간 (운동 개수에 따라 대략적인 시간 계산)
    private var estimatedTimeText: String {
        let baseTime = 10 // 기본 10분
        let timePerExercise = 5 // 운동당 약 5분
        
        let totalMinutes = baseTime + (exerciseCount * timePerExercise)
        
        if totalMinutes < 60 {
            return "\(totalMinutes)분"
        } else {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            
            if minutes == 0 {
                return "\(hours)시간"
            } else {
                return "\(hours)시간 \(minutes)분"
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 20) {
        TemplateHeaderView(
            name: "상체 운동",
            exerciseCount: 5
        )
        
        TemplateHeaderView(
            name: "빈 템플릿",
            exerciseCount: 0
        )
        
        TemplateHeaderView(
            name: "매우 긴 이름의 레그 데이 템플릿 이름이 길어도 표시 잘 됨",
            exerciseCount: 12
        )
    }
    .padding()
} 