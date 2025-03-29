//
//  HistoryListView.swift
//  운동 기록 목록 화면
//
//  Created by woo on 3/29/25.
//

import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HistoryViewModel
    @State private var showingCalendarView = false
    @State private var selectedSession: WorkoutSession?
    
    init(modelContext: ModelContext) {
        self._viewModel = State(initialValue: HistoryViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 세션 목록
                List {
                    if viewModel.sessions.isEmpty {
                        ContentUnavailableView {
                            Label("운동 기록 없음", systemImage: "figure.run.circle")
                        } description: {
                            Text("아직 완료된 운동 기록이 없습니다.\n운동을 시작하고 완료해보세요!")
                        }
                    } else {
                        ForEach(viewModel.sessions) { session in
                            Button(action: {
                                selectedSession = session
                            }) {
                                WorkoutSessionRow(session: session)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let session = viewModel.sessions[index]
                                viewModel.deleteSession(session)
                            }
                        }
                    }
                }
                .navigationTitle("운동 기록")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingCalendarView = true
                        }) {
                            Label("달력", systemImage: "calendar")
                        }
                    }
                }
                .refreshable {
                    viewModel.fetchSessions()
                }
                .sheet(isPresented: $showingCalendarView) {
                    CalendarView(viewModel: viewModel)
                }
                .sheet(item: $selectedSession) { session in
                    WorkoutSessionDetailView(session: session)
                }
                // 운동 완료 알림 수신 시 기록 새로고침
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("WorkoutCompleted"))) { _ in
                    print("운동 완료 알림 수신")
                    viewModel.fetchSessions()
                }
                .onAppear {
                    print("기록 탭 나타남")
                    viewModel.fetchSessions()
                }
            }
        }
    }
}
