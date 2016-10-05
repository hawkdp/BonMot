//
//  NSAttributedStringDebugTests.swift
//
//  Created by Brian King on 9/1/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
import BonMot

class NSAttributedStringDebugTests: XCTestCase {

    #if os(OSX)
        let imageForTest = testBundle.image(forResource: "robot")!
    #else
        let imageForTest = UIImage(named: "robot", in: testBundle, compatibleWith: nil)!
    #endif

    func testDebugRepresentationReplacements() {
        let testCases: [(String, String)] = [
            ("BonMot", "BonMot"),
            ("Bon\tMot", "Bon{tab}Mot"),
            ("Bon\nMot", "Bon{lineFeed}Mot"),
            ("it ignores spaces", "it ignores spaces"),
            ("Pilcrow¶", "Pilcrow¶"),
            ("Floppy💾Disk", "Floppy💾Disk"),
            ("\u{000A1338}A\u{000A1339}", "{unassignedUnicode<A1338>}A{unassignedUnicode<A1339>}"),
            ("neonسلام🚲\u{000A1338}₫\u{000A1339}", "neonسلام🚲{unassignedUnicode<A1338>}₫{unassignedUnicode<A1339>}"),
        ]
        for (index, testCase) in testCases.enumerated() {
            let line = UInt(#line - testCases.count - 2 + index)
            let debugString = NSAttributedString(string: testCase.0).debugRepresentation.string
            XCTAssertEqual(testCase.1, debugString, line: line)
        }
    }

    func testImageRepresentationHasSize() {
        XCTAssertEqual(imageForTest.attributedString().debugRepresentation.string, "{image36x36}")
    }

    func testThatNSAttributedStringSpeaksUTF16() {
        // We don't actually need to test this - just demonstrating how it works
        let string = "\u{000A1338}A"
        XCTAssertEqual(string.characters.count, 2)
        XCTAssertEqual(string.utf8.count, 5)
        XCTAssertEqual(string.utf16.count, 3)
        let mutableAttributedString = NSMutableAttributedString(string: string)
        XCTAssertEqual(mutableAttributedString.string, string)
        mutableAttributedString.replaceCharacters(in: NSRange(location: 0, length: 2), with: "foo")
        XCTAssertEqual(mutableAttributedString.string, "fooA")
    }

    // ParagraphStyles are a bit interesting, as tabs behave over a line, but multiple paragraph styles can be applied on that line.
    // I'm not sure how a multi-paragrah line would behave, but this confirms that NSAttributedString doesn't do any coalescing
    func testParagraphStyleBehavior() {
        let style1 = NSMutableParagraphStyle()
        style1.lineSpacing = 1000
        let style2 = NSMutableParagraphStyle()
        style2.headIndent = 1000
        let string1 = NSMutableAttributedString(string: "first part ", attributes: [NSParagraphStyleAttributeName: style1])
        let string2 = NSAttributedString(string: "second part.\n", attributes: [NSParagraphStyleAttributeName: style2])
        string1.append(string2)
        let p1 = string1.attribute(NSParagraphStyleAttributeName, at: 0, effectiveRange: nil) as? NSParagraphStyle
        let p2 = string1.attribute(NSParagraphStyleAttributeName, at: string1.length - 1, effectiveRange: nil) as? NSParagraphStyle
        XCTAssertNotEqual(p1, p2)
    }

}
