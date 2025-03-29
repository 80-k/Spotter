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
                
                // 운동 추가 버튼
                AddExerciseButton(action: {
                    showingExerciseSelector = true
                })
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // 휴식 타이머 섹션 - 활성화된 경우에만 표시
                if viewModel.restTimerActive, let activeExercise = viewModel.currentActiveExercise {
                    RestTimerSectionView(
                        exercise: activeExercise,
                        remainingTime: viewModel.remainingRestTime,
                        totalTime: viewModel.currentActiveSet?.restTime ?? 60
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                // 현재 진행 중인 운동 섹션 - 활성화된 경우에만 표시
                if let activeExercise = viewModel.currentActiveExercise {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
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
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .scale))
                }
                
                // 대기 중인 운동 목록
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.exercises.filter { exercise in
                            viewModel.currentActiveExercise?.id != exercise.id
                        }) { exercise in
                            WorkoutExerciseSection(
                                viewModel: viewModel,
                                exercise: exercise,
                                isActive: false
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .disabled(viewModel.isAnotherExerciseActive(exercise))
                            .opacity(viewModel.isAnotherExerciseActive(exercise) ? 0.5 : 1.0)
                        }
                    }
                    .padding(.vertical)
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
            // 각종 알림창 처리
            .modifier(WorkoutAlertsModifier(
                viewModel: viewModel,
                showCompletionAlert: $showCompletionAlert,
                showCancelAlert: $showCancelAlert,
                dismiss: dismiss
            ))
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
            .onAppear {
                // 다이나믹 아일랜드 활성화
                LiveActivityManager.shared.startActivity(
                    workoutName: viewModel.currentSession.template?.name ?? "운동",
                    startTime: viewModel.currentSession.startTime
                )
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                // 앱이 백그라운드로 갈 때 휴식 중인 세트가 있으면 라이브 액티비티 업데이트
                if newPhase == .background {
                    updateLiveActivityWithRestingSet()
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentActiveExercise != nil)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.restTimerActive)
        }
    }
    
    // 현재 휴식 중인 세트가 있으면 다이나믹 아일랜드 업데이트
    private func updateLiveActivityWithRestingSet() {
        if viewModel.restTimerActive, let exercise = viewModel.currentActiveExercise {
            LiveActivityManager.shared.updateRestTimer(
                exerciseName: exercise.name,
                remainingTime: Int(viewModel.remainingRestTime)
            )
        }
    }
}

// 상단 헤더 뷰
struct WorkoutHeaderView: View {
    let elapsedTime: TimeInterval
    let onCancel: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            // 경과 시간
            StopwatchView(elapsedTime: elapsedTime)
                .font(.title2)
            
            Spacer()
            
            // 취소 버튼
            Button(action: onCancel) {
                Text("취소")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding(.trailing, 8)
            
            // 완료 버튼
            Button(action: onComplete) {
                Text("완료")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
    }
}

// 운동 추가 버튼
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

// 알림창 모디파이어
struct WorkoutAlertsModifier: ViewModifier {
    var viewModel: ActiveWorkoutViewModel
    @Binding var showCompletionAlert: Bool
    @Binding var showCancelAlert: Bool
    let dismiss: DismissAction
    
    func body(content: Content) -> some View {
        content
            // 완료 확인 알림
            .alert("운동 완료", isPresented: $showCompletionAlert) {
                Button("취소", role: .cancel) { }
                Button("완료", role: .destructive) {
                    // 저장 성공 확인 후 지연 처리로 화면 닫기
                    let success = viewModel.completeWorkout()
                    if success {
                        // 저장 완료를 위해 약간의 지연 후 화면 닫기
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    } else {
                        // 실패 시 즉시 닫기
                        dismiss()
                    }
                }
            } message: {
                Text("현재 운동을 완료하시겠습니까?")
            }
            // 취소 확인 알림
            .alert("운동 취소", isPresented: $showCancelAlert) {
                Button("아니오", role: .cancel) { }
                Button("예", role: .destructive) {
                    // 운동 세션 취소하고 화면 닫기
                    LiveActivityManager.shared.endActivity()
                    dismiss()
                }
            } message: {
                Text("정말로 운동을 취소하시겠습니까?\n저장되지 않은 운동 기록은 사라집니다.")
            }
            // 운동 삭제 확인 알림
            .alert("운동 삭제", isPresented: Binding(
                get: { viewModel.exerciseToDelete != nil },
                set: { if !$0 { viewModel.exerciseToDelete = nil } }
            )) {
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
                if let exercise = viewModel.exerciseToDelete {
                    Text("\(exercise.name) 운동을 정말로 삭제하시겠습니까?\n모든 세트 정보가 함께 삭제됩니다.")
                } else {
                    Text("")
                }
            }
    }
}
