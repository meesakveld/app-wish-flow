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
    @Published var selectedCurrency: Currency? {
        didSet {
            if let selectedCurrency = selectedCurrency {
                onCurrencyChange?(selectedCurrency)
            }
        }
    }
    
    @Published var loadingState: LoadingState = .readyToLoad
    var onCurrencyChange: ((Currency) -> Void)?
    
    func getCurrencies(selectedCurrencyCode: String?) async {
        loadingState = .isLoading
        do {
            let response = try await Strapi.contentManager.collection("currencies").getDocuments(as: [Currency].self)
            
            self.currencies = response.data
            self.loadingState = .finished
            
            if let selectedCode = selectedCurrencyCode,
               let foundCurrency = self.currencies.first(where: { $0.code == selectedCode }) {
                self.selectedCurrency = foundCurrency
            } else {
                self.selectedCurrency = self.currencies.first
            }
        } catch {
            self.currencies = []
            self.selectedCurrency = nil
            self.loadingState = .finished
            print(error)
        }
    }
}


@MainActor
struct PriceEntry: View {
    @StateObject private var vm = PriceEntryViewModel()
    
    var title: String
    @Binding var selectedCurrency: Currency
    @Binding var priceValue: Double
    var selectedCurrencyCode: String?
    
    @State private var price: String

    init(
        title: String = "Price",
        selectedCurrency: Binding<Currency>,
        price: Binding<Double>,
        selectedCurrencyCode: String? = nil
    ) {
        self.title = title
        self._selectedCurrency = selectedCurrency
        self._priceValue = price
        self.selectedCurrencyCode = selectedCurrencyCode
        self.price = price.wrappedValue.description == "0.0" ? "" : price.wrappedValue.description
    }
    
    var body: some View {
        HStack {
            Text(title)
                .style(textStyle: .text(.medium), color: .cForeground)
            
            Spacer()
            
            HStack(alignment: .center) {
                Menu {
                    if vm.loadingState == .isLoading {
                        ProgressView()
                    } else if !vm.currencies.isEmpty {
                        ForEach(vm.currencies, id: \.documentId) { currency in
                            Button {
                                vm.selectedCurrency = currency
                            } label: {
                                Text("\(currency.symbol) - \(currency.name)")
                            }
                        }
                    } else {
                        Text("No currencies available")
                    }
                } label: {
                    Text(vm.selectedCurrency?.symbol ?? "...")
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
            vm.onCurrencyChange = { currency in
                selectedCurrency = currency
            }
            await vm.getCurrencies(selectedCurrencyCode: selectedCurrencyCode)
        }
    }
}

#Preview {
    PriceEntry(selectedCurrency: .constant(Currency()), price: .constant(19.0))
}
