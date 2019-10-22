//
//  WelcomeCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

protocol WelcomeCoordinatorDelegate: AnyObject {
  func onboardingCoordinator(
    _ onboardingCoordinator: WelcomeCoordinator,
    activated dataManager: DataManager)
}

/// Manages the user flows for logging in and creating new accounts
final class WelcomeCoordinator: MainCoordinator<WelcomeDataSource, CollectionViewController> {

  weak var delegate: WelcomeCoordinatorDelegate?
  private let userManager: UserManager

  // MARK: - Lifecycle

  init(navigator: Navigator, userManager: UserManager) {
    self.userManager = userManager

    let dataSource = WelcomeDataSource()
    let viewController = CollectionViewController()
    let listController = LegacyListController()
    super.init(
      navigator: navigator,
      viewController: viewController,
      dataSource: dataSource,
      listController: listController
    )
    dataSource.actions.subscribe(onNext: { [weak self] in self?.handle($0) }).disposed(by: disposeBag)
  }

  // MARK: - Private

  private func displaySignInVC(mode: SignInDataSource.Mode) {
    let coordinator = SignInCoordinator(navigator: navigator, userManager: userManager, mode: mode)
    coordinator.delegate = self
    push(coordinator, animated: true)
  }
  private func handle(_ action: WelcomeDataSource.Action) {
    switch action {
    case .login: displaySignInVC(mode: .login)
    case .createAccount: displaySignInVC(mode: .createAccount)
    }
  }
}

extension WelcomeCoordinator: SignInCoordinatorDelegate {
  func signInCoordinator(_ signInCoordinator: SignInCoordinator, activated dataManager: DataManager) {
    delegate?.onboardingCoordinator(self, activated: dataManager)
  }
}
