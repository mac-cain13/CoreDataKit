# CoreDataKit

**CoreDataKit takes care of the hard and verbose parts of CoreData. It manages child contexts for you and helps to easily fetch, create and delete objects.**

> *CoreData:* object graph management solution, including persistence. *Kit:* set of equipment needed for a specific purpose.

## Installation

_Due to the current lack of [proper infrastructure](http://cocoapods.org) for Swift dependency management, using CoreDataKit in your project requires the following steps:_

1. Add CoreDataKit as a [submodule](http://git-scm.com/docs/git-submodule) by opening the Terminal, `cd`-ing into your top-level project directory, and entering the command `git submodule add https://github.com/mac-cain13/CoreDataKit.git`
2. Open the `CoreDataKit` folder, and drag `CoreDataKit.xcodeproj` into the file navigator of your app project.
3. In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
4. Ensure that the deployment target of CoreDataKit.framework matches that of the application target.
5. In the tab bar at the top of that window, open the "Build Phases" panel.
6. Expand the "Target Dependencies" group, and add `CoreDataKit.framework`.
7. Click on the `+` button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `CoreDataKit.framework`.

## Usage

The most basic and most used variant to setup a stack backed by an automigrating SQLite store is this:
```
// Initialize CoreData stack
if let persistentStoreCoordinator = NSPersistentStoreCoordinator(automigrating: true) {
  CoreDataKit.sharedStack = CoreDataStack(persistentStoreCoordinator: persistentStoreCoordinator)
}
```

From here you are able to use the shared stack. For example to create and save an entity, this example performs a block an a background context, saves it to the persistent store and executes a completion handler:
```
CoreDataKit.performBlockOnBackgroundContext({ context in
	if let car = context.create(Car.self).successValue() {
		car.color = "Hammerhead Silver"
		car.model = "Aston Martin DB9"
	}

	return .SaveToPersistentStore
}, completionHandler: { result, _ in
    switch result {
    case .Success:
    	println("Car saved, time to update the interface!")
      
    case let .Failure(error):
      	println("Saving Harvey Specters car failed with error: \(error)")
    }
})
```

## Contributing

We'll love contributions, please report bugs in the issue tracker, create pull request (please branch of `develop`) and suggest new great features (also in the issue tracker).

## License & Credits

CoreDataKit is written by [Mathijs Kadijk](https://github.com/mac-cain13) and available under the [MIT license](LICENSE), so feel free to use it in commercial and non-commercial projects. CoreDataKit is inspired on [MagicalRecord](https://github.com/magicalpanda/MagicalRecord).
