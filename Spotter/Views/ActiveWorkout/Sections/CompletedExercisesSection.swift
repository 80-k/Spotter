//
//  CompletedExercisesSection.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct CompletedExercisesSection: View {
    var viewModel: ActiveWorkoutViewModel
    
    var body: some View {
        if !viewModel.completedExercises.isEmpty {
            SectionHeader(
                title: "완료된 운동",
                icon: "checkmark.circle.fill",
                color: .green
            )
            .padding(.horizontal)
            .padding(.top, 8)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.completedExercises) { exercise in
                    CompletedExerciseSectionView(
                        viewModel: viewModel,
                        exercise: exercise
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
}
