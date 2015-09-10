# CoreDataKit

**CoreDataKit takes care of the hard and verbose parts of CoreData. It manages child contexts for you and helps to easily fetch, create and delete objects.**

> *CoreData:* object graph management solution, including persistence. *Kit:* set of equipment needed for a specific purpose.

## Installation

[CocoaPods](http://cocoapods.org) is the advised way to include CoreDataKit into your project. A basic [Podfile](http://cocoapods.org/#get_started) including CoreDataKit would look like this:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'CoreDataKit', '~> 0.8'
```

## Usage

The most basic and most used variant to setup a stack backed by an automigrating SQLite store is this:
```swift
// Initialize CoreData stack
if let persistentStoreCoordinator = NSPersistentStoreCoordinator(automigrating: true) {
  CDK.sharedStack = CoreDataStack(persistentStoreCoordinator: persistentStoreCoordinator)
}
```

### Implement NamedManagedObject protocol

For CoreDataKit to be able to use your NSManagedObject subclass, such as Car in the example below, CDK needs to have the subclass implement the NamedManagedObject protocol in order to be able to initialize your class:

```swift
class Car: NSManagedObject, NamedManagedObject {

  static var entityName = "Car" // corresponding to your Entity name in your xcdatamodeld
  
  @NSManaged var color: String
  @NSManaged var model: String
}

```

From here you are able to use the shared stack. For example to create and save an entity, this example performs a block an a background context, saves it to the persistent store and executes a completion handler:
```swift
CDK.performBlockOnBackgroundContext({ context in
  do {
    let car = try context.create(Car.self)
    car.color = "Hammerhead Silver"
    car.model = "Aston Martin DB9"

    return .SaveToPersistentStore
  }
  catch {
    return .DoNothing
  }
}, completionHandler: { result in
  do {
    try result()
    print("Car saved, time to update the interface!")
  }
  catch {
    print("Saving Harvey Specters car failed with error: \(error)")
  }
})
```

### Using promises

If you prefer using promises, instead of the callback style of this library, you can use the  [Promissum](https://github.com/tomlokhorst/Promissum) library with CoreDataKit. Using the [CoreDataKit+Promise](https://github.com/tomlokhorst/Promissum/blob/develop/extensions/PromissumExtensions/CoreDataKit%2BPromise.swift) extension, the example from above can be rewritten as such:
```swift
let createPromise = CDK.performBlockOnBackgroundContextPromise { context in
  do {
    let car = try context.create(Car.self)
    car.color = "Hammerhead Silver"
    car.model = "Aston Martin DB9"

    return .SaveToPersistentStore
  }
  catch {
    return .DoNothing
  }
}

createPromise
  .then { _ in
    print("Car saved, time to update the interface!")
  }
  .trap { error in
    print("Saving Harvey Specters car failed with error: \(error)")
  }
```

## Contributing

We'll love contributions, please report bugs in the issue tracker, create pull request (please branch of `develop`) and suggest new great features (also in the issue tracker).

## License & Credits

CoreDataKit is written by [Mathijs Kadijk](https://github.com/mac-cain13) and available under the [MIT license](LICENSE), so feel free to use it in commercial and non-commercial projects. CoreDataKit is inspired on [MagicalRecord](https://github.com/magicalpanda/MagicalRecord).
