//
//  GitHubUserViewModel.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import Foundation
import Combine

final class GitHubUserViewModel: ObservableObject {
    @Published var user: GitHubUser?
    @Published var repos: [GitHubRepo] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isLoadingMore = false

    private var page = 1
    private let perPage = 20
    private var cancellables = Set<AnyCancellable>()

    func loadUser(username: String) {
        isLoading = true
        user = nil
        repos = []
        page = 1

        GitHubUserAPIService.shared.fetchUser(username: username)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.errorMessage = "User not found / network error (\(err.localizedDescription))"
                }
            } receiveValue: { [weak self] user in
                self?.user = user
                self?.loadRepos()
            }
            .store(in: &cancellables)
    }

    func loadRepos() {
        guard let username = user?.login else { return }
        isLoadingMore = true
        GitHubUserAPIService.shared.fetchRepos(username: username, page: page, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingMore = false
                if case .failure(let err) = completion {
                    self?.errorMessage = "Failed to load repos (\(err.localizedDescription))"
                }
            } receiveValue: { [weak self] newRepos in
                guard let self = self else { return }
                self.repos.append(contentsOf: newRepos)
                if newRepos.count == self.perPage {
                    self.page += 1
                }
            }
            .store(in: &cancellables)
    }
}


