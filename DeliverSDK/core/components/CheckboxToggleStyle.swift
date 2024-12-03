//
//  CheckboxToggleStyle.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 25/11/2024.
//

import SwiftUI

internal struct CheckboxToggleStyle: ToggleStyle {
    
    func makeBody(configuration: ToggleStyle.Configuration) -> some View {
        HStack {

            RoundedRectangle(cornerRadius: 5.0)
                .fill(configuration.isOn ? Color(.dBlack) : .white)
                .frame(width: 25, height: 25)
                .overlay(
                    Image(systemName:"checkmark")
                        .foregroundColor(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0)
                        .stroke(Color(.dBlack), lineWidth: 1)
                        
                )
            configuration
                .label
                .foregroundColor(configuration.isOn ? .black : .gray)
        }
        .onTapGesture {
            withAnimation(.spring()) {
                configuration.isOn.toggle()
            }
        }
    }
}
