//
//  Color.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI

extension Color {
    static let primaryGreen = Color(hex: "#41C274")
    static let primaryLime = Color(hex: "#EFFFC0")
    static let primaryOrange = Color(hex: "#FFA131")
    static let primaryWhite = Color(hex: "#FFFFFF")
    static let primaryBlack = Color(hex: "#000000")
    static let primaryGray = Color(hex: "#D3D3D3")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
