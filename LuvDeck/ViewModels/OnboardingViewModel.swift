// OnboardingViewModel.swift
import Foundation
import UserNotifications

class OnboardingViewModel: ObservableObject {
    @Published var onboardingCompleted: Bool = UserDefaults.standard.bool(forKey: "onboardingCompleted")
    @Published var currentStep: Int = 0
    
    // MARK: - Check Onboarding Status (with completion)
    func checkOnboardingStatus(userId: String?, didJustSignUp: Bool, completion: @escaping () -> Void = {}) {
        print("Checking onboarding status: userId=\(userId ?? "nil"), didJustSignUp=\(didJustSignUp)")
        
        if didJustSignUp {
            if !UserDefaults.standard.bool(forKey: "onboardingCompleted") {
                onboardingCompleted = false
                currentStep = 0
                print("New user: Starting onboarding")
            } else {
                onboardingCompleted = true
                currentStep = 5
                print("New user already completed onboarding, skipping")
            }
            completion()
        }
        else if let userId = userId {
            FirebaseManager.shared.checkOnboardingStatus(for: userId) { [weak self] completed in
                DispatchQueue.main.async {
                    self?.onboardingCompleted = completed
                    self?.currentStep = completed ? 5 : 0
                    UserDefaults.standard.set(completed, forKey: "onboardingCompleted")
                    print("Onboarding status from Firestore: completed=\(completed)")
                    completion()
                }
            }
        }
        else {
            let completed = UserDefaults.standard.bool(forKey: "onboardingCompleted")
            onboardingCompleted = completed
            currentStep = completed ? 5 : 0
            print("No user: Using UserDefaults, onboardingCompleted=\(completed)")
            completion()
        }
    }
    
    // MARK: - Next Step
    func nextStep(userId: String?) {
        print("Next step called: currentStep=\(currentStep)")
        if currentStep < 4 {
            currentStep += 1
        } else {
            completeOnboarding(userId: userId)
        }
    }
    
    // MARK: - Request Notification Permission
    func requestNotificationPermission(userId: String?) {
        NotificationManager.shared.requestPermission { success in
            DispatchQueue.main.async {
                print(success ? "Notification permission granted" : "Notification permission denied")
                self.currentStep = 4
            }
        }
    }
    
    // MARK: - Complete Onboarding
    func completeOnboarding(userId: String?) {
        print("Completing onboarding for userId: \(userId ?? "nil")")
        DispatchQueue.main.async {
            self.onboardingCompleted = true
            self.currentStep = 5
            UserDefaults.standard.set(true, forKey: "onboardingCompleted")
            
            if let userId = userId {
                FirebaseManager.shared.setOnboardingCompleted(for: userId) { success in
                    DispatchQueue.main.async {
                        print(success ? "Firestore: Onboarding completed" : "Firestore: Failed")
                    }
                }
            }
        }
    }
}
