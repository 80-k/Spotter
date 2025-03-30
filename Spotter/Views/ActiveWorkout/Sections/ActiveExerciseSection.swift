//
//  ActiveExerciseSection.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct ActiveExerciseSection: View {
    var viewModel: ActiveWorkoutViewModel
    
    var body: some View {
        if let activeExercise = viewModel.currentActiveExercise {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundColor(.blue)
                    Text("현재 진행 중")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                WorkoutExerciseSection(
                    viewModel: viewModel,
                    exercise: activeExercise,
                    isActive: true
                )
                .padding(.horizontal)
            }
            .padding(.bottom, 12)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)
            .transition(.opacity.combined(with: .scale))
        }
    }
}
