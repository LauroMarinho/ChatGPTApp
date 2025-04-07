//
//  ChatViewController.swift
//  ChatGPTApp
//
//  Created by Lauro Marinho on 03/04/25.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private let inputField = UITextField()
    private let sendButton = UIButton()
    
    private var messages: [String] = [] // Armazena as mensagens

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    private func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        inputField.placeholder = "Type a message..."
        inputField.borderStyle = .roundedRect
        inputField.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = .blue
        sendButton.layer.cornerRadius = 5
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        view.addSubview(tableView)
        view.addSubview(inputField)
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -10),
            
            inputField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            inputField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            inputField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -10),
            inputField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func sendMessage() {
        guard let text = inputField.text, !text.isEmpty else { return }
        messages.append("You: \(text)")
        inputField.text = ""
        tableView.reloadData()
        
        fetchChatGPTResponse(for: text)
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }
    
    // MARK: - OpenAI API Request
    private func fetchChatGPTResponse(for message: String) {
        ChatGPTService.shared.sendMessage(message: message) { [weak self] response in
            DispatchQueue.main.async {
                self?.messages.append("ChatGPT: \(response)")
                self?.tableView.reloadData()
            }
        }
    }
}

