//
//  ScanServiceView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation
import SwiftUI

struct ScanServiceView: UIViewRepresentable {
    @Binding var service: ScanService
    
    init(service: Binding<ScanService>){
        self._service = service
    }
    
    func makeUIView(context: Context) -> some UIView {
        return service.view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
