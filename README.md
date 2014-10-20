> This is a preliminary document and this framework is still under heavy development.

# $MODULE_NAME

TODO: logo and subtitle

$MODULE_NAME is a logging framework written in Swift.

TODO: short teaser / example


## About Logging

> **Logging** is a means of tracking events that happen when some software runs. The software’s developer adds logging calls to their code to indicate that certain events have occurred. An event is described by a descriptive message which can optionally contain variable data (i.e. data that is potentially different for each occurrence of the event). Events also have an importance which the developer ascribes to the event; the importance can also be called the *level* or *severity*. *From the [Python documentation](https://docs.python.org/2/library/logging.html).*

That's not what logging is for everyone, though. There are people who would say:

> **Logging** is the cutting, skidding, on-site processing, and loading of trees or logs onto trucks or skeleton cars. *From [Wikipedia](http://en.wikipedia.org/wiki/Logging).*

For now, let's focus on what the Python people tell us. They seem to know what they are talking about.


## Overview

- Instead of using those plain old `print` statements, send events to a `Logger` instance. It will pass the event to its `handlers`.
- A `Handler` uses its `Formatter` to 


## Installation

TODO: describe installing submodule


## Usage

### Logging without configuration

	import $MODULE_NAME
	
	log("TODO: find cool message to log")

You can log events without any configuration and see a nicely formatted message show up in the console. This is for very quick and basic use only. Read on to find out about $MODULE_NAME's *log levels* and the *logger hierarchy*.

### Using Log Levels

You can assign an *importance* or *severity* to an event corresponding to one of the following *log levels*:

TODO: describe these better (http://stackoverflow.com/questions/7839565/logging-levels-logback-rule-of-thumb-to-assign-log-levels can be helpful)

- **Critical:** Events that are unexpected and can cause serious problems. You would want to be called in the middle of the night to deal with these.
- **Warning:** Events that are unexpected, but will probably not affect the runtime of your software. You would want to investigate these eventually.
- **Info:** General events that describe the system lifecycle.
- **Debug:** Events to give you an understanding about the flow through the system.
- **Verbose:** Detailed information about the environment.

The logger that handles the event has a log level as well. **If the event's log level is lower than the logger's, it will not be logged.** In addition to the log levels above, a logger can have one of the following log levels. Assigning these to events only makes sense in specific use cases.

- **All:** All events will be logged.
- **Off:** No events will be logged.

> With log levels, you can control the verbosity of your software. A common use case is to use a low log level during development and increase it in a release environment, or to adjust it for specific parts of your software and different logging destinations, such as the console or a file.

For a basic configuration, you can adjust $MODULE_NAME's default log level. Read about the *logger hierarchy* below to learn how to control the log level more specifically.

	$MODULE_NAME.logLevel = .Debug
	
	// These events will be logged, because their log level is >= .Debug
	log("debug msg", forLevel: .Debug)
	log("info msg", forLevel: .Info)	
	log("warning msg", forLevel: .Warning)	
	log("critical msg", forLevel: .Critical)	
	
	// These events will not be logged, because their log level is < .Debug
	log("verbose msg", forLevel: .Verbose)


### Using the Logger Hirarchy

You usually want to use *loggers* to log events instead of the global `log` function. A logger is always part of a hierarchy and inherits attributes, such as the log level, from its parent. This way, you can provide a default configuration and adjust it for specific parts of your software.

> This is especially useful during development to lower the log level of the part of your software you are currently working on.

Every logger has a `key` as well to identify the source of any given event. In its hierarchy, the key expands to a dot-separated *key path*, such as "Parent.Child".

You can build your own hierarchy, of course, but $MODULE_NAME provides a convenient way for you to utilize this powerful feature:

- The *default logger* is the root of the logger hierarchy and can be retrieved using the `Logger.defaultLogger()` class method. Use it to set a default log level.
- Whenever you want to log an event, use the `Logger.loggerForKeyPath:` class method to retrieve an appropriate logger. Provide a key path that describes the part of your software the event is relevant for, such as "MyModule.MyType". This method will always return the same logger for a given key path and establish the logger hierarchy, if it does not yet exist.

It is convenient to use a *Computed Property* to retrieve the appropriate logger for a type:

	import $MODULE_NAME
	
	extension MyType {
		
		var logger: Logger {
			return Logger.loggerForKeyPath("MyModule.MyType")
		}
		
	}

Now, you can easily log events using the type's `logger` property:

	self.logger.log("TODO: find cool message", forLevel: .Debug)

To adjust the logging configuration, you can use the same method:

	Logger.defaultLogger().logLevel = .Warning // Set the default log level to .Warning
	Logger.loggerForKeyPath("MyModule").logLevel = .Debug // We are working on this part of the software, so set its log level to .Debug

> **Note:** A good place to do this configuration is in the `AppDelegate`'s `application:didFinishLaunchingWithOptions:` method.

## Advanced Usage

### Using Handlers

### Formatting

### TODO's

- Add a method to log details about the app (version, ...)