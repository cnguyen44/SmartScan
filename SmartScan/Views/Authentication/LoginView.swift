//
//  LoginView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/22/24.
//

import SwiftUI
import Combine

enum FocusedField:Hashable{
    case name, password
}

class LoginViewModel: ObservableObject {
    @Published var isAppUnLocked = false
    @Published var errorMessage = ""
    
    func signin(username: String, password: String) {
        let service = AuthenticationService()
        service.signin(username: username, password: password) { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    DataManager.shared.user = user
                    self?.isAppUnLocked = true
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self?.errorMessage = "Invalid username or password"
                }
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var appLockVM: AppLockViewModel
    @StateObject private var viewModel = LoginViewModel()
    @State private var username = ""
    @State private var password = ""
    @FocusState private var focus: FocusedField?
    @State private var iconHeight: CGFloat = 150
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationStack {
            ZStack{
                VStack{
                    Image(systemName:"doc.viewfinder")
                        .font(.system(size: 100))
                        .foregroundStyle(.white)
                        .padding(.top, iconHeight)
                    Text("Smart Scan")
                        .font(.system(size: 25, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .padding(.top, 12)
                    
                    TextField("Username", text: $username)
                        .frame(maxHeight: 56)
                        .padding(.top, 64)
                        .padding([.leading,.trailing],32)
                        .textContentType(.username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($focus, equals: .name)
                        .onSubmit {
                            focus = .password
                        }
                    
                    SecureField("Password", text: $password)
                        .frame(maxHeight: 56)
                        .padding(.top, 16)
                        .padding([.leading,.trailing],32)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($focus, equals: .password)
                    
                    Text(viewModel.errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(.top,5)
                    
                    Button(action: {
                        viewModel.signin(username: username, password: password)
                        appLockVM.isAppUnLocked = viewModel.isAppUnLocked
                    }, label: {
                        Text("SIGN IN")
                            .padding(.all, 32)
                            .frame(maxWidth: .infinity, maxHeight: 56)
                            .background(Color.white)
                            .foregroundColor(Color(red: 1/255.0, green: 133/255.0, blue: 174/255.0))
                            .cornerRadius(8)
                            .font(.system(size: 17, weight: .bold, design: .default))
                    })
                    .padding(.horizontal, 32)
                    
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .underline()
                        }.isDetailLink(false)
                    }
                    .padding(.top,50)
                    Spacer()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            .background(LinearGradient(gradient: Gradient(colors: [Color(red: 31/255.0, green: 189/255.0, blue: 233/255.0), Color(red: 113/255.0, green: 187/255.0, blue: 82/255.0)]), startPoint: .top, endPoint: .bottom))
            .ignoresSafeArea()
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            //Register to keyboard notification
            NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillShowNotification)
                .merge(with: NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillChangeFrameNotification))
                .map {_ in
                    50
                }
                .subscribe(Subscribers.Assign(object: self, keyPath: \.iconHeight))
            
            NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillHideNotification)
                .compactMap { notification in
                    150
                }
                .subscribe(Subscribers.Assign(object: self, keyPath: \.iconHeight))
            
            //Listen to app unlock state
            viewModel.$isAppUnLocked.sink { value in
                DispatchQueue.main.async{
                    appLockVM.isAppUnLocked = value
                }
            }
            .store(in: &cancellables)
        }
    }
}

#Preview {
    LoginView()
}
