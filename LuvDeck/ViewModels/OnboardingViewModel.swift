// OnboardingViewModel.swift
import Foundation
import FirebaseFirestore

class OnboardingViewModel: ObservableObject {
    
    @Published var onboardingCompleted: Bool {
        didSet { UserDefaults.standard.set(onboardingCompleted, forKey: "onboardingCompleted") }
    }
    
    @Published var currentStep: Int {
        didSet { UserDefaults.standard.set(currentStep, forKey: "onboardingStep") }
    }
    
    // Answers
    @Published var desiredAspects: Set<String> = []
    @Published var missingAspects: Set<String> = []
    @Published var preferredVibes: Set<String> = []
    @Published var desiredVibe: String? = nil
    @Published var relationshipStage: String? = nil
    @Published var mainGoal: String? = nil
    
    private let totalSteps = 8   // Increased because we added 2 free trial views
    
    var lastStep: Int { totalSteps - 1 }
    
    var progress: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }
    
    init() {
        self.onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        self.currentStep = UserDefaults.standard.integer(forKey: "onboardingStep")
    }
    
    func checkOnboardingStatus(userId: String?, completion: @escaping () -> Void = {}) {
        // If already completed in UserDefaults, trust it
        if onboardingCompleted {
            completion()
            return
        }
        
        guard let userId = userId else {
            onboardingCompleted = false
            currentStep = 0
            completion()
            return
        }
        
        FirebaseManager.shared.checkOnboardingStatus(for: userId) { [weak self] completed in
            DispatchQueue.main.async {
                self?.onboardingCompleted = completed
                self?.currentStep = completed ? self?.lastStep ?? 0 : 0
                completion()
            }
        }
    }
    
    func nextStep() {
        if currentStep < lastStep {
            currentStep += 1
        }
    }
    
    func completeOnboarding(userId: String?) {
        onboardingCompleted = true
        currentStep = lastStep
        
        guard let userId = userId else { return }
        
        let data: [String: Any] = [
            "onboardingCompleted": true,
            "onboardingCompletedAt": Date(),
            "desiredAspects": Array(desiredAspects),
            "missingAspects": Array(missingAspects),
            "preferredVibes": Array(preferredVibes),
            "desiredVibe": desiredVibe ?? "",
            "relationshipStage": relationshipStage ?? "",
            "mainGoal": mainGoal ?? ""
        ]
        
        Firestore.firestore().collection("users").document(userId)
            .setData(data, merge: true)
    }
    
    func resetOnboarding() {
        currentStep = 0
        onboardingCompleted = false
        desiredAspects.removeAll()
        missingAspects.removeAll()
        preferredVibes.removeAll()
        desiredVibe = nil
        relationshipStage = nil
        mainGoal = nil
    }
}
