//
//  ExerciseDetailView.swift
//  Spotter
//
//  Created by woo on 3/31/25.
//

import SwiftUI

struct ExerciseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: ExerciseItem
    
    var body: some View {
        Form {
            Section(header: Text("운동 정보")) {
                HStack {
                    Text("이름")
                    Spacer()
                    Text(exercise.name)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("운동 부위")
                    Spacer()
                    Text(exercise.muscleGroup)
                        .foregroundColor(.secondary)
                }
            }
            
            if !exercise.exerciseDescription.isEmpty {
                Section(header: Text("상세 설명")) {
                    Text(exercise.exerciseDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    dismiss()
                }
            }
        }
    }
}
