// WorkoutSession.swift
// 운동 세션 모델 - 실제로 수행된 운동 기록
//  Created by woo on 3/29/25.

import Foundation
import SwiftData

/// 운동 세션 모델
@Model
final class WorkoutSession {
    // 기본 정보
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval? // totalDuration → duration으로 변경
    
    // 추가 통계 정보
    var totalWeight: Double = 0.0    // 세션에서 들어올린 총 무게
    var totalSets: Int = 0           // 총 세트 수
    var completedSets: Int = 0       // 완료된 세트 수
    
    // 관계 설정
    @Relationship(deleteRule: .cascade)
    var workoutTemplate: WorkoutTemplate? // template → workoutTemplate으로 변경
    
    @Relationship(deleteRule: .cascade)
    var workoutSets: [WorkoutSet]? = [] // sets → workoutSets로 변경
    
    init(workoutTemplate: WorkoutTemplate) {
        self.startTime = Date()
        self.workoutTemplate = workoutTemplate
        self.workoutSets = []
    }
    
    /// 운동 완료
    func finishWorkout() { // completeWorkout → finishWorkout으로 변경
        self.endTime = Date()
        self.duration = self.endTime!.timeIntervalSince(startTime)
        
        // 통계 정보 계산
        calculateStats()
    }
    
    /// 통계 정보 계산
    private func calculateStats() {
        guard let sets = workoutSets else { return }
        
        totalSets = sets.count
        completedSets = sets.filter { $0.isCompleted }.count
        
        // 총 무게 계산 (세트당 무게 * 횟수의 합)
        totalWeight = sets.reduce(0.0) { sum, set in
            if set.isCompleted {
                return sum + set.totalWeight
            }
            return sum
        }
    }
    
    /// 특정 운동에 대한 세트들 가져오기
    func fetchSetsForExercise(_ exerciseId: PersistentIdentifier) -> [WorkoutSet] { // getSetsForExercise → fetchSetsForExercise로 변경
        guard let allSets = workoutSets else { return [] }
        
        let filteredSets = allSets.filter { set in
            // 방법 1: exerciseItem 관계를 통한 확인
            if let exercise = set.exerciseItem, exercise.id == exerciseId {
                return true
            }
            
            // 방법 2: 백업 ID를 통한 확인
            if set.exerciseId == String(describing: exerciseId) {
                return true
            }
            
            return false
        }
        
        return filteredSets
    }
    
    /// 세트 추가
    func createSet(for exerciseItem: ExerciseItem) -> WorkoutSet { // addSet → createSet으로 변경
        let newSet = WorkoutSet(exerciseItem: exerciseItem, workoutSession: self)
        if workoutSets == nil {
            workoutSets = []
        }
        
        // 동일한 운동의 마지막 세트 순서를 확인하여 새 세트의 순서를 설정
        let existingSets = fetchSetsForExercise(exerciseItem.id)
        if let lastSet = existingSets.max(by: { $0.order < $1.order }) {
            newSet.order = lastSet.order + 1
        } else {
            newSet.order = 1 // 첫 세트인 경우 1로 시작
        }
        
        workoutSets!.append(newSet)
        
        // ModelContext가 존재하면 새 세트 삽입
        if let context = modelContext {
            context.insert(newSet)
        }
        
        return newSet
    }
    
    /// 현재 진행 중인지 여부
    var isInProgress: Bool {
        return endTime == nil
    }
    
    /// 세션의 완료율 (완료된 세트 / 총 세트)
    var completionRate: Double {
        guard totalSets > 0 else { return 0 }
        return Double(completedSets) / Double(totalSets)
    }
    
    /// 포맷팅된 운동 시간
    var formattedDuration: String {
        return formatDuration(duration ?? 0)
    }
    
    /// 시간 포맷팅 (예: "1시간 24분 30초")
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