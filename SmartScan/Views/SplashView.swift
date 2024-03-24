//
//  SplashView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/22/24.
//

import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    
    var body: some View {
        Text("Splash View")
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}
