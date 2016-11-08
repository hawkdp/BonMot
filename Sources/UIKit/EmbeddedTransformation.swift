//
//  EmbeddedTransformation.swift
//  BonMot
//
//  Created by Brian King on 9/28/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

/// BonMot embeds transformation objects inside `NSAttributedString` attributes
/// to do adaptive styling. To simplify `NSAttributedString`'s `NSCoding`
/// support, these transformations get embedded using plist-compatible objects.
/// This protocol defines a contract to simplify this. `NSCoding` is not used so
/// that value types can conform.
internal protocol EmbeddedTransformation {

    /// Return a plist-compatible dictionary of any state that is needed to
    /// persist the adaptation
    var representation: StyleAttributes { get }

    /// Take the adaptations dictionary and create an array of
    /// `AdaptiveStyleTransformation`s. To register a new adaptive transformation,
    /// add the type to `EmbeddedTransformationHelpers.embeddedTransformationTypes`.
    static func from(representation dictionary: StyleAttributes) -> EmbeddedTransformation?

}

// Helpers for managing keys in the `StyleAttributes` related to adaptive functionality.
internal enum EmbeddedTransformationHelpers {

    struct Key {

        static let type = "type"
        static let size = "size"

    }

    static var embeddedTransformationTypes: [EmbeddedTransformation.Type] = [AdaptiveStyle.self, Tracking.self, Tab.self]

    static func embed(transformation theTransformation: EmbeddedTransformation, to styleAttributes: StyleAttributes) -> StyleAttributes {
        let representation = theTransformation.representation
        var styleAttributes = styleAttributes
        var adaptations = styleAttributes[BonMotTransformationsAttributeName] as? [StyleAttributes] ?? []

        // Only add the transformation once.
        let contains = adaptations.contains() { NSDictionary(dictionary: $0) == NSDictionary(dictionary: representation) }
        if !contains {
            adaptations.append(representation)
        }
        styleAttributes[BonMotTransformationsAttributeName] = adaptations
        return styleAttributes
    }

    static func transformations<T>(from styleAttributes: StyleAttributes) -> [T] {
        let representations = styleAttributes[BonMotTransformationsAttributeName] as? [StyleAttributes] ?? []
        let results: [T?] = representations.map { representation in
            for type in embeddedTransformationTypes {
                if let transformation = type.from(representation: representation) as? T {
                    return transformation
                }
            }
            return nil
        }
        return results.flatMap({ $0 })
    }

}
