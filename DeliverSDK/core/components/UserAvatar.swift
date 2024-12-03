//
//  UserAvatar.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 25/11/2024.
//

import SwiftUI

internal struct UserAvatar: View {
    
    var user: User?
    var size: CGFloat = 32
    
    
    var body: some View {
        if let urlString = user?.avatar,
            let url = URL(string: "\(Context.shared.apiBaseUrl)/img/\(urlString)") {
            AsyncImage(
                url: url,
                placeholder: { initialView() },
                errorImage:{ initialView() },
                image: {
                    Image(uiImage: $0)
                        .resizable()
                        .frame(width: size, height: size)
                        .cornerRadius(size/2)
                }
            )
        }
        else {
            initialView()
        }
    }
    
    func initialView() -> some View {
        
        Text(Context.shared.user?.initial ?? "-")
            .font(.deliver(ofSize: 14, weight: .bold))
            .padding(6)
            .overlay(
                RoundedRectangle(cornerRadius: size/2) // Rounded border
                    .fill(Color.green.opacity(0.2))
            )
    }
}
