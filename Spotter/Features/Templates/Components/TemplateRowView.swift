// TemplateRowView.swift
// 템플릿 목록의 각 행을 표시하는 재사용 가능한 컴포넌트
// Created by woo on 4/1/25.

import SwiftUI

struct TemplateRowView: View {
    let template: WorkoutTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 템플릿 이름
            Text(template.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                // 운동 개수
                Label("\(template.exercises.count) 운동", systemImage: "dumbbell.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 마지막 사용 정보
                if let lastUsed = template.lastUsed {
                    Label(formatDate(lastUsed), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 운동 미리보기 (최대 3개)
            if !template.exercises.isEmpty {
                Text(exercisePreviewText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.vertical, 6)
    }
    
    // 날짜 포맷팅
    private func formatDate(_ date: Date) -> String {
        // 1주일 이내면 '3일 전'과 같이 표시
        let calendar = Calendar.current
        if let days = calendar.dateComponents([.day], from: date, to: Date()).day, days < 7 {
            if days == 0 {
                return "오늘"
            } else {
                return "\(days)일 전"
            }
        } else {
            // 그 외에는 날짜 표시
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        }
    }
    
    // 운동 미리보기 텍스트
    private var exercisePreviewText: String {
        let maxExercises = 3
        let exercises = Array(template.exercises.prefix(maxExercises))
        let exerciseNames = exercises.map { $0.exercise?.name ?? "알 수 없는 운동" }
        let preview = exerciseNames.joined(separator: ", ")
        
        if template.exercises.count > maxExercises {
            return "\(preview) 외 \(template.exercises.count - maxExercises)개"
        } else {
            return preview
        }
    }
}

#Preview {
    // 미리보기용 템플릿 데이터
    let template = WorkoutTemplate(name: "상체 운동")
    // 운동 추가
    let exercise1 = ExerciseItem(name: "벤치 프레스", category: "가슴")
    let exercise2 = ExerciseItem(name: "덤벨 숄더 프레스", category: "어깨")
    let exercise3 = ExerciseItem(name: "랫 풀다운", category: "등")
    
    // 템플릿에 운동 추가
    template.addExercise(exercise1, sets: 3)
    template.addExercise(exercise2, sets: 3)
    template.addExercise(exercise3, sets: 3)
    template.lastUsed = Calendar.current.date(byAdding: .day, value: -2, to: Date())
    
    return List {
        TemplateRowView(template: template)
    }
    .listStyle(.insetGrouped)
} 