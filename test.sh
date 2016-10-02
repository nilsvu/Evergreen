#!/bin/bash

set -e # exit on failure

# Run Tests via iOS
xcodebuild test -workspace Evergreen.xcworkspace -scheme Evergreen-iOS -destination "platform=iOS Simulator,name=iPhone 6s,OS=10.0" &&

# Run Tests via OS X
xcodebuild test -workspace Evergreen.xcworkspace -scheme Evergreen-OSX -destination "platform=OS X" &&

# Run Tests via tvOS
xcodebuild test -workspace Evergreen.xcworkspace -scheme Evergreen-tvOS -destination "platform=tvOS Simulator,name=Apple TV 1080p,OS=10.0"
