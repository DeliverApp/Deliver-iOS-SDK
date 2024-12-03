//
//  SecondaryDeliverButtonStyle.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 22/11/2024.
//

import SwiftUI

internal struct SecondaryDeliverButtonStyle: ButtonStyle {
    
    internal func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration
            .label
            .padding(.horizontal, 8)
            .frame(height: 40)
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
            Image(systemName: "qrcode")
            Text("Hello world")
        }
    }
    .buttonStyle(.secondaryDeliverButtonStlye)
}


extension ButtonStyle where Self == SecondaryDeliverButtonStyle {
    
    internal static var secondaryDeliverButtonStlye: SecondaryDeliverButtonStyle { SecondaryDeliverButtonStyle() }
}
