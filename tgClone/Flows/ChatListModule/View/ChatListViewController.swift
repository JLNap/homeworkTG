//
//  ChatListViewController.swift
//  tgClone
//
//  Created by Андрей Чучупал on 24.10.2025.
//

import UIKit

// MARK: - Chat List View Protocol

protocol ChatListViewProtocol: AnyObject {
    func showChats(_ chats: [ChatListModel])
    func showError(_ error: String)
    func showLoading()
    func hideLoading()
}

// MARK: - Chat List View Controller

final class ChatListViewController: UIViewController {
    
    enum Section { case main }
    
    // MARK: - Properties
    
    private var presenter: ChatListPresenterProtocol!
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var headerView: UIView!
    private var tabBarView: UIView!
    private var dataSource: UITableViewDiffableDataSource<Section, ChatListModel>!
    private var chats: [ChatListModel] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
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
        dataSource = UITableViewDiffableDataSource<Section, ChatListModel>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, chat in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
                
                let lastMessage = chat.messages.last
                let lastMessageText = lastMessage?.text ?? "Нет сообщений"
                let lastMessageDate = lastMessage?.date ?? Date()
                
                cell.configure(
                    friendName: chat.name,
                    lastMsg: lastMessageText,
                    avatar: chat.avatar,
                    msgDate: lastMessageDate,
                    pin: chat.isPinned
                )
                
                return cell
            })
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ChatListModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(chats)
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
    
    func createSwipeActions() -> [UIContextualAction] {
        let mute = createAction(.mute, "Mute", "speaker.slash.fill", .systemOrange)
        let delete = createAction(.delete, "Delete", "trash.fill", .systemRed)
        let archive = createAction(.archive, "Archive", "archivebox.fill", .systemGray)
        return [mute, delete, archive]
    }
    
    func createLeadingActions() -> [UIContextualAction] {
        let unread = createAction(.unread, "Unread", "bubble.left.fill", .systemBlue)
        let pin = createAction(.pin, "Pin", "pin.fill", .systemGreen)
        return [unread, pin]
    }
    
    func createAction(_ type: SwipeAction, _ title: String, _ iconName: String, _ color: UIColor) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "") { [weak self] _, _, completion in
            if let index = self?.tableView.indexPathForSelectedRow?.row {
                self?.presenter.handleSwipeAction(type, at: index)
            }
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
    func showChats(_ chats: [ChatListModel]) {
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
        let chat = chats[indexPath.row]
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: {
                ChatBuilder.build(with: chat.messages, chatModel: chat)
            },
            actionProvider: { _ in
                let actions = [
                    UIAction(title: "Mark as Unread", image: UIImage(systemName: "bubble.left")) { _ in },
                    UIAction(title: "Pin", image: UIImage(systemName: "pin")) { _ in },
                    UIAction(title: "Mute", image: UIImage(systemName: "speaker.slash")) { _ in },
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in }
                ]
                return UIMenu(title: "", children: actions)
            }
        )
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = createSwipeActions()
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = createLeadingActions()
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
