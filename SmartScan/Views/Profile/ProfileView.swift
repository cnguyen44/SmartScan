//
//  ProfileView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    func signout(handler: @escaping (Bool)->Void){
        let service = AuthenticationService()
        service.signout(handler: handler)
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var appLockVM: AppLockViewModel
    @State var email: String?
    @State var firstName: String?
    @State var lastName: String?
    @State var image: Image?
    
    var body: some View {
        ZStack{
            Color(.white)
            VStack(alignment: .leading) {
                VStack {
                    if image != nil {
                        ZStack {
                            Color(red: 181/255, green: 230/255, blue: 241/255).ignoresSafeArea()
                            image?
                                .resizable().aspectRatio(contentMode: .fit).clipShape(Circle())
                                .shadow(radius: 10)
                                .overlay(Circle().stroke(Color(.blue), lineWidth: 2))
                                .frame(width: 190, height: 190)
                        }
                        
                    } else {
                        //TODO: load image from camera of photo library
                    }
                }
                .frame(height: 196).padding(.top)
            }
            List {
                //TODO: user modifier for cell style
                
                // Email Field
                VStack(alignment: .leading){
                    Text("EMAIL")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 1/255, green: 133/255, blue: 174/255))
                        .padding([.top,.bottom], 11)
                    Text(DataManager.shared.user?.email ?? "")
                        .font(.system(size: 17))
                        .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.6))
                        .padding(.bottom, 11).disabled(true)
                }
                
                // Firstname Field
                VStack(alignment: .leading){
                    Text("FIRST NAME").font(.system(size: 13))
                        .foregroundColor(Color(red: 255/255, green: 59/255, blue: 48/255))
                        .padding([.top,.bottom], 11)
                    Text(DataManager.shared.user?.firstName ?? "")
                        .font(.system(size: 17))
                        .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.6))
                        .padding(.bottom, 11)
                }
                
                // Lastname Field
                VStack(alignment: .leading){
                    Text("LAST NAME")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 255/255, green: 59/255, blue: 48/255))
                        .padding([.top,.bottom], 11)
                    Text(DataManager.shared.user?.lastName ?? "")
                        .font(.system(size: 17))
                        .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.6))
                        .padding(.bottom, 11).disabled( true)
                }
                
                // Sign Out Button
                VStack {
                    Button(action: {
                        print("Sign Out Button Tapped...!!!")
                        viewModel.signout { success in
                            if success{
                                appLockVM.isAppUnLocked = false
                            } else{
                                //TODO: show some message or alert
                                print("Sign out failed")
                            }
                        }
                    }, label: {
                        Text("Sign Out").font(.system(size: 17)).foregroundColor(Color(.black))
                    })
                    
                }.frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 44,
                    maxHeight: .infinity,
                    alignment: .center)
            }
            .listStyle(PlainListStyle())
            .padding(.bottom)
        }
        .navigationBarTitle(Text("Profile"), displayMode: .large)
        .navigationBarItems(leading:
                                Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Image(systemName: "chevron.backward").frame(width: 11.98, height: 20.79)
                Text("Back").padding(.leading, -5).font(.system(size: 17))
            }
        }))
    }
}

#Preview {
    ProfileView()
}
