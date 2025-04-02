//
//  CalendarView.swift
//  Spotter
//
//  Created by woo on 3/29/25.
//

import SwiftUI

// CalendarView 전체는 SessionHistoryView로 기능이 통합되어 
// 사용되지 않는 것으로 보입니다. CalendarGridView만 유지합니다.
// 이전 코드는 주석 처리하여 필요시 참조할 수 있도록 합니다.

/*
struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: HistoryViewModel
    @State private var selectedDate = Date()
    @State private var selectedSession: WorkoutSession?
    
    init(viewModel: HistoryViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 달력 뷰
                CalendarGridView(
                    viewModel: viewModel,
                    selectedDate: $selectedDate
                )
                .padding()
                
                // 선택한 날짜의 세션 목록
                List {
                    ForEach(viewModel.sessionsForDate(selectedDate)) { session in
                        Button(action: {
                            selectedSession = session
                        }) {
                            WorkoutSessionRow(session: session)
                        }
                    }
                }
                .overlay {
                    if viewModel.sessionsForDate(selectedDate).isEmpty {
                        ContentUnavailableView(
                            "기록 없음",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("선택한 날짜에 운동 기록이 없습니다.")
                        )
                    }
                }
            }
            .navigationTitle("달력")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedSession) { session in
                WorkoutSessionDetailView(session: session)
            }
        }
    }
}
*/

struct CalendarGridView: View {
    let viewModel: HistoryViewModel
    @Binding var selectedDate: Date
    
    @State private var currentMonth = Date()
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let days = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        VStack {
            // 월 선택기
            HStack {
                Button(action: {
                    if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
                        currentMonth = newMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearFormatter.string(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
                        currentMonth = newMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // 요일 헤더
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 달력 그리드
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        Button(action: {
                            selectedDate = date
                        }) {
                            VStack {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 14))
                                
                                // 운동 세션이 있는 날은 표시
                                if viewModel.hasSessionsForDate(date) {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 6, height: 6)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .frame(width: 32, height: 32)
                            .background(isSelected(date) ? Color.blue.opacity(0.3) : Color.clear)
                            .cornerRadius(16)
                        }
                    } else {
                        // 빈 셀
                        Text("")
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
    }
    
    // 현재 월의 날짜 배열 생성
    func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        
        // 현재 월의 시작일
        guard let monthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: currentMonth)
        ) else {
            return []
        }
        
        // 현재 월의 마지막 날
        guard let monthEnd = calendar.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: monthStart
        ) else {
            return []
        }
        
        // 총 일수
        let daysInMonth = calendar.component(.day, from: monthEnd)
        
        // 첫 번째 날의 요일 (0: 일요일, 1: 월요일, ...)
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        
        var days = [Date?]()
        
        // 시작 요일 전 빈칸 추가
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        
        // 각 날짜 추가
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        
        return days
    }
    
    // 선택된 날짜인지 확인
    private func isSelected(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    // 월/년 포맷터
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()
}
