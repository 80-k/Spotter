// WorkoutSet.swift
// 운동 세트 모델 - 각 운동의 세트 정보 (무게, 횟수 등)
//  Created by woo on 3/29/25.

import Foundation
import SwiftData

/// 운동 세트 모델
@Model
final class WorkoutSet {
    // 기본 정보
    var weight: Double = 0.0
    var reps: Int = 0
    var isCompleted: Bool = false
    var restTime: TimeInterval = 60 // 기본 휴식 시간 60초
    var startRestTime: Date?
    var order: Int = 0 // 세트 순서 (높은 값이 나중에 추가된 세트)
    
    // 관계 설정
    @Relationship(inverse: \WorkoutSession.workoutSets)
    var workoutSession: WorkoutSession? // session → workoutSession으로 변경
    
    // 운동 관계 설정
    @Relationship
    var exerciseItem: ExerciseItem? // exercise → exerciseItem으로 변경
    
    // 운동 ID도 별도로 저장 (관계 조회 오류에 대한 백업)
    var exerciseId: String = ""
    
    init(exerciseItem: ExerciseItem, workoutSession: WorkoutSession? = nil) {
        self.exerciseItem = exerciseItem
        self.exerciseId = String(describing: exerciseItem.id) // ID를 String으로 명시적 변환
        self.workoutSession = workoutSession
    }
    
    /// 세트 완료
    func completeSet() {
        isCompleted = true
        startRestTime = Date()
    }
    
    /// 세트 재개
    func resumeSet() {
        isCompleted = false
        startRestTime = nil
    }
    
    /// 현재 휴식 경과 시간 계산
    var currentRestDuration: TimeInterval {
        guard isCompleted, let startRest = startRestTime else { return 0 }
        return Date().timeIntervalSince(startRest)
    }
    
    /// 남은 휴식 시간 계산
    var remainingRestTime: TimeInterval {
        let elapsed = currentRestDuration
        return max(0, restTime - elapsed)
    }
    
    /// 총 무게 (무게 × 횟수)
    var totalWeight: Double {
        return weight * Double(reps)
    }
} 