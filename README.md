[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?longCache=true)](Package.swift)
[![Written in Swift](https://img.shields.io/badge/Swift-5.3-orange.svg?longCache=true)](https://swift.org)
[![Supported platforms](https://img.shields.io/badge/iOS14-blue.svg?longCache=true)](Package.swift)

# SwiftUI InfiniteNavigation

InfiniteNavigation is a Swift Package for SwiftUI that provides a programmatic navigation framework for unlimited nested navigations using the native push and present transitions.

![demo-gif](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExZTQ5ZWNkMDRmMDg0NDkzZDVhZjFkNDhmNjE2ZmU2OTYxODlhYzJjOSZjdD1n/vsAs2ngVs4sdQ01PQ4/giphy.gif)

## Why was InfiniteNavigation created?

The standard navigation framework including `NavigationLink` and `.sheet()` provided by SwiftUI is limited in its nesting capabilities, which can make it difficult to create complex navigation structures in your app. Additionally, existing third-party solutions often come with their own limitations, such as no support for the native iOS swipe back gesture when pushing a view.

InfiniteNavigation was created to provide a solution that is easy to use and understand, and that leverages the native iOS push and present transitions. With InfiniteNavigation, you can create unlimited nested navigations and navigate programmatically without worrying about limitations or the complexity of other solutions.

## Features

- Unlimited nested navigations (push, present, push, present and so on...)
- Uses native iOS push and present transitions
- Easy to use API
- Lightweight and performant

## Requirements

- iOS 14.0 or later
- Swift 5.3+

## Installation

You can install InfiniteNav using Swift Package Manager. Simply add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/davidscheutz/swiftui-infinite-navigation.git", from: "1.0.0")
]
```

## Components

InfiniteNavigation is built of three main components:

**NavDestination**

A wrapper to determine whether a view should be presented or pushed.

```swift
public enum NavDestination<T> {
    case detail(T) // push
    case sheet(T)  // present 
}
```

**NavAction**

Operations to manipulate the current navigation stack.

```swift
enum NavAction<T> {
    case show(NavDestination<T>)
    case setStack([T])
    case dismiss
    case pop  // singe detail
    case popToCurrentRoot // all details of current stack
}
```

**InfiniteNavContainer**

The heart of the framework. It leverages `UINavigationController` and standard `UIKIt` presentation APIs to deliver a native, solid user experience and performance.

## Usage

InfiniteNavigation is easy to use and works great with the Coordinator and other navigation patterns.

Let's put it all together.

1. Create an `enum` that represents all your view destinations, e.g.:

```swift
enum MyDestination {
    case view1
    case view2
    ...
}
```

2. Implement the `NavDestinationBuilder`, which is just a function required by the `InfiniteNavContainer` to build a `SwiftUI.View` for each case of your destination enum.

```swift
func build(for destination: MyDestination) -> AnyView {
    switch destination {
    case .view1:
        return View1().toAnyView()
    case .view2:
        return View2().toAnyView()
    ...
    }
}
```

PS: InfiniteNavigation comes with a handy `.toAnyView()` view extension.

3. Create a `Combine.Publisher` that will be used to command the `InfiniteNavContainer`.

```swift
private(set) lazy var navPublisher = navigateTo.eraseToAnyPublisher()    
private let navigateTo = PassthroughSubject<NavAction<MyDestination>, Never>()
```

It's recommended to use a dedicated object that encapsulates your app navigation.

4. Setup the `InfiniteNavContainer` using the newly created destination enum, destination publisher and the view builder:

```swift
InfiniteNavigation.create(
    initialStack: Array<YOUR_VIEW_TYPE>,
    navAction: AnyPublisher<NavAction<YOUR_VIEW_TYPE>>,
    environment: YOUR_ENVIRONMENT,
    viewBuilder: (YOUR_VIEW_TYPE) -> AnyView,
    homeView: () -> some View
)
```

Optional: the `initialStack` will setup the initial view state without an animation, on top of the `homeView`.

Optional: Providing an `environment` to make it available to all views on the stack.

5. Use the `PassthroughSubject` to manipulate the navigation stack.

```swift
navigateTo.send(.show(.sheet(.view1))) // present View1 as full screen sheet
navigateTo.send(.show(.detail(.view2))) // push View2 as detail
navigateTo.send(.setStack([.view1, .view2])) // push an entire stack of views

navigateTo.send(.dismiss)
navigateTo.send(.pop)
navigateTo.send(.popToCurrentRoot) // pop to root of current stack, each sheet has it's own stack
```

## Demo

To see InfiniteNavigation in action, you can check out the included demo project. The demo project showcases an example of how to use the framework in a real-world-ish scenario.

To run the demo project, follow these steps:

1. Clone the InfiniteNavigation repository
2. Open the project using Xcode
3. Select InfiniteNavigationDemo target
4. Build and run the project

## Contributing

Contributions to InfiniteNavigation are welcome and encouraged! If you have an idea for a feature or improvement, please submit a pull request or open an issue.

## License

InfiniteNavigation is available under the MIT license. See the LICENSE file for more information.

## Credits

InfiniteNavigation was created by [David Scheutz](https://www.linkedin.com/in/david-scheutz-192334157/).
