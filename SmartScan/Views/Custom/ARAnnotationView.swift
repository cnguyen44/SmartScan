//
//  ARAnnotationView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import SwiftUI

struct ARAnnotationView: UIViewRepresentable {
    @Binding var service: ARAnnotationService
    
    init(service: Binding<ARAnnotationService>){
        self._service = service
    }
    
    func makeUIView(context: Context) -> some UIView {
        return service.view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

//#Preview {
//    ARAnnotationView()
//}
