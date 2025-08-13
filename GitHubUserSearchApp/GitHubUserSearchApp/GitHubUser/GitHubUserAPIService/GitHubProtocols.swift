//
//  GitHubProtocols.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import Foundation
import Combine

protocol GitHubFetchReposProtocol {
    func fetchRepos(username: String, page: Int, perPage: Int) -> AnyPublisher<[GitHubRepo], Error>
}

protocol GitHubSearchUsersProtocol {
    func searchUsers(keyword: String, page: Int, perPage: Int) -> AnyPublisher<[GitHubUserSearchItem], Error>
}

protocol GitHubFetchUserProtocol {
    func fetchUser(username: String) -> AnyPublisher<GitHubUser, Error>
}
