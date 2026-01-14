// OnboardingViewModel.swift - IMPROVED VERSION
import Foundation
import UserNotifications
import FirebaseFirestore

class OnboardingViewModel: ObservableObject {
    // =====================================
    // EXISTING (UNCHANGED)
    // =====================================
    @Published var onboardingCompleted: Bool =
        UserDefaults.standard.bool(forKey: "onboardingCompleted")
    @Published var currentStep: Int = 0
    
    // =====================================
    // ONBOARDING ANSWERS
    // =====================================
    @Published var referralSource: String? = nil
    @Published var shortTermGoals: Set<String> = []
    @Published var longTermGoal: String? = nil
    @Published var relationshipFocus: Set<String> = []
    @Published var dailyCommitment: Int? = nil
    
    // FIXED: Now 13 total steps (0-12)
    private let totalSteps = 13
    
    // Helper computed property for progress
    var progress: Double {
        return Double(currentStep + 1) / Double(totalSteps)
    }
    
    // Check if we can proceed from current step
    var canProceed: Bool {
        switch currentStep {
        case 0: return referralSource != nil
        case 1: return !shortTermGoals.isEmpty
        case 2: return longTermGoal != nil
        case 3: return !relationshipFocus.isEmpty
        case 4: return dailyCommitment != nil
        default: return true
        }
    }
    
    // MARK: - Check Onboarding Status
    func checkOnboardingStatus(
        userId: String?,
        didJustSignUp: Bool,
        completion: @escaping () -> Void = {}
    ) {
        print("✅ Checking onboarding: userId=\(userId ?? "nil"), didJustSignUp=\(didJustSignUp)")
        
        if didJustSignUp {
            if !UserDefaults.standard.bool(forKey: "onboardingCompleted") {
                onboardingCompleted = false
                currentStep = 0
                print("🆕 New user: Starting onboarding")
            } else {
                onboardingCompleted = true
                currentStep = totalSteps - 1
                print("✅ New user already completed onboarding")
            }
            completion()
        }
        else if let userId = userId {
            FirebaseManager.shared.checkOnboardingStatus(for: userId) { [weak self] completed in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.onboardingCompleted = completed
                    self.currentStep = completed ? self.totalSteps - 1 : 0
                    UserDefaults.standard.set(completed, forKey: "onboardingCompleted")
                    print("📱 Firestore status: completed=\(completed)")
                    completion()
                }
            }
        }
        else {
            let completed = UserDefaults.standard.bool(forKey: "onboardingCompleted")
            onboardingCompleted = completed
            currentStep = completed ? totalSteps - 1 : 0
            print("💾 Using UserDefaults: completed=\(completed)")
            completion()
        }
    }
    
    // MARK: - Navigation
    func nextStep(userId: String?) {
        print("➡️ Next step: \(currentStep) -> \(currentStep + 1)")
        
        if currentStep < totalSteps - 1 {
            currentStep += 1
        } else {
            completeOnboarding(userId: userId)
        }
    }
    
    func previousStep() {
        guard currentStep > 0 else { return }
        print("⬅️ Previous step: \(currentStep) -> \(currentStep - 1)")
        currentStep -= 1
    }
    
    // MARK: - Request Notification Permission
    func requestNotificationPermission(userId: String?, completion: @escaping () -> Void) {
        NotificationManager.shared.requestPermission { success in
            DispatchQueue.main.async {
                print(success ? "🔔 Notifications enabled" : "🔕 Notifications denied")
                completion()
            }
        }
    }
    
    // MARK: - Complete Onboarding
    func completeOnboarding(userId: String?) {
        print("🎉 Completing onboarding for userId: \(userId ?? "nil")")
        
        DispatchQueue.main.async {
            self.onboardingCompleted = true
            self.currentStep = self.totalSteps - 1
            UserDefaults.standard.set(true, forKey: "onboardingCompleted")
            
            guard let userId else {
                print("⚠️ No userId to save onboarding data")
                return
            }
            
            FirebaseManager.shared.setOnboardingCompleted(for: userId)
            
            // Persist onboarding answers
            let data: [String: Any] = [
                "referralSource": self.referralSource ?? "",
                "shortTermGoals": Array(self.shortTermGoals),
                "longTermGoal": self.longTermGoal ?? "",
                "relationshipFocus": Array(self.relationshipFocus),
                "dailyCommitmentMinutes": self.dailyCommitment ?? 0,
                "onboardingCompletedAt": Date()
            ]
            
            Firestore.firestore()
                .collection("users")
                .document(userId)
                .setData(data, merge: true) { error in
                    if let error = error {
                        print("❌ Error saving onboarding data: \(error)")
                    } else {
                        print("✅ Onboarding data saved successfully")
                    }
                }
        }
    }
    
    // MARK: - Reset (for testing)
    func resetOnboarding() {
        currentStep = 0
        onboardingCompleted = false
        referralSource = nil
        shortTermGoals = []
        longTermGoal = nil
        relationshipFocus = []
        dailyCommitment = nil
        UserDefaults.standard.set(false, forKey: "onboardingCompleted")
        print("🔄 Onboarding reset")
    }
}
