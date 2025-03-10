//
//  AddEventView.swift
//  WishFlow
//
//  Created by Mees Akveld on 10/03/2025.
//

import SwiftUI

@MainActor
class AddEventViewModel: ObservableObject {
    @Published var tabViewIndex: Int = 0
    @Published var newTabViewIndex: Int = 0 {
        didSet { withAnimation { tabViewIndex = newTabViewIndex }}
    }
    
    let user: User? = AuthenticationManager.shared.user
    
    init() {
        if user == nil { AuthenticationManager.shared.logout() }
    }
    
    
}

struct AddEventView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject private var navigationManager: NavigationManager
    @ObservedObject var vm: AddEventViewModel = AddEventViewModel()
    
    // FORM VALUES
    @State var title: String = ""
    @State var description: String = ""
    @State var image: UIImage? = nil
    @State var imageURL: String? = nil
    @State var url: String = ""
    
    @State var price: Double = 0.0
    @State var currency: Currency = Currency()
    @State private var priceCurrencyCode: String? = nil
    
    @State private var mayBeGivenMoreThenOne: Bool = false
    @State var giftLimit: Int = 1
    
    func reset() {
        title = ""
        description = ""
        image = nil
        imageURL = nil
        url = ""
        price = 0.0
        priceCurrencyCode = nil
        mayBeGivenMoreThenOne = false
        giftLimit = 1
    }
    
    var body: some View {
        VStack(spacing: 40) {
            
            // MARK: - Title
            HStack(alignment: .center) {
                Text("Create an event")
                    .multilineTextAlignment(.center)
                    .style(textStyle: .title(.h1), color: .cForeground)
            }
            .padding(.horizontal)
            
            TabView(selection: $vm.tabViewIndex) {
                // MARK: - Select event type
                ScrollView {
                    VStack(spacing: 40) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Event type")
                                    .style(textStyle: .text(.bold), color: .cForeground)
                                
                                Text("Choose an event type based on the kind of event you want to organize.")
                                    .style(textStyle: .textSmall(.regular), color: .cForeground)
                            }
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            DropEffect {
                                HStack {
                                    VStack(alignment: .leading, spacing: 15) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Single Recipient")
                                                .style(textStyle: .title(.h3), color: .cBlack)
                                            
                                            Text("A gifting occasion where **one person** receives gifts from others.")
                                                .style(textStyle: .textSmall(.medium), color: .cBlack)
                                        }
                                        
                                        Text("E.g. Birthday, Graduation")
                                            .style(textStyle: .textSmall(.regular), color: .cBlack)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(15)
                                .background(Color.cGreen)
                            }
                            
                            DropEffect {
                                HStack {
                                    VStack(alignment: .leading, spacing: 15) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Group Gifting")
                                                .style(textStyle: .title(.h3), color: .cBlack)
                                            
                                            Text("A gifting format where **multiple people** contribute to or exchange gifts within a group.")
                                                .style(textStyle: .textSmall(.medium), color: .cBlack)
                                        }
                                        
                                        Text("E.g. Christmas, Baby Shower")
                                            .style(textStyle: .textSmall(.regular), color: .cBlack)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(15)
                                .background(Color.cBlue)
                            }
                            
                            DropEffect {
                                HStack {
                                    VStack(alignment: .leading, spacing: 15) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("One to one")
                                                .style(textStyle: .title(.h3), color: .cBlack)
                                            
                                            Text("A gifting system where one person gives a gift to one person, **randomly assigned**.")
                                                .style(textStyle: .textSmall(.medium), color: .cBlack)
                                        }
                                        
                                        Text("E.g. Secret Santa, Valentine’s Day")
                                            .style(textStyle: .textSmall(.regular), color: .cBlack)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(15)
                                .background(Color.cOrange)
                            }
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
                                
                                ImageEntry(
                                    identifier: "image",
                                    title: "Image",
                                    value: $image,
                                    valueURL: imageURL,
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors
                                )
                                
                                TextEntry(
                                    identifier: "url",
                                    value: $url,
                                    title: "URL",
                                    placeholder: "Enter enter",
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors
                                )
                                
                                PriceEntry(
                                    selectedCurrency: $currency,
                                    price: $price,
                                    selectedCurrencyCode: priceCurrencyCode
                                )
                                
                                // MayBeGivenMoreThenOneEntry
                                Group {
                                    Toggle("May be given more then once", isOn: $mayBeGivenMoreThenOne)
                                        .style(textStyle: .text(.medium), color: .cForeground)
                                        .tint(.cOrange)
                                    
                                    if mayBeGivenMoreThenOne {
                                        HStack(spacing: 20) {
                                            Stepper("Receive limit", value: $giftLimit, in: 1...999)
                                            
                                            Text(giftLimit.description)
                                        }
                                        .style(textStyle: .text(.medium), color: .cForeground)
                                    }
                                }
                            }
                        } submit: { setIsLoading, setFormError, inputsErrors, isShowingInputsErrors in
                            Button {
                                Task {
                                    setIsLoading(.isLoading)
                                    setFormError(nil)
                                    isShowingInputsErrors.wrappedValue = true
                                    
                                    
                                    if inputsErrors.isEmpty {
                                        do {
                                            //                                            let wish = try await vm.addWish(
                                            //                                                title: title,
                                            //                                                description: description,
                                            //                                                url: url,
                                            //                                                imageURL: imageURL,
                                            //                                                imageUIImage: image,
                                            //                                                giftLimit: giftLimit,
                                            //                                                priceAmount: price,
                                            //                                                priceCurrencyDocumentId: currency.documentId
                                            //                                            )
                                            //                                            navigationManager.back()
                                            //                                            if let wish = wish {
                                            //                                                navigationManager.navigate(to: .wish(documentId: wish.documentId))
                                            //                                            }
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
                                        Text("Save")
                                            .style(textStyle: .text(.medium), color: .cBlack)
                                            .padding(15)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .background(Color.cGreen)
                                }
                            }
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
                reset()
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
                AddEventView()
                    .environmentObject(NavigationManager())
            }
    }
}
