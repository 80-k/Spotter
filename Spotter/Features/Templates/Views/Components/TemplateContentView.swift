// TemplateContentView.swift
// 템플릿 콘텐츠 영역 컴포넌트
// Created by woo on 4/16/25.

import SwiftUI

/// ActorTemplateListView의 메인 콘텐츠 영역을 담당하는 컴포넌트
struct TemplateContentView<TDataSource: TemplateDataSource & OperationStateReporting, TActions: TemplateActionDelegate>: View {
    // MARK: - 속성
    
    @ObservedObject var viewModel: TDataSource
    @ObservedObject var actions: TActions
    
    // MARK: - 본문
    
    var body: some View {
        ZStack {
            // ViewState 기반의 콘텐츠 표시 로직
            TemplateListContent(viewModel: viewModel, actions: actions)
                .withTemplateState(
                    viewModel: viewModel,
                    loading: { LoadingView.fullScreen(message: "템플릿 로딩 중...") },
                    empty: { EmptyTemplateView(actions: actions) },
                    error: { error in
                        ErrorView(
                            error: error,
                            retryAction: { viewModel.loadTemplates() }
                        )
                    }
                )
            
            // 진행 중인 작업 표시기
            if viewModel.pendingOperationsCount > 0 {
                OperationsIndicatorView(count: viewModel.pendingOperationsCount)
            }
        }
        .onChange(of: actions.searchText) { _, _ in
            actions.searchTemplates()
        }
    }
}

/// 템플릿 목록을 표시하는 컴포넌트 (정상 데이터 상태)
struct TemplateListContent<TDataSource: TemplateDataSource, TActions: TemplateActionDelegate>: View {
    @ObservedObject var viewModel: TDataSource
    @ObservedObject var actions: TActions
    
    var body: some View {
        TemplateListContentView(viewModel: viewModel, actions: actions)
    }
}

/// 빈 템플릿 상태 뷰 컴포넌트
struct EmptyTemplateView<TActions: TemplateActionDelegate>: View {
    @ObservedObject var actions: TActions
    
    var body: some View {
        EmptyStateView(
            icon: "list.bullet.clipboard",
            title: "운동 템플릿이 없습니다",
            message: "새로운 운동 템플릿을 만들어 나만의 운동 계획을 세워보세요.",
            buttonTitle: "템플릿 추가",
            buttonIcon: "plus.circle.fill",
            action: { actions.showingAddTemplate = true }
        )
    }
}

// MARK: - 도구 모음 수정자

extension View {
    /// 템플릿 화면 표준 도구 모음 추가
    func templateNavigationTools<TActions: TemplateActionDelegate, TDataSource: TemplateDataSource>(
        actions: TActions,
        viewModel: TDataSource
    ) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    actions.showingAddTemplate = true
                } label: {
                    Label("템플릿 추가", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.refreshCache()
                } label: {
                    Label("새로고침", systemImage: "arrow.clockwise")
                }
            }
        }
    }
    
    /// 템플릿 관련 다이얼로그 수정자
    func withTemplateDialogs(_ actions: TemplateActionsHandler) -> some View {
        self
            // 템플릿 추가 다이얼로그
            .alert("새 템플릿 추가", isPresented: $actions.showingAddTemplate) {
                TextField("템플릿 이름", text: $actions.newTemplateName)
                    .autocorrectionDisabled()
                
                Button("취소", role: .cancel) {
                    actions.cancelDialog()
                }
                
                Button("추가") {
                    actions.addTemplate()
                }
            }
            // 템플릿 삭제 확인 다이얼로그
            .confirmationDialog(
                "정말 삭제하시겠습니까?",
                isPresented: $actions.showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("삭제", role: .destructive) {
                    actions.confirmDeleteTemplate()
                }
                Button("취소", role: .cancel) { 
                    actions.cancelDialog()
                }
            } message: {
                Text("이 템플릿과 관련된 운동 데이터는 남아있지만, 템플릿은 영구적으로 삭제됩니다.")
            }
    }
}

// MARK: - 오류 표시 오버레이

/// 템플릿 화면의 오류 표시 컴포넌트
struct TemplateErrorOverlay<TDataSource: TemplateDataSource>: View {
    @ObservedObject var viewModel: TDataSource
    
    var body: some View {
        if let error = viewModel.error {
            ErrorBannerView(
                error: error,
                onDismiss: { viewModel.clearError() }
            )
        }
    }
}

// MARK: - 작업 진행 표시기

/// 진행 중인 백그라운드 작업 표시 컴포넌트
struct OperationsIndicatorView: View {
    let count: Int
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("\(count)개 작업 진행 중")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.8))
                    )
                    .padding(.trailing)
                    .padding(.bottom)
            }
        }
    }
}

// MARK: - 미리보기

struct TemplateContentView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewDataFactory.createPreviewContainer()
        let repo = TemplateRepository(modelContext: previewContainer.mainContext)
        let viewModel = ActorTemplateViewModel(repository: repo)
        let actions = TemplateActionsHandler(viewModel: viewModel)
        
        // 샘플 데이터 생성
        PreviewDataFactory.populatePreviewContext(previewContainer.mainContext)
        
        return NavigationStack {
            TemplateContentView(viewModel: viewModel, actions: actions)
                .navigationTitle("운동 시작")
        }
    }
} 