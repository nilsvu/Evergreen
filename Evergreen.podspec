Pod::Spec.new do |s|
  s.name         = "Evergreen"
  s.version      = "0.7.1"
  s.summary      = "A Swift Logging Framework."
  s.description  = <<-DESC
    Evergreen is a logging framework written in Swift.

    It's all about replacing your `print()` statements with calls to Evergreen's versatile `log()` functions. Configure a logger hierarchy with log levels for your App or framework and use it to controle the verbosity of your software's output. Use handlers and formatters to control the way log events are handled.
    DESC
  s.homepage     = "http://github.com/viWiD/Evergreen"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = { "Nils Fischer" => "n.fischer@viwid.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/viWiD/Evergreen.git", :tag => "v0.7.1" }
  s.source_files = "Evergreen"
end
