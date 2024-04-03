//
//  ScanTextView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import SwiftUI
    
struct ScanTextView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var model = ViewModel()
    
    init(){
        print("ScanTextView init")
    }
    
    var body: some View {
        ZStack {
            ScanServiceView(service: $model.service)
        }
        .navigationTitle("Scan Text")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button(action: {
                    self.model.stopScan()
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                HStack {
                    Image("navbar_back")
                    Text("Cancel")
                }
            },
            trailing:
                Button(action: {
                    //TODO: implementation
                }) {
                     Text("Translate")
            }

        )
        .ignoresSafeArea()
        .onAppear {
            print("ScanTextView onAppear")
            self.model.startScan()
        }
        .onDisappear {
            print("ScanTextView onDisappear")
            self.model.stopScan()
        }
    }
}

extension ScanTextView{
    class ViewModel: ObservableObject {
        var service: ScanService
        
        init() {
            self.service = ScanTextService()
        }
        
        func startScan(){
            self.service.prepareScan { (result) in
                switch result{
                case .success(let data):
                    guard let text = data.first?.result else {
                        return
                    }
                    print(text)
                    //TODO: translate text with GooleML
                case .failure(let error):
                    //TODO: show error
                    print(error)
                }
            }
        }
        
        func stopScan(){
            self.service.stop()
        }
    }
}

#Preview {
    ScanTextView()
}
