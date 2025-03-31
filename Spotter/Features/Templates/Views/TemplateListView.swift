// TemplateListView.swift
// 템플릿 목록 제공 뷰
// Created by woo on 4/19/25.

import SwiftUI

/// 템플릿 목록 표시 뷰
///
/// 프로토콜 기반 데이터 소스와 액션 핸들러를 통해
/// 템플릿 목록을 표시하고 상호작용을 관리합니다.
struct TemplateListView<
    ModelType: TemplateDataSource,
    ActionType: TemplateActionDelegate
>: View, TemplateViewComponent {
    // MARK: - TemplateViewComponent 구현
    
    typealias DataSourceType = ModelType
    typealias ActionType = ActionType
    
    @ObservedObject var viewModel: ModelType
    @ObservedObject var actions: ActionType
    
    // MARK: - 속성
    
    /// 오류 핸들링 서비스
    @EnvironmentObject private var environment: SpotterEnvironment
    
    /// 비동기 작업 관리
    @StateObject private var operationHelper = AsyncOperationHelper()
    
    /// 검색 시 애니메이션 설정
    private let searchAnimation = Animation.easeInOut(duration: 0.3)
    
    // MARK: - 뷰 본문
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("운동 템플릿")
                .toolbar { toolbarItems }
                .searchable(text: $actions.searchText, prompt: "템플릿 검색")
                .refreshable { await refresh() }
        }
        .onAppear { initialize() }
        .withTemplateDialogs(actions)
        .withErrorHandling(viewModel.currentError) { 
            Task { await refresh() }
        }
    }
    
    // MARK: - 하위 뷰 컴포넌트
    
    /// 메인 콘텐츠 뷰
    @ViewBuilder
    private var contentView: some View {
        ZStack {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.templates.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                templateListContent
            }
        }
    }
    
    /// 로딩 표시 뷰
    @ViewBuilder
    private var loadingView: some View {
        LoadingView(message: "템플릿 불러오는 중...")
    }
    
    /// 빈 상태 표시 뷰
    @ViewBuilder
    private var emptyStateView: some View {
        EmptyStateView(
            title: "템플릿 없음",
            message: "새 템플릿을 추가하여 시작하세요",
            systemImage: "dumbbell",
            actionTitle: "템플릿 추가",
            action: { showAddDialog() }
        )
    }
    
    /// 템플릿 목록 콘텐츠
    @ViewBuilder
    private var templateListContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                recentTemplatesSection
                allTemplatesSection
            }
            .padding(.horizontal)
        }
    }
    
    /// 최근 사용 템플릿 섹션
    @ViewBuilder
    private var recentTemplatesSection: some View {
        if !viewModel.recentlyUsedTemplates.isEmpty {
            TemplateListSectionView(
                title: "최근 사용",
                templates: viewModel.recentlyUsedTemplates,
                onTemplateSelect: { actions.selectTemplate($0) },
                onDelete: { actions.requestDeleteTemplate($0) },
                onEdit: { actions.editTemplate($0) }
            )
        }
    }
    
    /// 모든 템플릿 섹션
    @ViewBuilder
    private var allTemplatesSection: some View {
        TemplateListSectionView(
            title: "모든 템플릿",
            templates: viewModel.templates,
            onTemplateSelect: { actions.selectTemplate($0) },
            onDelete: { actions.requestDeleteTemplate($0) },
            onEdit: { actions.editTemplate($0) }
        )
    }
    
    /// 툴바 아이템
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showAddDialog() }) {
                Image(systemName: "plus")
            }
        }
    }
    
    // MARK: - 액션 메서드
    
    /// 초기화 (프로토콜 구현)
    func initialize() {
        if viewModel.templates.isEmpty && !viewModel.isLoading {
            Task {
                await refresh()
            }
        }
    }
    
    /// 데이터 새로고침 (프로토콜 구현)
    func refresh() async {
        let result = await operationHelper.execute {
            try await viewModel.refreshTemplates()
        }
    }
    
    /// 템플릿 추가 다이얼로그 표시 (프로토콜 구현)
    func showAddDialog() {
        actions.showAddDialog()
    }
}

// MARK: - 초기화 익스텐션

extension TemplateListView {
    /// 더 간편한 초기화를 위한 편의 생성자
    init(provider: ViewModelProvider) {
        let viewModel = provider.templateViewModel()
        let actions = provider.createTemplateActionsHandler(for: viewModel)
        self.init(viewModel: viewModel, actions: actions)
    }
}

// MARK: - 뷰 수정자 확장

extension View {
    /// 템플릿 다이얼로그 수정자
    func withTemplateDialogs(_ actions: TemplateActionDelegate) -> some View {
        self
            .confirmationDialog(
                "새 템플릿 추가",
                isPresented: .init(
                    get: { actions.isShowingAddDialog },
                    set: { if !$0 { actions.cancelDialogs() } }
                ),
                titleVisibility: .visible
            ) {
                Button("빈 템플릿 생성") { actions.addTemplate() }
                Button("취소", role: .cancel) { actions.cancelDialogs() }
            }
            .alert(
                "템플릿 삭제",
                isPresented: .init(
                    get: { actions.isShowingDeleteConfirmation },
                    set: { if !$0 { actions.cancelDialogs() } }
                ),
                actions: {
                    Button("삭제", role: .destructive) { actions.confirmDeleteTemplate() }
                    Button("취소", role: .cancel) { actions.cancelDialogs() }
                },
                message: {
                    if let template = actions.selectedTemplate {
                        Text("\(template.name) 템플릿을 삭제하시겠습니까?")
                    } else {
                        Text("선택한 템플릿을 삭제하시겠습니까?")
                    }
                }
            )
    }
    
    /// 오류 처리 수정자
    func withErrorHandling(_ error: Error?, retryAction: @escaping () -> Void) -> some View {
        self.overlay {
            if let error = error {
                ErrorBannerView(
                    error: error,
                    onDismiss: { /* 오류 지우기 */ },
                    retryAction: retryAction
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: error != nil)
            }
        }
    }
}

// MARK: - 프리뷰

#Preview {
    let container = DependencyContainer.testContainer()
    return TemplateListView(provider: container)
        .environmentObject(SpotterEnvironment.shared)
} 