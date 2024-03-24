//
//  SettingsView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    
    var body: some View {
        VStack(alignment:.leading){
            List{
                VStack(alignment: .leading){
                    Text("APP VERSION").font(.system(size: 13)).foregroundColor(Color(red: 1/255, green: 133/255, blue: 174/255)).padding(.top, 16)
                    Text(appVersion).padding(.top, 11)
                }
            }
            .listStyle(PlainListStyle())
            .padding(.top, 5)
        }
        .navigationBarTitle(Text("Settings"), displayMode: .large)
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
    SettingsView()
}
