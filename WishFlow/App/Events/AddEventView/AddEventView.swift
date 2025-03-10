//
//  AddEventView.swift
//  WishFlow
//
//  Created by Mees Akveld on 10/03/2025.
//

import SwiftUI

@MainActor
class AddEventViewModel: ObservableObject {
    @Published var tabViewIndex: Int = 1
    @Published var newTabViewIndex: Int = 1 {
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
    @State var eventType: EventType = .singleRecipient
    @State var title: String = ""
    @State var description: String = ""
    @State var image: UIImage? = nil
    @State var eventDate: Date = Date()
    @State var giftDeadline: Date = Date()
    @State var claimDeadline: Date = Date()
    
    @State var minPrice: Double = 0.0
    @State var maxPrice: Double = 0.0
    @State var currency: Currency = Currency()
    
    func reset() {
        title = ""
        description = ""
        image = nil
        minPrice = 0.0
        maxPrice = 0.0
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
                            Button {
                                eventType = .singleRecipient
                                vm.newTabViewIndex = 1
                            } label: {
                                EventTypeCard(
                                    title: "Single Recipient",
                                    description: "A gifting occasion where **one person** receives gifts from others.",
                                    example: "E.g. Birthday, Baby Shower",
                                    backgroundColor: .cGreen
                                )
                            }
                            
                            Button {
                                eventType = .groupGifting
                                vm.newTabViewIndex = 1
                            } label: {
                                EventTypeCard(
                                    title: "Group Gifting",
                                    description: "A gifting format where **multiple people** exchange gifts within a group.",
                                    example: "E.g. Christmas",
                                    backgroundColor: .cBlue
                                )
                            }
                            
                            Button {
                                eventType = .oneToOne
                                vm.newTabViewIndex = 1
                            } label: {
                                EventTypeCard(
                                    title: "One to one",
                                    description: "A gifting system where pairings are **randomly assigned**, each person gives a gift to one person within a group.",
                                    example: "E.g. Secret Santa, Valentine’s Day",
                                    backgroundColor: .cOrange
                                )
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
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors
                                )
                                
                                DatePicker(selection: $eventDate, in: Date()..., displayedComponents: [.date]) {
                                    Text("Event date")
                                        .style(textStyle: .text(.medium), color: .cForeground)
                                }
                                
                                Text("Budget")
                                    .style(textStyle: .text(.bold), color: .cForeground)
                                    .padding(.top, 10)
                                
                                HStack {
                                    CheckCircle(isChecked: false) {
                                        //
                                    }
                                    
                                    PriceEntry(
                                        title: "Minimal budget",
                                        selectedCurrency: $currency,
                                        price: $minPrice
                                    )
                                }
                                
                                HStack {
                                    CheckCircle(isChecked: false) {
                                        //
                                    }
                                    
                                    PriceEntry(
                                        title: "Maximum budget",
                                        selectedCurrency: $currency,
                                        price: $maxPrice
                                    )
                                }
                                
                                Text("Timing")
                                    .style(textStyle: .text(.bold), color: .cForeground)
                                    .padding(.top, 10)
                                
                                HStack {
                                    CheckCircle(isChecked: false) {
                                        //
                                    }
                                    
                                    DatePicker(selection: $giftDeadline, in: Date()...eventDate.addFifteenMinutes(), displayedComponents: [.date]) {
                                        Text("Deadline adding wishes")
                                            .style(textStyle: .text(.medium), color: .cForeground)
                                    }
                                }
                                
                                HStack {
                                    CheckCircle(isChecked: false) {
                                        //
                                    }
                                    
                                    DatePicker(selection: $claimDeadline, in: Date()...eventDate.addFifteenMinutes(), displayedComponents: [.date]) {
                                        Text("Deadline gift selecting")
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
                }
                .tag(1)
                
            }
            .ignoresSafeArea(edges: [.bottom])
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
