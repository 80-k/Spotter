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
    
    // 운동 완료 메서드 - 개선된 버전
    func completeWorkout() {
        self.endTime = Date()
        self.totalDuration = self.endTime!.timeIntervalSince(startTime)
        print("운동 완료 시간: \(self.endTime!)")
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
}
