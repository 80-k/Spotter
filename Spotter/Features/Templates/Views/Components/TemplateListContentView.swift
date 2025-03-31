// TemplateListContentView.swift
// 템플릿 목록 내용을 표시하는 컴포넌트
// Created by woo on 4/15/25.

import SwiftUI

/// 템플릿 목록 표시를 담당하는 컴포넌트
struct TemplateListContentView<TDataSource: TemplateDataSource, TActionDelegate: TemplateActionDelegate>: View {
    // MARK: - 속성
    
    @ObservedObject var viewModel: TDataSource
    @ObservedObject var actions: TActionDelegate
    
    /// 정렬 및 표시 옵션
    @State private var sortOption: TemplateSortOption = .lastUsed
    @State private var showRecent: Bool = true
    
    // MARK: - 본문
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 최근 사용 템플릿 표시 (조건부)
                if showRecent && !viewModel.recentlyUsedTemplates.isEmpty && actions.searchText.isEmpty {
                    recentTemplatesSection
                }
                
                // 모든 템플릿 목록
                allTemplatesSection
            }
            .padding(.horizontal)
        }
        .animation(.easeInOut, value: viewModel.templates.count)
        .animation(.easeInOut, value: actions.searchText)
        .refreshable {
            await actions.refreshData()
        }
    }
    
    // MARK: - 서브뷰
    
    /// 최근 사용 템플릿 섹션
    private var recentTemplatesSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("최근 사용")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                
                Button {
                    withAnimation { showRecent.toggle() }
                } label: {
                    Image(systemName: "chevron.up")
                        .rotationEffect(.degrees(showRecent ? 0 : 180))
                        .animation(.easeInOut, value: showRecent)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 4)
            
            if showRecent {
                TemplateListSectionView(
                    templates: viewModel.recentlyUsedTemplates,
                    sectionTitle: "",
                    onSelect: { actions.selectAndStartWorkout(template: $0) },
                    onDelete: { actions.requestDeleteTemplate(template: $0) }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.bottom, 8)
    }
    
    /// 모든 템플릿 섹션
    private var allTemplatesSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(actions.searchText.isEmpty ? "모든 템플릿" : "검색 결과")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 정렬 옵션 선택기
                Menu {
                    Picker("정렬", selection: $sortOption) {
                        ForEach(TemplateSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("정렬", systemImage: "arrow.up.arrow.down")
                        .labelStyle(.iconOnly)
                }
            }
            .padding(.bottom, 4)
            
            // 표시할 템플릿 목록이 있으면 목록 표시, 없으면 검색 결과 없음 표시
            if !sortedTemplates.isEmpty {
                TemplateListSectionView(
                    templates: sortedTemplates,
                    sectionTitle: "",
                    onSelect: { actions.selectAndStartWorkout(template: $0) },
                    onDelete: { actions.requestDeleteTemplate(template: $0) }
                )
            } else if !actions.searchText.isEmpty {
                // 검색 결과 없음
                SearchResultView(
                    searchText: actions.searchText,
                    message: "일치하는 템플릿이 없습니다",
                    buttonTitle: "새 템플릿 추가",
                    buttonAction: { actions.showingAddTemplate = true }
                )
            }
        }
    }
    
    // MARK: - 컴퓨티드 프로퍼티
    
    /// 현재 정렬 옵션에 따라 정렬된 템플릿 목록
    private var sortedTemplates: [WorkoutTemplate] {
        // 검색 중이면 기본 템플릿 목록 반환
        if !actions.searchText.isEmpty {
            return viewModel.templates
        }
        
        // 정렬 옵션에 따라 정렬
        switch sortOption {
        case .name:
            return viewModel.templates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .lastUsed:
            return viewModel.templates.sorted { ($0.lastUsed ?? Date.distantPast) > ($1.lastUsed ?? Date.distantPast) }
        case .useCount:
            return viewModel.templates.sorted { $0.useCount > $1.useCount }
        case .created:
            return viewModel.templates.sorted { $0.createDate > $1.createDate }
        }
    }
}

// MARK: - 미리보기

struct TemplateListContentView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewDataFactory.createPreviewContainer()
        let repo = TemplateRepository(modelContext: previewContainer.mainContext)
        let viewModel = ActorTemplateViewModel(repository: repo)
        let actions = TemplateActionsHandler(viewModel: viewModel)
        
        // 샘플 데이터 생성
        viewModel.templates = PreviewDataFactory.createTemplates()
        
        return NavigationStack {
            TemplateListContentView(viewModel: viewModel, actions: actions)
                .padding(.top)
                .navigationTitle("운동 시작")
        }
    }
} 