//
//  TextField.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 22/11/2024.
//

import SwiftUI

internal struct TextField: View {
    
    @Binding private var value: String
    private var placeHolder: String?
    private var label: String?
    
    init(value: Binding<String>, placeHolder: String? = nil, label: String? = nil) {
        self._value = value
        self.placeHolder = placeHolder
        self.label = label
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label =  label {
                Text(label)
                    .font(.deliver(ofSize: 14, weight: .regular))
                    .foregroundColor(Color(.gray))
            }
            SwiftUI.TextField(placeHolder ?? "", text: $value)
                .accentColor(.blue)
                .padding(.horizontal) // Add padding inside the text field
                .cornerRadius(8) // Rounded corners
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8) // Rounded border
                        .stroke(Color(.border), lineWidth: 1) // 1px border with gray color
                )
                
        }
    }
}


internal struct TextFieldPreview: View {
    
    @State var text: String = "Hello worlda"
    
    var body: some View {
        TextField(value: $text)
    }
}

#Preview {
    
    
    
    TextFieldPreview()
}
