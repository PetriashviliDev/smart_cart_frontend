//
//  NetworkService.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import Foundation

struct ReminderResponse: Codable {
    let text: String
    let date: String
    let priority: String
}

class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    private let baseURL = "https://your-backend-api.com"
    private let session = URLSession.shared
    
    private init() {}
    
    func processAudioRecording(audioData: Data) async throws -> [ReminderResponse] {
        guard let url = URL(string: "\(baseURL)/process-audio") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("audio/m4a", forHTTPHeaderField: "Content-Type")
        request.httpBody = audioData
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        let reminders = try JSONDecoder().decode([ReminderResponse].self, from: data)
        return reminders
    }
    
    func uploadAudioFile(audioData: Data) async throws -> String {
        guard let url = URL(string: "\(baseURL)/upload") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"recording.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NetworkError.invalidResponse
        }
        
        return responseString
    }
}

enum NetworkError: Error {
    case invalidURL
    case serverError
    case invalidResponse
    case noData
}
