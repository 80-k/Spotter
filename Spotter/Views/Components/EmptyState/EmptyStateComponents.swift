// EmptyStateComponents.swift
// 빈 상태 UI 컴포넌트 모음 - 앱 전체에서 재사용 가능
// Created by woo on 3/31/25.

import SwiftUI

// 템플릿 빈 상태 뷰
struct EmptyTemplateView: View {
    let onAddTemplate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("템플릿이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("+ 버튼을 눌러 새 템플릿을 추가하세요")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button(action: onAddTemplate) {
                Label("템플릿 추가하기", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(Color(.systemBackground))
    }
}

// 운동 빈 상태 뷰 - 템플릿 상세 화면용
struct EmptyTemplateExerciseView: View {
    let onAddExercise: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("운동이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("+ 버튼을 눌러 운동을 추가하세요")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
            
            Button(action: onAddExercise) {
                Label("운동 추가하기", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(Color(.systemBackground))
    }
}

// 운동 선택 화면 빈 상태 컴포넌트
struct EmptyExerciseListView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.4))
                .padding(.top, 20)
            
            Text("등록된 운동이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("새 운동을 등록하거나 검색어를 확인해보세요")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// 검색 결과 없음 컴포넌트
struct NoSearchResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.4))
                .padding(.bottom, 8)
            
            Text("'\(searchText)'에 대한 검색 결과가 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}
