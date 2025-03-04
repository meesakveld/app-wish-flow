//
//  AddWishView.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import SwiftUI

class AddWishViewModel: ObservableObject {
    @Published var tabViewIndex: Int = 1
}

struct AddWishView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject private var alertManager: AlertManager
    
    @ObservedObject var vm: AddWishViewModel = AddWishViewModel()
    
    @State var title: String = ""
    @State var description: String = ""
    @State var image: Data? = nil
    @State var url: String = ""
    @State var price: Double = 0
    @State var giftLimit: Int = 1
    
    var body: some View {
        VStack(spacing: 40) {
            
            // MARK: - Title
            HStack(alignment: .center) {
                Text("Add a wish")
                    .multilineTextAlignment(.center)
                    .style(textStyle: .title(.h1), color: .cForeground)
            }
            
            TabView(selection: $vm.tabViewIndex) {
                // MARK: - Add via URL or manual
                ScrollView {
                    VStack(spacing: 40) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Add via URL or manual")
                                    .style(textStyle: .text(.bold), color: .cForeground)
                                
                                Text("Paste the link to the gift you want and add it to your wishlist.")
                                    .style(textStyle: .textSmall(.regular), color: .cForeground)
                            }
                            Spacer()
                        }
                        
                        FormWrapper { inputsErrors, isShowingInputsErrors in
                            Group {
                                TextEntry(
                                    identifier: "url",
                                    value: $url,
                                    title: "URL",
                                    placeholder: "Enter enter",
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors
                                )
                            }
                        } submit: { setIsLoading, setFormError, inputsErrors, isShowingInputsErrors in
                            Button {
                                Task {
                                    setIsLoading(.isLoading)
                                    setFormError(nil)
                                    isShowingInputsErrors.wrappedValue = true


                                    if inputsErrors.isEmpty {
                                        do {
//                                            try await vm.login(identifier: identifier, password: password)
//                                            navigationManager.navigate(to: .home)
                                        } catch {
                                            print(error)
                                            setFormError("Something went wrong")
                                        }
                                    }
                                    setIsLoading(.finished)
                                }
                            } label: {
                                DropEffect {
                                    HStack {
                                        Text("Next")
                                            .style(textStyle: .text(.medium), color: .cBlack)
                                            .padding(15)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .background(Color.cGreen)
                                }
                            }
                        }
                        
                        Button {
                            print("")
                        } label: {
                            Text("Add manual")
                                .underline()
                                .style(textStyle: .text(.medium), color: .cForeground.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)
                }
                .tag(1)
                
                ScrollView {
                    VStack(spacing: 40) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Wish information")
                                    .style(textStyle: .text(.bold), color: .cForeground)
                                
                                Text("Enter the details of your wish and add it to your wishlist.")
                                    .style(textStyle: .textSmall(.regular), color: .cForeground)
                            }
                            Spacer()
                        }
                        
                        FormWrapper { inputsErrors, isShowingInputsErrors in
                            Group {
                                TextEntry(
                                    identifier: "url",
                                    value: $url,
                                    title: "URL",
                                    placeholder: "Enter enter",
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors
                                )
                            }
                        } submit: { setIsLoading, setFormError, inputsErrors, isShowingInputsErrors in
                            Button {
                                Task {
                                    setIsLoading(.isLoading)
                                    setFormError(nil)
                                    isShowingInputsErrors.wrappedValue = true


                                    if inputsErrors.isEmpty {
                                        do {
//                                            try await vm.login(identifier: identifier, password: password)
//                                            navigationManager.navigate(to: .home)
                                        } catch {
                                            print(error)
                                            setFormError("Something went wrong")
                                        }
                                    }
                                    setIsLoading(.finished)
                                }
                            } label: {
                                DropEffect {
                                    HStack {
                                        Text("Next")
                                            .style(textStyle: .text(.medium), color: .cBlack)
                                            .padding(15)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .background(Color.cGreen)
                                }
                            }
                        }
                        
                        Button {
                            print("")
                        } label: {
                            Text("Add manual")
                                .underline()
                                .style(textStyle: .text(.medium), color: .cForeground.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)
                }
                .tag(2)
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Spacer()
            
        }
        .background(Color.cBackground)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
        }){
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
    }
}


#Preview {
    NavigationStack {
        NavigationLink("", value: true)
            .navigationDestination(isPresented: .constant(true)) {
                AddWishView()
            }
    }
}
