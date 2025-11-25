// SparkViewModel.swift
import Foundation

class SparkViewModel: ObservableObject {
    @Published var showingSheet = false
    @Published var selectedItem: SparkItem?
    
    private let allItems = sparkDatabase
    
    func showRandom(_ category: SparkCategory) {
        let filtered = allItems.filter { $0.category == category }
        selectedItem = filtered.randomElement()
        showingSheet = true
    }
}
