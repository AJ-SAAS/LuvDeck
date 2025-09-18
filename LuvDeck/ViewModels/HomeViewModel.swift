import SwiftUI
import UIKit

class HomeViewModel: ObservableObject {
    @Published var ideas: [Idea] = []
    @Published var currentIndex: Int = 0
    @Published var isLoading: Bool = true
    private var userId: String?
    
    init(userId: String?) {
        self.userId = userId
        print("HomeViewModel initialized with userId: \(userId ?? "nil")")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fetchIdeas()
        }
    }
    
    func fetchIdeas() {
        guard let userId = userId else {
            print("Cannot fetch ideas: userId is nil")
            DispatchQueue.main.async {
                self.ideas = []
                self.isLoading = false
            }
            return
        }
        print("Fetching ideas for userId: \(userId)")
        DispatchQueue.main.async {
            self.isLoading = true
        }
        FirebaseManager.shared.fetchIdeas { [weak self] ideas in
            DispatchQueue.main.async {
                self?.ideas = ideas
                self?.isLoading = false
                print("Fetched \(ideas.count) ideas")
            }
        }
    }
    
    func nextIdea() {
        if currentIndex < ideas.count - 1 {
            currentIndex += 1
            print("Moved to next idea: index=\(currentIndex)")
        }
    }
    
    func previousIdea() {
        if currentIndex > 0 {
            currentIndex -= 1
            print("Moved to previous idea: index=\(currentIndex)")
        }
    }
    
    func likeIdea(_ idea: Idea) {
        guard let userId = userId else {
            print("Cannot like idea: userId is nil")
            return
        }
        FirebaseManager.shared.saveLikedIdea(idea, for: userId)
        print("Liked idea: \(idea.title)")
    }
    
    func shareIdea(_ idea: Idea) {
        let shareText = "\(idea.title): \(idea.description)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        if let rootViewController = windowScene?.windows.first?.rootViewController {
            DispatchQueue.main.async {
                print("Presenting UIActivityViewController for idea: \(idea.title)")
                rootViewController.present(activityVC, animated: true)
            }
        } else {
            print("Failed to find root view controller for sharing")
        }
    }
}
