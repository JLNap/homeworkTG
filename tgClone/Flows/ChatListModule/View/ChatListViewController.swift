//
//  ChatListViewController.swift
//  tgClone
//
//  Created by Андрей Чучупал on 24.10.2025.
//

import UIKit
import CoreData

protocol ChatListViewProtocol: AnyObject {
    func showChats(_ chats: [ChatList])
    func showError(_ error: String)
    func showLoading()
    func hideLoading()
}

final class ChatListViewController: UIViewController {
    
    enum Section { case main }
    
    private var presenter: ChatListPresenterProtocol!
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var headerView: UIView!
    private var tabBarView: UIView!
    
    private var dataSource: UITableViewDiffableDataSource<Section, ChatList>!
    private var chats: [ChatList] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewDidLoad()
    }
    
    // MARK: - Configuration
    
    func configure(with presenter: ChatListPresenterProtocol) {
        self.presenter = presenter
    }
}

// MARK: - UI Setup

private extension ChatListViewController {
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        createHeader()
        createSearchBar()
        createTableView()
        createTabBar()
        setupConstraints()
        configureDataSource()
    }
    
    func createHeader() {
        headerView = Components.shared.createChatHeader(
            title: "Chats",
            rightButtonAction: { [weak self] in
                self?.handleComposeTapped()
            },
            leftButtonAction: { [weak self] in
                self?.handleEditTapped()
            }
        )
        view.addSubview(headerView)
    }
    
    func createSearchBar() {
        searchBar = Components.shared.createSearchBar()
        searchBar.delegate = self
        view.addSubview(searchBar)
    }
    
    func createTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell")
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    func createTabBar() {
        tabBarView = Components.shared.createCustomTabBar(selectedIndex: 2) { [weak self] index in
            self?.handleTabSelection(index)
        }
        view.addSubview(tabBarView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            searchBar.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tabBarView.topAnchor),
            
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - Data Source

private extension ChatListViewController {
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, ChatList>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, chat in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
                
                var lastMessageText = "Нет сообщений"
                var lastMessageDate = chat.lastMessageDate ?? Date()
                
                if let messages = chat.chat?.allObjects as? [Chat], !messages.isEmpty {
                    
                    let sortedMessages = messages.sorted {
                        ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast)
                    }
                    
                    if let lastMsg = sortedMessages.first {
                        lastMessageText = lastMsg.text ?? "Сообщение"
                        lastMessageDate = lastMsg.date ?? Date()
                    }
                }
                
                cell.configure(
                    friendName: chat.name ?? "No Name",
                    lastMsg: lastMessageText,
                    avatar: chat.avatar ?? "",
                    msgDate: lastMessageDate,
                    pin: chat.isPinned
                )
                
                return cell
            })
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ChatList>()
        snapshot.appendSections([.main])
        snapshot.appendItems(chats)
        snapshot.reloadItems(chats)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - User Actions

private extension ChatListViewController {
    
    func handleEditTapped() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    func handleComposeTapped() {
        presenter.didTapCompose()
    }
    
    func handleTabSelection(_ index: Int) {
        presenter.didSelectTab(at: index)
    }
}

// MARK: - Swipe Actions

private extension ChatListViewController {
    
    func createSwipeActions(for indexPath: IndexPath) -> [UIContextualAction] {
        let mute = createAction(.mute, "Mute", "speaker.slash.fill", .systemOrange, at: indexPath)
        let delete = createAction(.delete, "Delete", "trash.fill", .systemRed, at: indexPath)
        let archive = createAction(.archive, "Archive", "archivebox.fill", .systemGray, at: indexPath)
        return [mute, delete, archive]
    }
    
    func createLeadingActions(for indexPath: IndexPath) -> [UIContextualAction] {
        let chat = chats[indexPath.row]
        let unread = createAction(.unread, "Unread", "bubble.left.fill", .systemBlue, at: indexPath)
        
        let isPinned = chat.isPinned
        let pinTitle = isPinned ? "Unpin" : "Pin"
        let pinIcon = isPinned ? "pin.slash.fill" : "pin.fill"
        
        let pin = createAction(.pin, pinTitle, pinIcon, .systemGreen, at: indexPath)
        
        return [unread, pin]
    }
    
    func createAction(_ type: SwipeAction, _ title: String, _ iconName: String, _ color: UIColor, at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "") { [weak self] _, _, completion in
            self?.presenter.handleSwipeAction(type, at: indexPath.row)
            completion(true)
        }
        
        if let icon = UIImage(systemName: iconName) {
            action.image = Components.shared.imageWithText(
                icon: icon,
                text: title,
                size: CGSize(width: 60, height: 60)
            )
        }
        action.backgroundColor = color
        return action
    }
}

// MARK: - ChatListViewProtocol

extension ChatListViewController: ChatListViewProtocol {
    func showChats(_ chats: [ChatList]) {
        self.chats = chats
        applySnapshot()
    }
    
    func showError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showLoading() {
        
    }
    
    func hideLoading() {
        
    }
}

// MARK: - UITableViewDelegate

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectChat(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.row < chats.count else { return nil }
        let chat = chats[indexPath.row]
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: {
                ChatBuilder.build(chat: chat)
            },
            actionProvider: { [weak self] _ in
                guard let self = self else { return UIMenu(title: "", children: []) }
                
                let isPinned = chat.isPinned
                let pinTitle = isPinned ? "Unpin" : "Pin"
                let pinImageName = isPinned ? "pin.slash" : "pin"
                
                let pinAction = UIAction(title: pinTitle, image: UIImage(systemName: pinImageName)) { _ in
                    self.presenter.handleSwipeAction(.pin, at: indexPath.row)
                }
                
                let actions = [
                    UIAction(title: "Mark as Unread", image: UIImage(systemName: "bubble.left")) { _ in
                        self.presenter.handleSwipeAction(.unread, at: indexPath.row)
                    },
                    pinAction,
                    UIAction(title: "Mute", image: UIImage(systemName: "speaker.slash")) { _ in
                        self.presenter.handleSwipeAction(.mute, at: indexPath.row)
                    },
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                        self.presenter.handleSwipeAction(.delete, at: indexPath.row)
                    }
                ]
                return UIMenu(title: "", children: actions)
            }
        )
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = createSwipeActions(for: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = createLeadingActions(for: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

// MARK: - UISearchBarDelegate

extension ChatListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.didSearchTextChange(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        presenter.didSearchTextChange("")
    }
}

extension ChatList: @unchecked Sendable {}
extension Chat: @unchecked Sendable {}
