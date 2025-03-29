//
//  WorkoutExerciseHeader.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

// 운동 헤더 컴포넌트
struct WorkoutExerciseHeader: View {
    let exerciseName: String
    let onRestTimeChange: (TimeInterval) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(exerciseName)
                .font(.headline)
            
            Spacer()
            
            // 컨텍스트 메뉴 버튼 추가
            Menu {
                // 휴식 시간 변경 메뉴
                Menu("휴식 시간 설정") {
                    Button("30초") { onRestTimeChange(30) }
                    Button("60초") { onRestTimeChange(60) }
                    Button("90초") { onRestTimeChange(90) }
                    Button("120초") { onRestTimeChange(120) }
                }
                
                Divider()
                
                // 운동 삭제 버튼
                Button(role: .destructive, action: onDelete) {
                    Label("운동 삭제", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
