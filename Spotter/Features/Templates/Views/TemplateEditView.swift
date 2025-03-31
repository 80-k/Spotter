// TemplateEditView.swift
// 템플릿 편집 화면
// Created by woo on 4/1/25.

import SwiftUI
import SwiftData

struct TemplateEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String
    let template: WorkoutTemplate
    
    // 콜백
    var onSave: (WorkoutTemplate) -> Void
    
    init(template: WorkoutTemplate, onSave: @escaping (WorkoutTemplate) -> Void) {
        self.template = template
        self._name = State(initialValue: template.name)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("템플릿 정보")) {
                    TextField("템플릿 이름", text: $name)
                }
            }
            .navigationTitle("템플릿 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveTemplate()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveTemplate() {
        template.name = name
        
        do {
            try modelContext.save()
            onSave(template)
        } catch {
            print("템플릿 저장 중 오류 발생: \(error)")
        }
    }
} 