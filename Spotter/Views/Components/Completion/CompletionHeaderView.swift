//
//  CompletionHeaderView.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct CompletionHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // 축하 메시지
            Text("운동 완료!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.blue)
            
            // 트로피 아이콘
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
                .padding()
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 150, height: 150)
                )
            
            // 저장 완료 표시
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("운동 기록이 저장되었습니다")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
    }
}
