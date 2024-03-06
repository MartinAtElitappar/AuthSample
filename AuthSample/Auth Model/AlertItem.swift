//
//  AlertItem.swift
//  ElitDrawTheWord
//
//  Created by Martin Poulsen on 2022-05-27.
//

import Foundation

struct AlertItem: Identifiable {
  var id = UUID()
  var title: String
  var message: String
}
