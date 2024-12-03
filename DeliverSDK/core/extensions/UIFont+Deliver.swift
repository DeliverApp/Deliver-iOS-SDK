//
//  UIFont+Deliver.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 17/12/2023.
//

import UIKit
import SwiftUI

extension UIFont {
    
    internal static func deliver(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        
        switch weight {
            case .black:        return UIFont(name: "Nunito-black", size: size)!
            case .bold:         return UIFont(name: "Nunito-bold", size: size)!
            case .heavy:        return UIFont(name: "Nunito-ExtraBold", size: size)!
            case .ultraLight:   return UIFont(name: "Nunito-ExtraLight", size: size)!
            case .light:        return UIFont(name: "Nunito-Light", size: size)!
            case .medium:       return UIFont(name: "Nunito-Medium", size: size)!
            case .regular:      return UIFont(name: "Nunito-Regular", size: size)!
            case .semibold:     return UIFont(name: "Nunito-Semibold", size: size)!
            case .thin:         return UIFont(name: "Nunito-Thin", size: size)!
            default:            return UIFont(name: "Nunito-Regular", size: size)!
        }
    }
    
    internal static func code(ofSize size: CGFloat) -> UIFont {
        UIFont(name: "SourceCodePro-Regular", size: size)!
    }
}

extension Font {
    
    internal static func deliver(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> Font {
        
        switch weight {
            case .black:        return Font.custom("Nunito-black", size: size)
            case .bold:         return Font.custom("Nunito-bold", size: size)
            case .heavy:        return Font.custom("Nunito-ExtraBold", size: size)
            case .ultraLight:   return Font.custom("Nunito-ExtraLight", size: size)
            case .light:        return Font.custom("Nunito-Light", size: size)
            case .medium:       return Font.custom("Nunito-Medium", size: size)
            case .regular:      return Font.custom("Nunito-Regular", size: size)
            case .semibold:     return Font.custom("Nunito-Semibold", size: size)
            case .thin:         return Font.custom("Nunito-Thin", size: size)
            default:            return Font.custom("Nunito-Regular", size: size)
        }
    }
    
    internal static func code(ofSize size: CGFloat) -> Font {
        Font.custom("SourceCodePro-Regular", size: size)
    }
}
