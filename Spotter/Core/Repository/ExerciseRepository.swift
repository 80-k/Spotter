// ExerciseRepository.swift
// ExerciseItem 모델에 특화된 Repository 구현
// Created by woo on 4/1/25.

import Foundation
import SwiftData

class ExerciseRepository: ModelRepository<ExerciseItem> {
    /// 카테고리(근육 그룹)별로 운동 가져오기
    func getByMuscleGroup(_ muscleGroup: String) throws -> [ExerciseItem] {
        try find(where: #Predicate { $0.muscleGroup == muscleGroup })
    }
    
    /// 이름으로 운동 검색
    func searchByName(_ query: String) throws -> [ExerciseItem] {
        if query.isEmpty {
            return try getAll()
        }
        
        // 모든 운동을 가져온 후 메모리에서 필터링
        // SwiftData의 Predicate 제약으로 인해 복잡한 문자열 검색은 메모리에서 처리
        let allExercises = try getAll()
        return allExercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(query) ||
            exercise.muscleGroup.localizedCaseInsensitiveContains(query)
        }
    }
    
    /// 모든 근육 그룹 카테고리 가져오기
    func getAllMuscleGroups() throws -> [String] {
        let exercises = try getAll()
        let categories = Set(exercises.map { $0.muscleGroup })
        return Array(categories).sorted()
    }
    
    /// 카테고리별 운동 개수 계산
    func getMuscleGroupDistribution() throws -> [String: Int] {
        let exercises = try getAll()
        var distribution: [String: Int] = [:]
        
        for exercise in exercises {
            let group = exercise.muscleGroup
            distribution[group, default: 0] += 1
        }
        
        return distribution
    }
} 