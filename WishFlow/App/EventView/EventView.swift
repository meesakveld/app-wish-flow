//
//  EventView.swift
//  WishFlow
//
//  Created by Mees Akveld on 26/02/2025.
//

import SwiftUI

class EventViewModel: ObservableObject {
    @Published var event: Event? = nil
    @Published var eventIsLoading: LoadingState = .preparingToLoad
    @Published var eventHasError: Bool = false
    
    @Published var eventViewSubpage: eventViewSubpage = .info
    
    func getEvent(documentId: String, isLoading: Binding<LoadingState>) async {
        eventHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            //            try await Task.sleep(nanoseconds: 20_000_000_000)
            let strapiResponse = try await EventManager.shared.getEventByDocumentId(documentId: documentId)
            print(strapiResponse)
            event = strapiResponse
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    enum eventViewSubpage {
        case info, myWishes, gifties
    }
}

struct EventView: View {
    let documentId: String
    @ObservedObject var vm: EventViewModel = EventViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            
            // MARK: - Title
            HStack(alignment: .center) {
                Text(vm.event?.title ?? "Event title")
                    .multilineTextAlignment(.center)
                    .style(textStyle: .title(.h1), color: .cForeground)
            }
            .padding(.horizontal)
            
            
            // MARK: - Image
            VStack(spacing: 12) {
                
                DropEffect {
                    ZStack {
                        Color.cYellow
                            .frame(maxWidth: .infinity, maxHeight: 200)
                        
                        if let url = vm.event?.image?.formats?.small?.url {
                            AsyncImage(url: URL(string: url)) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxWidth: .infinity, maxHeight: 200)
                        }
                    }
                }
                
                
                // MARK: - Menu Switcher
                DropEffect {
                    HStack(spacing: 0) {
                        Text("Info")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.cPurple)
                            .border(Color.cBlack)
                            .overlay {
                                if vm.eventViewSubpage == .info {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.cBlack, lineWidth: 1.5)
                                        .background(Color.clear)
                                        .padding(4)
                                }
                            }
                            .onTapGesture { vm.eventViewSubpage = .info }
                        
                        Text("My wishes")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.cYellow)
                            .border(Color.cBlack)
                            .overlay {
                                if vm.eventViewSubpage == .myWishes {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.cBlack, lineWidth: 1.5)
                                        .background(Color.clear)
                                        .padding(4)
                                }
                            }
                            .onTapGesture { vm.eventViewSubpage = .myWishes }
                        
                        Text("Gifties")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.cGreen)
                            .border(Color.cBlack)
                            .overlay {
                                if vm.eventViewSubpage == .gifties {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.cBlack, lineWidth: 1.5)
                                        .background(Color.clear)
                                        .padding(4)
                                }
                            }
                            .onTapGesture { vm.eventViewSubpage = .gifties }
                    }
                    .style(textStyle: .text(.medium), color: .cBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                }
                
            }
            
            // MARK: - Info
            ScrollView {
                VStack(spacing: 40) {
                    Text(
                        vm.event?.description ?? "Lorem ipsum dolor sit amet consectetur. Eros fusce ut ipsum in velit eu eros. Consectetur id enim eleifend eget sit lacus. Laoreet at elit id sodales. Amet viverra Amet viverra amet ipsum suspendisse eget urna hendrerit ac."
                    )
                    .style(textStyle: .text(.regular), color: .cForeground)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center) {
                            Text("Eventdate:")
                                .style(textStyle: .text(.medium), color: .cBlack)
                            
                            Text((vm.event?.eventDate ?? Date()).dateToStringFormatter(DateFormat: .EEE_comma_MMM_dd_yyyy))
                                .style(textStyle: .text(.regular), color: .cBlack)
                            
                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Text("Budget:")
                                .style(textStyle: .text(.medium), color: .cBlack)
                            
                            Text("€10 - €20")
                                .style(textStyle: .text(.regular), color: .cBlack)
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .loadingEffect(vm.eventIsLoading.isInLoadingState())
        .padding(.horizontal)
        .background(Color.cBackground.ignoresSafeArea())
        .task {
            await vm.getEvent(documentId: documentId, isLoading: $vm.eventIsLoading)
        }
        .toolbar {
            Button {
                print("add event")
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

#Preview {
    NavigationStack {
        NavigationLink("", value: true)
            .navigationDestination(isPresented: .constant(true)) {
                EventView(documentId: "yyi02rmev5oqpgxllz903avf")
            }
    }
}
