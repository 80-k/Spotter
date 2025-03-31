// AsyncTemplateListView.swift
// Swift Concurrency를 활용한 템플릿 목록 화면
// Created by woo on 4/1/25.

import SwiftUI
import SwiftData

struct AsyncTemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.container) private var container
    
    @State private var viewModel: AsyncTemplateListViewModel
    @State private var showingAddTemplate = false
    @State private var activeWorkoutSession: WorkoutSession?
    @State private var navigateToActiveWorkout = false
    @State private var newTemplateName = ""
    
    init(modelContext: ModelContext) {
        let repo = TemplateRepository(modelContext: modelContext)
        self._viewModel = State(initialValue: AsyncTemplateListViewModel(repository: repo))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("템플릿 로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.templates.isEmpty {
                    // 빈 상태 화면
                    emptyStateView
                } else {
                    // 템플릿 목록
                    templateListView
                }
            }
            .navigationTitle("운동 시작")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTemplate = true
                    } label: {
                        Label("템플릿 추가", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToActiveWorkout) {
                if let session = activeWorkoutSession {
                    // ActiveWorkoutView와 연결
                    Text("운동 세션 시작: \(session.template?.name ?? "")")
                }
            }
        }
        .refreshable {
            // 당겨서 새로고침 시 비동기 데이터 로딩
            await viewModel.fetchTemplates()
        }
        .alert("새 템플릿 추가", isPresented: $showingAddTemplate) {
            TextField("템플릿 이름", text: $newTemplateName)
                .autocorrectionDisabled()
            
            Button("취소", role: .cancel) {
                newTemplateName = ""
            }
            
            Button("추가") {
                // 비동기로 템플릿 추가
                Task {
                    if !newTemplateName.isEmpty {
                        await viewModel.addTemplate(name: newTemplateName)
                        newTemplateName = ""
                    }
                }
            }
        }
        .onAppear {
            // DI 컨테이너를 통해 리포지토리 교체
            if let repo = container.templateRepository() {
                viewModel = AsyncTemplateListViewModel(repository: repo)
            }
        }
    }
    
    // 빈 상태 화면
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "list.bullet.clipboard",
            title: "운동 템플릿이 없습니다",
            message: "새로운 운동 템플릿을 만들어 시작하세요",
            buttonTitle: "템플릿 추가",
            buttonIcon: "plus.circle.fill",
            action: { showingAddTemplate = true }
        )
    }
    
    // 템플릿 목록 뷰
    private var templateListView: some View {
        List {
            ForEach(viewModel.templates) { template in
                TemplateRowView(template: template)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigateToTemplateDetail(template)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            // 비동기로 템플릿 삭제
                            Task {
                                await viewModel.deleteTemplate(template)
                            }
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
        .overlay(alignment: .bottom) {
            // 오류 메시지 표시
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: viewModel.errorMessage)
    }
    
    // 템플릿 상세 화면으로 이동
    private func navigateToTemplateDetail(_ template: WorkoutTemplate) {
        // 여기서는 간단하게 운동 세션 바로 시작
        Task {
            if let session = await viewModel.startWorkout(with: template) {
                activeWorkoutSession = session
                navigateToActiveWorkout = true
            }
        }
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: WorkoutTemplate.self)
    
    return AsyncTemplateListView(modelContext: ModelContext(modelContainer))
} 