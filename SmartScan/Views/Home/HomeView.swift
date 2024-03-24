//
//  HomeView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import SwiftUI

struct HomeView: View {
    @State private var showScanText = false
    @State private var showScanVIN = false
    @State private var showARView = false
    
    var body: some View {
        ZStack {
            VStack{
                Spacer()
                VStack{
                    Text("Scan Text")
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 1/255.0, green: 133/255.0, blue: 174/255.0))
                    Text("Scan text")
                        .font(.system(size: 17))
                }
                .frame(maxWidth: 340, maxHeight: 100)
                .background(RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white))
                .onTapGesture {
                    self.showScanText.toggle()
                }
                .fullScreenCover(isPresented: $showScanText){
                    NavigationStack{
                        ScanTextView()
                    }
                }
                
                VStack{
                    Text("Scan Car VIN")
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 1/255.0, green: 133/255.0, blue: 174/255.0))
                    Text("Scan car VIN")
                        .font(.system(size: 17))
                }
                .frame(maxWidth: 340, maxHeight: 100)
                .background(RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white))
                .onTapGesture {
                    self.showScanVIN.toggle()
                }
                .fullScreenCover(isPresented: $showScanVIN){
                    NavigationStack{
                        ScanVINView()
                    }
                }
                
                VStack{
                    Text("Add AR Object")
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 1/255.0, green: 133/255.0, blue: 174/255.0))
                    Text("Add AR Object by tap on screen")
                        .font(.system(size: 17))
                }
                .frame(maxWidth: 340, maxHeight: 100)
                .background(RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white))
                .onTapGesture {
                    self.showARView.toggle()
                }
                .fullScreenCover(isPresented: $showARView){
                    NavigationStack{
                        ARAddAnnotationView()
                    }
                }
                
                Spacer()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 31/255.0, green: 189/255.0, blue: 233/255.0), Color(red: 113/255.0, green: 187/255.0, blue: 82/255.0)]), startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
    }
}

#Preview {
    HomeView()
}
