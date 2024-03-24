//
//  TabbarView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/22/24.
//

import SwiftUI

struct TabbarView: View {
    @State private var selected = 0
    @State private var showMenu = false
    @State private var showProfileView = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack{
            TabView(selection: $selected){
                NavigationStack {
                    HomeView()
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(
                            leading: Image("smartscan_black").opacity(showMenu ? 0 : 1),
                            trailing: Button(action: {
                                            self.showMenu.toggle()
                                        }, label: {
                                            Image("navbar_hamburger")
                                        }))
                }
                .tabItem {
                    Image(selected==0 ? "tab_home_selected":"tab_home").renderingMode(.template)
                    Text("Home")
                }
                .tag(0)
                
                NavigationStack {
                    ToolsView()
                }
                .tabItem {
                    Image(selected==1 ? "tab_tools":"tab_tools_selected").renderingMode(.template)
                    Text("Tools")
                }.tag(1)
            }
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.backgroundColor = UIColor(red: 31/255.0, green: 31/255.0, blue: 31/255.0, alpha: 1.0)
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            SideMenu(width: 320, isOpen: $showMenu, sideMenuDidSelectedRow: self.sideMenuDidSelectedRow(rowType:))
        }
        .fullScreenCover(isPresented: $showProfileView){
            NavigationStack{
                ProfileView()
            }
        }
        .fullScreenCover(isPresented: $showSettings){
            NavigationStack{
                SettingsView()
            }
        }
    }
    
    //MARK: Side menu call back
    func sideMenuDidSelectedRow(rowType: SideMenuRowType){
        self.showMenu = false
        switch rowType {
        case .home:
            self.selected = 0
        case .profile:
            print("Side menu profile")
            self.showProfileView.toggle()
        case .settings:
            print("Side menu settings")
            self.showSettings.toggle()
        }
    }
}

#Preview {
    TabbarView()
}
