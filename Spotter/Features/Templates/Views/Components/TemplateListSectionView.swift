// TemplateListSectionView.swift
// 템플릿 목록 섹션 컴포넌트
// Created by woo on 4/1/25.

import SwiftUI
import SwiftData

/// 템플릿 목록의 섹션 컴포넌트
struct TemplateListSectionView: View {
    // MARK: - 프로퍼티
    
    /// 표시할 템플릿 목록
    let templates: [WorkoutTemplate]
    
    /// 섹션 제목
    let title: String
    
    /// 템플릿 선택 시 호출되는 액션
    let onTemplateTap: (WorkoutTemplate) -> Void
    
    /// 템플릿 삭제 시 호출되는 액션 (nil이면 삭제 기능 숨김)
    let onTemplateDelete: ((WorkoutTemplate) -> Void)?
    
    /// 템플릿 편집 시 호출되는 액션 (nil이면 편집 기능 숨김)
    let onTemplateEdit: ((WorkoutTemplate) -> Void)?
    
    /// 내부 상태
    @State private var selectedTemplate: WorkoutTemplate?
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - 초기화
    
    init(
        templates: [WorkoutTemplate],
        title: String,
        onTemplateTap: @escaping (WorkoutTemplate) -> Void,
        onTemplateDelete: ((WorkoutTemplate) -> Void)? = nil,
        onTemplateEdit: ((WorkoutTemplate) -> Void)? = nil
    ) {
        self.templates = templates
        self.title = title
        self.onTemplateTap = onTemplateTap
        self.onTemplateDelete = onTemplateDelete
        self.onTemplateEdit = onTemplateEdit
    }
    
    // MARK: - 뷰 본문
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 섹션 제목이 있는 경우에만 표시
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 4)
            }
            
            // 템플릿 목록
            ForEach(templates) { template in
                templateItem(template)
            }
        }
    }
    
    // MARK: - 서브뷰
    
    /// 개별 템플릿 항목 뷰
    @ViewBuilder
    private func templateItem(_ template: WorkoutTemplate) -> some View {
        templateRow(template)
            .ifLet(onTemplateTap) { view, action in
                view.contentShape(Rectangle())
                    .onTapGesture { action(template) }
            }
            .applySwipeActions(
                onDelete: onTemplateDelete != nil ? { onTemplateDelete?(template) } : nil,
                onEdit: onTemplateEdit != nil ? { onTemplateEdit?(template) } : nil
            )
            .listRowBackground(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .listRowInsets(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
    }
    
    /// 템플릿 행 내용
    private func templateRow(_ template: WorkoutTemplate) -> some View {
        HStack(spacing: 12) {
            // 템플릿 아이콘
            ZStack {
                Circle()
                    .fill(template.category?.color ?? .blue)
                    .frame(width: 44, height: 44)
                
                Image(systemName: template.category?.icon ?? "list.bullet")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // 템플릿 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    // 운동 수
                    Label("\(template.exerciseCount)개 운동", systemImage: "dumbbell.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 사용 횟수
                    if template.useCount > 0 {
                        Label("\(template.useCount)회 사용", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // 마지막 사용 날짜
                    if let lastUsed = template.lastUsed {
                        Text("최근: \(lastUsed.timeAgoDisplay())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // 템플릿 선택 또는 액션 아이콘
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    colorScheme == .dark ? 
                        Color(.systemGray5) : 
                        Color(.systemGray6).opacity(0.5)
                )
        )
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
    }
}

// MARK: - 뷰 확장

extension View {
    /// 삭제/편집 스와이프 액션 적용
    @ViewBuilder
    func applySwipeActions(
        onDelete: (() -> Void)?,
        onEdit: (() -> Void)?
    ) -> some View {
        if #available(iOS 15.0, *) {
            self.swipeActions(edge: .trailing) {
                if let onDelete = onDelete {
                    Button(role: .destructive, action: onDelete) {
                        Label("삭제", systemImage: "trash")
                    }
                }
                
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Label("편집", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
            }
        } else {
            // iOS 15 이전 버전 지원 (필요한 경우)
            self
        }
    }
    
    /// 조건부 클로저 수정자 적용
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - 미리보기

#Preview {
    NavigationStack {
        List {
            // 샘플 템플릿으로 미리보기
            let template1 = WorkoutTemplate(name: "상체 운동")
            let template2 = WorkoutTemplate(name: "하체 운동")
            let template3 = WorkoutTemplate(name: "전신 운동")
            
            // 운동 추가
            let exercise1 = ExerciseItem(name: "벤치 프레스", category: "가슴")
            let exercise2 = ExerciseItem(name: "스쿼트", category: "하체")
            
            template1.addExercise(exercise1, sets: 3)
            template2.addExercise(exercise2, sets: 4)
            template1.lastUsed = Date()
            
            // 전체 템플릿 섹션
            TemplateListSectionView(
                templates: [template1, template2, template3],
                title: "모든 템플릿",
                onTemplateTap: { _ in },
                onTemplateDelete: { _ in },
                onTemplateEdit: { _ in }
            )
            
            // 최근 사용 섹션 (삭제/편집 없음)
            TemplateListSectionView(
                templates: [template1],
                title: "최근 사용",
                onTemplateTap: { _ in }
            )
        }
        .listStyle(.insetGrouped)
        .navigationTitle("템플릿")
    }
} 