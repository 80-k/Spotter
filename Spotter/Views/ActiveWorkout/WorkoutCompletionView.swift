//
//  WorkoutCompletionView.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI
import SwiftData

struct WorkoutCompletionView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더 (트로피 아이콘 및 축하 메시지)
                    CompletionHeaderView()
                    
                    // 통계 정보
                    CompletionStatsView(session: session)
                    
                    // 확인 버튼
                    Button(action: {
                        dismiss()
                        // 부모 뷰도 함께 닫기
                        onDismiss?()
                    }) {
                        Text("확인")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("운동 완료")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                        // 부모 뷰도 함께 닫기
                        onDismiss?()
                    }
                }
            }
        }
    }
}
