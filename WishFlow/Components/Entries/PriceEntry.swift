//
//  PriceEntry.swift
//  WishFlow
//
//  Created by Mees Akveld on 07/03/2025.
//

import SwiftUI
import StrapiSwift

@MainActor
class PriceEntryViewModel: ObservableObject {
    @Published var currencies: [Currency] = []
    @Published var loadingState: LoadingState = .readyToLoad
    
    func getCurrencies() async {
        loadingState = .isLoading
        do {
            let response = try await Strapi.contentManager.collection("currencies").getDocuments(as: [Currency].self)
            currencies = response.data
        } catch {
            currencies = []
            print(error)
        }
        loadingState = .finished
    }
}

struct PriceEntry: View {
    @ObservedObject var vm: PriceEntryViewModel = PriceEntryViewModel()
    
    let title: String = "Price"
    @Binding var selectedCurrency: Currency
    @Binding var priceValue: Double
    @State private var price: String
    
    var selectedCurrencyCode: String? = nil
    
    init(selectedCurrency: Binding<Currency>, price: Binding<Double>) {
        self._selectedCurrency = selectedCurrency
        self._priceValue = price
        self.price = price.wrappedValue.description
    }
    
    init(selectedCurrency: Binding<Currency>, price: Binding<Double>, selectedCurrencyCode: String?) {
        self._selectedCurrency = selectedCurrency
        self._priceValue = price
        self.price = price.wrappedValue.description
        self.selectedCurrencyCode = selectedCurrencyCode
    }
    
    var body: some View {
        HStack {
            Text(title)
                .style(textStyle: .text(.medium), color: .cForeground)
            
            Spacer()
            
            HStack(alignment: .center) {
                Menu {
                    ForEach(vm.currencies, id: \.documentId) { currency in
                        Button {
                            selectedCurrency = currency
                        } label: {
                            Text("\(currency.symbol) - \(currency.name)")
                        }

                    }
                } label: {
                    Text(selectedCurrency.symbol)
                        .frame(height: 40)
                        .padding(.horizontal, 15)
                        .background(Color.cWhite)
                        .cornerRadius(7.5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7.5)
                                .stroke(Color.cBlack, lineWidth: 2)
                        )
                }
                
                TextField("12,99", text: $price)
                    .frame(height: 40)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 70)
                    .padding(.horizontal, 10)
                    .background(Color.cWhite)
                    .cornerRadius(7.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7.5)
                            .stroke(Color.cBlack, lineWidth: 2)
                    )
                    .onChange(of: price) { _, nv in
                        priceValue = Double(nv) ?? 0
                    }
            }
            .style(textStyle: .text(.medium), color: .cForeground)
            .loadingEffect(vm.loadingState.isInLoadingState())
        }
        .task {
            await vm.getCurrencies()
            if !vm.currencies.isEmpty, let selectedCurrencyCode = selectedCurrencyCode {
                let foundCurrency = vm.currencies.first(where: { $0.code == selectedCurrencyCode })
                if let foundCurrency = foundCurrency {
                    selectedCurrency = foundCurrency
                }
            }
        }
    }
}

#Preview {
    PriceEntry(selectedCurrency: .constant(Currency()), price: .constant(19.0))
}
