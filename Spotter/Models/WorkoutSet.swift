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
    var order: Int = 0 // 세트 순서 (높은 값이 나중에 추가된 세트)
    
    // 관계 설정
    @Relationship(inverse: \WorkoutSession.sets)
    var session: WorkoutSession?
    
    // 운동 관계 설정 - 명시적 관계로 변경
    // 참고: .externalStorage 속성은 관계 조회 시 문제를 일으킬 수 있음
    @Relationship
    var exercise: ExerciseItem?
    
    // 운동 ID도 별도로 저장 (관계 조회 오류에 대한 백업)
    var exerciseId: String = ""
    
    init(exercise: ExerciseItem, session: WorkoutSession? = nil) {
        self.exercise = exercise
        self.exerciseId = String(describing: exercise.id) // ID를 String으로 명시적 변환
        self.session = session
    }
    
    // 세트 완료 메서드 - 무게와 횟수 정보 유지
    func completeSet() {
        // 무게와 횟수가 0이면 기본값 유지 또는 기본값 설정
        // 이미 입력된 값이 있다면 그대로 유지
        // 없다면 0으로 유지
        
        // 완료 상태로 변경
        isCompleted = true
        startRestTime = Date()
    }
    
    // 세트 재개 메서드 - 무게와 횟수 정보 유지
    func resumeSet() {
        // 무게와 횟수 정보는 그대로 유지
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
