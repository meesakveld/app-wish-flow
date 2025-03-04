//
//  Searchbar.swift
//  WishFlow
//
//  Created by Mees Akveld on 23/02/2025.
//

import SwiftUI
import Combine

class SearchbarViewModel: ObservableObject {
    @Published var searchDebounce: String = ""
    private var cancellable: AnyCancellable?

    init(searchBinding: Binding<String>) {
        cancellable = $searchDebounce
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { newValue in
                searchBinding.wrappedValue = newValue
            }
    }
}

struct Searchbar: View {
    @Binding var search: String
    let searchString: String
    
    @StateObject private var viewModel: SearchbarViewModel
    @FocusState private var isFocused: Bool
    let autoFocus: Bool

    init(search: Binding<String>, searchString: String, autoFocus: Bool = false) {
        self._search = search
        self._viewModel = StateObject(wrappedValue: SearchbarViewModel(searchBinding: search))
        self.autoFocus = autoFocus
        self.searchString = searchString
    }

    var body: some View {
        DropEffect {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .font(.custom("", fixedSize: 20))
                    .frame(minHeight: 48)
                    .foregroundStyle(.cForeground)
                    .padding(.horizontal, 12)
                    .background(Color.cGreen)
                    .border(Color.black)
                    .onTapGesture {
                        isFocused = true
                    }

                TextField(searchString, text: $viewModel.searchDebounce)
                    .style(textStyle: .text(.regular), color: .black)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .padding(.horizontal, 10)
                    .background(Color.cWhite)
                    .multilineTextAlignment(.leading)
                    .focused($isFocused)
                    .onAppear {
                        if autoFocus {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isFocused = true
                            }
                        }
                    }
                    .onSubmit {
                        isFocused = false
                    }
            }
        }
    }
}

#Preview {
    Searchbar(search: .constant(""), searchString: "Search an event")
}
