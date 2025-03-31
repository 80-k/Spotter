// TemplateDialogs.swift
// 템플릿 관련 다이얼로그 컴포넌트
// Created by woo on 4/16/25.

import SwiftUI

/// 템플릿 관련 다이얼로그를 제공하는 뷰 수정자
struct TemplateDialogModifiers: ViewModifier {
    @ObservedObject var actions: TemplateActionDelegate
    
    func body(content: Content) -> some View {
        content
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

/// 템플릿 관련 오류 표시 컴포넌트
struct TemplateErrorOverlay<T: TemplateDataSource>: View {
    @ObservedObject var viewModel: T
    
    var body: some View {
        ZStack {
            if let error = viewModel.error {
                ErrorBannerView(
                    error: error,
                    onDismiss: { viewModel.clearError() }
                )
            }
        }
    }
}

// MARK: - 뷰 확장

extension View {
    /// 템플릿 다이얼로그 추가
    func withTemplateDialogs<T: TemplateActionDelegate>(_ actions: T) -> some View {
        self.modifier(TemplateDialogModifiers(actions: actions))
    }
    
    /// 네비게이션 도구 모음 추가
    func templateNavigationTools<T: TemplateActionDelegate, U: TemplateDataSource>(
        actions: T,
        viewModel: U
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
} 