// WorkoutHistoryTabView.swift
// 운동 기록 탭 뷰 - 세션 기록과 운동 통계 탭을 포함
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct WorkoutHistoryTabView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: HistoryViewModel
    @State private var selectedTab = 0
    
    init(modelContext: ModelContext) {
        self._viewModel = StateObject(wrappedValue: HistoryViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 탭 선택 버튼
                HStack(spacing: 0) {
                    TabButton(
                        title: "세션 기록",
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                    )
                    
                    TabButton(
                        title: "운동 통계",
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                    )
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // 선택된 탭에 따른 컨텐츠 표시
                TabView(selection: $selectedTab) {
                    // 세션 기록 탭
                    SessionHistoryView(viewModel: viewModel)
                        .tag(0)
                    
                    // 운동 통계 탭
                    ExerciseStatsView(viewModel: viewModel)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
            }
            .navigationTitle("운동 기록")
            // 운동 완료 알림 수신 시 기록 새로고침
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("WorkoutCompleted"))) { _ in
                viewModel.fetchSessions()
            }
            .onAppear {
                viewModel.fetchSessions()
            }
            .refreshable {
                viewModel.fetchSessions()
            }
        }
    }
}

// 탭 버튼 컴포넌트
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .padding(.vertical, 8)
                
                // 선택 표시 바
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
                    .animation(.spring(), value: isSelected)
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }
}
