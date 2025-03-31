// TemplateNavigationContainer.swift
// 템플릿 네비게이션 및 컨테이너 컴포넌트
// Created by woo on 4/16/25.

import SwiftUI

/// 템플릿 화면 네비게이션과 컨테이너를 담당하는 컴포넌트
/// 네비게이션, 검색, 툴바, 에러 처리 등 담당
struct TemplateNavigationContainer<TDataSource: TemplateDataSource & OperationStateReporting, TActions: TemplateActionDelegate>: View {
    // MARK: - 속성
    
    @ObservedObject var viewModel: TDataSource
    @ObservedObject var actions: TActions
    
    // MARK: - 본문
    
    var body: some View {
        NavigationStack {
            // 콘텐츠 뷰 표시
            TemplateContentView(viewModel: viewModel, actions: actions)
                .navigationTitle("운동 시작")
                .searchable(text: $actions.searchText, prompt: "템플릿 검색")
                .templateNavigationTools(actions: actions, viewModel: viewModel)
                .navigationDestination(isPresented: $actions.navigateToActiveWorkout, destination: workoutSessionDestination)
        }
        .withTemplateDialogs(actions)
        .overlay { TemplateErrorOverlay(viewModel: viewModel) }
        .task {
            // 최초 로드가 필요한 경우
            if viewModel.templates.isEmpty && !viewModel.isLoading {
                viewModel.loadTemplates()
            }
        }
    }
    
    // MARK: - 서브뷰
    
    /// 운동 세션 네비게이션 대상
    @ViewBuilder
    private func workoutSessionDestination() -> some View {
        if let session = actions.activeWorkoutSession {
            // 세션으로 이동
            WorkoutSessionView(session: session)
        } else {
            // 세션이 없는 경우 (기본 대응)
            Text("세션 정보를 불러올 수 없습니다")
                .foregroundColor(.secondary)
        }
    }
}

/// WorkoutSessionView 임시 스텁 구현 (필요에 따라 실제 뷰로 교체)
struct WorkoutSessionView: View {
    let session: WorkoutSession
    
    var body: some View {
        VStack(spacing: 16) {
            Text("세션: \(session.template?.name ?? "명칭 없음")")
                .font(.title)
            
            Text("시작 시간: \(session.startDate?.formatted() ?? "미정")")
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .navigationTitle("운동 세션")
    }
}

// MARK: - 미리보기

struct TemplateNavigationContainer_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewDataFactory.createPreviewContainer()
        let repo = TemplateRepository(modelContext: previewContainer.mainContext)
        let viewModel = ActorTemplateViewModel(repository: repo)
        let actions = TemplateActionsHandler(viewModel: viewModel)
        
        // 샘플 데이터 생성
        PreviewDataFactory.populatePreviewContext(previewContainer.mainContext)
        
        return TemplateNavigationContainer(viewModel: viewModel, actions: actions)
            .environmentObject(DependencyContainer.shared)
    }
} 