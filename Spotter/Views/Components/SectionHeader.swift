//
//  SectionHeader.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

// 파일 시작 부분에 추가
struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            Spacer()
        }
        .padding(.top, 8)
    }
}
