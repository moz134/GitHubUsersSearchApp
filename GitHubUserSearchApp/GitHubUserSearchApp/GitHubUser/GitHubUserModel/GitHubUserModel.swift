//
//  GitHubUserModel.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import Foundation

struct GitHubUser: Codable, Identifiable {
    let id: Int
    let login: String
    let avatar_url: URL?
    let name: String?
    let bio: String?
    let followers: Int?
    let public_repos: Int?
    let html_url: URL?
}

struct GitHubRepo: Codable, Identifiable {
    let id: Int
    let name: String
    let full_name: String?
    let description: String?
    let stargazers_count: Int?
    let forks_count: Int?
    let html_url: URL?
}


struct GitHubUserSearchItem: Codable, Identifiable {
    let id: Int
    let login: String
    let avatar_url: URL?
}

struct GitHubUserSearchResponse: Codable {
    let total_count: Int
    let items: [GitHubUserSearchItem]
}
