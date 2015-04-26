> This is a preliminary document and this framework is still under heavy development. Feel to give it a try and let me know your thoughts.

# Evergreen

Evergreen is a logging framework written in Swift.

```swift
import Evergreen

log("Hello World!", forLevel: .Info)
```

```sh
2015-04-26 01:48:32.415 [AppDelegate.swift|INFO] Hello World!
```

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

### Manually


---


## Usage

### Logging without configuration

```swift
import Evergreen

log("Hello World!")
```

You can log events without any configuration and see a nicely formatted message show up in the console. This is for very quick and basic use only. Read on to learn about Evergreen's more sophisticated logging options.

### Using Log Levels

You can assign an *importance* or *severity* to an event corresponding to one of the following *log levels*:

- **Critical:** Events that are unexpected and can cause serious problems. You would want to be called in the middle of the night to deal with these.
- **Error:** Events that are unexpected and can cause serious problems. Someone should tell you about these straight away.
- **Warning:** Events that are unexpected, but will probably not affect the runtime of your software. You would want to investigate these eventually.
- **Info:** General events that document the software's lifecycle.
- **Debug:** Events to give you an understanding about the flow through the system.
- **Verbose:** Detailed information about the environment.

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

### Using the Logger Hierarchy

You usually want to use *loggers* to log events instead of the global `log` function. A logger is always part of a hierarchy and inherits attributes, such as the log level, from its parent. This way, you can provide a default configuration and adjust it for specific parts of your software.

> This is particularly useful during development to lower the log level of the part of your software you are currently working on.

Every logger has a `key` to identify the source of any given event. In its hierarchy, the key expands to a dot-separated *key path*, such as "Parent.Child".

You can manually build your own hierarchy, of course, but Evergreen provides a convenient way for you to utilize this powerful feature:

- The *default logger* is the root of the logger hierarchy and can be retrieved using the `Evergreen.defaultLogger` constant. Use it to set a default log level. The global variable `Evergreen.logLevel` also refers to the default logger.
- Retrieve an appropriate logger using the `childForKeyPath:` instance method or one of various class methods like `Logger.loggerForKeyPath:`. Provide a key path that describes the part of your software the event is relevant for, such as `"MyModule.MyType"`. These methods will always return the same logger instance for a given key path and establish the logger hierarchy, if it does not yet exist.

It is convenient to use a *Computed Property* to retrieve the appropriate logger for a type:

```swift
import Evergreen

extension MyType {
	
	var logger: Logger {
		return Logger.loggerForKeyPath("MyModule.MyType")
	}
	
}
```

Now, you can easily log events using the type's `logger` property:

```swift
self.logger.log("Initializing...", forLevel: .Debug)
```

To adjust the logging configuration 

```swift
Evergreen.logLevel = .Warning // Set the default log level to .Warning
let logger = Logger.loggerForKeyPath("MyModule") // Retrieve a logger with the key 'MyModule' descending from the default logger
logger.logLevel = .Debug // We are working on this part of the software, so set its log level to .Debug
```

> **Note:** A good place to do this configuration is in the `AppDelegate`'s `application:didFinishLaunchingWithOptions:` method.

### Using Environment Variables for Configuration

## Advanced Usage

### Using Handlers

### Formatting


---


## Contact

Evergreen was created by [Nils Fischer](http://www.viwid.com).

## License

Evergreen is released under the MIT license. See LICENSE for details.

## TODOs

- [ ] Add a way to log details about the app, e.g. version, build, ...
- [ ] Add support for colors in the console
- [ ] Implement additional handlers, e.g. to send records to a server or via Email
- [ ] Never stop adding tests
