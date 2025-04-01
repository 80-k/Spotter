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
        guard let allSets = sets else { return [] }
        
        // 필터링 결과 디버깅
        let filteredSets = allSets.filter { set in
            // 방법 1: exercise 관계를 통한 확인
            if let exercise = set.exercise, exercise.id == exerciseId {
                return true
            }
            
            // 방법 2: 백업 ID를 통한 확인
            if set.exerciseId == String(describing: exerciseId) {
                // exercise 관계가 없지만 ID가 일치하면 관계 재설정
                print("관계 재설정: exercise 관계가 없지만 ID가 일치하여 관계 복구")
                // 이 부분은 실제 동작 시 exercise 엔티티를 다시 찾아와야 할 수 있음
                return true
            }
            
            return false
        }
        
        print("getSetsForExercise: 총 \(allSets.count)개 중 \(filteredSets.count)개 세트 반환 (운동 ID: \(exerciseId))")
        return filteredSets
    }
    
    // 세트 추가 메서드
    func addSet(for exercise: ExerciseItem) -> WorkoutSet {
        let newSet = WorkoutSet(exercise: exercise, session: self)
        if sets == nil {
            sets = []
        }
        
        // 동일한 운동의 마지막 세트 순서를 확인하여 새 세트의 순서를 설정
        let existingSets = getSetsForExercise(exercise.id)
        if let lastSet = existingSets.max(by: { $0.order < $1.order }) {
            newSet.order = lastSet.order + 1
        } else {
            newSet.order = 1 // 첫 세트인 경우 1로 시작
        }
        
        sets!.append(newSet)
        
        print("세트 추가됨: \(exercise.name), 총 세트 수: \(sets!.count), 세트 순서: \(newSet.order)")
        
        // ModelContext가 nil인지 확인
        if let context = modelContext {
            context.insert(newSet)
            print("ModelContext 존재함, 새 세트 삽입됨")
        } else {
            print("경고: ModelContext가 nil입니다. 세트가 추가되었지만 데이터베이스에 저장되지 않을 수 있습니다.")
        }
        
        return newSet
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
