//
//  GitHubUserRepos.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import SwiftUI

struct GitHubUserReposView: View {
    let repo: GitHubRepo
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(repo.name).font(.headline)
            if let desc = repo.description {
                Text(desc).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
            }
            HStack(spacing: 12) {
                Label("\(repo.stargazers_count ?? 0)", systemImage: "star")
                Label("\(repo.forks_count ?? 0)", systemImage: "tuningfork")
                Spacer()
                if let url = repo.html_url {
                    Link("Open", destination: url)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }.padding(.vertical, 8)
    }
}
