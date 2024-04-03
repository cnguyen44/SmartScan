//
//  ScanVINView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import SwiftUI
import Combine
    
struct ScanVINView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ViewModel()
    
    init(){
        print("ScanVINView init")
    }
    
    var body: some View {
        ZStack {
            ScanServiceView(service: $viewModel.service)
            VStack{
                HStack {
                    Image("border_left")
                        .frame(width: 50, height: 120, alignment: .center)
                        .padding(.trailing, -30)
                    Rectangle()
                        .fill(viewModel.overlayColor)
                        .frame(width: 457, height: 80, alignment: .center)
                        .opacity(0.2)
                    Image("border_right")
                        .frame(width: 50, height: 120, alignment: .center)
                        .padding(.leading, -30)
                }
                

            }
            Spacer()
        }
        .navigationTitle("Place VIN within border")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button(action: {
                    self.rotateLanscapeLeft(rotate: false)
                    self.viewModel.stopScan()
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
                     Text("Add Car")
            }

        )
        .ignoresSafeArea()
        .onAppear {
            print("ScanVINView onAppear")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.rotateLanscapeLeft(rotate: true)
            }
            self.viewModel.startScan()
        }
        .onDisappear {
            print("ScanVINView onDisappear")
            self.viewModel.stopScan()
        }
    }
    
    //MARK: Private
    private func rotateLanscapeLeft(rotate: Bool){
        if rotate {
            AppDelegate.self.orientationLock = UIInterfaceOrientationMask.landscapeLeft
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
        else {
            AppDelegate.self.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

extension ScanVINView{
    class ViewModel: ObservableObject {
        var overlayColor = Color(red: 233/255.0, green: 31/255.0, blue: 31/255.0)
        var service: ScanService
        
        init() {
            self.service = ScanVINService()
            self.service.deviceOrientation = .landscapeRight
        }
        
        func startScan(){
            self.overlayColor = Color(red: 233/255.0, green: 31/255.0, blue: 31/255.0)
            self.service.prepareScan { (result) in
                switch result{
                case .success(let data):
                    guard let vin = data.first?.result else {
                        return
                    }
                    if self.service.state == .active {
                        DispatchQueue.main.async {
                            self.stopScan()
                            self.overlayColor = Color(red: 31/255.0, green: 189/255.0, blue: 233/255.0)
                        }
                        self.getVehicle(vin: vin)
                    }
                case .failure(let error):
                    //TODO: show error
                    print(error)
                }
            }
        }
        
        func stopScan(){
            self.service.stop()
        }
        
        //MARK: private
        private func getVehicle(vin: String){
            let service = CarService()
            service.getVehicle(vin: vin) { response in
                switch response{
                case .success(let car):
                    DispatchQueue.main.async {
                        print(car)
                        self.startScan()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

#Preview {
    ScanVINView()
}
