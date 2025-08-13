//
//  GitHubProfileHeaderView.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import SwiftUI

struct GitHubProfileHeaderView: View {
    let user: GitHubUser
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            GitHubUserImageView(url: user.avatar_url)
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 6) {
                Text(user.login).font(.title2).bold()
                if let name = user.name { Text(name).font(.subheadline) }
                if let bio = user.bio { Text(bio).font(.body).foregroundColor(.secondary) }
                HStack(spacing: 12) {
                    Label("\(user.followers ?? 0) followers", systemImage: "person.2")
                    Label("\(user.public_repos ?? 0) repos", systemImage: "tray.full")
                }.font(.footnote).foregroundColor(.secondary)
            }
            Spacer()
        }.padding()
    }
}
