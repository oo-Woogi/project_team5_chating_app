### GPS 기반 채팅 앱 💬

📌 프로젝트 소개

이 프로젝트는 GPS 위치 정보와 실시간 채팅 기능을 결합한 GPS 기반 채팅 앱입니다.
사용자는 현재 위치(읍면동 단위)를 기반으로 해당 지역의 다른 사용자와 실시간으로 소통할 수 있습니다.
Flutter를 사용하여 크로스 플랫폼(Android/iOS)을 지원하며, 상태 관리를 위해 Riverpod 기반의 MVVM 아키텍처를 적용했습니다.

📂 프로젝트 바로가기 링크

⭐️ Notion: https://www.notion.so/teamsparta/5-23a2dc3ef514811489b1cb6bbec2e9e0
⭐️ Figma: https://www.figma.com/design/bHTT0QkbvTu1ts2m34qVLn/Flutter-%EC%88%99%EB%A0%A8-5%EC%A1%B0?node-id=1082-1215&p=f&t=G55YJSS4PUBTRtid-0
⭐️ GitHub: https://github.com/oo-Woogi/project_team5_chating_app

💡 프로젝트 개요

위치 기반 서비스와 채팅 기능을 결합하여, 사용자들이 특정 지역 커뮤니티를 형성하고 소통할 수 있는 플랫폼을 구축하는 것을 목표로 합니다.

🎯 프로젝트 기능

WelcomePage: 사용자 이름 입력, 현재 위치(읍면동) 정보 획득, 채팅 시작
ChatPage: 실시간 채팅 목록 표시, 메시지 입력 및 전송
GPS 기능: geolocator 패키지를 이용해 현재 위치 좌표 획득
VWORLD API 연동: GPS 좌표를 읍면동 주소로 변환
Firebase Firestore: 실시간 채팅 데이터 저장 및 불러오기 (address 필터링 및 createdAt 정렬)
프로필 사진 업로드 (도전 기능): image_picker와 Firebase Storage를 활용한 프로필 사진 업로드 및 채팅에 표시

📚 기술 스택

프레임워크: Flutter
상태 관리: Riverpod (MVVM 아키텍처)
백엔드: Firebase Firestore, Firebase Storage
네트워크: dio
위치 정보: geolocator, VWORLD API
개발 도구: Visual Studio Code, Figma, GitHub

🧠 고민한 점

Riverpod를 활용한 MVVM 구조에서 상태 관리와 데이터 흐름을 어떻게 설계할 것인가?
Firebase Firestore의 where와 orderBy를 함께 사용할 때 발생하는 인덱싱 문제를 어떻게 해결할 것인가?
geolocator를 이용한 GPS 권한 요청 및 위치 정보 획득 로직을 안정적으로 구현하는 방법
VWORLD API를 연동하여 주소 정보를 정확하게 변환하는 방법

🚀 프로젝트 시작하기

1. 환경 설정
Flutter SDK: Flutter 공식 홈페이지
Firebase 프로젝트: Firebase 콘솔에서 프로젝트 생성 및 연동
VWORLD API: VWORLD 개발자 센터에서 API 키 발급

2. 패키지 설치
pubspec.yaml에 필요한 패키지를 추가하고 flutter pub get 명령어를 실행합니다.

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: # 상태 관리
  firebase_core: # 파이어베이스 코어
  cloud_firestore: # 파이어베이스 데이터베이스
  geolocator: # GPS
  dio: # VWORLD API 연동
  firebase_storage: # 파이어베이스 스토리지
  image_picker: # 이미지 선택
