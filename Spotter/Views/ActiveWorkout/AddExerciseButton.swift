//
//  AddExerciseButton.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct AddExerciseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                Text("운동 추가")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

#Preview {
    AddExerciseButton(action: {})
        .padding()
}
