// TemplateListView.swift
// 템플릿 목록 제공 뷰
// Created by woo on 4/18/25.

import SwiftUI

/// 템플릿 목록 표시 뷰
///
/// 프로토콜 기반 데이터 소스와 액션 핸들러를 통해
/// 템플릿 목록을 표시하고 상호작용을 관리합니다.
struct TemplateListView<
    DataSource: TemplateDataSource,
    ActionHandler: TemplateActionDelegate
>: View, TemplateViewComponent {
    // MARK: - TemplateViewComponent 구현
    
    typealias DataSourceType = DataSource
    typealias ActionType = ActionHandler
    
    @ObservedObject var viewModel: DataSource
    @ObservedObject var actions: ActionHandler
    
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
                .toolbar {
                    toolbarItems
                }
                .searchable(text: $actions.searchText, prompt: "템플릿 검색")
                .refreshable {
                    await refresh()
                }
        }
        .onAppear {
            initialize()
        }
        // 템플릿 추가 다이얼로그
        .confirmationDialog(
            "새 템플릿 추가",
            isPresented: $actions.isShowingAddDialog,
            titleVisibility: .visible
        ) {
            Button("빈 템플릿 생성") {
                actions.addTemplate()
            }
            Button("취소", role: .cancel) {
                actions.cancelDialogs()
            }
        }
        // 템플릿 삭제 확인 다이얼로그
        .alert(
            "템플릿 삭제",
            isPresented: $actions.isShowingDeleteConfirmation,
            actions: {
                Button("삭제", role: .destructive) {
                    actions.confirmDeleteTemplate()
                }
                Button("취소", role: .cancel) {
                    actions.cancelDialogs()
                }
            },
            message: {
                if let template = actions.selectedTemplate {
                    Text("\(template.name) 템플릿을 삭제하시겠습니까?")
                } else {
                    Text("선택한 템플릿을 삭제하시겠습니까?")
                }
            }
        )
        // 오류 표시
        .errorView(
            content: { EmptyView() },
            retryAction: { 
                Task { await refresh() }
            }
        )
    }
    
    // MARK: - 하위 뷰
    
    /// 메인 콘텐츠 뷰
    @ViewBuilder
    private var contentView: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView(message: "템플릿 불러오는 중...")
            } else if viewModel.templates.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    title: "템플릿 없음",
                    message: "새 템플릿을 추가하여 시작하세요",
                    systemImage: "dumbbell",
                    actionTitle: "템플릿 추가",
                    action: { showAddDialog() }
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // 최근 사용 섹션
                        if !viewModel.recentlyUsedTemplates.isEmpty {
                            TemplateListSectionView(
                                title: "최근 사용",
                                templates: viewModel.recentlyUsedTemplates,
                                onTemplateSelect: { template in
                                    actions.selectTemplate(template)
                                },
                                onDelete: { template in
                                    actions.requestDeleteTemplate(template)
                                },
                                onEdit: { template in
                                    actions.editTemplate(template)
                                }
                            )
                        }
                        
                        // 모든 템플릿 섹션
                        TemplateListSectionView(
                            title: "모든 템플릿",
                            templates: viewModel.templates,
                            onTemplateSelect: { template in
                                actions.selectTemplate(template)
                            },
                            onDelete: { template in
                                actions.requestDeleteTemplate(template)
                            },
                            onEdit: { template in
                                actions.editTemplate(template)
                            }
                        )
                    }
                    .padding(.horizontal)
                }
            }
        }
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
    
    /// 새 템플릿 다이얼로그 표시
    private func showAddDialog() {
        actions.showAddDialog()
    }
    
    /// 데이터 새로고침
    private func refresh() async {
        let result = await operationHelper.execute {
            try await viewModel.refreshTemplates()
        }
        
        // 오류 처리는 operationHelper 내부에서 자동 처리됨
        if result.error != nil {
            // 추가 오류 처리 로직이 필요하면 여기에 작성
        }
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

// MARK: - 프리뷰

#Preview {
    let container = DependencyContainer.testContainer()
    return TemplateListView(provider: container)
        .environmentObject(SpotterEnvironment.shared)
} 