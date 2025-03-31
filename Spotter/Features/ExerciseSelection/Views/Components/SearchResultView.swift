// SearchResultView.swift
// 운동 선택 기능에 특화된 빈 상태 컴포넌트
// Created by woo on 4/1/25.

import SwiftUI

// MARK: - 검색 결과 없음 뷰
/// 운동 검색 결과가 없을 때 표시되는 기능 특화 컴포넌트
struct SearchResultView: View {
    let searchText: String
    let onAddExercise: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // 공통 EmptyStateView 활용
            EmptyStateView(
                icon: "magnifyingglass",
                title: "검색 결과 없음",
                message: "'\(searchText)'에 대한 운동을 찾을 수 없습니다",
                buttonTitle: "새 운동 등록하기",
                buttonIcon: "plus.circle.fill",
                action: onAddExercise
            )
            
            // 운동 선택 기능에 특화된 추가 안내
            Text("* 이름 또는 근육 그룹으로 검색해보세요")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
    }
}

// MARK: - 카테고리 빈 상태 뷰
/// 선택된 카테고리에 운동이 없을 때 표시되는 기능 특화 컴포넌트
struct CategoryEmptyView: View {
    let categoryName: String
    let onAddExercise: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // 공통 EmptyStateView 활용
            EmptyStateView(
                icon: "tag",
                title: "\(categoryName) 카테고리",
                message: "이 카테고리에 등록된 운동이 없습니다",
                buttonTitle: "새 운동 추가하기",
                buttonIcon: "plus.circle.fill",
                action: onAddExercise
            )
            
            // 카테고리 특화 추가 안내
            Text("카테고리는 운동 추가 시 설정할 수 있습니다")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
    }
}

// MARK: - 미리보기
#Preview {
    VStack(spacing: 20) {
        SearchResultView(searchText: "벤치프레스", onAddExercise: {})
            .frame(height: 300)
        
        Divider()
        
        CategoryEmptyView(categoryName: "가슴", onAddExercise: {})
            .frame(height: 300)
    }
} 