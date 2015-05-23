//: # Evergreen

/*:
This playground showcases some basic features of the Evergreen framework. Consult the README.md for a thorough documentation.
*/


import Evergreen


log("Hello World!") // Look at the console output!


Evergreen.logLevel = .Debug

// These events will be logged, because their log level is >= .Debug
log("Debug", forLevel: .Debug)
log("Info", forLevel: .Info)
log("Warning", forLevel: .Warning)
log("Critical", forLevel: .Critical)

// These events will not be logged, because their log level is < .Debug
log("Verbose", forLevel: .Verbose)

// Each log level has a corresponding log function alias for convenience
debug("Debug")


// Use the logger hierarchy to adjust the logging configuration for specific parts of your software
let fooLogger = Evergreen.getLogger("MyModule.Foo")
fooLogger.logLevel = .Verbose
fooLogger.log("Verbose", forLevel: .Verbose)


class Tree: Printable {
    
    // Use constants for convenient access to loggers in the logger hierarchy
    let logger = Evergreen.getLogger("Tree")

    private(set) var height: Float = 0
    let maxHeight: Float = 5
    
    init() {
        self.logger.log("You planted a tree: \(self)", forLevel: .Info)
    }
    
    func grow() {
        logger.tic(andLog: "Your tree is growing...", forLevel: .Debug)
        while abs(maxHeight - height) > 0.5 {
            height += (maxHeight - height) / 4
            logger.log("Your tree grew: \(self)", forLevel: .Verbose)
        }
        logger.toc(andLog: "Your tree is fully grown: \(self)", forLevel: .Info)
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
🌳.logger.logLevel = .Info
🌳.grow()

🌳 = Tree()
🌳.logger.logLevel = .Verbose
🌳.grow()
