// WorkoutSet.swift
// 운동 세트 모델 - 각 운동의 세트 정보 (무게, 횟수 등)
//  Created by woo on 3/29/25.

import Foundation
import SwiftData

@Model
final class WorkoutSet {
    // 기본 정보
    var weight: Double = 0.0
    var reps: Int = 0
    var isCompleted: Bool = false
    var restTime: TimeInterval = 60 // 기본 휴식 시간 60초
    var startRestTime: Date?
    
    // 관계 설정
    @Relationship
    var exercise: ExerciseItem?
    
    init(exercise: ExerciseItem) {
        self.exercise = exercise
    }
    
    // 세트 완료 메서드
    func completeSet() {
        isCompleted = true
        startRestTime = Date()
    }
    
    // 세트 재개 메서드
    func resumeSet() {
        isCompleted = false
        startRestTime = nil
    }
    
    // 현재 휴식 경과 시간 계산
    var currentRestDuration: TimeInterval {
        guard isCompleted, let startRest = startRestTime else { return 0 }
        return Date().timeIntervalSince(startRest)
    }
    
    // 남은 휴식 시간 계산
    var remainingRestTime: TimeInterval {
        let elapsed = currentRestDuration
        return max(0, restTime - elapsed)
    }
}
