import Foundation
import UserNotifications

class OnboardingViewModel: ObservableObject {
    @Published var onboardingCompleted: Bool = false
    @Published var currentStep: Int = 0
    
    func checkOnboardingStatus(userId: String?, didJustSignUp: Bool) {
        print("Checking onboarding status: userId=\(userId ?? "nil"), didJustSignUp=\(didJustSignUp)")
        if didJustSignUp || userId == nil {
            onboardingCompleted = false
            currentStep = 0
            print("New user: Reset onboarding")
        } else {
            FirebaseManager.shared.checkOnboardingStatus(for: userId!) { completed in
                DispatchQueue.main.async {
                    self.onboardingCompleted = completed
                    self.currentStep = completed ? 5 : 0
                    print("Onboarding status checked: completed=\(completed), currentStep=\(self.currentStep)")
                }
            }
        }
    }
    
    func nextStep(userId: String?) {
        print("Next step called: currentStep=\(currentStep), userId=\(userId ?? "nil")")
        if currentStep < 4 { // Updated for 5 steps (0–4)
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
                // Move to the next screen (fifth screen) instead of completing
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
            print("Set onboardingCompleted=true, currentStep=5")
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
                print("No userId provided; skipping Firestore update")
            }
        }
    }
}
