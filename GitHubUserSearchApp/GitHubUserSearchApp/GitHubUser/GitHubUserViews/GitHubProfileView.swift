//
//  GitHubProfileView.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import SwiftUI

struct GitHubProfileView: View {
    @StateObject private var vm = GitHubUserViewModel()
    let username: String

    var body: some View {
        VStack {
            if vm.isLoading {
                ProgressView(GitHubUserConstants.profileAPICallLoaderMsg)
                Spacer()
            } else if let error = vm.errorMessage {
                Text(error).foregroundColor(.red).padding()
                Spacer()
            } else if let user = vm.user {
                ScrollView {
                    GitHubProfileHeaderView(user: user)
                    LazyVStack {
                        ForEach(vm.repos) { repo in
                            GitHubUserReposView(repo: repo)
                                .padding(.horizontal)
                                .onAppear {
                                    if vm.repos.last?.id == repo.id {
                                        vm.loadRepos()
                                    }
                                }
                            Divider().padding(.leading)
                        }
                        if vm.isLoadingMore {
                            ProgressView().padding()
                        }
                    }
                }
            }
        }
        .onAppear { vm.loadUser(username: username) }
        .navigationTitle(username)
        .navigationBarTitleDisplayMode(.inline)
    }
}
