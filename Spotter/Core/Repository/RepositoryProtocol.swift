// RepositoryProtocol.swift
// 리포지토리 패턴을 위한 기본 프로토콜
// Created by woo on 4/16/25.

import Foundation
import SwiftData

/// 모든 리포지토리를 위한 공통 프로토콜
protocol RepositoryProtocol {
    /// 리포지토리가 사용하는 모델 컨텍스트
    var modelContext: ModelContext { get }
    
    /// 기본 초기화 메서드
    init(modelContext: ModelContext)
    
    /// 트랜잭션 범위 내에서 작업 수행
    func withTransaction<T>(_ operation: @escaping () throws -> T) async throws -> T
}

/// 리포지토리 공통 확장
extension RepositoryProtocol {
    /// 트랜잭션 래퍼 메서드 기본 구현
    func withTransaction<T>(_ operation: @escaping () throws -> T) async throws -> T {
        try await modelContext.transaction {
            try operation()
        }
    }
}

/// 템플릿 특화 리포지토리 프로토콜
protocol TemplateRepositoryProtocol: RepositoryProtocol {
    /// 모든 템플릿 조회
    func getAll(sortBy sortDescriptors: [SortDescriptor<WorkoutTemplate>]?) -> [WorkoutTemplate]
    
    /// 이름으로 템플릿 검색
    func search(matching query: String) -> [WorkoutTemplate]
    
    /// ID로 특정 템플릿 조회 
    func get(by id: UUID) -> WorkoutTemplate?
    
    /// 템플릿 저장
    func save(_ template: WorkoutTemplate) throws
    
    /// 템플릿 삭제
    func delete(_ template: WorkoutTemplate) throws
    
    /// 템플릿 사용 정보 업데이트
    func updateUsage(_ template: WorkoutTemplate) throws
}

/// 세션 특화 리포지토리 프로토콜
protocol SessionRepositoryProtocol: RepositoryProtocol {
    /// 모든 세션 조회
    func getAllSessions(sortBy sortDescriptors: [SortDescriptor<WorkoutSession>]?) -> [WorkoutSession]
    
    /// 날짜 범위로 세션 조회
    func getSessions(from startDate: Date, to endDate: Date) -> [WorkoutSession]
    
    /// 특정 템플릿으로 생성된 세션 조회
    func getSessions(forTemplate templateId: UUID) -> [WorkoutSession]
    
    /// 템플릿으로 새 세션 생성
    func createSession(with template: WorkoutTemplate) -> WorkoutSession
    
    /// 세션 저장
    func save(_ session: WorkoutSession) throws
    
    /// 세션 삭제
    func delete(_ session: WorkoutSession) throws
}

/// 운동 항목 리포지토리 프로토콜
protocol ExerciseRepositoryProtocol: RepositoryProtocol {
    /// 모든 운동 항목 조회
    func getAllExercises() -> [ExerciseItem]
    
    /// 특정 템플릿의 운동 항목 조회
    func getExercises(forTemplate templateId: UUID) -> [ExerciseItem]
    
    /// 운동 항목 저장
    func save(_ exercise: ExerciseItem) throws
    
    /// 운동 항목 삭제
    func delete(_ exercise: ExerciseItem) throws
} 