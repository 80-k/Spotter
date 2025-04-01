// ExerciseSetSection.swift
// 세트 정보 섹션 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI
import SwiftData

// 세트 정보 섹션 컴포넌트
struct ExerciseSetSection: View {
    var sets: [WorkoutSet]
    var isEditMode: Bool
    var areAllSetsCompleted: Bool
    var areSomeSetsCompleted: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 세트 섹션 헤더
            HStack {
                Text("세트 정보")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(SpotColor.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(SpotColor.primary.opacity(0.2))
                        .frame(width: 8, height: 8)
                    
                    Text("\(sets.count)세트")
                        .font(.caption)
                        .foregroundColor(SpotColor.secondaryText)
                }
                
                if areAllSetsCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(SpotColor.success)
                        
                        Text("완료")
                            .font(.caption)
                            .foregroundColor(SpotColor.success)
                    }
                } else if areSomeSetsCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(SpotColor.warning)
                        
                        Text("진행중")
                            .font(.caption)
                            .foregroundColor(SpotColor.warning)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 세트 정보 범례 - 항목 설명
            if !sets.isEmpty {
                HStack {
                    Text("번호")
                        .font(.caption2)
                        .foregroundColor(SpotColor.secondaryText)
                        .frame(width: 40, alignment: .center)
                    
                    Spacer()
                    
                    Text("무게")
                        .font(.caption2)
                        .foregroundColor(SpotColor.secondaryText)
                        .frame(width: 90, alignment: .center)
                    
                    Text("횟수")
                        .font(.caption2)
                        .foregroundColor(SpotColor.secondaryText)
                        .frame(width: 80, alignment: .center)
                    
                    Spacer()
                    
                    Text("상태")
                        .font(.caption2)
                        .foregroundColor(SpotColor.secondaryText)
                        .frame(width: 60, alignment: .center)
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 2)
            }
        }
    }
}
