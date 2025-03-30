//
//  WorkoutTemplateListView.swift
//  Spotter - 최신 SwiftUI 네비게이션 API 활용
//
//  Created by woo on 3/31/25.
//

import SwiftUI
import SwiftData

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
                    NavigationLink(value: template) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(template.name)
                                .font(.headline)
                            
                            if let exercises = template.exercises, !exercises.isEmpty {
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
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let template = viewModel.templates[index]
                        viewModel.deleteTemplate(template)
                    }
                }
            }
            .navigationTitle("운동 시작")
            .navigationDestination(for: WorkoutTemplate.self) { template in
                WorkoutTemplateDetailView(
                    template: template,
                    viewModel: viewModel
                ) { session in
                    activeWorkoutSession = session
                }
            }
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
        }
    }
}
