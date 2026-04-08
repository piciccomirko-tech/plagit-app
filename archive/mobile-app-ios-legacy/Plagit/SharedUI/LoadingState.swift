//
//  LoadingState.swift
//  Plagit
//
//  Shared loading state enum for all admin ViewModels.
//

import Foundation

enum LoadingState: Equatable {
    case idle, loading, loaded, error(String)
}
