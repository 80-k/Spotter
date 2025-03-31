// TemplateListRow.swift
// 템플릿 목록에서 사용하는 행 컴포넌트
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

/// 템플릿 목록 행 컴포넌트
struct TemplateListRow: View {
    let template: WorkoutTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 템플릿 이름
            Text(template.name)
                .font(.headline)
            
            HStack(spacing: 16) {
                // 운동 개수
                if let exercises = template.exercises, !exercises.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "dumbbell.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("\(exercises.count)개 운동")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "dumbbell")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("운동 없음")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 최근 사용 정보
                if let lastUsed = getLastUsedDate() {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatDate(lastUsed))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    // 최근 사용 날짜 가져오기
    private func getLastUsedDate() -> Date? {
        return template.sessions?
            .compactMap { $0.endTime }
            .sorted(by: >)
            .first
    }
    
    // 날짜 포맷팅
    private func formatDate(_ date: Date) -> String {
        // 오늘/어제/이번 주로 표시
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "오늘"
        }
        
        if calendar.isDateInYesterday(date) {
            return "어제"
        }
        
        // 1주일 이내
        if let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()),
           date > oneWeekAgo {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // 요일
            return formatter.string(from: date)
        }
        
        // 그 외
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview(traits: .sizeThatFitsLayout) {
    let template = WorkoutTemplate(name: "상체 운동")
    
    // 예시 운동 추가
    let chest = ExerciseItem(name: "벤치 프레스", muscleGroup: "가슴")
    let shoulder = ExerciseItem(name: "숄더 프레스", muscleGroup: "어깨")
    template.addExercise(chest)
    template.addExercise(shoulder)
    
    return List {
        TemplateListRow(template: template)
        
        TemplateListRow(template: WorkoutTemplate(name: "빈 템플릿"))
    }
}
