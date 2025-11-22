# LineTweak

LINE 메신저의 전송취소 기능을 완벽하게 차단하고 광고를 제거하는 iOS Tweak입니다. 상대방이 메시지를 전송취소해도 삭제되지 않고 계속 확인할 수 있으며, 사진과 동영상까지 로컬에 안전하게 보관됩니다.

## 주요 기능

### 🔒 완벽한 전송취소 방지
- **다층 방어 시스템**: NSObject, CoreData, UI 레벨에서 3중 차단
- **메시지 복원**: 데이터베이스 삭제 시도 자동 감지 및 복원
- **실시간 모니터링**: 전송취소 이벤트를 실시간으로 감지하고 차단

### 📸 미디어 파일 저장
- 사진(JPEG) 및 동영상(MP4, MOV 등) 자동 저장
- 압축 옵션으로 저장 공간 절약 가능
- 재귀적 객체 탐색으로 숨겨진 미디어도 추출

### 🚫 광고 차단
- **UIView/UIViewController 광고 차단**: 클래스명 패턴 감지
- **WebView 광고 차단**: 광고 URL 자동 차단
- **광고 메서드 후킹**: showAd, loadAd, displayAd 등 차단
- 깔끔한 UI 경험 제공

### ⚙️ 설정 앱 통합
- iOS 설정 앱에서 직접 제어
- 트윅 활성화/비활성화
- 저장된 메시지 목록 보기
- 최대 저장 개수 제한
- 미디어 저장 및 압축 옵션
- 광고 차단 활성화/비활성화
- 디버그 로그 토글

## 기술 세부사항

### 구현 방식

**Level 1: NSObject 메서드 후킹**
```objc
- (void)unsendMessage:(id)message
- (void)deleteMessage:(id)message
- (void)removeMessage:(id)message
```
LINE 앱의 메시지 전송취소/삭제 메서드를 가로채 실행을 차단합니다.

**Level 2: CoreData 객체 복원**
```objc
- (BOOL)save:(NSError **)error
```
데이터베이스 저장 시점에 삭제된 Message/Chat/Talk 엔티티를 감지하고 자동으로 복원합니다.

**Level 3: UI 삭제 차단**
```objc
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths
- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths
```
UITableView와 UICollectionView의 삭제 애니메이션까지 차단하여 UI에서도 메시지가 사라지지 않습니다.

### 미디어 추출 알고리즘
Objective-C 런타임 리플렉션을 활용하여 메시지 객체의 모든 프로퍼티를 재귀적으로 탐색하고 UIImage, NSURL, NSData 타입의 미디어 데이터를 자동 추출합니다.

## 설치 방법

### 요구사항
- 탈옥된 iOS 기기 (iOS 14.0 이상)
- Rootless 탈옥 환경 (Dopamine, Palera1n 등)
- Sileo 또는 dpkg

### 설치
1. `.deb` 파일 다운로드
2. Sileo에서 설치하거나 수동 설치:
```bash
dpkg -i com.taeho.linetweak_*.deb
```

3. SpringBoard 리스프링:
```bash
killall -9 SpringBoard
```

4. 설정 > LineTweak에서 활성화

## 사용법

1. **설정 앱 > LineTweak** 진입
2. **트윅 활성화** 스위치 ON
3. 필요에 따라 옵션 조정:
   - 사진/동영상 저장: 미디어 파일 로컬 저장 여부
   - 미디어 압축: JPEG 압축으로 용량 절약
   - 최대 저장 개수: 메모리 관리 (기본 1000개)
4. LINE 앱 재시작

### 저장된 메시지 확인
- **메시지 목록 보기**: 전송취소된 메시지 전체 확인
- **저장된 메시지 개수**: 현재 저장된 개수 표시
- **전체 삭제**: 저장된 모든 메시지 삭제

## 개발 환경

### 빌드 요구사항
- Theos (iOS 16.5 SDK)
- iOS Toolchain (Clang)
- ldid (코드 서명)

### 컴파일
```bash
make clean
make package
```

### 대상 아키텍처
- arm64
- arm64e

### 프레임워크 의존성
- UIKit
- Foundation
- CoreData
- AVFoundation
- WebKit
- MobileSubstrate

## 저장 위치

- **설정 파일**: `/var/mobile/Library/Preferences/com.taeho.linetweak.plist`
- **메시지 데이터**: `/var/mobile/Documents/LineTweak/DeletedMessages.plist`
- **미디어 파일**: `/var/mobile/Documents/LineTweak/Media/`

## 버전 히스토리

### v1.3.0 (최신)
- 🚫 **광고 차단 기능 추가**
- UIView/UIViewController 기반 광고 자동 숨김
- WKWebView 광고 URL 차단
- 광고 관련 메서드 후킹
- 설정 UI에 광고 차단 토글 추가

### v1.2.0
- CoreData 객체 복원 기능 강화
- UICollectionView 삭제 차단 추가
- 엔티티 타입 감지 개선
- 미디어 추출 안정성 향상

### v1.1.0
- 사진/동영상 저장 기능 추가
- 미디어 압축 옵션 추가
- 재귀적 객체 탐색 알고리즘 구현

### v1.0.0
- 초기 릴리스
- 기본 전송취소 차단 기능
- 설정 UI 구현

## 라이선스

이 프로젝트는 교육 및 개인 사용 목적으로 제작되었습니다.

## 면책 조항

이 Tweak는 LINE 메신저의 정상적인 기능을 변경합니다. 사용으로 인해 발생하는 모든 문제는 사용자의 책임입니다.
- LINE 이용약관 위반 가능성
- 앱 크래시 또는 불안정성
- 데이터 손실 위험

## 개발자

**Taeho**
- Package: com.taeho.linetweak

## 기여

이슈 및 개선 제안은 GitHub Issues를 통해 제출해주세요.

---

**Note**: 이 프로젝트는 탈옥 iOS 환경에서만 동작하며, LINE 앱의 내부 구조 변경 시 업데이트가 필요할 수 있습니다.
