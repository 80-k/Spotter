// WorkoutSession.swift
// 운동 세션 모델 - 실제로 수행된 운동 기록
//  Created by woo on 3/29/25.

import Foundation
import SwiftData

@Model
final class WorkoutSession {
    // 기본 정보
    var startTime: Date
    var endTime: Date?
    var totalDuration: TimeInterval? // 초 단위 총 운동 시간
    
    // 추가 통계 정보
    var totalWeight: Double = 0.0    // 세션에서 들어올린 총 무게
    var totalSets: Int = 0           // 총 세트 수
    var completedSets: Int = 0       // 완료된 세트 수
    
    // 관계 설정
    @Relationship(deleteRule: .cascade)
    var template: WorkoutTemplate?
    
    @Relationship(deleteRule: .cascade)
    var sets: [WorkoutSet]? = []
    
    init(template: WorkoutTemplate) {
        self.startTime = Date()
        self.template = template
        self.sets = []
    }
    
    // 운동 완료 메서드 - 더 개선된 버전
    func completeWorkout() {
        self.endTime = Date()
        self.totalDuration = self.endTime!.timeIntervalSince(startTime)
        
        // 통계 정보 계산
        calculateStats()
        
        print("운동 완료 시간: \(self.endTime!)")
        print("총 운동 시간: \(formatDuration(self.totalDuration ?? 0))")
        print("총 세트 수: \(totalSets), 완료된 세트 수: \(completedSets)")
    }
    
    // 통계 정보 계산
    private func calculateStats() {
        guard let sets = sets else { return }
        
        totalSets = sets.count
        completedSets = sets.filter { $0.isCompleted }.count
        
        // 총 무게 계산 (세트당 무게 * 횟수의 합)
        totalWeight = sets.reduce(0.0) { sum, set in
            if set.isCompleted {
                return sum + (set.weight * Double(set.reps))
            }
            return sum
        }
    }
    
    // 특정 운동에 대한 세트들 가져오기
    func getSetsForExercise(_ exerciseId: PersistentIdentifier) -> [WorkoutSet] {
        return sets?.filter { $0.exercise?.id == exerciseId } ?? []
    }
    
    // 세트 추가 메서드
    func addSet(for exercise: ExerciseItem) -> WorkoutSet {
        let newSet = WorkoutSet(exercise: exercise)
        if sets == nil {
            sets = []
        }
        sets!.append(newSet)
        return newSet
    }
    
    // 운동 추가 메서드
    func addExercise(_ exercise: ExerciseItem) {
        // 운동을 직접 세션에 넣지 않고, 이 운동에 대한 기본 세트를 추가
        _ = addSet(for: exercise)
    }
    
    // 시간 포맷팅 (예: "1시간 24분 30초")
    private func formatDuration(_ duration: TimeInterval) -> String {
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
