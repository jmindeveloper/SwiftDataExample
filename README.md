WWDC2023에서 새롭게 발표된 SwiftData를 간단하게 사용해봤습니다. 설명이 자세하지 못하거나 부정확할 수 있습니다

> SwiftData는 Xcode beta 15.0 이상, iOS beta 17.0, Swift 5.9 이상부터 사용 가능합니다

# 1. SwiftData란?
---
![](https://velog.velcdn.com/images/kjm9683/post/b394b86e-f79e-4138-940d-2a9b81271e6a/image.png)

앱이 생성하거나 소비하는 데이터를 모델링하는 여러 사용자 지정 유형을 정의할 가능성이 높습니다. 예를 들어, 여행 앱은 여행, 항공편 및 예약된 숙박 시설을 나타내는 클래스를 정의할 수 있습니다. SwiftData를 사용하면 해당 데이터를 빠르고 효율적으로 유지하여 앱 실행에서 사용할 수 있으며, SwiftUI와 프레임워크의 통합을 활용하여 해당 데이터를 다시 가져와 화면에 표시할 수 있습니다.

설계에 따라, SwiftData는 기존 모델 클래스를 보완합니다. 이 프레임워크는 스위프트 코드에서 앱의 스키마를 표현적으로 설명할 수 있는 매크로 및 속성 래퍼와 같은 도구를 제공하여 모델 및 마이그레이션 매핑 파일과 같은 외부 종속성에 대한 의존성을 제거합니다.

# 2. 예시
---
해당 예시에서는 SwiftData 를 이용해서 간단한 todo 앱을 만들어 볼거다
SwiftUI 및 UIKit 에서의 사용법을 알아볼것이며 먼저 SwiftUI로 설명 후 UIKit에서의 차이점을 설명하겠다
## 2.1 SwiftUI
### 2.1.1 Model
model은 macro이다
macro에 대한 설명은 [여기](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)서 볼 수 있다

모델클래스는 자동으로 `PersistentModel` 및 `Observable` 프로토콜을 채택한다
> PersistentModel 프로토콜은 SwiftData가 Swift 클래스를 저장된 모델로 관리할 수 있는 인터페이스이며 AnyObject를 채택하고 있다<br>
따라서 @model 은 struct에서 사용하지 못한다

```swift
@Model
class TodoItem {
    let id: UUID
    
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(title: String, isCompleted: Bool, createdAt: Date) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
```
### 2.1.2 Configure Model Storage
앱은 런타임에 어떤 모델을 유지하고 기본 스토리지에 사용할 구성을 알아야 한다
```swift
@main
struct SwiftDataExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [TodoItem.self])
        }
    }
}
```
기본 스토리지를 설정하기 위해 `modelContainer`를 사용한다
모든 중첩된 뷰가 제대로 구성된 환경을 사용할 수 있도록 뷰 계층의 맨 위에 추가해야 한다

modelContainer(for:inMemory:isAutosaveEnabled:isUndoEnabled:onSetup:) 
- for modelType: 모델 컨테이너를 만드는 데 사용되는 스키마를 정의하는 모델 유형
- inMemory: 컨테이너가 데이터를 메모리에만 저장해야 하는지여부
  - 기본적으로 컨테이너는 모델 데이터를 디스크에 지속적으로 저장한다. 만약 앱 수명동안 메모리에만 데이터를 저장할려면 해당 파라미터에 false를 전달해야 한다	
- isAutosaveEnabled: 자동 저장을 활성화할려면 true
  - context에 변화가 생겼을때 디스크에 자동저장된다. 만약 해당 파라미터에 false가 전달된다면 디스크에 저장하기 위해 save() 함수를 호출해 줘야 할것이다
- onSetup: 컨테이너 생성이 성공 or 실패했을 때 호출되는 콜백

> Container는 한 번만 생성된다
> 뷰가 처음 생성된 후 modelType 및 inMemory 파라미터에 전달되는 새로운 값은 무시된다

### 2.1.3 Fetch Models
런타임에 모델 클래스의 인스턴스를 관리하려면 모델 데이터와 모델 컨테이너와의 조정을 담당하는 객체인 `model Context` 가 있어야 한다
SwiftUI에서는 `@Environment(\.modelContext)`를 사용하면 된다
```swift
@Environment(\.modelContext) private var context
```
SwiftData는 모델 데이터를 가져오기를 수행하기 위한 `Query PropertyWrapper` 및 `FetchDescription` 을 제공한다
`FetchDescription`은 밑에 UIKit에서 알아보겠다
```swift
@Query(sort: [SortDescriptor<TodoItem>(\TodoItem.title, order: .forward), SortDescriptor<TodoItem>(\TodoItem.createdAt, order: .forward)], animation: .default) var allTodoItems: [TodoItem]
```
sort는 SortDescriptor  의 배열이며 모델을 가져올때 정렬조건이다
정렬조건이 하나일 경우에는
```swift
@Query(sort: \.title, order: .forward, animation: .default) var allTodoItems: [TodoItem]
```
이렇게도 사용 가능하다
@Model 메크로는 클래스에 Observable 프로토콜을 채택하므로 가져온 인스턴스에 변경이 발생하면 뷰를 새로 고칠 수 있다
### 2.1.4 Save Models
```swift
let todo = TodoItem(title: todoTitle, isCompleted: isCompleted, createdAt: Date())
context.insert(todo)
```
todo 인스턴스를 생성 후 context에 insert 해준다

만약 2.1.2 과정에서 isAutosaveEnabled를 true 로 해주었다면 컨텍스트는 인스턴스의 변경사항을 자동으로 추적하고 디스크에 저장할 것 이다
만약 false로 해주었다면 적절한 시점에 save() 메서드를 호출하여 저장해주면 된다

물론 저장 외에도 변경, 삭제가 가능하며 [전체코드](https://github.com/jmindeveloper/SwiftDataExample/tree/master)에서 확인 가능하다
## 2.2 UIKit
### 2.2.1 ModelContainer
SwiftUI에서는 modelContainer 로 뷰에 직접 container를 주입해 주었다
하지만 UIKit에서는 modelContainer 를 사용하지 못하기 때문에 container를 직접 생성해 줘야 한다
```swift
let container = try? ModelContainer(for: [TodoItem.self])
```
### 2.2.2 fetchDescriptor
UIKit에서는 Query Property Wrapper를 지원하지 않는다
따라서 위에서 본 `FetchDescription`를 사용해야 한다
```swift
func fetchContext() {
	let fetchDescriptor = FetchDescriptor<TodoItem>(sortBy: [SortDescriptor<TodoItem>(\TodoItem.title, order: .forward), SortDescriptor<TodoItem>(\TodoItem.createdAt, order: .forward)])
	self.todoItems = (try? context?.fetch(fetchDescriptor)) ?? []
}
```
query property wrapper 랑 거의 동일하다
다만 fetchDescriptor에서는 fetch 조건, fetchLimit, fetchOffset 등 좀더 세세한 설정을 할 수 있다

> fetchDescriptor에 대해 더 자세히 알려면 [클릭](https://developer.apple.com/documentation/swiftdata/fetchdescriptor)

하지만 fetchDescriptor 는 context의 변화를 알려주지는 않는것 같다 (제가 못찾는 것일수도)
따라서 context가 변할때마다 위 함수를 실행시켜줘서 view를 업데이트 해주고 있다

---
참고
https://developer.apple.com/documentation/swiftdata/preservingyourappsmodeldataacrosslaunches#Save-models-for-later-use
전체코드
https://github.com/jmindeveloper/SwiftDataExample/tree/master