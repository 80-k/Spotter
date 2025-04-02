// WorkoutRepositoryProtocol.swift
// 운동 저장소 프로토콜 정의
// Created by woo on 3/30/25.

import Foundation
import SwiftData
import Combine

// TODO: 이 프로토콜은 현재 앱에서 직접 사용되고 있지 않습니다.
// 리포지토리 패턴을 위해 구현되었으나, 현재는 ViewModel에서 직접 SwiftData ModelContext를 사용하고 있습니다.
// 애플리케이션이 확장될 경우를 대비해 유지되고 있습니다.

/// 운동 관련 데이터 접근을 위한 리포지토리 프로토콜
protocol WorkoutRepositoryProtocol {
    // MARK: - 템플릿 관련
    
    /// 모든 운동 템플릿 가져오기
    func fetchWorkoutTemplates() -> AnyPublisher<[WorkoutTemplate], Error>
    
    /// 운동 템플릿 저장하기
    func saveWorkoutTemplate(_ template: WorkoutTemplate) -> AnyPublisher<Void, Error>
    
    /// 운동 템플릿 삭제하기
    func deleteWorkoutTemplate(_ template: WorkoutTemplate) -> AnyPublisher<Void, Error>
    
    // MARK: - 세션 관련
    
    /// 모든 운동 세션 가져오기
    func fetchWorkoutSessions() -> AnyPublisher<[WorkoutSession], Error>
    
    /// 운동 세션 저장하기
    func saveWorkoutSession(_ session: WorkoutSession) -> AnyPublisher<Void, Error>
    
    /// 운동 세션 삭제하기
    func deleteWorkoutSession(_ session: WorkoutSession) -> AnyPublisher<Void, Error>
    
    // MARK: - 운동 항목 관련
    
    /// 모든 운동 항목 가져오기
    func fetchExerciseItems() -> AnyPublisher<[ExerciseItem], Error>
    
    /// 운동 항목 저장하기
    func saveExerciseItem(_ exerciseItem: ExerciseItem) -> AnyPublisher<Void, Error>
} 