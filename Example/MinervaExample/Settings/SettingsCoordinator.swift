//
//  SettingsCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import RxSwift

protocol SettingsCoordinatorDelegate: AnyObject {
  func settingsCoordinatorLogoutCurrentUser(
    _ settingsCoordinator: SettingsCoordinator
  )
}

final class SettingsCoordinator: MainCoordinator<SettingsDataSource, CollectionViewController> {

  weak var delegate: SettingsCoordinatorDelegate?
  private let userManager: UserManager
  private let dataManager: DataManager

  // MARK: - Lifecycle

  init(navigator: Navigator, userManager: UserManager, dataManager: DataManager) {
    self.userManager = userManager
    self.dataManager = dataManager

    let dataSource = SettingsDataSource(dataManager: dataManager)
    let viewController = CollectionViewController()
    let listController = LegacyListController()
    super.init(
      navigator: navigator,
      viewController: viewController,
      dataSource: dataSource,
      listController: listController
    )
    dataSource.actions.subscribe(onNext: { [weak self] in self?.handle($0) }).disposed(by: disposeBag)
    viewController.title = "Settings"
  }

  // MARK: - Private

  private func deleteUser() {
    let userID = dataManager.userAuthorization.userID
    LoadingHUD.show(in: viewController.view)
    userManager.delete(userID: userID)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] () -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.delegate?.settingsCoordinatorLogoutCurrentUser(strongSelf)
        },
        onError: { [weak self] error -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.viewController.alert(error, title: "Failed to delete the user")
        }
      ).disposed(by: disposeBag)
  }

  private func logoutUser() {
    let userID = dataManager.userAuthorization.userID
    LoadingHUD.show(in: viewController.view)
    userManager.logout(userID: userID)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] () -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.delegate?.settingsCoordinatorLogoutCurrentUser(strongSelf)
        },
        onError: { [weak self] error -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.viewController.alert(error, title: "Failed to logout")
        }
      ).disposed(by: disposeBag)
  }

  private func displayUserUpdatePopup(for user: User) {
    let navigator = BasicNavigator(parent: self.navigator)
    let coordinator = UpdateUserCoordinator(navigator: navigator, dataManager: dataManager, user: user)
    presentWithCloseButton(coordinator, modalPresentationStyle: .safeAutomatic)
  }
  private func handle(_ action: SettingsDataSource.Action) {
    switch action {
    case .deleteAccount:
      deleteUser()
    case .logout:
      logoutUser()
    case .update(let user):
      displayUserUpdatePopup(for: user)
    }
  }
}
