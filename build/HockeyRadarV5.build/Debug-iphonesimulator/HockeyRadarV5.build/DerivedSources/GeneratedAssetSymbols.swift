import Foundation
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "backgrounds" asset catalog image resource.
    static let backgrounds = DeveloperToolsSupport.ImageResource(name: "backgrounds", bundle: resourceBundle)

    /// The "calibrationNet" asset catalog image resource.
    static let calibrationNet = DeveloperToolsSupport.ImageResource(name: "calibrationNet", bundle: resourceBundle)

    /// The "dinkydiagram" asset catalog image resource.
    static let dinkydiagram = DeveloperToolsSupport.ImageResource(name: "dinkydiagram", bundle: resourceBundle)

    /// The "dot" asset catalog image resource.
    static let dot = DeveloperToolsSupport.ImageResource(name: "dot", bundle: resourceBundle)

    /// The "net2" asset catalog image resource.
    static let net2 = DeveloperToolsSupport.ImageResource(name: "net2", bundle: resourceBundle)

    /// The "nets" asset catalog image resource.
    static let nets = DeveloperToolsSupport.ImageResource(name: "nets", bundle: resourceBundle)

    /// The "puck" asset catalog image resource.
    static let puck = DeveloperToolsSupport.ImageResource(name: "puck", bundle: resourceBundle)

    /// The "radar" asset catalog image resource.
    static let radar = DeveloperToolsSupport.ImageResource(name: "radar", bundle: resourceBundle)

    /// The "shootingandaccuracy" asset catalog image resource.
    static let shootingandaccuracy = DeveloperToolsSupport.ImageResource(name: "shootingandaccuracy", bundle: resourceBundle)

    /// The "sticks" asset catalog image resource.
    static let sticks = DeveloperToolsSupport.ImageResource(name: "sticks", bundle: resourceBundle)

}

