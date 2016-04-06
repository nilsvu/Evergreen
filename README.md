# Evergreen

> Most *natural* Swift logging

[![Build Status](https://travis-ci.org/viWiD/Evergreen.svg?branch=master)](https://travis-ci.org/viWiD/Evergreen)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Evergreen.svg)](https://img.shields.io/cocoapods/v/Evergreen.svg)
[![Platform](https://img.shields.io/cocoapods/p/Evergreen.svg?style=flat)](http://cocoadocs.org/docsets/Evergreen)
[![Gitter](https://badges.gitter.im/viWiD/Evergreen.svg)](https://gitter.im/viWiD/Evergreen?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Evergreen is a logging framework written in Swift. It is designed to work just as you would expect, yet so versatile you can make it work however you wish.

Integrate Evergreen logging into your Swift project to replace those plain `print()` statements with calls to Evergreen's versatile logging functions that make it easy to **adjust the verbosity** of the output, log to **multiple destinations** (e.g. a file) with **custom formatting** and even **measure time**.

```swift
import Evergreen

log("Hello World!", forLevel: .Info)
```

```sh
[AppDelegate.swift|INFO] Hello World!
```

> Evergreen logging is great to use in any Swift project, but particularly useful when developing a framework. Give the users of your framework the opportunity to easily adjust the verbosity of the output your framework generates.


## About Logging

> **Logging** is a means of tracking events that happen when some software runs. The software’s developer adds logging calls to their code to indicate that certain events have occurred. An event is described by a descriptive message which can optionally contain variable data (i.e. data that is potentially different for each occurrence of the event). Events also have an importance which the developer ascribes to the event; the importance can also be called the *level* or *severity*.
>
> &mdash; <cite>From the [Python documentation](https://docs.python.org/2/library/logging.html).</cite>

That's not what logging is for everyone, though. There are people who would say:

> **Logging** is the cutting, skidding, on-site processing, and loading of trees or logs onto trucks or skeleton cars.
>
> &mdash; <cite>From [Wikipedia](http://en.wikipedia.org/wiki/Logging).</cite>

For now, let's focus on what the Python people tell us. They seem to know what they are talking about.


## Installation

### CocoaPods

The easiest way to integrate Evergreen into your project is via [CocoaPods](http://cocoapods.org):

1. Install CocoaPods:

	```sh
	$ gem install cocoapods
	```

2. Create a `Podfile` in you project's directory or add Evergreen to your existing `Podfile`:

	```
	source 'https://github.com/CocoaPods/Specs.git'
	platform :ios, '8.0'
	use_frameworks!

	pod 'Evergreen'
	```

3. Let CocoaPods do its magic:

	```sh
	$ pod install
	```
	
As usual with CocoaPods, make sure to use the `*.xcworkspace` instead of the `*.xcodeproj`.

### Swift Package Manager (currently in beta)

You can also use the Swift Package Manager included in the [Swift 2.2 beta](https://swift.org/download/). Just add Evergreen as a dependency to your package description, like this:

```swift
import PackageDescription

let package = Package(
    name: "HelloWorld",
    dependencies: [
        .Package(url: "https://github.com/viWiD/Evergreen.git", majorVersion: 0),
        // ...
    ]
)
```

### Manually

You can also integrate Evergreen into you project manually:

1. Add Evergreen as a [submodule](http://git-scm.com/docs/git-submodule):

	```sh
	$ git submodule add https://github.com/viWiD/Evergreen.git
	```

2. Drag `Evergreen.xcodeproj` into the file navigator of your project.
3. In the target configuration under *General*, add `Evergreen.framework` to the *Embedded Binaries*


---


## Usage

> **Note:** Open the `Evergreen.xcworkspace` and have a look at the `Evergreen.playground` for a more interactive tour through Evergreen's functionality. You can also create a Playground in your project's workspace and `import Evergreen` to try for yourself.

### Logging without configuration

```swift
import Evergreen

log("Hello World!")
```

You can log events without any configuration and see a nicely formatted message show up in the console. This is for very quick and basic use only. Read on to learn about Evergreen's more sophisticated logging options.

### Using Log Levels

You can assign an *importance* or *severity* to an event corresponding to one of the following *log levels*:

- **Critical:** Events that are unexpected and can cause serious problems. You would want to be called in the middle of the night to deal with these.
- **Error:** Events that are unexpected and not handled by your software. Someone should tell you about these ASAP.
- **Warning:** Events that are unexpected, but will probably not affect the runtime of your software. You would want to investigate these eventually.
- **Info:** General events that document the software's lifecycle.
- **Debug:** Events to give you an understanding about the flow through your software, mainly for debugging purposes.
- **Verbose:** Detailed information about the environment to provide additional context when needed.

The logger that handles the event has a log level as well. **If the event's log level is lower than the logger's, it will not be logged.**

In addition to the log levels above, a logger can have one of the following log levels. Assigning these to events only makes sense in specific use cases.

- **All:** All events will be logged.
- **Off:** No events will be logged.

> With log levels, you can control the verbosity of your software. A common use case is to use a low log level during development and increase it in a release environment, or to adjust it for specific parts of your software and different logging destinations, such as the console or a file.

For a basic configuration, you can adjust Evergreen's default log level. Read about the *logger hierarchy* below to learn how to control the log level more granually.

```swift
Evergreen.logLevel = .Debug

// These events will be logged, because their log level is >= .Debug
log("Debug", forLevel: .Debug)
log("Info", forLevel: .Info)
log("Warning", forLevel: .Warning)
log("Error", forLevel: .Error)
log("Critical", forLevel: .Critical)

// These events will not be logged, because their log level is < .Debug
log("Verbose", forLevel: .Verbose)
```

Every log level has a corresponding log function for convenience:

```swift
debug("Debug") // equivalent to log("Debug", forLevel: .Debug)
info("Info") // equivalent to log("Info", forLevel: .Info)
// ...
```


### Using the Logger Hierarchy

You usually want to use *loggers* to log events instead of the global functions. A logger is always part of a hierarchy and inherits attributes, such as the log level, from its parent. This way, you can provide a default configuration and adjust it for specific parts of your software.

> This is particularly useful during development to lower the log level of the part of your software you are currently working on.

Every logger has a `key` to identify the source of any given event. In its hierarchy, the key expands to a dot-separated *key path*, such as "Parent.Child".

You can manually build your own hierarchy, of course, but Evergreen provides a convenient way for you to utilize this powerful feature:

- The *default logger* is the root of the logger hierarchy and can be retrieved using the `Evergreen.defaultLogger` constant. Use it to set a default log level. The global variable `Evergreen.logLevel` also refers to the default logger.
- Retrieve an appropriate logger using the global `Evergreen.getLogger()` function or one of various instance and class methods like `logger.childForKeyPath()`. Provide a key path that describes the part of your software the event is relevant for, such as `"MyModule.MyType"`. These methods will always return the same logger instance for a given key path and establish the logger hierarchy, if it does not yet exist.

It is convenient to use a constant stored attribute to make an appropriate logger available for a given type:

```swift
import Evergreen

class MyType {
	
	let logger = Evergreen.getLogger("MyModule.MyType")
	
	init() {
		self.logger.debug("Initializing...")
	}
	
}
```

Having established a logger hierarchy, you can adjust the logging configuration for parts of it:

```swift
Evergreen.logLevel = .Warning // Set the defaultLogger's log level to .Warning
let logger = Evergreen.getLogger("MyModule") // Retrieve the logger with key 'MyModule' directly descending from the default logger
logger.logLevel = .Debug // We are working on this part of the software, so set its log level to .Debug
```

> **Note:** A good place to do this configuration for production is in the `AppDelegate`'s `application:didFinishLaunchingWithOptions:` method. Temporary log level adjustments are best configured as environment variables as described in the following section.


### Using Environment Variables for Configuration

The preferred way to temporarily configure the logger hierarchy is using environment variables. This way, you can conveniently enable more verbose logging for the parts of your software you are currently working on. In Xcode, choose your target from the dropdown in the toolbar, select `Edit Scheme...` `>` `Run` `>` `Arguments` and add environment variables to the list.

Every environment variable prefixed `Evergreen` is evaluated as a logger key path and assigned a log level corresponding to the variable's value. Values should match the log level descriptions, e.g. `Debug` or `Warning`.

Valid environment variable declarations would be e.g. `Evergreen = Debug` or `Evergreen.MyLogger = Verbose`.


### Logging `ErrorType` Errors alongside your Events

You can pass any error conforming to Swift's `ErrorType` (such as `NSError`) to Evergreen's logging functions, either as the message or in the separate `error:` argument:

```swift
let error: ErrorType // some error
debug("Something unexpected happened here!", error: error)
```


### Measuring Time

Easily measure the time between two events:

```swift
tic(andLog: "Starting expensive operation...", forLevel: .Debug)
// ...
toc(andLog: "Completed expensive operation!", forLevel: .Info)
```

```sh
[Default|DEBUG] Starting expensive operation...
[Default|INFO] Completed expensive operation! [ELAPSED TIME: 0.0435580015182495s]
```

You can also use the `timerKey` argument for nested timing:

```swift
tic(andLog: "Starting expensive operation...", forLevel: .Debug, timerKey: "expensiveOperation")
for var i=0; i<10; i++ {
	tic(andLog: "\(i+1). iteration...", forLevel: .Verbose, timerKey: "iteration")
	// ...
	toc(andLog: "Done!", forLevel: .Verbose, timerKey: "iteration")
}
toc(andLog: "Completed expensive operation!", forLevel: .Info, timerKey: "expensiveOperation")
```

### Logging Events only once

You can keep similar events from being logged in excessive amounts by associating a `key` with them in any logging call, e.g.:

```swift
debug("Announcing this once!", onceForKey: "announcement")
```


## Advanced Usage

### Using Handlers

When a logger determines that an event should be handled, it will pass it to its *handlers*. A handler uses its *formatter* to retrieve a human-readable *record* from the event and then *emits* the record. Subclasses of `Handler` emit records in different ways:

- A `ConsoleHandler` prints the record to the console.
- A `FileHandler` writes the records to a file.
- A `StenographyHandler` appends the record to an array in memory.

> You can override `emitRecord:` in you own subclass to implement any custom behaviour you like, e.g. send it to a server.

Evergreen's `defaultLogger` has a `ConsoleHandler` attached by default, so every event in its hierarchy will be logged to the console. You can easily add additional handlers, by appending them to an appropriate logger's `handlers` array:

```swift
let logger = Evergreen.defaultLogger
let stenographyHandler = StenographyHandler()
logger.handlers.append(stenographyHandler)
```

You can also set a handler's `logLevel`, to add an additional level of filtering.

### Formatting

Evergreen's `Formatter` class implements a convenient way for you to adjust the format of log records.

The default implementation of the `recordFromEvent:` method, that you can also override in a subclass, of course, uses a list `components: [Formatter.Component]` to construct a record from an event using instances of the `Formatter.Component` enumeration:

```swift
let simpleFormatter = Formatter(components: [ .Text("["), .Logger, .Text("|"), .LogLevel, .Text("] "), .Message ])
let consoleHandler = ConsoleHandler(formatter: simpleFormatter)
Evergreen.defaultLogger.handlers = [ consoleHandler ]
```


---

## Contact

Evergreen was created and is maintained by [Nils Fischer](http://www.viwid.com) ([@knlyy](https://twitter.com/knlyy)).

## Roadmap

The beta status of this framework mostly means that I haven't quite finished writing the documentation yet.

Before finalizing a 1.0 release, I would greatly appreciate some professional opinions on the API and architecture. Any suggestions via Email ([n.fischer@viwid.com](mailto:n.fischer@viwid.com)) or Tweet ([@knlyy](https://twitter.com/knlyy)) are very welcome!

## License

Evergreen is released under the MIT license. See LICENSE.md for details.
