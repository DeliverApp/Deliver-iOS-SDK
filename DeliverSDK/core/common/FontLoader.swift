//
//  FontLoader.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 19/12/2023.
//

import UIKit

/// FontLoader handler custom font loading.
/// Nothing else
internal struct FontLoader {
    
    internal static func load() {
        let fontNames = [
            "SourceCodePro-Regular",
            "Nunito-Black",
            "Nunito-Bold",
            "Nunito-ExtraBold",
            "Nunito-ExtraLight",
            "Nunito-Ligh",
            "Nunito-Medium",
            "Nunito-Regular",
            "Nunito-SemiBold",
        ]
  
        fontNames.forEach { fontName in
          
            let fontUrl = Bundle.module.url(forResource: fontName, withExtension: "ttf")

            if let fontUrl = fontUrl  {

                if let dataProvider = CGDataProvider(url: fontUrl as CFURL),
                   let newFont = CGFont(dataProvider) {
                    var error: Unmanaged<CFError>?
                    if !CTFontManagerRegisterGraphicsFont(newFont, &error) {
//                        print("Error loading Font! \(String(describing: error))")
                    }
                    else {
//                        print("Font loaded \(newFont)")
                    }
                } else {
//                    assertionFailure("Error loading font")
                }
            }
            else {
//                print("🚫 Font URL invalid: \(fontUrl)")
            }
        }
    }
}
