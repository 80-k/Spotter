//
//  WorkoutSessionDetailView.swift
//  Spotter
//
//  Created by woo on 3/29/25.
//

import SwiftUI
import SwiftData

struct WorkoutSessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let session: WorkoutSession
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            List {
                // 세션 요약 정보
                Section(header: Text("세션 정보")) {
                    if let template = session.workoutTemplate {
                        HStack {
                            Text("템플릿")
                            Spacer()
                            Text(template.name)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("시작 시간")
                        Spacer()
                        Text(dateFormatter.string(from: session.startTime))
                            .foregroundColor(.secondary)
                    }
                    
                    if let endTime = session.endTime {
                        HStack {
                            Text("종료 시간")
                            Spacer()
                            Text(dateFormatter.string(from: endTime))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("총 운동 시간")
                            Spacer()
                            Text(formatDuration(from: session.startTime, to: endTime))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 운동별 세트 정보
                if let template = session.workoutTemplate, let exercises = template.exerciseItems {
                    ForEach(exercises) { exercise in
                        let exerciseSets = session.fetchSetsForExercise(exercise.id)
                        if !exerciseSets.isEmpty {
                            Section(header: Text(exercise.name)) {
                                ForEach(exerciseSets) { set in
                                    HStack {
                                        Text("세트 \(exerciseSets.firstIndex(where: { $0.id == set.id })! + 1)")
                                        
                                        Spacer()
                                        
                                        if set.weight > 0 {
                                            Text("\(String(format: "%.1f", set.weight))kg")
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        if set.reps > 0 {
                                            Text("\(set.reps) rep")
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        if set.isCompleted {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("세션 상세 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // 세션 지속 시간 포맷팅
    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d시간 %d분 %d초", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d분 %d초", minutes, seconds)
        } else {
            return String(format: "%d초", seconds)
        }
    }
}
