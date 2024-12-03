# 🐶 DogWalk
> ### 견주들을 위한 산책 기록·공유하는 소셜 커뮤니티 서비스

<br />

## 프로젝트 소개
> **개발 기간** : 2024. 10. 28 (월) ~ 2024. 11. 25 (월)<br />
> **개발 인원** : iOS 4인 + Back-End 2인<br />
> **최소 버전** : iOS 17.0+<br />

<br />

<div align="center">
  <img width="24%" src="https://github.com/user-attachments/assets/1942a03c-ccb3-4f13-a037-ce6731148775" />
  <img width="24%" src="https://github.com/user-attachments/assets/01738047-dbc6-4c59-b481-439b6f47e0df" />
  <img width="24%" src="https://github.com/user-attachments/assets/5d91c9d4-2c99-4635-9d98-c52ee1cf2ee9" />
  <img width="24%" src="https://github.com/user-attachments/assets/0ba89026-2500-4518-b708-bf26277cf20e" />
</div>

<br /><br />

| **[김윤우](https://github.com/yoonwooiOS)** | **[김준희](https://github.com/dev-junehee)** | **[박성민](https://github.com/sixteenis)** | **[소정섭](https://github.com/wjdtjq6)** |
| :-: | :-: | :-: | :-: |
| <a href="https://github.com/dev-junehee"><img src="https://avatars.githubusercontent.com/u/170070172?v=4" width=200px alt="김준희" /> | <a href="https://github.com/sixteenis"><img src="https://avatars.githubusercontent.com/u/116873887?v=4" width=200px alt="김준희" /> | <a href="https://github.com/dev-junehee"><img src="https://avatars.githubusercontent.com/u/108184083?s=96&v=4" width=200px alt="김준희" /> | <a href="https://github.com/dev-junehee"><img src="https://avatars.githubusercontent.com/u/71679088?v=4" width=200px alt="김준희" /> |


<br />

## 사용 기술 및 개발 환경
- **iOS** : Swift 5, Xcode 15.3, SwiftUI, MapKit
- **Architecture** : MVI + Coordinator
- **Reactive** : Combine
- **Network** : Swift Concurrency + Router Pattern
- **Socket** : Socket.IO
- **Local DB** : CoreData

<br />

## 주요 기능
- 강아지와 산책 기록 🔥 
- 다른 유저와 실시간 1:1 채팅 💬
- 위치 기반 게시글 조회 👀 
- 커뮤니티 게시글 작성 & 조회  ✍️ 

<br />

## 주요 구현 사항
### MVI 아키텍쳐 설계
  <img width="100%" src="https://github.com/user-attachments/assets/8c2e2af3-9b5a-496c-b400-f9eca439339a" />

- **SRP (Single Responsibility Principle)**
  - Container, Intent, Model, Repository의 역할 분리 통해 단일 책임 원칙을 준수한 아키텍처 
- **DIP (Depency Inversion Principle)**
  - 프로토콜 기반 구현을 통해 추상화를 진행하여 의존 역전 원칙을 준수한 아키텍처 설계
- **무결성 (Intergrity)**
  - Intent에 StateAction Protocol을 채택하여 Model에 데이터 전달 시 메서드를 통해 전달하여 무결성을 보장
- **Side Effect**
  - ContentState를 통해 비동기 작업과 같은 외부 요인에 따라 화면 전환 타입을 관리하여 외부 데이터 반영 시의 흐름 제어
- **Container**
  - MVI의 단방향 데이터 흐름과 캡슐화를 유지하기 위해 Intent Protocol과 State Protocol을 주입받아 View에 매핑 방식의 Container 설계

<br />

### 산책 기록
> #### MapKit
  - followsUserLocation 메서드를 통해 사용자 위치와 카메라 위치가 다를 경우에 새로고침 버튼 나타나는 로직 구현

> #### 타이머
  - DispatchSourceTimer를 활용해 백그라운드에서도 동작 가능한 타이머를 구현하고, 이를 MapPolyline과 결합하여 실시간 경로 추적 및 시각화 기능 개발

### 위치기반 게시글 조회
- 카메라 포지션 변경 이벤트마다 map.region.span.latitudeDelta 값을 활용하여, 이를 실제 미터 단위 반경으로 변환하여 동적 위치 조회 범위 조정
- MKCoordinateRegion을 사용하여 경로의 최대/최소 위경도 값을 기반으로 동적인 지도 축척(zoom level)을 구현하고, MKMapSnapshotter를 활용하여 해당 경로가 포함된 지도 이미지를 캡처
    
> #### Pagination
- 페이지네이션 관련 상태값은 Repository에서만 관리
- Cursor기반 Pagination을 통해 화면에 필요한 게시글 개수를 서버에 요청해 서버의 트래픽을 줄임

> #### multipart/form-data
- Custom Multipart/form-data 처리로 이미지 업로드 시 필요한 HTTP 멀티 파트 형식 구현

### 소셜 로그인
> #### 애플 로그인
- 비밀번호 또는 iCloud에 따른 로그인 분기 처리 진행

### 채팅
> #### 1:1 실시간 채팅 구현
- Socket.IO와 CoreData 사용해 서버와 클라이언트 사이의 양방향 통신을 구현하고, 채팅 데이터를 로컬에 저장
- SocketProvider 프로토콜을 준수하는 SocketIOManager를 구현하여 소켓 연결, 해제, 메시지 수신 이벤트 관리
- 상대방의 userID를 받아 채팅방을 생성 후, 만들어진 roomID를 통해 기존 채팅방 여부를 판단하여 예외 처리 진행
    - 채팅방을 처음 만드는 경우, 채팅방 생성과 동시에 소켓 연결
    - 기존 채팅방인 경우, CoreData에 저장된 기존 채팅 내역을 불러온 후 소켓 연결
- 메세지 전송 : 서버 통신을 통해 전송한 메세지를 CoreData에 저장하여 화면 갱신
- 메시지 수신 : 소켓 이벤트를 통해 데이터를 수신하여 디코딩 후 PassthroughSubject를 통해 CoreData에 저장하여 화면 갱신
- Background 상태 진입 시 소켓 연결 해제

<br />

## 브랜치 전략
### GitLab Flow 및 Branch Protect 도입
- **production**
  - 실제 서비스 배포용 브랜치
  - 3명의 Approve가 있어야 Merge 가능

- **pre-production**
  - 배포 전 테스트 진행용 브랜치
  - 3명의 Approve가 있어야 Merge 가능

- **main**
  - 개발 진행용 브랜치
  - 2명의 Approve가 있어야 Merge 가능

- **feat**, **design**, **fix**...
  - 기능 단위 브랜치 (main 브랜치에서 분기)
  - Issue, Commit 컨벤션과 동일한 Prefix 사용하여 작업 구분
- 각 브랜치별 작업 내용 확인을 위해 브랜치명 컨벤션 도입
  - prefix/이슈번호-작업설명(PascalCase)
  - `Feat/1-ProjectSetting`

<br />

| Prefix  | Description | Prefix  | Description | 
|------------|-----------|------------|-----------|
| Feat | 새로운 기능에 대한 커밋 | UI | UI 스타일에 관한 커밋 |
| Fix | 버그 수정에 대한 커밋 | Refactor | 코드 리팩토링에 대한 커밋 |
| Build | 빌드 관련 파일 수정에 대한 커밋 | Test | 테스트 코드 수정에 대한 커밋 |
| Chore | 그 외 자잘한 수정에 대한 커밋 | Init | 프로젝트 시작에 대한 커밋 |
| Ci | CI 관련 설정 수정에 대한 커밋 | Release | 릴리즈에 대한 커밋 |
| Docs | 문서 수정에 대한 커밋 | WIP | 미완성 작업에 대한 임시 커밋 |

<br />

## 트러블 슈팅
### 1. CoreData에 저장되는 채팅 Custom Type 배열로 관리
-  CoreChatRoom 엔티티에 Message 데이터를 CustomType 배열 ([Message]) 형태로 관리
- CoreData에서 기본적으로 지원하지 않는 Custom Type은 직렬화/역직렬화 과정이 필요
> ### 문제점 🤔
 **1. 비효율적인 데이터 추가**
- 데이터 한 개를 추가하더라도 배열 전체를 역직렬화하여 메모리에 로드한 뒤, 다시 직렬화하여 저장해야 하는데 이 과정에서 불필요한 메모리 사용량 증가 및 속도 저하 발생

 **2. 검색/수정/삭제의 비효율성**
- 특정 데이터를 검색하거나 수정, 삭제하려면 배열 전체를 역직렬화한 후 조건에 따라 반복문으로 처리해야 함
- 데이터 크기에 비례한 O(n)의 시간 복잡도

> ### 개선 사항 🫢

**Custom Type 배열에서 Relationship으로 전환**

 **1. Relationship 설정**
- 1:N 관계로 변경: ChatRoom (1) → Message (N).
- ChatRoom의 roomID를 **Foreign Key**로 사용하여, Message가 속한 채팅방을 참조하도록 설계.

 **2. 시간 복잡도 개선**
- Custom Type 배열 관리 시: 조회, 수정, 삽입, 삭제 작업 모두 **O(n)**
- Relationship 구조로 변경 후
    - **추가**: **O(1)**
    - **검색**: **O(log n)**
    - **삭제**: **O(n)**
    - **수정**: **O(1)**
    
### 2. 유저 갤러리 접근 시 과도한 리소스 호출 문제
### 문제점 🤔
 **`1. 이미지 가져오기`**
- 사용자 갤러리에 접근 시 동기식으로 가져와서 UI가 끊기는 문제점 발생

### 개선 사항 🫢
- PHCachingImageManager에 isSynchronous 메서드를 통해 비동기 업로드를 통해 개선
- 페이징 처리 및 이미지 캐싱을 통해 개선
