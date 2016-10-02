//: # Evergreen

/*:
This playground showcases some basic features of the Evergreen framework. Consult the README.md for a thorough documentation.
*/


import Evergreen

log("Hello World!") // Look at the console output!


Evergreen.logLevel = .debug

// These events will be logged, because their log level is >= .Debug
Evergreen.log("Debug", forLevel: .debug)
Evergreen.log("Info", forLevel: .info)
Evergreen.log("Warning", forLevel: .warning)
Evergreen.log("Critical", forLevel: .critical)

// These events will not be logged, because their log level is < .Debug
Evergreen.log("Verbose", forLevel: .verbose)

// Each log level has a corresponding log function alias for convenience
Evergreen.debug("Debug")

// Easily log errors
let error = NSError(domain: "error_domain", code: 0, userInfo: [ NSLocalizedDescriptionKey: "This was unexpected."])
Evergreen.critical(error)
Evergreen.debug("Some nasty error occured!", error: error)

// Use the logger hierarchy to adjust the logging configuration for specific parts of your software
let fooLogger = Evergreen.getLogger("MyModule.Foo")
fooLogger.logLevel = .verbose
fooLogger.log("Verbose", forLevel: .verbose)


class Tree: CustomStringConvertible {
    
    // Use constants for convenient access to loggers in the logger hierarchy
    let logger = Evergreen.getLogger("Tree")

    private(set) var height: Float = 0
    let maxHeight: Float = 5
    
    init() {
        logger.info("You planted a tree: \(self)")
    }
    
    func grow() {
        logger.tic(andLog: "Your tree is growing...", forLevel: .debug)
        while abs(maxHeight - height) > 0.5 {
            height += (maxHeight - height) / 4
            logger.verbose("Your tree grew: \(self)")
        }
        logger.toc(andLog: "Your tree is fully grown: \(self)", forLevel: .info)
    }
    
    var description: String {
        let symbol: String
        switch self.height {
        case 0..<maxHeight/2:
            symbol = "🌱"
        default:
            symbol = "🌳"
        }
        return "\(symbol) (\(height)m)"
    }
    
}

var 🌳: Tree

🌳 = Tree()
🌳.logger.logLevel = .info
🌳.grow()

🌳 = Tree()
🌳.logger.logLevel = .verbose
🌳.grow()
