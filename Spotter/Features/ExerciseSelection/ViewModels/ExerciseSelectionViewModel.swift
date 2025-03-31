// ExerciseSelectionViewModel.swift
// 운동 선택 화면 뷰모델 - MVVM 패턴 적용
// Created by woo on 3/31/25.

import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
class ExerciseSelectionViewModel {
    // MARK: - 프로퍼티
    
    // 데이터 모델 컨텍스트
    private var modelContext: ModelContext
    
    // 모든 등록된 운동 목록
    private(set) var availableExercises: [ExerciseItem] = []
    
    // 현재 선택된 운동 목록
    private(set) var selectedExercises: [ExerciseItem] = []
    
    // 검색어
    var searchText = ""
    
    // 카테고리별 필터링
    var selectedCategory: String?
    
    // 로딩 상태
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - 초기화
    
    init(modelContext: ModelContext, initialSelection: [ExerciseItem] = []) {
        self.modelContext = modelContext
        self.selectedExercises = initialSelection
        fetchExercises()
    }
    
    // MARK: - 데이터 관리
    
    /// 모델 컨텍스트 업데이트 - 환경에서 제공된 컨텍스트 사용
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
    }
    
    /// 모든 운동 목록 가져오기
    func fetchExercises() {
        isLoading = true
        errorMessage = nil
        
        do {
            let descriptor = FetchDescriptor<ExerciseItem>(sortBy: [SortDescriptor(\.name)])
            availableExercises = try modelContext.fetch(descriptor)
            isLoading = false
        } catch {
            errorMessage = "운동 목록을 가져오는 중 오류가 발생했습니다"
            print("운동 목록을 가져오는 중 오류 발생: \(error)")
            isLoading = false
        }
    }
    
    /// 운동이 현재 선택되었는지 확인
    func isExerciseSelected(_ exercise: ExerciseItem) -> Bool {
        return selectedExercises.contains { $0.id == exercise.id }
    }
    
    /// 운동 선택 토글
    func toggleExerciseSelection(_ exercise: ExerciseItem) {
        if isExerciseSelected(exercise) {
            removeFromSelection(exercise)
        } else {
            addToSelection(exercise)
        }
    }
    
    /// 선택 목록에 운동 추가
    func addToSelection(_ exercise: ExerciseItem) {
        // 이미 선택되어 있지 않은 경우에만 추가
        if !isExerciseSelected(exercise) {
            selectedExercises.append(exercise)
            
            // 진동 피드백 (추가)
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif
        }
    }
    
    /// 선택 목록에서 운동 제거
    func removeFromSelection(_ exercise: ExerciseItem) {
        selectedExercises.removeAll { $0.id == exercise.id }
        
        // 진동 피드백 (제거)
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    // MARK: - 필터링 및 컴퓨티드 프로퍼티
    
    /// 필터링된 운동 목록 (검색어 및 카테고리 적용)
    var filteredExercises: [ExerciseItem] {
        var filtered = availableExercises
        
        // 검색어로 필터링
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.muscleGroup.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 카테고리로 필터링
        if let category = selectedCategory, !category.isEmpty {
            filtered = filtered.filter { $0.muscleGroup == category }
        }
        
        return filtered
    }
    
    /// 사용 가능한 모든 근육 그룹 카테고리
    var availableCategories: [String] {
        let categories = Set(availableExercises.map { $0.muscleGroup })
        return Array(categories).sorted()
    }
    
    /// 근육 그룹별 운동 개수
    var categoryDistribution: [String: Int] {
        var distribution: [String: Int] = [:]
        
        for exercise in availableExercises {
            let group = exercise.muscleGroup
            distribution[group, default: 0] += 1
        }
        
        return distribution
    }
} 