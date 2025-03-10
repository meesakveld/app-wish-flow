//
//  EditWishView.swift
//  WishFlow
//
//  Created by Mees Akveld on 10/03/2025.
//

import SwiftUI
import StrapiSwift

@MainActor
class EditWishViewModel: ObservableObject {
    @Published var wish: Gift? = nil
    @Published var wishIsLoading: LoadingState = .preparingToLoad
    @Published var wishHasError: Bool = false
    
    let user: User? = AuthenticationManager.shared.user
    
    init() {
        if user == nil { AuthenticationManager.shared.logout() }
    }
    
    func getWish(documentId: String, isLoading: Binding<LoadingState>) async {
        wishHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            let strapiResponse = try await GiftManager.shared.getGiftByDocumentId(documentId: documentId, userId: user?.id ?? 1)
            wish = strapiResponse
        } catch {
            wishHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateWish(documentId: String, title: String?, description: String?, image: UIImage?, url: String?, price: Double?, priceCurrencyDocumentId: String?, giftLimit: Int?, isLoading: Binding<LoadingState>) async throws {
        wishHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // —— Update image ——
            // Delete old image
            if let image = image, let oldImageId = wish?.image?.id {
                try await Strapi.mediaLibrary.files.withId(oldImageId).delete(as: StrapiImage.self)
            }
            
            // Upload new image
            var imageId: Int?
            if let image = image {
                let response = try await Strapi.mediaLibrary.files.uploadImage(image: image)
                imageId = response?.id
            }
            
            // —— Update gift ——
            try await GiftManager.shared.updateGiftByDocumentId(
                documentId: documentId,
                title: title,
                description: description,
                url: url,
                imageId: imageId,
                giftLimit: giftLimit,
                priceAmount: price,
                priceCurrencyDocumentId: priceCurrencyDocumentId
            )
        } catch {
            wishHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
}

struct EditWishView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject private var navigationManager: NavigationManager
    @ObservedObject var vm: EditWishViewModel = EditWishViewModel()
    
    let documentId: String
    
    // —— Form Values ——
    @State var title: String = ""
    @State var description: String = ""
    @State var image: UIImage? = nil
    @State private var imageURL: String? = nil
    @State var url: String = ""
    
    @State var price: Double = 0.0
    @State var currency: Currency = Currency()
    @State private var priceCurrencyCode: String? = nil
    
    @State private var mayBeGivenMoreThenOne: Bool = false
    @State var giftLimit: Int = 1
    
    func checkForDiff<T: Equatable>(oldValue: T?, newValue: T?) -> T? {
        if oldValue != newValue { return newValue }
        return nil
    }
    
    var body: some View {
        ScrollView {
            // MARK: - Error handling for when wish is not found
            if vm.wishHasError {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        FeedbackMessage(
                            image: "error",
                            text: "Whoops! We can't find the wish you are trying to edit — try again later!"
                        ) {
                            Button {
                                Task {
                                    await vm.getWish(documentId: documentId, isLoading: $vm.wishIsLoading)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle")
                                    Text("Refresh")
                                }
                                .style(textStyle: .text(.regular), color: .cOrange)
                            }
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity ,maxHeight: .infinity)
            }
            
            // MARK: - Wish
            if !vm.wishHasError {
                VStack(spacing: 40) {
                    
                    // MARK: - Title
                    HStack(alignment: .center) {
                        Text("Edit wish")
                            .multilineTextAlignment(.center)
                            .style(textStyle: .title(.h1), color: .cForeground)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 40) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Wish information")
                                    .style(textStyle: .text(.bold), color: .cForeground)
                                
                                Text("Update here the details of your wish.")
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
                                        .onChange(of: mayBeGivenMoreThenOne) { _, nv in
                                            if !nv { giftLimit = 1 }
                                        }
                                    
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
                                            let updatedTitle = checkForDiff(oldValue: vm.wish?.title, newValue: title)
                                            let updatedDescription = checkForDiff(oldValue: vm.wish?.description, newValue: description)
                                            let updatedUrl = checkForDiff(oldValue: vm.wish?.url, newValue: url)
                                            let updatedPrice = checkForDiff(oldValue: vm.wish?.price?.amount, newValue: price)
                                            let updatedCurrencyId = checkForDiff(oldValue: vm.wish?.price?.currency?.documentId, newValue: currency.documentId)
                                            let updatedGiftLimit = checkForDiff(oldValue: vm.wish?.giftLimit, newValue: giftLimit)
                                            let updatedImage = checkForDiff(oldValue: nil, newValue: image)

                                            try await vm.updateWish(
                                                documentId: documentId,
                                                title: updatedTitle,
                                                description: updatedDescription,
                                                image: updatedImage,
                                                url: updatedUrl,
                                                price: updatedPrice,
                                                priceCurrencyDocumentId: updatedCurrencyId,
                                                giftLimit: updatedGiftLimit,
                                                isLoading: $vm.wishIsLoading
                                            )

                                            self.mode.wrappedValue.dismiss()
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
                    .loadingEffect(vm.wishIsLoading.isInLoadingState())
                }
                .task {
                    await vm.getWish(documentId: documentId, isLoading: $vm.wishIsLoading)
                    if let wish = vm.wish {
                        title = wish.title
                        description = wish.description
                        imageURL = wish.image?.getURL(size: .medium)
                        url = wish.url ?? ""
                        price = wish.price?.amount ?? 0.0
                        priceCurrencyCode = wish.price?.currency?.code
                        mayBeGivenMoreThenOne = wish.giftLimit > 1
                        giftLimit = wish.giftLimit
                    }
                }
            }
        }
        .background(Color.cBackground.ignoresSafeArea())
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
    NavigationStack {
        NavigationLink("", value: true)
            .navigationDestination(isPresented: .constant(true)) {
                EditWishView(documentId: "j7u00k3sajkspg36gw0srngk")
            }
    }
}
