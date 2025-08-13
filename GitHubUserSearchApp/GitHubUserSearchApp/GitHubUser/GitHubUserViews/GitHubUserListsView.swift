//
//  GitHubUserLists.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import SwiftUI

struct GitHubUserListsView: View {
    @StateObject private var viewModel = GitHubUserSearchViewModel(api: GitHubUserAPIService.shared)
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    TextField(GitHubUserConstants.userTextFieldPlaceholder, text: $viewModel.query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    Button("Search") {
                        viewModel.searchUsers(reset: true)
                    }
                }
                .padding()

                if viewModel.isLoading {
                    ProgressView(GitHubUserConstants.usersSearchLoading)
                    Spacer()

                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                    Spacer()

                } else if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { user in
                        NavigationLink(destination: GitHubProfileView(username: user.login)) {
                            HStack {
                                GitHubUserImageView(url: user.avatar_url)
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                                Text(user.login)
                                    .font(.headline)
                            }
                        }
                        .onAppear {
                            // Pagination trigger
                            if viewModel.searchResults.last?.id == user.id {
                                viewModel.searchUsers(reset: false)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())

                    // Bottom loading indicator
                    if viewModel.isLoadingMore {
                        ProgressView()
                            .padding()
                    }

                }
                else {
                    Spacer()
                    Text("Enter a keyword to search GitHub users")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .navigationTitle("GitHub Search")
        }
    }
}
