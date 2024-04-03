//
//  AddARObjectView.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import SwiftUI

struct ARAddAnnotationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var model = ViewModel()
    @State private var startAnnotation = false
    @State private var annotationStyle = ARAnnotationStyle.targetSquare
    
    var body: some View {
        NavigationStack{
            ZStack(alignment:.bottom){
                ARAnnotationView(service: $model.service)
                
                VStack{
                    HStack{
                        Spacer()
                        VStack{
                            Button {
                                self.annotationStyle = .targetSquare
                                self.model.service.annotationStyle = .targetSquare
                            } label: {
                                Image(systemName: "square")
                                    .resizable()
                                    .aspectRatio(contentMode: ContentMode.fit)
                            }
                            .frame(maxWidth:.infinity, maxHeight: .infinity)
                            .foregroundColor(Color.gray)
                            .padding(.top,10)
                            
                            Button {
                                self.annotationStyle = .targetCircle
                                self.model.service.annotationStyle = .targetCircle
                            } label: {
                                Image(systemName: "scope")
                                    .resizable()
                                    .aspectRatio(contentMode: ContentMode.fit)
                            }
                            .frame(maxWidth:.infinity, maxHeight: .infinity)
                            .foregroundColor(Color.gray)
                            .padding(.top,10)

                            Button {
                                self.annotationStyle = .sphere
                                self.model.service.annotationStyle = .sphere
                            } label: {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: ContentMode.fit)
                            }
                            .frame(maxWidth:.infinity, maxHeight: .infinity)
                            .foregroundColor(Color.gray)
                            .padding(.bottom,10)
                        }
                        .background(Color.white)
                        .frame(width: 50, height: 150)
                        .cornerRadius(20)
                        .padding()
                         
                    }
                    .disabled(!startAnnotation)
                    .opacity(startAnnotation ? 1.0 : 0.0)
                    
                    HStack(spacing:20){
                        Button {
                            self.model.service.removePreviousAnnotation()
                        } label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                                .resizable()
                                .aspectRatio(contentMode: ContentMode.fit)
                        }
                        .frame(maxWidth:.infinity, maxHeight: .infinity)
                        .padding(.leading,20)
                        
                        Button {
                            self.startAnnotation.toggle()
                            self.model.service.canAddAnnotation = self.startAnnotation
                        } label: {
                            Image(systemName: startAnnotation ? "plus.circle.fill" : "plus.circle")
                                .resizable()
                                .aspectRatio(contentMode: ContentMode.fit)
                        }
                        .frame(maxWidth:.infinity, maxHeight: .infinity)

                        
                        Button {
                            self.model.service.removeAnnotations()
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .aspectRatio(contentMode: ContentMode.fit)
                        }
                        .frame(maxWidth:.infinity, maxHeight: .infinity)
                        .padding(.trailing,20)

                    }
                    .background(Color.white)
                    .frame(width:200, height: 100)
                    .cornerRadius(20)
                    .padding()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                                    Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Text("Cancel").foregroundColor(.black)
                }
            },
                                trailing: Button(action: {
                self.model.service.removeAnnotations()
            }, label: {
                Text("Refresh")
            })
            )
            .toolbar{
                ToolbarItem(placement: .principal) {
                    Image("smartscan_black")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80.57, height: 36)
                   
                }
            }
        }
        .onAppear {
            model.service.start()
        }
        .onDisappear {
            model.service.stop()
        }
    }
}

extension ARAddAnnotationView{
    class ViewModel: ObservableObject {
        var service: ARAnnotationService
        
        init() {
            self.service = ARAnnotationService()
            self.service.annotationStyle = .sphere
            self.service.canAddAnnotation = true
        }
        
        func startScan(){
            self.service.prepare { result in
                switch result{
                case .success(let data):
                    print(data)
                    break
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
    ARAddAnnotationView()
}
