// TemplateViewComponents.swift
// 템플릿 관련 재사용 뷰 컴포넌트
// Created by woo on 4/18/25.

import SwiftUI

// MARK: - 로딩 뷰

/// 로딩 상태를 표시하는 뷰
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 빈 상태 뷰

/// 데이터가 없을 때 표시하는 빈 상태 뷰
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 오류 배너 뷰

/// 오류 표시 배너 뷰
struct ErrorBannerView: View {
    let error: Error
    let onDismiss: () -> Void
    var retryAction: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                    
                    Text("오류 발생")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                if let retryAction = retryAction {
                    Button(action: retryAction) {
                        Text("다시 시도")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(Color.red.opacity(0.9))
            .cornerRadius(12)
            .shadow(radius: 5)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - 템플릿 카드 뷰

/// 템플릿을 카드 형태로 표시하는 뷰
struct TemplateCardView: View {
    let template: WorkoutTemplate
    var onSelect: ((WorkoutTemplate) -> Void)? = nil
    
    var body: some View {
        Button(action: { onSelect?(template) }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(template.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let lastUsed = template.lastUsedDate {
                        Text(lastUsed.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let exercises = template.exercises, !exercises.isEmpty {
                    Text("\(exercises.count) 운동")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("운동 없음")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 프리뷰

#Preview("로딩 뷰") {
    LoadingView(message: "데이터 로딩 중...")
}

#Preview("빈 상태 뷰") {
    EmptyStateView(
        title: "템플릿 없음",
        message: "새 템플릿을 추가하여 시작하세요",
        systemImage: "dumbbell",
        actionTitle: "템플릿 추가",
        action: {}
    )
}

#Preview("오류 배너") {
    ErrorBannerView(
        error: NSError(domain: "com.example", code: 404, userInfo: [NSLocalizedDescriptionKey: "서버에 연결할 수 없습니다"]),
        onDismiss: {},
        retryAction: {}
    )
}

#Preview("템플릿 카드") {
    TemplateCardView(
        template: PreviewDataFactory.createSampleTemplate(),
        onSelect: { _ in }
    )
} 