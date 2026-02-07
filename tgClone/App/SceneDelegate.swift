//
//  SceneDelegate.swift
//  tgClone
//
//  Created by Андрей Чучупал on 20.10.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window
        self.window?.rootViewController = UINavigationController(rootViewController: ChatListBuilder.build())
        window.makeKeyAndVisible()
    }
}

