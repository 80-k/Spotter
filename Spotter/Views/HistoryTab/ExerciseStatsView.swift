// ExerciseStatsView.swift
// 운동 통계 탭 - 운동별 통계 정보를 표시
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData
import Charts

struct ExerciseStatsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private(set) var viewModel: HistoryViewModel
    @State private var selectedExercise: ExerciseItem?
    @State private var timeRange: TimeRange = .month
    
    enum TimeRange: String, CaseIterable {
        case week = "주간"
        case month = "월간"
        case year = "연간"
        case all = "전체"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 운동 통계 위젯
                WorkoutStatisticsWidget(
                    totalWorkouts: viewModel.totalWorkouts,
                    streakDays: viewModel.streakDays,
                    totalDuration: viewModel.totalDuration,
                    averageWorkoutTime: viewModel.averageWorkoutTime
                )
                .padding(.horizontal)
                
                // 기간 선택 세그먼트
                Picker("기간", selection: $timeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // 운동 부위별 통계
                VStack(alignment: .leading, spacing: 8) {
                    Text("부위별 운동 비율")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.sessions.isEmpty {
                        ContentUnavailableView {
                            Label("통계 데이터 없음", systemImage: "chart.pie")
                        } description: {
                            Text("아직 완료된 운동 기록이 없습니다.\n운동을 시작하고 완료해보세요!")
                        }
                        .frame(height: 200)
                    } else {
                        MuscleGroupPieChartView(viewModel: viewModel, timeRange: timeRange)
                            .frame(height: 250)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                
                // 가장 많이 한 운동 Top 5
                VStack(alignment: .leading, spacing: 8) {
                    Text("가장 많이 한 운동 Top 5")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.sessions.isEmpty {
                        ContentUnavailableView {
                            Label("통계 데이터 없음", systemImage: "chart.bar")
                        } description: {
                            Text("아직 완료된 운동 기록이 없습니다.")
                        }
                        .frame(height: 150)
                    } else {
                        TopExercisesChartView(viewModel: viewModel, timeRange: timeRange)
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                
                // 운동 볼륨 추이
                VStack(alignment: .leading, spacing: 8) {
                    Text("운동 볼륨 추이")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.sessions.isEmpty {
                        ContentUnavailableView {
                            Label("통계 데이터 없음", systemImage: "chart.line.uptrend.xyaxis")
                        } description: {
                            Text("아직 완료된 운동 기록이 없습니다.")
                        }
                        .frame(height: 150)
                    } else {
                        VolumeProgressChartView(viewModel: viewModel, timeRange: timeRange)
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        .background(backgroundColor)
        .sheet(item: $selectedExercise) { exercise in
            ExerciseStatsDetailView(exercise: exercise, viewModel: viewModel)
        }
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

// 부위별 운동 비율 차트
struct MuscleGroupPieChartView: View {
    var viewModel: HistoryViewModel
    let timeRange: ExerciseStatsView.TimeRange
    
    var body: some View {
        // 여기에 실제 차트 구현 (SwiftUI Charts 사용)
        Text("부위별 운동 비율 차트가 표시됩니다")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

// 가장 많이 한 운동 Top 5 차트
struct TopExercisesChartView: View {
    var viewModel: HistoryViewModel
    let timeRange: ExerciseStatsView.TimeRange
    
    var body: some View {
        // 여기에 실제 차트 구현 (SwiftUI Charts 사용)
        Text("가장 많이 한 운동 Top 5 차트가 표시됩니다")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

// 운동 볼륨 추이 차트
struct VolumeProgressChartView: View {
    var viewModel: HistoryViewModel
    let timeRange: ExerciseStatsView.TimeRange
    
    var body: some View {
        // 여기에 실제 차트 구현 (SwiftUI Charts 사용)
        Text("운동 볼륨 추이 차트가 표시됩니다")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

// 운동 통계 상세 뷰
struct ExerciseStatsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: ExerciseItem
    var viewModel: HistoryViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("\(exercise.name) 운동 통계")
                        .font(.headline)
                    
                    // 여기에 운동별 상세 통계 추가
                    Text("운동별 상세 통계가 표시됩니다")
                }
                .padding()
            }
            .navigationTitle("운동 통계")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}
