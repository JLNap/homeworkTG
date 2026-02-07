//
//  ImageTitleView.swift
//  tgClone
//
//  Created by Андрей Чучупал on 22.10.2025.
//

import UIKit

final class Components {
    static let shared = Components()
    lazy var router: ChatListRouterProtocol = ChatListRouter()
    private init() {}
    
    func imageWithText(icon: UIImage, text: String, size: CGSize) -> UIImage? {
        let label = UILabel(frame: CGRect(x: 0, y: size.height - 20, width: size.width, height: 20))
        label.text = text
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .white
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height - 20))
        imageView.image = icon
        imageView.tintColor = .white
        imageView.contentMode = .center
        
        let container = UIView(frame: CGRect(origin: .zero, size: size))
        container.addSubview(imageView)
        container.addSubview(label)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        container.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    // MARK: - Header Component
    func createChatHeader(title: String,
                          leftButtonTitle: String = "Edit",
                          rightButtonAction: @escaping () -> Void,
                          leftButtonAction: @escaping () -> Void) -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemBackground
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let leftAction = UIAction { _ in
            leftButtonAction()
        }
        
        let rightAction = UIAction { _ in
            rightButtonAction()
        }
        
        let leftButton = UIButton(type: .system)
        leftButton.setTitle(leftButtonTitle, for: .normal)
        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        leftButton.setTitleColor(.systemBlue, for: .normal)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.addAction(leftAction, for: .touchUpInside) // Вешаем правильный экшн
        
        let rightButton = UIButton(type: .system)
        let composeImage = UIImage(systemName: "square.and.pencil")
        rightButton.setImage(composeImage, for: .normal)
        rightButton.tintColor = .systemBlue
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.addAction(rightAction, for: .touchUpInside) // Вешаем правильный экшн
        
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(leftButton)
        headerView.addSubview(rightButton)
        
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 33),
            
            leftButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            leftButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            rightButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            rightButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            rightButton.widthAnchor.constraint(equalToConstant: 24),
            rightButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return headerView
    }
    
    // MARK: - Search Bar Component
    func createSearchBar(placeholder: String = "Search for messages or users") -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.layer.cornerRadius = 10
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return searchBar
    }
    
    // MARK: - Tab Bar Component
    func createCustomTabBar(selectedIndex: Int = 2,
                            tabSelectAction: @escaping (Int) -> Void) -> UIView {
        let tabBarView = UIView()
        tabBarView.backgroundColor = UIColor.systemGray6
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        let topSeparator = UIView()
        topSeparator.backgroundColor = UIColor.separator
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        enum TabType: Int, CaseIterable {
            case contacts = 0
            case calls = 1
            case chats = 2
            case settings = 3
            
            var iconName: String {
                switch self {
                case .contacts: return "person.circle"
                case .calls: return "phone"
                case .chats: return "message.fill"
                case .settings: return "person.crop.circle"
                }
            }
            
            var title: String {
                switch self {
                case .contacts: return "Contacts"
                case .calls: return "Calls"
                case .chats: return "Chats"
                case .settings: return "Settings"
                }
            }
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for tabType in TabType.allCases {
            let button = createTabBarButton(
                iconName: tabType.iconName,
                title: tabType.title,
                isSelected: tabType.rawValue == selectedIndex,
                tag: tabType.rawValue
            )
            
            let buttonAction = UIAction { _ in
                updateButtonSelection(in: stackView, selectedIndex: tabType.rawValue)
                tabSelectAction(tabType.rawValue)
                handleTabSelection(tabType: tabType)
            }
            
            button.addAction(buttonAction, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        func updateButtonSelection(in stackView: UIStackView, selectedIndex: Int) {
            for (index, arrangedSubview) in stackView.arrangedSubviews.enumerated() {
                guard let button = arrangedSubview as? UIButton else { continue }
                
                let isSelected = index == selectedIndex
                button.tintColor = isSelected ? .systemBlue : .systemGray
            }
        }
        
        func handleTabSelection(tabType: TabType) {
            switch tabType {
            case .contacts:
                router.noAction()
            case .calls:
                router.noAction()
            case .chats:
                router.noAction()
            case .settings:
                router.noAction()
            }
        }
        
        tabBarView.addSubview(topSeparator)
        tabBarView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            tabBarView.heightAnchor.constraint(equalToConstant: 93),
            
            topSeparator.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            stackView.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: tabBarView.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        return tabBarView
    }
    
    private func createTabBarButton(iconName: String, title: String, isSelected: Bool, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: iconName)
        config.title = title
        config.imagePlacement = .top
        config.imagePadding = 8
        config.titleAlignment = .center
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 10)
            return outgoing
        }
        
        button.configuration = config
        button.tintColor = isSelected ? .systemBlue : .systemGray
        
        return button
    }
    
    //MARK: - Chat view header
    func createChatHeader(with chatModel: ChatList) -> UIView {
        
        let headerView = UIView()
        headerView.backgroundColor = .appHeaderBar
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let backButton = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.title = "Chats"
        config.imagePadding = 5
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -8, bottom: 0, trailing: 0)
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17)
            return outgoing
        }
        
        backButton.configuration = config
        backButton.tintColor = .systemBlue
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        let backAction = UIAction { _ in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let navController = window.rootViewController as? UINavigationController {
                navController.popViewController(animated: true)
            }
        }
        backButton.addAction(backAction, for: .touchUpInside)
        
        let avatarImageView = UIImageView()
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let avatarImage = UIImage(named: chatModel.avatar ?? "") {
            avatarImageView.image = avatarImage
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray3
        }
        
        let textContainer = UIStackView()
        textContainer.axis = .vertical
        textContainer.spacing = 2
        textContainer.alignment = .leading
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = chatModel.name
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let statusLabel = UILabel()
        statusLabel.text = "last seen just now"
        statusLabel.font = UIFont.systemFont(ofSize: 13)
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textContainer.addArrangedSubview(nameLabel)
        textContainer.addArrangedSubview(statusLabel)
        
        headerView.addSubview(backButton)
        headerView.addSubview(avatarImageView)
        headerView.addSubview(textContainer)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            avatarImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            avatarImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            textContainer.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            textContainer.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            textContainer.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -16)
        ])
        
        return headerView
    }
    
    private func generateLastSeenStatus(from messages: [MessageModel]) -> String {
        guard let lastMessage = messages.last else {
            return "last seen recently"
        }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastMessage.date)
        
        if timeInterval < 60 {
            return "last seen just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "last seen \(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "last seen \(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "last seen \(formatter.string(from: lastMessage.date))"
        }
    }
    
    // MARK: - Chat bottom bar
    func createChatBottomBar(
        attachmentAction: UIAction? = nil,
        sendAction: ((String, String) -> Void)? = nil,
        voiceAction: UIAction? = nil
    ) -> UIView {
        
        let bottomView = UIView()
        bottomView.backgroundColor = .appBottomBar
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        let addFileBtn = UIButton(type: .system, primaryAction: attachmentAction)
        addFileBtn.setImage(UIImage(systemName: "paperclip"), for: .normal)
        addFileBtn.tintColor = .appBottomBtns
        addFileBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.backgroundColor = .appTextField
        containerView.layer.cornerRadius = 18
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let msgField = UITextField()
        msgField.placeholder = "Message"
        msgField.font = UIFont.systemFont(ofSize: 16)
        msgField.borderStyle = .none
        msgField.backgroundColor = .clear
        msgField.translatesAutoresizingMaskIntoConstraints = false
        
        let roleSwitch = UISwitch()
        roleSwitch.isOn = true
        roleSwitch.onTintColor = .systemBlue
        roleSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        let rightViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        rightViewContainer.addSubview(roleSwitch)
        roleSwitch.center = CGPoint(x: 30, y: 15)
        
        msgField.rightView = rightViewContainer
        msgField.rightViewMode = .always
        
        let micBtn = UIButton(type: .system)
        micBtn.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        micBtn.tintColor = .systemGray
        micBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let updateButtonState = { [weak micBtn, weak msgField] in
            guard let micBtn = micBtn, let msgField = msgField else { return }
            
            let hasText = !(msgField.text?.isEmpty ?? true)
            if hasText {
                micBtn.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
                micBtn.tintColor = .systemBlue
            } else {
                micBtn.setImage(UIImage(systemName: "mic.fill"), for: .normal)
                micBtn.tintColor = .appBottomBtns
            }
        }
        
        let micBtnAction = UIAction { _ in
            let hasText = !(msgField.text?.isEmpty ?? true)
            if hasText, let text = msgField.text {
                
                let role = roleSwitch.isOn ? "user" : "friend"
                
                sendAction?(text, role)
                
                msgField.text = ""
                updateButtonState()
            } else {
                print("no action")
            }
        }
        
        micBtn.addAction(micBtnAction, for: .primaryActionTriggered)
        
        let textFieldAction = UIAction { _ in updateButtonState() }
        msgField.addAction(textFieldAction, for: .editingChanged)
        msgField.addAction(textFieldAction, for: .allEditingEvents)
        
        bottomView.addSubview(addFileBtn)
        bottomView.addSubview(containerView)
        bottomView.addSubview(micBtn)
        containerView.addSubview(msgField)
        
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: 60),
            
            addFileBtn.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            addFileBtn.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            addFileBtn.widthAnchor.constraint(equalToConstant: 32),
            addFileBtn.heightAnchor.constraint(equalToConstant: 32),
            
            micBtn.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            micBtn.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            micBtn.widthAnchor.constraint(equalToConstant: 32),
            micBtn.heightAnchor.constraint(equalToConstant: 32),
            
            containerView.leadingAnchor.constraint(equalTo: addFileBtn.trailingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: micBtn.leadingAnchor, constant: -12),
            containerView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            msgField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            msgField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            msgField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            msgField.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return bottomView
    }
}
