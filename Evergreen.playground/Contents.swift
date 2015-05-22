//: # Evergreen

// TODO: Add plenty of rich text comments!

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

let logger = Evergreen.defaultLogger.childForKeyPath("MyLogger")
logger.logLevel = .Verbose
logger.log("Verbose", forLevel: .Verbose)

let detachedLogger = Logger(key: "MyDetachedLogger", parent: nil)
detachedLogger.handlers = [ ConsoleHandler(formatter: Formatter(components: [ .Logger, .Text(" says: '"), .Message, .Text("' - True Story!") ])) ]
detachedLogger.log("Hello World!", forLevel: .Critical)
logger.description(keyPathSeparator: ">")

class Tree: Printable {
    
    let logger = Evergreen.getLogger("Tree")

    private(set) var height: Float = 0
    let maxHeight: Float = 5
    
    init() {
        logger.log("You planted a tree: \(self)", forLevel: .Info)
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


logger.tic(andLog: "Starting expensive operation...", forLevel: .Debug, timerKey: "expensiveOperation")
for var i=0; i<10; i++ {
    logger.tic(andLog: "\(i). iteration...", forLevel: .Debug, timerKey: "iteration")
    // ...
    logger.toc(andLog: "Done!", forLevel: .Info, timerKey: "iteration")
}
logger.toc(andLog: "Completed expensive operation!", forLevel: .Info, timerKey: "expensiveOperation")
