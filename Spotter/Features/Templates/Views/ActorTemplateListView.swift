// ActorTemplateListView.swift
// Swift Actor를 활용한 스레드 안전한 템플릿 목록 화면
// Created by woo on 4/1/25.

import SwiftUI
import SwiftData

/// 템플릿 목록을 Actor 기반 ViewModel로 관리하는 메인 화면
struct ActorTemplateListView: View {
    // MARK: - 환경 및 의존성
    
    @EnvironmentObject private var provider: DependencyContainer
    @StateObject private var viewModel: ActorTemplateViewModel
    @StateObject private var actions: TemplateActionsHandler
    
    // MARK: - 초기화
    
    /// 리포지토리로부터 초기화 (SwiftUI 프리뷰용)
    init(repository: TemplateRepository) {
        // DI 컨테이너가 사용할 수 없는 상황(초기화 단계)에서 직접 생성하는 방식
        let vm = ActorTemplateViewModel(repository: repository)
        let actions = TemplateActionsHandler(viewModel: vm)
        self._viewModel = StateObject(wrappedValue: vm)
        self._actions = StateObject(wrappedValue: actions)
    }
    
    /// DI 컨테이너로부터 컴포넌트 생성 (앱 내부 사용)
    init(container: DependencyContainer = DependencyContainer.shared) {
        // ViewModelProvider를 통한 뷰모델 요청
        let vm = container.viewModel(of: ActorTemplateViewModel.self)
        let actions = TemplateActionsHandler(viewModel: vm)
        self._viewModel = StateObject(wrappedValue: vm)
        self._actions = StateObject(wrappedValue: actions)
    }
    
    /// 직접 ViewModel 주입 (테스트 및 커스텀 환경용)
    init(viewModel: ActorTemplateViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._actions = StateObject(wrappedValue: TemplateActionsHandler(viewModel: viewModel))
    }
    
    // MARK: - 뷰 본문
    
    var body: some View {
        TemplateNavigationContainer(viewModel: viewModel, actions: actions)
            .onAppear { syncWithProvider() }
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 컨테이너의 최신 뷰모델 인스턴스와 뷰모델 동기화
    private func syncWithProvider() {
        // ViewModelProvider를 통한 최신 뷰모델 인스턴스 요청
        let latestViewModel = provider.viewModel(of: ActorTemplateViewModel.self)
        
        // 최신 상태 동기화
        if latestViewModel !== viewModel {
            viewModel.updateState(from: latestViewModel)
        }
    }
}

// MARK: - 미리보기

struct ActorTemplateListView_Previews: PreviewProvider {
    static var previews: some View {
        // 미리보기 컨테이너 생성
        let previewContainer = PreviewDataFactory.createPreviewContainer()
        
        // 의존성 설정
        let repo = TemplateRepository(modelContext: previewContainer.mainContext)
        
        // 미리보기용 데이터 설정
        PreviewDataFactory.populatePreviewContext(previewContainer.mainContext)
        
        // 다양한 시나리오에 대한 미리보기
        Group {
            // 기본 화면
            ActorTemplateListView(repository: repo)
                .environmentObject(DependencyContainer.shared)
                .previewDisplayName("기본 화면")
            
            // 데이터 없는 상태
            ActorTemplateListView(repository: TemplateRepository(modelContext: ModelContext(PreviewDataFactory.createEmptyContainer())))
                .environmentObject(DependencyContainer.shared)
                .previewDisplayName("빈 상태")
            
            // 다크 모드
            ActorTemplateListView(repository: repo)
                .environmentObject(DependencyContainer.shared)
                .preferredColorScheme(.dark)
                .previewDisplayName("다크 모드")
        }
    }
} 