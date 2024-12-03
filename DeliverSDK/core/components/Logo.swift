//
//  Logo.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 22/11/2024.
//

import SwiftUI

internal struct Logo: View {
    
    var body: some View {
        Image("logo-deliver-small-1024x300", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    Logo()
}
