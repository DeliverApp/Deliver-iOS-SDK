//
//  ImageDeliverButtonStyle.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 22/11/2024.
//

import SwiftUI

internal struct ImageDeliverButtonStyle: ButtonStyle {
    
    internal func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .frame(width: 40, height: 40)
            .background(isPressed ? Color(.secondaryButtonBackgroundSelected) : Color(.secondaryButtonBackgroundNormal))
            .cornerRadius(8)
            .font(.deliver(ofSize: 14, weight: .bold))
            .overlay(
                RoundedRectangle(cornerRadius: 8) // Rounded border
                    .stroke(Color(.border), lineWidth: 1) // 1px border with gray color
            )
    }
}

#Preview {
    Button(action: {}) {
        HStack {
            Image(systemName:"qrcode")
        }
    }
    .buttonStyle(.imageDeliverButtonStyle)
    
}


extension ButtonStyle where Self == ImageDeliverButtonStyle {
    
    internal static var imageDeliverButtonStyle: ImageDeliverButtonStyle { ImageDeliverButtonStyle() }
}
