//
//  SideMenu.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import SwiftUI

enum SideMenuRowType{
    case home, profile, settings
}

struct SideMenuRow: View{
    let rowType: SideMenuRowType
    let sideMenuDidSelectedRow: (SideMenuRowType)->Void
    @State var selected = false
    
    init(rowType: SideMenuRowType, sideMenuDidSelectedRow: @escaping (SideMenuRowType)->Void){
        self.rowType = rowType
        self.sideMenuDidSelectedRow = sideMenuDidSelectedRow
    }
    
    var body: some View{
        HStack{
            self.image()
                .padding(.all,15)
            self.text()
                .font(.system(size: 17))
                .foregroundColor(self.selected ? Color.white : Color.black)
            
            if let image = self.accessoryImage(){
                Spacer()
                image
                    .padding(.trailing,15)
            }
            else{
                Spacer()
            }
        }
        .frame(height: 56)
        .background(self.selected ? Color.black : Color.white)
        .onTapGesture {
            self.selected.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.selected.toggle()
            }
            self.sideMenuDidSelectedRow(rowType)
        }
    }
    
    //MARK: Private
    private func image()->Image{
        switch rowType {
        case .home:
            return selected ? Image("side_menu_home_selected") : Image("side_menu_home")
        case .profile:
            return selected ? Image("side_menu_profile_selected") : Image("side_menu_profile")
        case .settings:
            return selected ? Image("side_menu_settings_selected") : Image("side_menu_settings")
        }
    }
    
    private func text()->Text{
        switch rowType {
        case .home:
            return Text("Home")
        case .profile:
            return Text("Profile")
        case .settings:
            return Text("Settings")
        }
    }
    
    private func accessoryImage()->Image?{
        switch rowType {
        case .settings:
            return Image(systemName: "chevron.right")
        default:
            return nil
        }
    }
}

struct SideMenu: View {
    let width: CGFloat
    @Binding var isOpen: Bool
    let sideMenuDidSelectedRow: (SideMenuRowType)->Void
    @State private var selectedRow: SideMenuRowType?
    
    var body: some View {
        ZStack{
            GeometryReader{ _ in
                EmptyView()
            }
            .background(Color.black.opacity(0.3))
            .opacity(self.isOpen ? 1 : 0)
            .animation(.easeIn, value: 0.25)
            
            HStack{
                Spacer()
                VStack(alignment:.leading){
                    HStack{
                        Image("smartscan_black")
                            .padding()
                        Spacer()
                        Button {
                            self.isOpen = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .font(.title2)
                        }
                        .padding()

                    }
                    .padding(.top,40)
                    
                    VStack(spacing:0){
                        SideMenuRow(rowType: .home, sideMenuDidSelectedRow: sideMenuDidSelectedRow)
                        SideMenuRow(rowType: .profile, sideMenuDidSelectedRow: sideMenuDidSelectedRow)
                        SideMenuRow(rowType: .settings, sideMenuDidSelectedRow: sideMenuDidSelectedRow)
                    }
                    
                    Spacer()
                }
                .frame(width:self.width)
                .background(Color.white)
                .offset(x:self.isOpen ? 0 : self.width)
                .animation(.default, value: 0.25)
            }
        }
        .ignoresSafeArea()
        .gesture(DragGesture()
                    .onEnded({ value in
            if value.translation.width > 100{
                withAnimation {
                    self.isOpen = false
                }
            }
        }))
    }
}

/*
#Preview {
    SideMenu(width: 320, isOpen: .constant(true), sideMenuDidSelectedRow: sideMenuDidSelectedRow(rowType:))
    
    func sideMenuDidSelectedRow(rowType: SideMenuRowType){
        switch rowType {
        case .home:
            print("Side menu home")
        case .profile:
            print("Side menu profile")
        case .settings:
            print("Side menu settings")
        }
    }
}
*/
