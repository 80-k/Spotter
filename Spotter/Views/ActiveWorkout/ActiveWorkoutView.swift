// ActiveWorkoutView.swift
// 활성 운동 세션 실행 화면
//  Created by woo on 3/29/25.

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var viewModel: ActiveWorkoutViewModel
    @State private var showingExerciseSelector = false
    @State private var showCompletionAlert = false
    @State private var showCancelAlert = false
    @State private var showingCompletionView = false
    @State private var completedSession: WorkoutSession?
    
    init(session: WorkoutSession, modelContext: ModelContext) {
        self._viewModel = State(initialValue: ActiveWorkoutViewModel(modelContext: modelContext, session: session))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단 헤더
                WorkoutHeaderView(
                    elapsedTime: viewModel.elapsedTime,
                    onCancel: { showCancelAlert = true },
                    onComplete: { showCompletionAlert = true }
                )
                
                // 휴식 타이머 섹션
                if viewModel.restTimerActive, let activeExercise = viewModel.currentActiveExercise {
                    ActiveRestTimerSection(
                        viewModel: viewModel,
                        activeExercise: activeExercise
                    )
                }
                
                // 모든 운동 리스트를 포함하는 스크롤 뷰
                ScrollView {
                    VStack(spacing: 16) {
                        // 현재 진행 중인 운동 섹션
                        ActiveExerciseSection(viewModel: viewModel)
                        
                        // 대기 중인 운동 목록
                        WaitingExercisesSection(viewModel: viewModel)
                        
                        // 완료된 운동 목록
                        CompletedExercisesSection(viewModel: viewModel)
                        
                        // 운동 추가 버튼
                        AddExerciseButton(action: {
                            showingExerciseSelector = true
                        })
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let templateName = viewModel.currentSession.template?.name {
                        Text(templateName)
                            .font(.headline)
                    }
                }
            }
            .alert("운동 완료", isPresented: $showCompletionAlert) {
                Button("취소", role: .cancel) { }
                Button("완료", role: .destructive) {
                    let success = viewModel.completeWorkout()
                    if success {
                        completedSession = viewModel.currentSession
                        showingCompletionView = true
                    } else {
                        dismiss()
                    }
                }
            } message: {
                Text("현재 운동을 완료하시겠습니까?")
            }
            .alert("운동 취소", isPresented: $showCancelAlert) {
                Button("아니오", role: .cancel) { }
                Button("예", role: .destructive) {
                    LiveActivityManager.shared.endActivity()
                    dismiss()
                }
            } message: {
                Text("정말로 운동을 취소하시겠습니까?\n저장되지 않은 운동 기록은 사라집니다.")
            }
            .alert("운동 삭제", isPresented: exerciseDeleteBinding) {
                Button("취소", role: .cancel) {
                    viewModel.exerciseToDelete = nil
                }
                Button("삭제", role: .destructive) {
                    if let exercise = viewModel.exerciseToDelete {
                        viewModel.deleteExerciseFromWorkout(exercise)
                    }
                    viewModel.exerciseToDelete = nil
                }
            } message: {
                deleteAlertMessage
            }
            // 운동 선택 시트
            .sheet(isPresented: $showingExerciseSelector) {
                WorkoutExerciseSelectorView(
                    onExerciseSelected: { exercise in
                        viewModel.addExerciseToWorkout(exercise)
                    },
                    isExerciseSelected: { exercise in
                        viewModel.exercises.contains(where: { $0.id == exercise.id })
                    }
                )
            }
            // 운동 완료 시트
            .fullScreenCover(isPresented: $showingCompletionView) {
                if let session = completedSession {
                    WorkoutCompletionView(session: session)
                }
            }
            .onAppear {
                setupLiveActivity()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background {
                    // 앱이 백그라운드로 갈 때 LiveActivity 업데이트
                    viewModel.handleAppBackgrounded()
                } else if newPhase == .active && oldPhase == .background {
                    // 앱이 백그라운드에서 활성 상태로 돌아올 때
                    viewModel.handleAppForegrounded()
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentActiveExercise != nil)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.restTimerActive)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.completedExercises.count)
        }
    }
    
    // 운동 삭제 바인딩
    private var exerciseDeleteBinding: Binding<Bool> {
        Binding(
            get: { viewModel.exerciseToDelete != nil },
            set: { if !$0 { viewModel.exerciseToDelete = nil } }
        )
    }
    
    // 삭제 알림 메시지
    private var deleteAlertMessage: Text {
        if let exercise = viewModel.exerciseToDelete {
            return Text("\(exercise.name) 운동을 정말로 삭제하시겠습니까?\n모든 세트 정보가 함께 삭제됩니다.")
        } else {
            return Text("")
        }
    }
    
    // 다이나믹 아일랜드 설정 - 개선된 버전
    private func setupLiveActivity() {
        // 이전에 활성화된 LiveActivity가 있을 수 있으므로 초기화
        LiveActivityManager.shared.reset()
        
        // 다이나믹 아일랜드 활성화
        LiveActivityManager.shared.startActivity(
            workoutName: viewModel.currentSession.template?.name ?? "운동",
            startTime: viewModel.currentSession.startTime
        )
        
        print("LiveActivity 초기 설정 완료")
        
        // 현재 상태에 따라 적절한 모드로 설정
        if viewModel.restTimerActive, let exercise = viewModel.currentActiveExercise {
            // 초기 상태가 휴식 모드인 경우 (예: 앱 재시작 후)
            LiveActivityManager.shared.updateRestTimer(
                exerciseName: exercise.name,
                remainingTime: Int(viewModel.remainingRestTime)
            )
            print("초기 상태: 휴식 타이머 모드 설정")
        } else {
            // 초기 상태가 운동 모드인 경우
            LiveActivityManager.shared.switchToWorkoutMode()
            print("초기 상태: 운동 모드 설정")
        }
        
        // 추가: 앱 시작 5초 후 현재 상태 로깅 (디버깅용)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            LiveActivityManager.shared.logCurrentState()
        }
    }
}
