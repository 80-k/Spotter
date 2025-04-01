# Spotter 앱 상세 기능 명세서

## 1. 다이나믹 아일랜드 기능 상세

### 1.1 다이나믹 아일랜드 모드 전환

다이나믹 아일랜드는 두 가지 주요 모드로 동작합니다:

#### 1.1.1 운동 모드
- **표시 정보**: 
  - 현재 운동 이름
  - 현재 세트 번호 / 총 세트 수 (예: "2/4")
  - 전체 운동 진행률 바
  - 현재 운동 시간

- **상호작용**:
  - 탭: 앱으로 이동
  - 길게 누르기: 확장 뷰 표시

- **확장 뷰 정보**:
  - 현재 운동 이름 및 세부 정보
  - 세트별 무게/반복 횟수
  - 세트 완료 버튼
  - 휴식 타이머 시작 버튼

- **업데이트 조건**:
  - 세트 완료 시
  - 운동 항목 변경 시
  - 1분마다 운동 시간 업데이트

#### 1.1.2 휴식 타이머 모드
- **표시 정보**:
  - 카운트다운 타이머 (분:초)
  - 원형 진행 표시기
  - 다음 운동 이름

- **상호작용**:
  - 탭: 앱으로 이동
  - 길게 누르기: 확장 뷰 표시

- **확장 뷰 정보**:
  - 더 큰 타이머 표시
  - 타이머 건너뛰기 버튼
  - 다음 운동 세부 정보
  - 타이머 조정 컨트롤 (+/- 15초)

- **업데이트 조건**:
  - 1초마다 타이머 업데이트
  - 타이머 완료 시 진동 알림

#### 1.1.3 모드 전환 애니메이션
- **운동 → 휴식 모드 전환**:
  - 페이드 아웃/인 애니메이션 (0.5초)
  - `fadeInRestTimerMode` 중간 상태로 전환
  - 운동 정보를 숨기고 타이머 정보 표시

- **휴식 → 운동 모드 전환**:
  - 페이드 아웃/인 애니메이션 (0.5초)
  - `fadeInWorkoutMode` 중간 상태로 전환
  - 타이머 정보를 숨기고 운동 정보 표시

- **전환 트리거**:
  - 세트 완료 후 자동 휴식 타이머 시작
  - 휴식 타이머 완료 시 자동 운동 모드 전환
  - 사용자가 건너뛰기 버튼 누를 때

### 1.2 LiveActivity 라이프사이클

#### 1.2.1 시작 조건
- 운동 세션이 시작될 때 자동으로 LiveActivity 활성화
- `startWorkoutActivity()` 호출

#### 1.2.2 업데이트 조건
- 세트 완료 시 (`updateWorkoutActivity()` 호출)
- 휴식 타이머 시작 시 (`startRestTimerActivity()` 호출)
- 휴식 타이머 진행 중 1초마다 (`updateRestTimerActivity()` 호출)

#### 1.2.3 종료 조건
- 운동 세션 완료 시
- 사용자가 수동으로 운동 종료 시
- 앱 강제 종료 시 (시스템 종료)
- `endActivity()` 호출로 종료

#### 1.2.4 백그라운드 동작
- 앱이 백그라운드 상태일 때도 LiveActivity 유지
- 타이머는 백그라운드에서도 정확하게 동작
- 시스템 메모리 부족 시에도 타이머 정확도 유지를 위한 처리

## 2. 메인 앱 화면별 기능 상세

### 2.1 온보딩 화면

#### 2.1.1 최초 실행 플로우
- 앱 최초 실행 시 표시
- 3단계로 구성: 소개, 목표 설정, 사용자 정보 입력
- 단계 간 스와이프로 이동 (페이지 컨트롤 표시)

#### 2.1.2 목표 설정
- 운동 목표 선택 (근력 향상, 체중 감량, 근육 증가 등)
- 주간 운동 일수 설정
- 선호하는 운동 유형 선택

#### 2.1.3 사용자 정보
- 이름 입력 (선택적)
- 성별, 키, 체중 입력 (선택적)
- 무게 단위 선택 (kg/lb)

#### 2.1.4 건너뛰기 옵션
- 온보딩 단계 건너뛰기 가능
- 나중에 설정에서 변경 가능함을 안내

### 2.2 메인 탭 화면

#### 2.2.1 시작 탭
- **템플릿 목록**:
  - 사용자 저장 템플릿 표시
  - 상단 검색 기능
  - 최근 사용 템플릿 상단 표시
  - 스와이프로 편집/삭제

- **템플릿 세부 화면**:
  - 운동 항목 목록
  - 예상 시간
  - 시작 버튼 (터치 시 세션 시작)
  - 편집 버튼 (터치 시 편집 모드)

- **새 템플릿 생성**:
  - + 버튼으로 생성
  - 템플릿 이름 입력
  - 운동 항목 추가 UI
  - 운동별 세트/무게/반복 설정

#### 2.2.2 활성 운동 화면
- **세션 헤더**:
  - 템플릿 이름
  - 경과 시간
  - 완료된 운동 수 / 총 운동 수
  - 일시 정지/재개 버튼
  - 종료 버튼

- **운동 목록**:
  - 현재 운동 강조 표시
  - 완료된 운동 체크 표시
  - 남은 운동 회색 처리

- **현재 운동 세트 관리**:
  - 세트 번호
  - 이전 세션 기록 (있을 경우)
  - 무게 입력 필드
  - 반복 횟수 입력 필드
  - 세트 완료 버튼
  - 실패 세트 표시 옵션

- **휴식 타이머 화면**:
  - 큰 카운트다운 타이머
  - 다음 세트 정보
  - 타이머 건너뛰기 버튼
  - 타이머 조정 (+/- 15초)
  - 시각적 진행 표시

#### 2.2.3 히스토리 탭
- **달력 뷰**:
  - 월별 달력 표시
  - 운동일 표시 (점 또는 강조)
  - 날짜 선택으로 해당 일 세션 표시

- **목록 뷰**:
  - 최근 운동 세션 목록
  - 날짜, 템플릿 이름, 운동 시간 표시
  - 필터 옵션 (날짜, 템플릿, 운동 유형)

- **세션 상세 화면**:
  - 모든 운동 및 세트 정보
  - 총 볼륨, 무게, 시간 통계
  - 메모 표시
  - 공유 옵션

- **통계 뷰**:
  - 주간/월간 운동 통계
  - 운동 유형별 분석
  - 무게 진행 차트
  - 목표 달성률

#### 2.2.4 설정 탭
- **사용자 프로필**:
  - 프로필 정보 편집
  - 목표 수정
  - 계정 관리 (로그인 시)

- **앱 설정**:
  - 다크/라이트 모드 전환
  - 알림 설정
  - 기본 휴식 타이머 시간
  - 무게 단위 (kg/lb)
  - 소리 설정

- **데이터 관리**:
  - 데이터 내보내기/가져오기
  - 백업 및 복원
  - 건강 앱 연동 설정

- **기타**:
  - 정보 및 법적 고지
  - 피드백 보내기
  - 앱 평가하기

### 2.3 팝업 및 모달

#### 2.3.1 운동 완료 팝업
- 세션 완료 시 표시
- 세션 요약 정보 표시
- 저장 또는 삭제 옵션
- 메모 추가 옵션

#### 2.3.2 세트 완료 모달
- 세트 완료 버튼 터치 시 표시
- 빠른 평가 옵션 (쉬움/적당함/어려움)
- 휴식 타이머 자동 시작

#### 2.3.3 운동 항목 선택 모달
- 새 운동 추가 시 표시
- 검색 기능
- 카테고리별 필터링
- 최근 사용 운동 상단 표시
- 사용자 정의 운동 생성 옵션

#### 2.3.4 경고 및 확인 대화상자
- 템플릿 삭제 확인
- 세션 종료 확인
- 데이터 삭제 확인
- 네트워크 오류 알림

## 3. 운동 세션 흐름

### 3.1 세션 시작

1. 사용자가 템플릿 선택 후 '시작' 버튼 터치
2. 세션 초기화:
   - 시작 시간 기록
   - 세션 ID 생성
   - SwiftData에 세션 정보 저장
3. 첫 번째 운동 항목으로 이동
4. LiveActivity 시작 (다이나믹 아일랜드 활성화)

### 3.2 세트 진행

1. 현재 운동 및 세트 표시
2. 사용자가 무게/반복 횟수 입력
3. '세트 완료' 버튼 터치
4. 데이터 저장 및 상태 업데이트
5. 평가 모달 표시 (선택적)
6. 휴식 타이머 자동 시작
7. LiveActivity 업데이트 (휴식 모드로 전환)

### 3.3 휴식 시간

1. 카운트다운 타이머 표시
2. 1초마다 타이머 업데이트
3. LiveActivity 업데이트
4. 타이머 완료 시:
   - 진동 알림
   - 다음 세트로 자동 이동
   - LiveActivity 운동 모드로 전환

### 3.4 운동 항목 전환

1. 모든 세트 완료 시 다음 운동으로 이동
2. UI 업데이트 (다음 운동 강조)
3. 새 운동 세트 정보 표시
4. LiveActivity 업데이트

### 3.5 세션 종료

1. 마지막 운동/세트 완료 또는 수동 종료
2. 종료 시간 기록
3. 세션 통계 계산
4. 완료 팝업 표시
5. 세션 데이터 저장
6. LiveActivity 종료

## 4. 세션 외 기능

### 4.1 템플릿 관리

#### 4.1.1 템플릿 생성
1. + 버튼 > '새 템플릿' 선택
2. 템플릿 이름 입력
3. 운동 추가 버튼 터치
4. 운동 선택 모달에서 운동 선택
5. 세트, 무게, 반복 횟수 설정
6. 추가 운동 계속 추가
7. 저장 버튼으로 완료

#### 4.1.2 템플릿 편집
1. 템플릿 목록에서 편집 버튼 또는 스와이프
2. 운동 순서 변경 (드래그)
3. 운동 삭제 (스와이프)
4. 운동 세부 정보 편집
5. 저장하여 업데이트

#### 4.1.3 템플릿 공유
1. 템플릿 상세 화면에서 공유 버튼
2. QR 코드 생성
3. 링크 공유 옵션
4. JSON 형식 내보내기

### 4.2 사용자 데이터 관리

#### 4.2.1 데이터 내보내기
1. 설정 > 데이터 관리 > 내보내기
2. 포맷 선택 (CSV, JSON)
3. 기간 선택
4. 내보내기 실행
5. 파일 저장 또는 공유

#### 4.2.2 데이터 백업
1. 설정 > 데이터 관리 > 백업
2. iCloud/로컬 저장 선택
3. 백업 생성
4. 자동 백업 옵션 설정

#### 4.2.3 건강 앱 통합
1. 설정 > 건강 앱 연동
2. 권한 허용
3. 동기화할 데이터 유형 선택
4. 자동 동기화 설정

### 4.3 알림 시스템

#### 4.3.1 리마인더 알림
1. 예약된 운동 시간 알림
2. 장기간 비활성 사용자 리마인더
3. 목표 달성률 알림

#### 4.3.2 타이머 알림
1. 휴식 타이머 종료 알림
2. 진동 및 소리 설정
3. 잠금 화면 알림

#### 4.3.3 목표 달성 알림
1. 개인 기록 경신 시 축하 알림
2. 주간/월간 목표 달성 시 알림
3. 연속 운동 일수 체크인

## 5. 특수 기능 및 시나리오

### 5.1 앱 상태 관리

#### 5.1.1 백그라운드 동작
- 세션 진행 중 앱이 백그라운드로 갈 때:
  - 타이머 계속 실행
  - 주기적 LiveActivity 업데이트
  - 배터리 최적화를 위한 업데이트 주기 조정

#### 5.1.2 중단 복구
- 앱 강제 종료 후 재시작 시:
  - 진행 중인 세션 감지
  - 복구 옵션 제공
  - 마지막 상태에서 계속할지 선택

#### 5.1.3 네트워크 변경
- 오프라인/온라인 상태 변화 처리
- 로컬 데이터 우선 사용
- 네트워크 복구 시 동기화

### 5.2 에러 처리

#### 5.2.1 데이터 오류
- 저장 실패 처리
- 복구 메커니즘
- 사용자 알림 및 재시도 옵션

#### 5.2.2 LiveActivity 오류
- 시스템 제한으로 활동 생성 실패 시 대체 UI
- 활동 업데이트 실패 시 재시도 로직
- 디버그 정보 로깅

### 5.3 접근성 대응

#### 5.3.1 VoiceOver 지원
- 모든 UI 요소 접근성 레이블 제공
- 운동 진행 상태 음성 안내
- 타이머 음성 알림

#### 5.3.2 다이나믹 타입
- 텍스트 크기 변경 지원
- UI 요소 자동 조정
- 레이아웃 최적화

#### 5.3.3 고대비 모드
- 고대비 색상 테마
- 접근성 설정에 따른 자동 조정

## 6. 기술적 구현 세부사항

### 6.1 LiveActivity 구현

```swift
// ActivityAttributes 정의
struct WorkoutActivityAttributes: ActivityAttributes {
    // 고정 데이터
    struct ContentState: Codable, Hashable {
        // 모드 상태
        var activityMode: ActivityMode
        
        // 운동 모드 데이터
        var exerciseName: String
        var currentSet: Int
        var totalSets: Int
        var progressPercentage: Double
        var elapsedTime: TimeInterval
        
        // 휴식 타이머 데이터
        var remainingSeconds: Int
        var totalRestSeconds: Int
        var nextExerciseName: String
    }
    
    // 식별 정보
    var workoutSessionId: UUID
    var templateName: String
}
```

### 6.2 다이나믹 아일랜드 전환 로직

```swift
// 모드 전환 메서드
func switchToRestTimerMode(remainingSeconds: Int, nextExerciseName: String) async {
    // 1. 페이드 아웃 애니메이션 설정
    var contentState = activity?.contentState
    contentState?.activityMode = .fadeInRestTimerMode
    
    // 2. 첫 번째 업데이트 - 전환 상태로
    await activity?.update(using: contentState)
    
    // 3. 잠시 대기 (애니메이션 시간)
    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초
    
    // 4. 실제 휴식 모드 데이터로 업데이트
    contentState?.activityMode = .restTimerMode
    contentState?.remainingSeconds = remainingSeconds
    contentState?.totalRestSeconds = remainingSeconds
    contentState?.nextExerciseName = nextExerciseName
    
    // 5. 최종 업데이트
    await activity?.update(using: contentState)
    
    // 6. 타이머 시작
    startRestTimer(seconds: remainingSeconds)
}

// 운동 모드로 전환
func switchToWorkoutMode(exerciseName: String, currentSet: Int, totalSets: Int) async {
    // 비슷한 패턴으로 구현
    // ...
}
```

### 6.3 타이머 구현

```swift
// 휴식 타이머 관리
func startRestTimer(seconds: Int) {
    restTimerTask?.cancel()
    
    // 초기 상태 설정
    var remainingSeconds = seconds
    
    // 타이머 작업 시작
    restTimerTask = Task { [weak self] in
        do {
            while remainingSeconds > 0 && !Task.isCancelled {
                // LiveActivity 업데이트
                await self?.updateRestTimerActivity(remainingSeconds: remainingSeconds)
                
                // 1초 대기
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // 카운트다운
                remainingSeconds -= 1
            }
            
            // 타이머 완료 시
            if !Task.isCancelled {
                await self?.timerCompleted()
            }
        } catch {
            // 작업 취소 또는 에러 처리
            print("Rest timer cancelled or error: \(error)")
        }
    }
}
```

### 6.4 운동 세션 진행 상태 관리

```swift
class WorkoutSessionManager: ObservableObject {
    // 상태 관리
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSetIndex: Int = 0
    @Published var isRestTimerActive: Bool = false
    @Published var sessionState: SessionState = .notStarted
    
    // 데이터
    @Published var workoutSession: WorkoutSession
    @Published var completedSets: [UUID: [WorkoutSet]] = [:]
    
    // 세트 완료 처리
    func completeCurrentSet(weight: Double, reps: Int) async {
        // 1. 세트 데이터 생성
        let set = WorkoutSet(
            exerciseId: currentExercise.id,
            weight: weight,
            reps: reps,
            isCompleted: true
        )
        
        // 2. 데이터 저장
        saveSet(set)
        
        // 3. 상태 업데이트
        updateCompletionStatus()
        
        // 4. LiveActivity 업데이트
        await liveActivityService.updateWorkoutActivity(
            exerciseName: currentExercise.name,
            currentSet: currentSetIndex + 1,
            totalSets: currentExercise.sets.count,
            progressPercentage: calculateProgress()
        )
        
        // 5. 다음 단계로 전환
        if hasMoreSetsInCurrentExercise() {
            // 휴식 타이머 시작
            startRestTimer()
        } else if hasMoreExercises() {
            // 다음 운동으로 이동
            moveToNextExercise()
        } else {
            // 세션 완료
            completeSession()
        }
    }
}
```

## 7. 추가 기능 사항

### 7.1 운동 데이터 동기화 및 백업

#### 7.1.1 iCloud 동기화
- iCloud를 통한 운동 데이터 자동 동기화
- 여러 기기 간 템플릿 및 운동 기록 공유
- CloudKit 프레임워크를 활용한 실시간 데이터 동기화
- 오프라인 모드 지원 및 충돌 해결 메커니즘

#### 7.1.2 백업 및 복원
- 모든 데이터의 수동 백업 생성 기능
- 특정 시점으로 데이터 복원 기능
- 클라우드 및 로컬 백업 옵션
- 백업 파일 암호화 지원

### 7.2 건강 앱 통합

#### 7.2.1 데이터 내보내기
- 운동 세션 데이터를 HealthKit으로 자동 내보내기
- 칼로리 소모량 계산 및 기록
- 운동 시간 및 유형 기록
- 심박수 데이터 통합 (외부 기기 연결 시)

#### 7.2.2 데이터 가져오기
- HealthKit에서 체중, 신장 등 사용자 정보 가져오기
- 다른 앱에서 기록된 운동 데이터 통합
- 건강 앱 데이터 기반 운동 제안

### 7.3 Apple Watch 통합

#### 7.3.1 Watch 앱 기능
- iPhone 없이 독립적인 운동 추적 지원
- 운동 중 심박수 모니터링
- 휴식 타이머 알림 및 햅틱 피드백
- 세트 완료 기록 기능

#### 7.3.2 iPhone-Watch 동기화
- 운동 세션 실시간 동기화
- Watch에서 세트 완료 시 iPhone LiveActivity 업데이트
- 양방향 데이터 흐름

### 7.4 사용자 커뮤니티 기능

#### 7.4.1 템플릿 공유 플랫폼
- 공개 템플릿 라이브러리 제공
- 사용자 제작 템플릿 업로드 및 평가
- 카테고리별 템플릿 검색 및 필터링
- 인기 템플릿 추천

#### 7.4.2 소셜 기능
- 친구 추가 및 운동 진행 상황 공유
- 운동 도전 과제 생성 및 참여
- 성취 배지 시스템
- 익명 사용자 통계 분석 및 비교

### 7.5 고급 알림 시스템

#### 7.5.1 알림 유형
- 예정된 운동 미리 알림
- 목표 달성 알림
- 정체기 감지 및 변화 제안
- 일정 기반 운동 알림 (예: 월수금 오후 6시)

#### 7.5.2 알림 개인화
- 사용자 행동 패턴 기반 알림 타이밍 조정
- 집중 모드 통합
- 알림 그룹화 및 우선순위 설정
- 사용자 피드백 기반 알림 최적화

### 7.6 다양한 운동 유형 지원

#### 7.6.1 유산소 운동 추적
- 러닝, 사이클링, 수영 등 유산소 운동 템플릿
- 심박수 구간 기반 트레이닝
- 거리, 속도, 시간 추적
- GPS 데이터 연동 (실외 운동 시)

#### 7.6.2 맞춤형 서킷 트레이닝
- 시간 기반 서킷 설정
- HIIT(고강도 인터벌 트레이닝) 지원
- 복합 운동 세트 구성
- 태버타, EMOM 등 특수 타이밍 프로토콜

### 7.7 AI 기반 기능

#### 7.7.1 개인화된 추천
- 사용자 운동 데이터 분석 기반 템플릿 추천
- 발전 곡선에 맞춘 무게/세트 제안
- 정체기 극복을 위한 운동 변화 제안
- 과훈련 방지 알고리즘

#### 7.7.2 자동 운동 인식
- 디바이스 센서를 활용한 운동 동작 자동 인식
- 반복 횟수 자동 카운팅
- 동작 품질 평가 및 피드백
- 정확도 향상을 위한 사용자 피드백 학습

### 7.8 접근성 개선

#### 7.8.1 VoiceOver 지원
- 모든 앱 기능의 완전한 VoiceOver 호환성
- 운동 중 음성 안내 옵션
- 음성 명령으로 세트 완료 및 휴식 타이머 조작

#### 7.8.2 다양한 접근성 옵션
- 대형 텍스트 지원 및 고대비 모드
- 모션 감소 모드
- 다양한 색각 이상자를 위한 색상 최적화
- 한 손 조작 최적화 UI

### 7.9 데이터 분석 및 인사이트

#### 7.9.1 고급 통계 분석
- 볼륨, 강도, 빈도 분석 그래프
- 주간/월간/연간 추세
- 운동 균형 분석 (근육 그룹별 트레이닝 분포)
- 오버트레이닝 위험 감지

#### 7.9.2 목표 추적
- 사용자 정의 목표 설정 및 추적
- 시각적 진행 지표
- 단기/중기/장기 목표 계층화
- 목표 달성 예측

### 7.10 다국어 및 지역화 지원

#### 7.10.1 다국어 지원
- 영어, 한국어, 일본어, 중국어, 스페인어 등 주요 언어 지원
- 지역별 측정 단위 자동 전환 (kg/lb, cm/inch)
- 운동 용어의 정확한 현지화

#### 7.10.2 문화적 최적화
- 국가별 인기 운동 추천
- 지역별 사용자 인터페이스 최적화
- 현지 법규 및 개인정보 보호법 준수

## 8. 기술적 구현 세부사항

### 8.1 LiveActivity 구현

```swift
// ActivityAttributes 정의
struct WorkoutActivityAttributes: ActivityAttributes {
    // 고정 데이터
    struct ContentState: Codable, Hashable {
        // 모드 상태
        var activityMode: ActivityMode
        
        // 운동 모드 데이터
        var exerciseName: String
        var currentSet: Int
        var totalSets: Int
        var progressPercentage: Double
        var elapsedTime: TimeInterval
        
        // 휴식 타이머 데이터
        var remainingSeconds: Int
        var totalRestSeconds: Int
        var nextExerciseName: String
    }
    
    // 식별 정보
    var workoutSessionId: UUID
    var templateName: String
}
```

### 8.2 다이나믹 아일랜드 전환 로직

```swift
// 모드 전환 메서드
func switchToRestTimerMode(remainingSeconds: Int, nextExerciseName: String) async {
    // 1. 페이드 아웃 애니메이션 설정
    var contentState = activity?.contentState
    contentState?.activityMode = .fadeInRestTimerMode
    
    // 2. 첫 번째 업데이트 - 전환 상태로
    await activity?.update(using: contentState)
    
    // 3. 잠시 대기 (애니메이션 시간)
    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초
    
    // 4. 실제 휴식 모드 데이터로 업데이트
    contentState?.activityMode = .restTimerMode
    contentState?.remainingSeconds = remainingSeconds
    contentState?.totalRestSeconds = remainingSeconds
    contentState?.nextExerciseName = nextExerciseName
    
    // 5. 최종 업데이트
    await activity?.update(using: contentState)
    
    // 6. 타이머 시작
    startRestTimer(seconds: remainingSeconds)
}

// 운동 모드로 전환
func switchToWorkoutMode(exerciseName: String, currentSet: Int, totalSets: Int) async {
    // 비슷한 패턴으로 구현
    // ...
}
```

### 8.3 타이머 구현

```swift
// 휴식 타이머 관리
func startRestTimer(seconds: Int) {
    restTimerTask?.cancel()
    
    // 초기 상태 설정
    var remainingSeconds = seconds
    
    // 타이머 작업 시작
    restTimerTask = Task { [weak self] in
        do {
            while remainingSeconds > 0 && !Task.isCancelled {
                // LiveActivity 업데이트
                await self?.updateRestTimerActivity(remainingSeconds: remainingSeconds)
                
                // 1초 대기
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // 카운트다운
                remainingSeconds -= 1
            }
            
            // 타이머 완료 시
            if !Task.isCancelled {
                await self?.timerCompleted()
            }
        } catch {
            // 작업 취소 또는 에러 처리
            print("Rest timer cancelled or error: \(error)")
        }
    }
}
```

### 8.4 운동 세션 진행 상태 관리

```swift
class WorkoutSessionManager: ObservableObject {
    // 상태 관리
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSetIndex: Int = 0
    @Published var isRestTimerActive: Bool = false
    @Published var sessionState: SessionState = .notStarted
    
    // 데이터
    @Published var workoutSession: WorkoutSession
    @Published var completedSets: [UUID: [WorkoutSet]] = [:]
    
    // 세트 완료 처리
    func completeCurrentSet(weight: Double, reps: Int) async {
        // 1. 세트 데이터 생성
        let set = WorkoutSet(
            exerciseId: currentExercise.id,
            weight: weight,
            reps: reps,
            isCompleted: true
        )
        
        // 2. 데이터 저장
        saveSet(set)
        
        // 3. 상태 업데이트
        updateCompletionStatus()
        
        // 4. LiveActivity 업데이트
        await liveActivityService.updateWorkoutActivity(
            exerciseName: currentExercise.name,
            currentSet: currentSetIndex + 1,
            totalSets: currentExercise.sets.count,
            progressPercentage: calculateProgress()
        )
        
        // 5. 다음 단계로 전환
        if hasMoreSetsInCurrentExercise() {
            // 휴식 타이머 시작
            startRestTimer()
        } else if hasMoreExercises() {
            // 다음 운동으로 이동
            moveToNextExercise()
        } else {
            // 세션 완료
            completeSession()
        }
    }
}
```

## 9. 기능 의존성 맵

다음은 주요 기능 간의 의존성과 상호작용을 보여줍니다:

```
LiveActivityService ─────────┐
      │                      │
      ↓                      ↓
WorkoutSessionManager ←→ TimerService
      │                      ↑
      ↓                      │
 ViewModels ─────────→ NotificationService
      │
      ↓
 SwiftUI Views
```

이 의존성 맵은 다양한 서비스 간의 통신 방법과 데이터 흐름을 보여줍니다. 각 컴포넌트는 자신의 책임을 가지며, 적절한 인터페이스를 통해 통신합니다. 