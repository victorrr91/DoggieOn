<img width="250" alt="어플 스크린샷" src="https://user-images.githubusercontent.com/76080066/220016407-45b4bc12-e590-48d8-950a-3a9bb9295217.png">


구현 사항

- 무한 스크롤링을 통해 페이지 로드
- Multipart/Form-data 형식으로 이미지 파일 업로드
- 하트 아이콘을 이용하여 like, unlike 구현

배운 점

- 페이지를 불러오는 과정을 시각적으로 표현해야 사용자가 상황을 인식할 수 있음
    
    → indicator 등을 활용
    
- Multipart/Form-data를 통해 이미지 업로드하는 방법을 배움
    
    → 어플을 개발하면서 자주 개발하게될 요소라 좋은 경험이 됨
    
- Rx를 사용하지 않고 클로져 기반으로 API 처리
- 데이터를 불러오고 저장할 시점에 대한 고민
    
    → like/unlike와 같이 빈번한 통신의 경우도 서버와 바로 싱크를 맞추는 것이 좋음 (다운 등으로 갑작스런 종료에도 데이터 보존) , 하지만 무거운 데이터의 경우는 캐싱 후 푸시를 생각해볼 법도 함.

포트폴리오 사이트: [https://victorios.imweb.me/Projects](https://victorios.imweb.me/Projects)
