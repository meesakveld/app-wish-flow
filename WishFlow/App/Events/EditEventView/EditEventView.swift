//
//  EditEventView.swift
//  WishFlow
//
//  Created by Mees Akveld on 11/03/2025.
//

import SwiftUI

struct EditEventView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @ObservedObject var vm: EditEventViewModel = EditEventViewModel()
    
    let documentId: String
    
    // FORM VALUES
    @State var title: String = ""
    @State var description: String = ""
    @State var image: UIImage? = nil
    @State private var imageURL: String? = nil
    @State var eventDate: Date = Date()
    @State var giftDeadline: Date = Date()
    @State var claimDeadline: Date = Date()
    @State var minPrice: Double = 0.0
    @State var minPriceCurrency: Currency = Currency()
    @State private var minPriceCurrencyCode: String? = nil
    @State var maxPrice: Double = 0.0
    @State var maxPriceCurrency: Currency = Currency()
    @State private var maxPriceCurrencyCode: String? = nil
    
    // Optional work values
    @State var isShowingGiftDeadline: Bool = false
    @State var isShowingClaimDeadline: Bool = false
    @State var isShowingMinPrice: Bool = false
    @State var isShowingMaxPrice: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            
            // MARK: - Title
            HStack(alignment: .center) {
                Text("Update an event")
                    .multilineTextAlignment(.center)
                    .style(textStyle: .title(.h1), color: .cForeground)
            }
            .padding(.horizontal)
            
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
                            
                            DatePicker(selection: $eventDate, in: Date()..., displayedComponents: [.date]) {
                                Text("Event date")
                                    .style(textStyle: .text(.medium), color: .cForeground)
                            }
                            
                            Text("Budget")
                                .style(textStyle: .text(.bold), color: .cForeground)
                                .padding(.top, 10)
                            
                            HStack {
                                CheckCircle(isChecked: isShowingMinPrice) {
                                    withAnimation { isShowingMinPrice.toggle() }
                                }
                                
                                PriceEntry(
                                    title: "Minimal budget",
                                    selectedCurrency: $minPriceCurrency,
                                    price: $minPrice,
                                    selectedCurrencyCode: minPriceCurrencyCode
                                )
                                .disabled(!isShowingMinPrice)
                                .opacity(isShowingMinPrice ? 1 : 0.4)
                            }
                            
                            HStack {
                                CheckCircle(isChecked: isShowingMaxPrice) {
                                    withAnimation { isShowingMaxPrice.toggle() }
                                }
                                
                                PriceEntry(
                                    title: "Maximum budget",
                                    selectedCurrency: $maxPriceCurrency,
                                    price: $maxPrice,
                                    selectedCurrencyCode: maxPriceCurrencyCode
                                )
                                .disabled(!isShowingMaxPrice)
                                .opacity(isShowingMaxPrice ? 1 : 0.4)
                            }
                            
                            Text("Timing")
                                .style(textStyle: .text(.bold), color: .cForeground)
                                .padding(.top, 10)
                            
                            HStack {
                                CheckCircle(isChecked: isShowingGiftDeadline) {
                                    withAnimation { isShowingGiftDeadline.toggle() }
                                }
                                
                                DatePicker(selection: $giftDeadline, in: Date()...eventDate.addFifteenMinutes(), displayedComponents: [.date]) {
                                    Text("Deadline adding wishes")
                                        .style(textStyle: .text(.medium), color: .cForeground)
                                }
                                .disabled(!isShowingGiftDeadline)
                                .opacity(isShowingGiftDeadline ? 1 : 0.4)
                            }
                            
                            HStack {
                                CheckCircle(isChecked: isShowingClaimDeadline) {
                                    withAnimation { isShowingClaimDeadline.toggle() }
                                }
                                
                                DatePicker(selection: $claimDeadline, in: giftDeadline...eventDate.addFifteenMinutes(), displayedComponents: [.date]) {
                                    Text("Deadline gift selecting")
                                        .style(textStyle: .text(.medium), color: .cForeground)
                                }
                                .disabled(!isShowingClaimDeadline)
                                .opacity(isShowingClaimDeadline ? 1 : 0.4)
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
                                        let updatedTitle = checkForDiff(oldValue: vm.event?.title, newValue: title)
                                        let updatedDescription = checkForDiff(oldValue: vm.event?.description, newValue: description)
                                        let updatedImage = checkForDiff(oldValue: nil, newValue: image)
                                        let updatedEventDate = checkForDiff(oldValue: vm.event?.eventDate, newValue: eventDate)
                                        let updatedMinBudgetAmount = isShowingMinPrice ? minPrice : nil
                                        let updatedMinBudgetCurreny = isShowingMinPrice ? minPriceCurrency : nil
                                        let updatedMaxBudgetAmount = isShowingMaxPrice ? maxPrice : nil
                                        let updatedMaxBudgetCurreny = isShowingMaxPrice ? maxPriceCurrency : nil
                                        let updatedGiftDeadline = isShowingGiftDeadline ? giftDeadline : nil
                                        let updatedClaimDeadline = isShowingClaimDeadline ? claimDeadline : nil

                                        let event = try await vm.updateEvent(
                                            documentId: documentId,
                                            title: updatedTitle,
                                            description: updatedDescription,
                                            image: updatedImage,
                                            eventDate: updatedEventDate,
                                            minBudgetAmount: updatedMinBudgetAmount,
                                            minBudgetCurrency: updatedMinBudgetCurreny,
                                            maxBudgetAmount: updatedMaxBudgetAmount,
                                            maxBudgetCurrency: updatedMaxBudgetCurreny,
                                            giftDeadline: updatedGiftDeadline,
                                            claimDeadline: updatedClaimDeadline
                                        )
                                        if let _ = event?.documentId {
                                            mode.wrappedValue.dismiss()
                                        }
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
                        .padding(.bottom, 40)
                    }
                    
                }
                .padding(.horizontal)
                .loadingEffect(vm.eventIsLoading.isInLoadingState())
                .task {
                    await vm.getEvent(documentId: documentId, isLoading: $vm.eventIsLoading)
                    if let event = vm.event {
                        title = event.title
                        description = event.description
                        imageURL = event.image?.getURL(size: .small)
                        eventDate = event.eventDate
                        if let giftDeadline = event.giftDeadline {
                            self.giftDeadline = giftDeadline
                            self.isShowingGiftDeadline = true
                        }
                        if let claimDeadline = event.claimDeadline {
                            self.claimDeadline = claimDeadline
                            self.isShowingClaimDeadline = true
                        }
                        
                        minPrice = event.minBudget?.amount ?? 0.0
                        minPriceCurrencyCode = event.minBudget?.currency?.code
                        if (minPriceCurrencyCode != nil) {
                            isShowingMinPrice = true
                        }
                        
                        maxPrice = event.maxBudget?.amount ?? 0.0
                        maxPriceCurrencyCode = event.maxBudget?.currency?.code
                        if (maxPriceCurrencyCode != nil) {
                            isShowingMaxPrice = true
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: [.bottom])
        }
        .background(Color.cBackground)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
        }){
            HStack {
                Image(systemName: "chevron.left")
                Text("Cancel")
            }
        })
    }
}

#Preview {
    EditEventView(documentId: "yyi02rmev5oqpgxllz903avf")
}
