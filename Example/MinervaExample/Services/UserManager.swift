//
//  UserManager.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import RxSwift

protocol UserManager {

  /// The cached user, if there is one
  func activateCachedUser() -> DataManager?

  /// Creates a new account if none exists
  func createAccount(withEmail email: String, password: String) -> Single<DataManager>

  /// Logs into an account if it exists and the password matches
  func login(withEmail email: String, password: String) -> Single<DataManager>

  /// Logs out the user with the ID
  func logout(userID: String) -> Single<Void>

  /// Deletes the user with the specified ID
  func delete(userID: String) -> Single<Void>
}
