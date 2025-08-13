//
//  GItHubUserCache.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import Foundation
import Combine

struct CachePolicy {
    let ttl: TimeInterval
    let allowStaleOnError: Bool
    static let duration = CachePolicy(ttl: 60, allowStaleOnError: true)
}

final class CachedAPIClient: APIClientProtocol {
    private let downstream: APIClientProtocol
    private let cache: ResponseCacheStore
    private let policy: CachePolicy

    init(downstream: APIClientProtocol,
         cache: ResponseCacheStore = CoreDataResponseCache(),
         policy: CachePolicy) {
        self.downstream = downstream
        self.cache = cache
        self.policy = policy
    }

    func request<T: Codable>(_ url: URL, type: T.Type) -> AnyPublisher<T, Error> {
        let key = CacheKey.from(url: url)
        let now = Date()
        if let (data, ts) = cache.read(for: key),
           now.timeIntervalSince(ts) < policy.ttl {
            return Just(data)
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }

        return downstream.request(url, type: T.self)
            .map { [weak self] decoded -> T in
                if let data = try? JSONEncoder().encode(decoded) {
                    self?.cache.write(data, for: key)
                }
                return decoded
            }
            .catch { [weak self] error -> AnyPublisher<T, Error> in
                if let self = self,
                   self.policy.allowStaleOnError,
                   let (data, _) = self.cache.read(for: key),
                   let decoded = try? JSONDecoder().decode(T.self, from: data) {
                    return Just(decoded).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
