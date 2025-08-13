//
//  GitHubUserAPIService.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import Foundation
import Combine

final class GitHubUserAPIService: GitHubFetchUserProtocol, GitHubFetchReposProtocol, GitHubSearchUsersProtocol {
    private let client: APIClientProtocol
    static let shared = GitHubUserAPIService()
    
    private init() {
        self.client = CachedAPIClient(downstream: GitHubUserNetworking(), policy: CachePolicy.duration)
    }
    
    // To fetch users
    func searchUsers(keyword: String, page: Int, perPage: Int) -> AnyPublisher<[GitHubUserSearchItem], Error> {
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(GitHubUserConstants.baseURL)/search/users?q=\(encodedKeyword)&per_page=\(perPage)&page=\(page)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return client.request(url, type: GitHubUserSearchResponse.self)
            .map { $0.items }
            .eraseToAnyPublisher()
    }
    
    // Fetch user profile Data
    func fetchUser(username: String) -> AnyPublisher<GitHubUser, Error> {
        guard let url = URL(string: "\(GitHubUserConstants.baseURL)/users/\(username)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return client.request(url, type: GitHubUser.self)
    }
    
    // To fetch repositories of user
    func fetchRepos(username: String, page: Int, perPage: Int) -> AnyPublisher<[GitHubRepo], Error> {
        guard let url = URL(string: "\(GitHubUserConstants.baseURL)/users/\(username)/repos?per_page=\(perPage)&page=\(page)&sort=updated") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return client.request(url, type: [GitHubRepo].self)
    }
}
