[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?longCache=true)](Package.swift)
[![Written in Swift](https://img.shields.io/badge/Swift-5.3-orange.svg?longCache=true)](https://swift.org)
[![Supported platforms](https://img.shields.io/badge/iOS14-blue.svg?longCache=true)](Package.swift)

# SwiftUI InfiniteNavigation

InfiniteNavigation is a navigation framework for programmatic, unlimited navigation using the native push and present transitions and interactive gestures. Without reinventing the wheel, it leverages existing native iOS features to get the best out of the platform.

**Native SwiftUI implementation for iOS 16!** 

Additionally, it maintains backward compatibility until iOS 14 by utilizing UIKit.

![demo-gif](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExZTQ5ZWNkMDRmMDg0NDkzZDVhZjFkNDhmNjE2ZmU2OTYxODlhYzJjOSZjdD1n/vsAs2ngVs4sdQ01PQ4/giphy.gif)

## Why was InfiniteNavigation created?

In SwiftUI, NavigationStack offers a partial solution for programmatic navigation, but it lacks support for sheets and does not cover iOS 14 or 15. Moreover, the responsibility of navigation should not reside within the UI itself. Views should be free from concerns about which views will be presented next or how they will be presented.

Furthermore, existing third-party solutions often come with their own limitations, such as the absence of support for the native iOS swipe back gesture for dismissing views.

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
enum MyDestination: Hashable {
    case view1
    case view2
    ...
}
```

2. Implement the `NavDestinationBuilder`, which is just a function required by the `InfiniteNavContainer` to build a `SwiftUI.View` for each case of your destination enum.

```swift
@ViewBuilder
func build(for destination: MyDestination) -> some {
    switch destination {
    case .view1:
        View1()
    case .view2:
        View2()
    ...
    }
}
```

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
    environments: [YOUR_ENVIRONMENT_OBJECTS],
    viewBuilder: (YOUR_VIEW_TYPE) -> some View,
    homeView: () -> some View
)
```

Optional: the `initialStack` will setup the initial view state without an animation, on top of the `homeView`.

Optional: Providing `environments` to make them available to all views within the navigation stack.

5. Use the `PassthroughSubject` to manipulate the navigation stack.

```swift
// presentation
navigateTo.send(.show(.sheet(.view1))) // present View1 as full screen sheet
navigateTo.send(.show(.detail(.view2))) // push View2 as detail
navigateTo.send(.setStack([.view1, .view2])) // push an entire stack of views

// dismissal
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
