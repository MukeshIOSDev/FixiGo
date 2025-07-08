//
//  FixiGoApp.swift
//  FixiGo
//
//  Created by Mukesh Behera on 26/06/25.
//

import SwiftUI
import Firebase
import FirebaseCore
import CoreText

@main
struct FixiGoApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Register custom fonts
        registerCustomFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
    
    private func registerCustomFonts() {
        // Register Poppins font family
        let fontNames = [
            "Poppins-Regular",
            "Poppins-Medium", 
            "Poppins-SemiBold",
            "Poppins-Bold",
            "Poppins-ExtraBold"
        ]
        
        for fontName in fontNames {
            if let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
            }
        }
    }
}
