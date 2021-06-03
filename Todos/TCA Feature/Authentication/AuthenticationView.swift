//
//  AuthenticationView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

struct AuthenticationView: View {
    let store: Store<Authentication.State, Authentication.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 0) {
                VStack {
                    Spacer(minLength: 0)
                    
                    //Icon
                    Image("icon2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    //Welcome back
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .padding(.vertical, 10)
                    
                    // Apple
                    SignInWithAppleToFirebase({ response in
                        if response == .success {
                            print("logged into Firebase through Apple!")
                        } else if response == .error {
                            print("error. Maybe the user cancelled or there's no internet")
                        }
                    })
                    
                    // Google Login
                    Button(action: {}) {
                        HStack {
                            Image("google")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                            
                            Spacer(minLength: 0)
                            Text("Log in with Google")
                                .foregroundColor(.black)
                            
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: -5, y: -5)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical)
                    
                    
                    // OR
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 1)
                        
                        Text("OR")
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 1)
                    }
                    
                    
                    Group {
                        // Email & Password

                        TextField("Email", text: viewStore.binding(get: \.email, send: Authentication.Action.updateEmail))
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 2).stroke(Color.gray.opacity(0.7), lineWidth: 1))
                        
                        SecureField("Password", text: viewStore.binding(get: \.password, send: Authentication.Action.updatePassword))
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 2).stroke(Color.gray.opacity(0.7), lineWidth: 1))
                            //.padding(.top)
                        
                        // Stay Logged in
                        HStack {
                            Toggle("Keep Loggin In", isOn: .constant(true))
                            
                            Spacer(minLength: 0)
                            
                            Button(action: {}) {
                                Text("Forgot Password")
                                    .underline()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top)
                        
                        // Login Button
                        Button(action: { viewStore.send(.loginButtonTapped) }) {
                            HStack {
                                Spacer()
                                
                                Text("Login")
                                Spacer()
                                Image(systemSymbol: .arrowRight)
                                
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.appColor)
                            .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Continue as Guest
                        Button(action: { viewStore.send(.signInAnonymouslyButtonTapped) }) {
                            HStack {
                                Spacer()

                                Text("Continue as Guest")
                                Spacer()
                                Image(systemSymbol: .arrowRight)

                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.appColor)
                            .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())

                        
                        // Signup Button
                        HStack {
                            Text("Don't have account yet?")
                                .foregroundColor(.gray)
                            
                            Button(action: {}) {
                                Text("Sign Up")
                                    .foregroundColor(.appColor)
                                    .underline()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        //.padding(.top, 10)
                    }
                    .padding(.top)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 50)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                
                VStack {
                    Spacer()
                    Image("working")
                        .resizable()
                        .scaledToFit()
                        .padding(.leading, -35)
                    
                    Spacer()
                }
                .background(Color.appColor)
            }
            .ignoresSafeArea()
            //.frame(width: 800, height: 600)
        }
    }
}

struct Authentication_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(store: Authentication.defaultStore)
    }
}
 
