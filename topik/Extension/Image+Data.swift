//
//  Image+Data.swift
//  topik
//
//  Created by Grzegorz Baranowski on 08/03/2025.
//

import SwiftUI

extension Data {

    func asImage() -> Image {
    #if canImport(UIKit)
        let songArtwork: UIImage = UIImage(data: self) ?? UIImage()
        return Image(uiImage: songArtwork)
    #elseif canImport(AppKit)
        let songArtwork: NSImage = NSImage(data: self) ?? NSImage()
        return Image(nsImage: songArtwork)
    #else
        return Image(systemImage: "some_default")
    #endif
    }

}

