//
//  ChatViewController.swift
//  tgClone
//
//  Created by Андрей Чучупал on 24.10.2025.
//

import UIKit

// MARK: - Chat Protocols

protocol ChatViewProtocol: AnyObject {
    func displayMessages(_ messages: [Chat])
    func showError(_ error: String)
    func updateScrollContent()
}

// MARK: - Chat View Controller

final class ChatViewController: UIViewController {
    
    // MARK: - Properties
    
    private var presenter: ChatPresenterProtocol!
    private let scrollView = UIScrollView()
    private var chatHeader: UIView?
    private var chatInputView: UIView?
    private var messages: [Chat] = []
    private var chatModel: ChatList?
    
    // MARK: - Constants
    
    private struct Constants {
        static let headerHeight: CGFloat = 60
        static let inputHeight: CGFloat = 60
        static let bubbleSpacing: CGFloat = 10
        static let topPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 20
        static let sideMargin: CGFloat = 16
        static let bubbleMaxWidthRatio: CGFloat = 0.65
        static let bubbleMaxWidth: CGFloat = 280
        static let labelInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .appHeaderBar
        setupChatInputView()
        setupScrollView()
        setupChatHeaderIfNeeded()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Configuration
    
    func configure(with presenter: ChatPresenterProtocol, chatModel: ChatList) {
        self.presenter = presenter
        self.chatModel = chatModel
    }
    
    func configure(with presenter: ChatPresenterProtocol) {
        self.presenter = presenter
    }
}

// MARK: - Private Methods

private extension ChatViewController {
    
    func scrollToBottomIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let contentHeight = self.scrollView.contentSize.height
            let scrollViewHeight = self.scrollView.bounds.height
            
            if contentHeight > scrollViewHeight {
                let bottomOffset = CGPoint(
                    x: 0,
                    y: contentHeight - scrollViewHeight + self.scrollView.adjustedContentInset.bottom
                )
                self.scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
    
    func setupChatHeaderIfNeeded() {
        guard let chatModel = self.chatModel,
              isViewLoaded,
              chatHeader == nil else {
            return
        }
        
        chatHeader = Components.shared.createChatHeader(with: chatModel)
        guard let chatHeader = chatHeader else { return }
        
        view.addSubview(chatHeader)
        
        NSLayoutConstraint.activate([
            chatHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatHeader.heightAnchor.constraint(equalToConstant: Constants.headerHeight)
        ])
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        updateScrollViewConstraints()
    }
    
    func setupScrollViewBackground() {
        guard let bgImage = UIImage(named: "bgPattern") else { return }
        scrollView.backgroundColor = UIColor(patternImage: bgImage)
    }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        setupScrollViewBackground()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.headerHeight),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: chatInputView?.topAnchor ?? view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupChatInputView() {
        let attachmentAction = UIAction() { [weak self] _ in
            self?.presenter.didTapAttachment()
        }
        
        let voiceAction = UIAction() { [weak self] _ in
            self?.presenter.didTapVoice()
        }
        
        chatInputView = Components.shared.createChatBottomBar(
            attachmentAction: attachmentAction,
            sendAction: { [weak self] text, role in
                self?.presenter.didSendMessage(text, role: role)
            },
            voiceAction: voiceAction
        )
        guard let chatInputView = chatInputView else { return }
        
        view.addSubview(chatInputView)
        
        NSLayoutConstraint.activate([
            chatInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            chatInputView.heightAnchor.constraint(equalToConstant: Constants.inputHeight)
        ])
    }
    
    func updateScrollViewConstraints() {
        guard let chatHeader = chatHeader else { return }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(scrollView, belowSubview: chatHeader)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: chatHeader.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: chatInputView?.topAnchor ?? view.safeAreaLayoutGuide.bottomAnchor)
        ])
        setupScrollViewBackground()
    }
}

// MARK: - Message Bubble Creation

private extension ChatViewController {
    
    func createBubbleView(for message: Chat) -> UIView {
        let role: ChatRoles = (message.role == "user") ? .user : .friend
        let bubble = BubbleView(role: role)
        let label = createMessageLabel(with: message.text ?? "")
        
        bubble.addSubview(label)
        setupLabelConstraints(label, in: bubble)
        
        return bubble
    }
    
    func createMessageLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func setupLabelConstraints(_ label: UILabel, in bubble: UIView) {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: Constants.labelInsets.top),
            label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -Constants.labelInsets.bottom),
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: Constants.labelInsets.left),
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -Constants.labelInsets.right)
        ])
    }
}

// MARK: - Message Layout Calculations

private extension ChatViewController {
    
    func calculateBubbleSize(for message: Chat) -> CGSize {
        let bubbleWidth = min(view.bounds.width * Constants.bubbleMaxWidthRatio, Constants.bubbleMaxWidth)
        let targetSize = CGSize(
            width: bubbleWidth - Constants.labelInsets.left - Constants.labelInsets.right,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        let label = UILabel()
        label.text = message.text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        
        let textHeight = label.sizeThatFits(targetSize).height
        let totalHeight = textHeight + Constants.labelInsets.top + Constants.labelInsets.bottom
        
        return CGSize(width: bubbleWidth, height: totalHeight)
    }
    
    func calculateBubblePosition(for message: Chat, width: CGFloat) -> CGFloat {
        return message.role == "user"
        ? view.bounds.width - width - Constants.sideMargin
        : Constants.sideMargin
    }
}

// MARK: - Message Layout Management

private extension ChatViewController {
    
    func layoutMessages() {
        clearScrollView()
        var currentY = Constants.topPadding
        
        for message in messages {
            let bubble = createBubbleView(for: message)
            let size = calculateBubbleSize(for: message)
            let xPosition = calculateBubblePosition(for: message, width: size.width)
            
            bubble.frame = CGRect(
                x: xPosition,
                y: currentY,
                width: size.width,
                height: size.height
            )
            
            scrollView.addSubview(bubble)
            currentY += size.height + Constants.bubbleSpacing
        }
        
        updateScrollViewContentSize(with: currentY)
    }
    
    func clearScrollView() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func updateScrollViewContentSize(with currentY: CGFloat) {
        scrollView.contentSize = CGSize(
            width: view.bounds.width,
            height: currentY + Constants.bottomPadding
        )
    }
}

// MARK: - ChatViewProtocol

extension ChatViewController: ChatViewProtocol {
    func displayMessages(_ messages: [Chat]) {
        self.messages = messages
        layoutMessages()
        scrollToBottomIfNeeded()
    }
    
    func showError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateScrollContent() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let bottomOffset = CGPoint(
                x: 0,
                y: max(0, self.scrollView.contentSize.height - self.scrollView.bounds.height)
            )
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
}
