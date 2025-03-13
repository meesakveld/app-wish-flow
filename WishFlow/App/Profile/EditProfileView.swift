//
//  EditProfileView.swift
//  WishFlow
//
//  Created by Mees Akveld on 13/03/2025.
//

import SwiftUI
import StrapiSwift

struct EditProfileView: View {
    @ObservedObject var vm: EditProfileViewModel = EditProfileViewModel()
    
    // Update profile
    @State var username: String = ""
    @State var email: String = ""
    @State var firstname: String = ""
    @State var lastname: String = ""
    @State var imageURL: String? = nil
    @State var image: UIImage? = nil
    
    // Update password
    @State var currentPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmNewPassword: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                
                // MARK: - UPDATE PROFILE
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Update profile")
                                .style(textStyle: .title(.h2), color: .cForeground)
                            
                            Text("Update here your username of email address.")
                                .style(textStyle: .textSmall(.regular), color: .cForeground)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    FormWrapper { inputsErrors, isShowingInputsErrors in
                        Group {
                            ImageEntry(
                                identifier: "avatar",
                                title: "Avatar",
                                value: $image,
                                valueURL: imageURL,
                                errors: inputsErrors,
                                isShowingErrors: isShowingInputsErrors
                            )
                            
                            TextEntry(
                                identifier: "username",
                                value: $username,
                                title: "Username",
                                placeholder: "Enter username",
                                errors: inputsErrors,
                                isShowingErrors: isShowingInputsErrors
                            )
                            
                            TextEntry(
                                identifier: "firstname",
                                value: $firstname,
                                title: "First name",
                                placeholder: "Enter your first name",
                                errors: inputsErrors,
                                isShowingErrors: isShowingInputsErrors
                            )
                            
                            TextEntry(
                                identifier: "lastname",
                                value: $lastname,
                                title: "Last name",
                                placeholder: "Enter your last name",
                                errors: inputsErrors,
                                isShowingErrors: isShowingInputsErrors
                            )
                            
                            TextEntry(
                                identifier: "email",
                                value: $email,
                                title: "Email",
                                placeholder: "Enter email",
                                errors: inputsErrors,
                                isShowingErrors: isShowingInputsErrors
                            )
                        }
                    } submit: { setIsLoading, setFormError, setFormSuccess, inputsErrors, isShowingInputsErrors in
                        Button {
                            Task {
                                setIsLoading(.isLoading)
                                setFormError(nil)
                                setFormSuccess(nil)
                                isShowingInputsErrors.wrappedValue = true
                                
                                if inputsErrors.isEmpty {
                                    do {
                                        let user = try await vm.updateProfile(username: username, firstname: firstname, lastname: lastname, email: email, image: image)
                                        if let user = user {
                                            username = user.username
                                            email = user.email
                                            if let firstname = user.firstname { self.firstname = firstname }
                                            if let lastname = user.lastname { self.lastname = lastname }
                                            
                                            setFormSuccess("Succes! Your account has been updated.")
                                        }
                                    } catch let error as StrapiSwiftError {
                                        switch error {
                                        case .badResponse(_, let message):
                                            setFormError(message)
                                        default:
                                            setFormError("Something went wrong")
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
                                    Text("Update profile")
                                        .style(textStyle: .text(.medium), color: .cBlack)
                                        .padding(15)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color.cGreen)
                            }
                        }
                    }
                }
                    
                // MARK: - UPDATE PASSWORD
                VStack(spacing: 20) {
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Update password")
                                .style(textStyle: .title(.h2), color: .cForeground)
                            
                            Text("Update here your password to keep your account secure.")
                                .style(textStyle: .textSmall(.regular), color: .cForeground)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    FormWrapper { inputsErrors, isShowingInputsErrors in
                        Group {
                            TextEntry(
                                identifier: "currentPassword",
                                value: $currentPassword,
                                title: "Current password",
                                placeholder: "Enter current password",
                                errors: inputsErrors,
                                isShowingErrors: isShowingInputsErrors,
                                entryType: .secureField
                            )
                            
                            TextEntry(
                                identifier: "newPassword",
                                value: $newPassword,
                                title: "New password",
                                placeholder: "Enter new password",
                                errors: inputsErrors,
                                isShowingErrors: isShowingInputsErrors,
                                entryType: .secureField
                            )
                            
                            TextEntry(
                                identifier: "confirmNewPassword",
                                value: $confirmNewPassword,
                                title: "Confirm new password",
                                placeholder: "Enter new password again",
                                errors: inputsErrors,
                                isShowingErrors: isShowingInputsErrors,
                                entryType: .secureField
                            )
                        }
                    } submit: { setIsLoading, setFormError, setFormSuccess, inputsErrors, isShowingInputsErrors in
                        Button {
                            Task {
                                setIsLoading(.isLoading)
                                setFormError(nil)
                                setFormSuccess(nil)
                                isShowingInputsErrors.wrappedValue = true
                                
                                if inputsErrors.isEmpty {
                                    do {
                                        try await vm.updatePassword(currentPassword: currentPassword, newPassword: newPassword, confirmNewPassworm: confirmNewPassword)
                                        setFormSuccess("Succes! Your password has been updated.")
                                        
                                        currentPassword = ""
                                        newPassword = ""
                                        confirmNewPassword = ""
                                    } catch let error as StrapiSwiftError {
                                        switch error {
                                        case .badResponse(_, let message):
                                            setFormError(message)
                                        default:
                                            setFormError("Something went wrong")
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
                                    Text("Update password")
                                        .style(textStyle: .text(.medium), color: .cBlack)
                                        .padding(15)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color.cGreen)
                            }
                        }
                    }
                    
                }
            }
            .padding([.top, .horizontal])
            .padding(.bottom, 40)
            .loadingEffect(vm.userIsLoading.isInLoadingState())
        }
        .task {
            await vm.getUser(isLoading: $vm.userIsLoading)
            vm.userIsLoading = .isLoading
            if let avatar = vm.user?.avatar?.getURL(size: .medium) { self.imageURL = avatar }
            if let username = vm.user?.username { self.username = username }
            if let firstname = vm.user?.firstname { self.firstname = firstname }
            if let lastname = vm.user?.lastname { self.lastname = lastname }
            if let email = vm.user?.email { self.email = email }
            vm.userIsLoading = .finished
        }
        .ignoresSafeArea(edges: [.bottom])
        .background(Color.cBackground.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(NavigationManager())
            .sheet(isPresented: .constant(true)) {
                EditProfileView()
            }
    }
}
