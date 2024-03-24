//
//  AppView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/22/24.
//

import SwiftUI
import LocalAuthentication

/// All App Lock related methods will be handled here
class AppLockViewModel: ObservableObject {
    @Published var isAppUnLocked: Bool = false
    
    /// This method will call on every launch of the app
    func appLockValidation() {
        let service = AuthenticationService()
        service.signin() { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    DataManager.shared.user = user
                    self?.biometricAuthentication()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Might not need, just for testing purpose
    func biometricAuthentication(){
        var error: NSError?
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Enable App Lock"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, error) in
                if success {
                    DispatchQueue.main.async {
                        self?.isAppUnLocked = true
                    }
                } else {
                    if let error = error {
                        DispatchQueue.main.async {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
        } else {
            print("No biometry")
        }
    }
}


struct AppView: View {
    @EnvironmentObject var appLockVM: AppLockViewModel
    @State var showSplash = true
    
    var body: some View {
        ZStack{
            if appLockVM.isAppUnLocked {
                TabbarView()
            }
            else {
                LoginView()
                    .zIndex(showSplash ? 0 : 1)
                //SplashView(showSplash: $showSplash)
            }
        }
        .onAppear {
            appLockVM.appLockValidation()
            
            //Load AR resources
            ARDataManager.shared.loadDataFromAppBundle()
        }
    }
}

#Preview {
    AppView()
}
