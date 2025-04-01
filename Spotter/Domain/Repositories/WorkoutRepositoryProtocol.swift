// WorkoutRepositoryProtocol.swift
// 운동 저장소 인터페이스
//  Created by woo on 3/30/25.

import Foundation
import SwiftData
import Combine

/// 운동 관련 데이터 접근을 위한 리포지토리 프로토콜
protocol WorkoutRepositoryProtocol {
    // 템플릿 관련
    func fetchWorkoutTemplates() -> AnyPublisher<[WorkoutTemplate], Error>
    func saveWorkoutTemplate(_ template: WorkoutTemplate) -> AnyPublisher<Void, Error>
    func deleteWorkoutTemplate(_ template: WorkoutTemplate) -> AnyPublisher<Void, Error>
    
    // 세션 관련
    func fetchWorkoutSessions() -> AnyPublisher<[WorkoutSession], Error>
    func saveWorkoutSession(_ session: WorkoutSession) -> AnyPublisher<Void, Error>
    func deleteWorkoutSession(_ session: WorkoutSession) -> AnyPublisher<Void, Error>
    
    // 운동 항목 관련
    func fetchExerciseItems() -> AnyPublisher<[ExerciseItem], Error>
    func saveExerciseItem(_ exerciseItem: ExerciseItem) -> AnyPublisher<Void, Error>
} 