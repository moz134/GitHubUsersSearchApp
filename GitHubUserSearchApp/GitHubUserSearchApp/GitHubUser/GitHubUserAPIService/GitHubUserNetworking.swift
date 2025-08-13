//
//  GitHubUserNetworking.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//


import Combine
import Foundation

protocol APIClientProtocol {
    func request<T: Codable>(_ url: URL, type: T.Type) -> AnyPublisher<T, Error>
}

final class GitHubUserNetworking: APIClientProtocol {
    func request<T: Decodable>(_ url: URL, type: T.Type) -> AnyPublisher<T, Error> {
        var req = URLRequest(url: url)
        req.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        return URLSession.shared.dataTaskPublisher(for: req)
            .tryMap { output in
                guard let http = output.response as? HTTPURLResponse,
                      (200...299).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: type, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

