//
//  APIClient.swift
//  Plagit
//
//  Reusable REST API client for all admin services.
//  Uses URLSession with async/await. Supports auth token injection,
//  JSON encoding/decoding, and structured error handling.
//

import Foundation

// MARK: - Configuration

struct APIConfig {
    /// Base URL for all API requests.
    /// Points to Railway production. To use a local server during development,
    /// temporarily change this to "http://127.0.0.1:3000/v1".
    static var baseURL: String = "https://plagit-backend-production.up.railway.app/v1"

    /// Auth token for authenticated requests. Set after login.
    /// The client injects this as a Bearer token in the Authorization header.
    static var authToken: String?

    /// Default request timeout in seconds.
    static var timeoutInterval: TimeInterval = 30
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(String)
    case encodingFailed(String)
    case badRequest(String)
    case unauthorized(String)
    case forbidden(String)
    case notFound
    case serverError(Int, String?)
    case networkError(String)
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return L10n.errInvalidUrl
        case .noData: return L10n.errNoData
        case .decodingFailed(let detail): return "\(L10n.errUnexpected): \(detail)"
        case .encodingFailed(let detail): return "\(L10n.errUnexpected): \(detail)"
        case .badRequest(let msg): return L10n.apiError(msg)
        case .unauthorized(let msg): return L10n.apiError(msg)
        case .forbidden(let msg): return L10n.apiError(msg)
        case .notFound: return L10n.errNotFound
        case .serverError(let code, _): return "\(L10n.errServer) (\(code))"
        case .networkError(_): return L10n.errNetwork
        case .unknown(let code): return "\(L10n.errUnexpected) (HTTP \(code))"
        }
    }
}

// MARK: - API Client

final class APIClient: Sendable {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared) {
        self.session = session

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    // MARK: - Core Request

    /// Perform a request and decode the response as the given type.
    func request<T: Decodable>(
        _ method: HTTPMethod,
        path: String,
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        let data = try await rawRequest(method, path: path, body: body, queryItems: queryItems)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    /// Perform a request that returns no meaningful body (e.g. DELETE, status-only responses).
    func requestVoid(
        _ method: HTTPMethod,
        path: String,
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws {
        _ = try await rawRequest(method, path: path, body: body, queryItems: queryItems)
    }

    // MARK: - Raw Request

    private func rawRequest(
        _ method: HTTPMethod,
        path: String,
        body: (any Encodable)?,
        queryItems: [URLQueryItem]?
    ) async throws -> Data {
        // Build URL
        guard var components = URLComponents(string: APIConfig.baseURL + path) else {
            throw APIError.invalidURL
        }
        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = APIConfig.timeoutInterval

        // Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = APIConfig.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Body
        if let body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingFailed(error.localizedDescription)
            }
        }

        // Execute
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }

        // Handle HTTP status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError("Invalid response type.")
        }

        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 400, 401:
            let msg = extractErrorMessage(from: data)
            throw httpResponse.statusCode == 400
                ? APIError.badRequest(msg)
                : APIError.unauthorized(msg)
        case 403:
            throw APIError.forbidden(extractErrorMessage(from: data))
        case 404:
            throw APIError.notFound
        case 500...599:
            let message = String(data: data, encoding: .utf8)
            throw APIError.serverError(httpResponse.statusCode, message)
        default:
            throw APIError.unknown(httpResponse.statusCode)
        }
    }

    private func extractErrorMessage(from data: Data) -> String {
        struct ErrorBody: Decodable { let error: String? }
        if let body = try? JSONDecoder().decode(ErrorBody.self, from: data), let msg = body.error {
            return msg
        }
        return String(data: data, encoding: .utf8) ?? "Unknown error."
    }
}

// MARK: - Encodable Wrapper

/// Use this for simple JSON body payloads that don't warrant a full struct.
struct JSONBody: Encodable {
    private let data: [String: AnyCodableValue]

    init(_ dict: [String: Any]) {
        self.data = dict.compactMapValues { AnyCodableValue($0) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        for (key, value) in data {
            let codingKey = DynamicCodingKey(stringValue: key)
            try container.encode(value, forKey: codingKey)
        }
    }
}

private struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }
    init(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}

enum AnyCodableValue: Encodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    init?(_ value: Any) {
        if let v = value as? String { self = .string(v) }
        else if let v = value as? Int { self = .int(v) }
        else if let v = value as? Double { self = .double(v) }
        else if let v = value as? Bool { self = .bool(v) }
        else { return nil }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let v): try container.encode(v)
        case .int(let v): try container.encode(v)
        case .double(let v): try container.encode(v)
        case .bool(let v): try container.encode(v)
        }
    }
}
