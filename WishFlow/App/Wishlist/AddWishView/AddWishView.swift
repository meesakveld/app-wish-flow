//
//  AddWishView.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import SwiftUI

class AddWishViewModel: ObservableObject {
    @Published var tabViewIndex: Int = 0
    @Published var newTabViewIndex: Int = 0 {
        didSet { withAnimation { tabViewIndex = newTabViewIndex }}
    }
    
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
            .padding(.horizontal)

            TabView(selection: $vm.tabViewIndex) {
                // MARK: - Add via URL or manual
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
                                    placeholder: "Enter the product url",
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
                                            let url = try validatedHttpsUrl(from: url)
                                            let data = await url.getPageData()
                                            print(data)
                                            
                                            if let title = data.getValue(.title) { self.title = title }
                                            if let description = data.getValue(.description) { self.description = description }
                                            print(data.getValue(.image))
                                            print(data.getValue(.price))
                                            print(data.getValue(.currency))
                                            vm.newTabViewIndex = 1
                                        } catch {
                                            print(error)
                                            setFormError(error.localizedDescription)
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
                            vm.newTabViewIndex = 1
                        } label: {
                            Text("Add manual")
                                .underline()
                                .style(textStyle: .text(.medium), color: .cForeground.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)
                }
                .tag(0)
                
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
                                    identifier: "title",
                                    value: $title,
                                    title: "Title",
                                    placeholder: "Enter title",
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors
                                )
                                
                                TextEntry(
                                    identifier: "description",
                                    value: $description,
                                    title: "Description",
                                    placeholder: "Enter description",
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors,
                                    entryType: .textEditor(lineLimit: 5)
                                )
                                
                                TextEntry(
                                    identifier: "url",
                                    value: $url,
                                    title: "URL",
                                    placeholder: "Enter enter",
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors
                                )
                                
                                TextEntry(
                                    identifier: "image",
                                    value: $url,
                                    title: "Image",
                                    placeholder: "Enter image",
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors
                                )
                                
                                TextEntry(
                                    identifier: "url",
                                    value: $url,
                                    title: "URL",
                                    placeholder: "Enter enter",
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors,
                                    isOptionalField: true
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
                    .ignoresSafeArea(edges: [.bottom])
                }
                .tag(1)
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onAppear {
                UIScrollView.appearance().isScrollEnabled = false
            }
            .onDisappear {
                UIScrollView.appearance().isScrollEnabled = true
            }
        }
        .background(Color.cBackground)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            if vm.tabViewIndex == 1 {
                vm.newTabViewIndex = 0
            } else {
                self.mode.wrappedValue.dismiss()
            }
        }){
            HStack {
                Image(systemName: "chevron.left")
                Text("Cancel")
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
