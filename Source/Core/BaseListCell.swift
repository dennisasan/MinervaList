//
//  BaseListCell.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class BaseListCell: ListCollectionViewCell {

  open private(set) var cellModel: ListCellModel?

  open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    if let attributes = layoutAttributes as? ListViewLayoutAttributes,
      let animation = attributes.animationGroup {
      self.layer.add(animation, forKey: nil)
    }
  }

  open override func prepareForReuse() {
    super.prepareForReuse()
    cellModel?.cell = nil
    cellModel = nil
    updatedCellModel()
  }

  open func updatedCellModel() {
  }

  open func willDisplayCell() {
  }

  open func didEndDisplayingCell() {
  }

  // MARK: - ListBindable

  public func bindViewModel(_ viewModel: Any) {
    guard let cellModel = viewModel as? ListCellModel else {
      assertionFailure("Invalid view model \(viewModel)")
      return
    }
    if let existingCell = self.cellModel?.cell, existingCell === self {
      self.cellModel?.cell = nil
    }
    if let model = cellModel as? ListBindableCellModelWrapper {
      model.willBind()
    }
    self.cellModel = cellModel
    self.cellModel?.cell = self
    updatedCellModel()
  }
}
