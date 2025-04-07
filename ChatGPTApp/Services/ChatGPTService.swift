//
//  ChatGPTService.swift
//  ChatGPTApp
//
//  Created by Lauro Marinho on 03/04/25.
//


import Foundation

class ChatGPTService {
    static let shared = ChatGPTService()
    
    private let apiKey = "SUA-API-PROPRIA-DE-ACESSO-AQUI"
    
    func sendMessage(message: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion("Erro: URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": message]]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion("Erro ao codificar JSON")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("Erro na requisição: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion("Erro: Nenhum dado recebido")
                return
            }
            
            // 🔴 Imprime a resposta bruta da API
            if let responseString = String(data: data, encoding: .utf8) {
                print("Resposta bruta da API: \(responseString)")
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let choices = jsonResponse?["choices"] as? [[String: Any]],
                   let messageData = choices.first?["message"] as? [String: String],
                   let responseText = messageData["content"] {
                    DispatchQueue.main.async {
                        completion(responseText)
                    }
                } else {
                    completion("Erro: Formato inesperado na resposta da API")
                }
            } catch {
                completion("Erro ao decodificar JSON: \(error.localizedDescription)")
            }
        }.resume()
        
    }
}
