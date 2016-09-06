/*
 This source file is part of the Swift.org open source project

 Copyright 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Basic
import TestSupport
@testable import Xcodeproj
import XCTest

class XcodeProjectModelSerializationTests: XCTestCase {
    
    func testBasicProjectSerialization() {
        // Create a project.
        let proj = Xcode.Project()
        
        // Serialize it to a property list.
        let plist = proj.generatePlist()
        
        // Assert various things about the property list.
        guard case let .dictionary(topLevelDict) = plist else {
            XCTFail("top-level of plist must be a dictionary")
            return
        }
        XCTAssertFalse(topLevelDict.isEmpty)
        
        // FIXME: We should factor out all of the following using helper assert
        // functions that deal with the enum casing.
        
        // Archive version should be 1.
        guard case let .string(archiveVersionStr) = topLevelDict["archiveVersion"]! else {
            XCTFail("top-level plist dictionary must have an `archiveVersion` string")
            return
        }
        XCTAssertEqual(archiveVersionStr, "1")
        
        // Object version should be 46 (Xcode 8.0).
        guard case let .string(objectVersionStr) = topLevelDict["objectVersion"]! else {
            XCTFail("top-level plist dictionary must have an `objectVersion` string")
            return
        }
        XCTAssertEqual(objectVersionStr, "46")
        
        // There should be a root object.
        guard case let .identifier(rootObjectID) = topLevelDict["rootObject"]! else {
            XCTFail("top-level plist dictionary must have a `rootObject` string")
            return
        }
        XCTAssertFalse(rootObjectID.isEmpty)
        
        // There should be a dictionary mapping identifiers to object dictionaries.
        guard case let .dictionary(objectDict) = topLevelDict["objects"]! else {
            XCTFail("top-level plist dictionary must have a `objects` dictionary")
            return
        }
        XCTAssertFalse(objectDict.isEmpty)
        
        // The root object should reference a PBXProject dictionary.
        guard case let .dictionary(projectDict) = objectDict[rootObjectID]! else {
            XCTFail("object dictionary must have an entry for the project")
            return
        }
        XCTAssertFalse(projectDict.isEmpty)
        
        // Project dictionary's `isa` must be "PBXProject".
        guard case let .string(projectClassName) = projectDict["isa"]! else {
            XCTFail("project object dictionary must have an `isa` string")
            return
        }
        XCTAssertEqual(projectClassName, "PBXProject")
    }
    
    static var allTests = [
        ("testBasicProjectCreation", testBasicProjectSerialization),
    ]
}
