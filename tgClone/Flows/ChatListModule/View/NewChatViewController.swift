//
//  NewChatViewController.swift
//  tgClone
//
//  Created by Андрей Чучупал on 07.02.2026.
//

import UIKit

final class NewChatViewController: UIViewController {
    
    var onChatCreated: (() -> Void)?
    private let avatarNames = ["ava1", "ava2", "ava3"]
    private var selectedAvatarName: String?
    private var avatarButtons: [UIButton] = []
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новый чат"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Имя собеседника"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let chooseAvatarLabel: UILabel = {
        let label = UILabel()
        label.text = "Выбери аватарку"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    private let avatarsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let createButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Начать чат", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        selectedAvatarName = avatarNames.first
        
        setupUI()
        setupAvatars()
    }
    
    private func setupUI() {
        [titleLabel, nameTextField, chooseAvatarLabel, avatarsStackView, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            chooseAvatarLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            chooseAvatarLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            avatarsStackView.topAnchor.constraint(equalTo: chooseAvatarLabel.bottomAnchor, constant: 10),
            avatarsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            avatarsStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            avatarsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.topAnchor.constraint(equalTo: avatarsStackView.bottomAnchor, constant: 30),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }
    
    private func setupAvatars() {
        for (index, name) in avatarNames.enumerated() {
            let button = UIButton(type: .custom)
            
            if let image = UIImage(named: name) {
                button.setImage(image, for: .normal)
            } else {
                button.backgroundColor = .systemGray5
            }
            
            button.imageView?.contentMode = .scaleAspectFill
            button.layer.cornerRadius = 30
            button.layer.masksToBounds = true
            button.tag = index
            
            button.addTarget(self, action: #selector(avatarTapped(_:)), for: .touchUpInside)
            
            if index == 0 {
                button.layer.borderWidth = 3
                button.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                button.layer.borderWidth = 0
                button.layer.borderColor = UIColor.clear.cgColor
            }
            
            button.widthAnchor.constraint(equalToConstant: 60).isActive = true
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            avatarButtons.append(button)
            avatarsStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func avatarTapped(_ sender: UIButton) {
        avatarButtons.forEach { btn in
            if btn == sender {
                btn.layer.borderWidth = 3
                btn.layer.borderColor = UIColor.systemBlue.cgColor
                UIView.animate(withDuration: 0.1) {
                    btn.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                } completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        btn.transform = .identity
                    }
                }
            } else {
                btn.layer.borderWidth = 0
                btn.layer.borderColor = UIColor.clear.cgColor
            }
        }
        
        let index = sender.tag
        if index < avatarNames.count {
            selectedAvatarName = avatarNames[index]
        }
    }
    
    @objc private func createTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            return
        }
        
        CoreDataManager.shared.createChatList(
            name: name,
            avatar: selectedAvatarName,
            isPinned: false
        )
        
        onChatCreated?()
        dismiss(animated: true)
    }
}
