//
//  GitHubUserSearchViewModel.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import Foundation
import Combine

final class GitHubUserSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var searchResults: [GitHubUserSearchItem] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isLoadingMore = false

    private var page = 1
    private let perPage = 20
    private var cancellables = Set<AnyCancellable>()
    private let api: GitHubSearchUsersProtocol

    init(api: GitHubSearchUsersProtocol) {
        self.api = api
        setupSearchDebounce()
    }
    /// Debounce setup for automatic search
    private func setupSearchDebounce() {
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // 500 milliseconds wait for api call
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self = self else { return }
                if !newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.searchUsers(reset: true)
                } else {
                    self.searchResults = []
                    self.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }

    func searchUsers(reset: Bool = true) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.errorMessage = GitHubUserConstants.textFieldEmpty
            return
        }
        errorMessage = nil

        if reset {
            page = 1
            searchResults = []
            isLoading = true
        } else {
            isLoadingMore = true
        }

        api.searchUsers(keyword: query, page: page, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                self?.isLoadingMore = false
                if case .failure(let err) = completion {
                    self?.errorMessage = GitHubUserConstants.userNotFound
                }
            } receiveValue: { [weak self] results in
                guard let self = self else { return }
                let newUniqueItems = results.filter { newUser in
                    !self.searchResults.contains(where: { $0.login == newUser.login })
                }
                self.searchResults.append(contentsOf: newUniqueItems)
                if results.count == self.perPage {
                    self.page += 1
                }
            }
            .store(in: &cancellables)
    }
}
