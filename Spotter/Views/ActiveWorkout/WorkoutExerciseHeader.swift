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
    var onMoveUp: (() -> Void)? = nil
    var onMoveDown: (() -> Void)? = nil
    
    @State private var showingRestTimeInfo: Bool = false
    
    var body: some View {
        HStack {
            // 운동 이름 표시
            HStack(spacing: 4) {
                if exerciseName.isEmpty {
                    Text("운동")
                        .font(.headline)
                        .italic()
                        .foregroundColor(.secondary)
                } else {
                    Text(exerciseName)
                        .font(.headline)
                }
            }
            
            Spacer()
            
            // 컨텍스트 메뉴 버튼 추가
            Menu {
                // 순서 변경 메뉴 추가
                if onMoveUp != nil || onMoveDown != nil {
                    Menu("순서 변경") {
                        if let moveUp = onMoveUp {
                            Button(action: moveUp) {
                                Label("위로 이동", systemImage: "arrow.up")
                            }
                        }
                        
                        if let moveDown = onMoveDown {
                            Button(action: moveDown) {
                                Label("아래로 이동", systemImage: "arrow.down")
                            }
                        }
                    }
                    
                    Divider()
                }
                
                // 휴식 시간 변경 메뉴
                Menu("휴식 시간 설정") {
                    Button("30초") { onRestTimeChange(30) }
                    Button("60초") { onRestTimeChange(60) }
                    Button("90초") { onRestTimeChange(90) }
                    Button("120초") { onRestTimeChange(120) }
                    Button("180초") { onRestTimeChange(180) }
                }
                
                // 휴식 시간 정보 표시 버튼
                Button("휴식 시간 정보") {
                    showingRestTimeInfo = true
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
        .alert("휴식 시간이란?", isPresented: $showingRestTimeInfo) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("세트 완료 후 표시되는 타이머의 시간입니다. 모든 세트에 동일하게 적용됩니다. 적절한 휴식은 운동 효과를 높이는 데 중요합니다.")
        }
    }
}
