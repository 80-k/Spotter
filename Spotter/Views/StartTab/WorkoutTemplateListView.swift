//
//  WorkoutTemplateListView.swift
//  수정된 템플릿 목록 화면 - 네비게이션 문제 해결
//  Created by woo on 3/31/25.
//

import SwiftUI
import SwiftData

// 템플릿 행 컴포넌트 - 리스트 아이템용 별도 뷰
struct TemplateRowView: View {
    var template: WorkoutTemplate
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(template.name)
                    .font(.headline)
                
                if let exercises = template.exerciseItems, !exercises.isEmpty {
                    Text("\(exercises.count)개 운동")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("운동 없음")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .contentShape(Rectangle())
    }
}

struct WorkoutTemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WorkoutTemplateListViewModel
    @State private var showingAddTemplate = false
    @State private var activeWorkoutSession: WorkoutSession?
    @State private var selectedTemplate: WorkoutTemplate? = nil
    
    init(modelContext: ModelContext) {
        self._viewModel = State(initialValue: WorkoutTemplateListViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.templates) { template in
                    Button {
                        selectedTemplate = template
                    } label: {
                        TemplateRowView(template: template)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let template = viewModel.templates[index]
                        viewModel.deleteTemplate(template)
                    }
                }
            }
            .navigationTitle("운동 시작")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTemplate = true
                    }) {
                        Label("템플릿 추가", systemImage: "plus")
                    }
                }
            }
            .refreshable {
                viewModel.fetchTemplates()
            }
            .sheet(isPresented: $showingAddTemplate) {
                WorkoutTemplateEditView(viewModel: viewModel)
            }
            .fullScreenCover(item: $activeWorkoutSession) { session in
                ActiveWorkoutView(
                    session: session,
                    modelContext: modelContext
                )
            }
            .sheet(item: $selectedTemplate) { template in
                NavigationStack {
                    WorkoutTemplateDetailView(
                        template: template,
                        viewModel: viewModel
                    ) { session in
                        selectedTemplate = nil
                        activeWorkoutSession = session
                    }
                }
            }
        }
    }
}
