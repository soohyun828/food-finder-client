# Food Finder
한식? 중식? 일식? 원하는 음식 종류가 있다면 해당 음식점들을 리스트업 해주고 경로 안내까지!

## 페이지 별 기능
### [초기화면 & 회원가입 & 로그인]
#### [초기화면]
- 서비스 접속시 splash 화면이 잠시 나온 뒤 로그인/회원가입 선택 페이지가 나타납니다.
#### [회원가입 & 로그인]
- 회원가입 시, 동일한 아이디로 가입된 아이디 중복 확인을 진행합니다.
- 비밀번호는 암호화해서 DB에 저장됩니다.
- 회원가입 완료시, 로그인 화면으로 바로 넘어갑니다.

![Image](https://github.com/user-attachments/assets/34d14a01-a4c8-44de-ae84-9ce863edaff0) |   ![Image](https://github.com/user-attachments/assets/a5e006d4-ed5e-4cab-8c48-4bcce981001b) |

### [음식점 리스트업 & 북마크 관리]
- 로그인하면 사용자 위치 기준 근방 5km 내의 원하는 업종별 음식점들을 거리순으로 리스트업 받을 수 있습니다. 
- 북마크 정보는 사용자 별로 따로 DB에서 관리합니다.

![Image](https://github.com/user-attachments/assets/2197970d-5625-434b-bf5b-23438449cb20)

### [메뉴로 음식점 검색]
- 북마크 탭에서 사용자의 북마크 음식점 리스트를 볼 수 있고, 삭제도 가능합니다.
- 검색한 메뉴를 파는 음식점들을 리스트업 받을 수 있습니다.

![Image](https://github.com/user-attachments/assets/9ee8d12d-0a37-414e-9eb0-36e0607f3f0a)

### [음식점 길찾기 (카카오 내비 연동)]
- 현재 사용자의 위치로부터 사용자가 선택한 음식점까지의 경로 안내가 시작됩니다.
  
![Image](https://github.com/user-attachments/assets/030111ad-d5b2-469b-bbd2-dbb39d154af1)

## 화면 구성 및 DB 서버 상호작용

![Image](https://github.com/user-attachments/assets/5a6ccbab-723e-4511-a32b-84ffc52fbab2)
![Image](https://github.com/user-attachments/assets/b3bebaae-d868-422d-8727-6f150cb156b1)
![Image](https://github.com/user-attachments/assets/cad27210-b0ba-40b4-a203-58a8232859e9)
![Image](https://github.com/user-attachments/assets/840b8a70-37da-4d6b-870b-2d5091a7cf55)

