//
//  DeliverButtonStyle.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 22/11/2024.
//

import SwiftUI

internal struct PrimaryDeliverButtonStyle: ButtonStyle {
    
    var isLoading: Bool = false
    
    internal func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        let isPressed = configuration.isPressed
        HStack(alignment: .center) {
            Spacer()
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            configuration.label
                .frame(height: 40)
                .font(.deliver(ofSize: 14, weight: .bold))
            Spacer()
        }
        .padding(.horizontal, 8)
        .foregroundColor(.white)
        .background(isPressed ? Color(.primaryButtonBackgroundSelected) : Color(.primaryButtonBackgroundNormal))
        .cornerRadius(8)
        
    }
}

#Preview {
    Button(action: {}) {
        HStack {
            Text("Hello world")
//                .frame(maxWidth: .infinity)
        }
    }
    .buttonStyle(.primaryDeliverButtonStlye)
    
}


extension ButtonStyle where Self == PrimaryDeliverButtonStyle {
    
    internal static var primaryDeliverButtonStlye: PrimaryDeliverButtonStyle { PrimaryDeliverButtonStyle(isLoading: false) }
}
