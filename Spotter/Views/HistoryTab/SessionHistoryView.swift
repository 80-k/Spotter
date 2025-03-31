// SessionHistoryView.swift
// 세션 기록 탭 - 달력 보기와 세션 목록을 포함
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private(set) var viewModel: HistoryViewModel
    @State private var showingCalendarView = false
    @State private var selectedSession: WorkoutSession?
    @State private var showingCalendar = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 달력 뷰 토글 버튼
                HStack {
                    Text(showingCalendar ? "달력 보기" : "전체 세션")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showingCalendar.toggle()
                        }
                    }) {
                        Label(
                            showingCalendar ? "목록 보기" : "달력 보기", 
                            systemImage: showingCalendar ? "list.bullet" : "calendar"
                        )
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if showingCalendar {
                    // 달력 뷰
                    VStack {
                        // 달력 그리드
                        CalendarGridView(
                            viewModel: viewModel,
                            selectedDate: $viewModel.selectedDate
                        )
                        .padding()
                        
                        // 선택한 날짜의 세션 목록
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(dateFormatter.string(from: viewModel.selectedDate)) 운동")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if viewModel.sessionsForDate(viewModel.selectedDate).isEmpty {
                                ContentUnavailableView(
                                    "기록 없음",
                                    systemImage: "calendar.badge.exclamationmark",
                                    description: Text("선택한 날짜에 운동 기록이 없습니다.")
                                )
                                .frame(height: 200)
                            } else {
                                ForEach(viewModel.sessionsForDate(viewModel.selectedDate)) { session in
                                    Button(action: {
                                        selectedSession = session
                                    }) {
                                        WorkoutSessionRow(session: session)
                                            .padding()
                                            .background(cardBackgroundColor)
                                            .cornerRadius(12)
                                            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                } else {
                    // 세션 목록
                    if viewModel.sessions.isEmpty {
                        ContentUnavailableView {
                            Label("운동 기록 없음", systemImage: "figure.run.circle")
                        } description: {
                            Text("아직 완료된 운동 기록이 없습니다.\n운동을 시작하고 완료해보세요!")
                        }
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.sessions) { session in
                                Button(action: {
                                    selectedSession = session
                                }) {
                                    WorkoutSessionRow(session: session)
                                        .padding()
                                        .background(cardBackgroundColor)
                                        .cornerRadius(12)
                                        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteSession(session)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .background(backgroundColor)
        .sheet(item: $selectedSession) { session in
            WorkoutSessionDetailView(session: session)
        }
    }
    
    // 날짜 포맷터
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }
    
    // 배경색 - 다크 모드 대응
    private var backgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.systemBackground)
        default:
            return Color.gray.opacity(0.03)
        }
    }
    
    // 카드 배경색 - 다크 모드 대응
    private var cardBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.secondarySystemBackground)
        default:
            return Color.white
        }
    }
    
    // 그림자 색상 - 다크 모드 대응
    private var shadowColor: Color {
        switch colorScheme {
        case .dark:
            return Color.black.opacity(0.1)
        default:
            return Color.black.opacity(0.03)
        }
    }
}
