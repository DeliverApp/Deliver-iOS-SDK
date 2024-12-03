//
//  SignInScreen.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 22/11/2024.
//

import SwiftUI

internal struct SignInScreen: View {

    @StateObject var viewModel: SignInViewModel
    
    init(viewModel: SignInViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Logo()
                    .padding(.top, 20)
                    .padding(.horizontal, 40)
                Text("Sign in to your account")
                    .font(.deliver(ofSize: 24, weight: .black))
                    .padding(.top, 24)
                HStack(alignment: .bottom, spacing: 10) {
                    TextField(value: $viewModel.email, placeHolder: "hello", label: "Email")
                        .font(.deliver(ofSize: 16, weight: .regular))
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    Button(action: {viewModel.openScanner()}) {
                        HStack {
                            Image(systemName: "qrcode") // Example system image (can use custom images too)
                                .foregroundColor(Color.black)
                                .frame(width: 40)
                        }
                    }
                    .buttonStyle(.imageDeliverButtonStyle)
                }
                TextField(value: $viewModel.otp, placeHolder: "••••••", label: "OTP")
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .font(.deliver(ofSize: 20, weight: .heavy))
                Button(action: {viewModel.signIn()}) {
                    Text("Log In")
//                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(PrimaryDeliverButtonStyle(isLoading: viewModel.isLoading == true ))
                .padding(.top, 40)
                if viewModel.error {
                    Text("If authentication fails, check your OTP on\ndeliverapp.io/store/settings")
                        .foregroundColor(Color.red)
                        .font(.deliver(ofSize: 12))
                }
                
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.horizontal)
        
    }
}

#Preview {
    
    SignInScreen(viewModel: SignInViewModel())
}
