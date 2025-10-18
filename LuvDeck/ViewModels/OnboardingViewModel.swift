import Foundation
import UserNotifications

class OnboardingViewModel: ObservableObject {
    @Published var onboardingCompleted: Bool = UserDefaults.standard.bool(forKey: "onboardingCompleted")
    @Published var currentStep: Int = 0
    
    func checkOnboardingStatus(userId: String?, didJustSignUp: Bool) {
        print("Checking onboarding status: userId=\(userId ?? "nil"), didJustSignUp=\(didJustSignUp)")
        if didJustSignUp {
            // New user: only show onboarding once
            if !UserDefaults.standard.bool(forKey: "onboardingCompleted") {
                onboardingCompleted = false
                currentStep = 0
                print("New user: Starting onboarding")
            } else {
                // Already completed, skip onboarding
                onboardingCompleted = true
                currentStep = 5
                print("New user already completed onboarding, skipping")
            }
        } else if let userId = userId {
            // Existing user: check Firestore
            FirebaseManager.shared.checkOnboardingStatus(for: userId) { (completed: Bool) in
                DispatchQueue.main.async {
                    self.onboardingCompleted = completed
                    self.currentStep = completed ? 5 : 0
                    UserDefaults.standard.set(completed, forKey: "onboardingCompleted")
                    print("Onboarding status checked: completed=\(completed), currentStep=\(self.currentStep)")
                }
            }
        } else {
            // No user: use local UserDefaults
            let completed = UserDefaults.standard.bool(forKey: "onboardingCompleted")
            onboardingCompleted = completed
            currentStep = completed ? 5 : 0
            print("No user: Using UserDefaults, onboardingCompleted=\(completed), currentStep=\(self.currentStep)")
        }
    }
    
    func nextStep(userId: String?) {
        print("Next step called: currentStep=\(currentStep), userId=\(userId ?? "nil")")
        if currentStep < 4 {
            currentStep += 1
            print("Advancing to onboarding step: \(currentStep)")
        } else {
            completeOnboarding(userId: userId)
        }
    }
    
    func requestNotificationPermission(userId: String?) {
        print("Requesting notification permission for userId: \(userId ?? "nil")")
        NotificationManager.shared.requestPermission { success in
            DispatchQueue.main.async {
                if success {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
                self.currentStep = 4
                print("Advancing to fifth onboarding screen: currentStep=\(self.currentStep)")
            }
        }
    }
    
    func completeOnboarding(userId: String?) {
        print("Completing onboarding for userId: \(userId ?? "nil")")
        DispatchQueue.main.async {
            self.onboardingCompleted = true
            self.currentStep = 5
            UserDefaults.standard.set(true, forKey: "onboardingCompleted")
            print("Set onboardingCompleted=true, currentStep=5, UserDefaults updated")
            if let userId = userId {
                FirebaseManager.shared.setOnboardingCompleted(for: userId) { success in
                    DispatchQueue.main.async {
                        if success {
                            print("Firestore: Onboarding completed set successfully")
                        } else {
                            print("Firestore: Failed to set onboarding completed")
                        }
                    }
                }
            } else {
                print("No userId provided; storing onboarding completion in UserDefaults only")
            }
        }
    }
}
