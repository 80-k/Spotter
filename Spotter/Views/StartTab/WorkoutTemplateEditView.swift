// WorkoutTemplateEditView.swift
// 운동 계획 템플릿 편집 화면
//  Created by woo on 3/29/25.

import SwiftUI

struct WorkoutTemplateEditView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: WorkoutTemplateListViewModel
    
    @State private var name: String = ""
    
    var template: WorkoutTemplate?
    
    init(viewModel: WorkoutTemplateListViewModel, template: WorkoutTemplate? = nil) {
        self.viewModel = viewModel
        self.template = template
        
        if let template = template {
            self._name = State(initialValue: template.name)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("템플릿 정보")) {
                    TextField("템플릿 이름", text: $name)
                }
            }
            .navigationTitle(template == nil ? "템플릿 추가" : "템플릿 편집")
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
        if let existingTemplate = template {
            // 기존 템플릿 수정
            existingTemplate.name = name
            viewModel.updateTemplate(existingTemplate)
        } else {
            // 새 템플릿 추가
            viewModel.addTemplate(name: name)
        }
    }
}
