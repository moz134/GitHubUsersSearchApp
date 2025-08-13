//
//  GitHubUserImageView.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import SwiftUI

struct GitHubUserImageView: View {
    @StateObject private var loader = ImageLoader()
    let url: URL?
    var body: some View {
        Group {
            if let ui = loader.image {
                Image(uiImage: ui).resizable().scaledToFill()
            } else {
                Rectangle().foregroundColor(Color.gray.opacity(0.3))
                    .overlay(ProgressView())
            }
        }
        .onAppear { loader.load(url: url) }
        .onDisappear { loader.cancel() }
    }
}
