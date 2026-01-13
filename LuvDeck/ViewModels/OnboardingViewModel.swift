// OnboardingViewModel.swift
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
    // NEW ONBOARDING ANSWERS (CONSISTENT)
    // =====================================
    @Published var referralSource: String? = nil
    @Published var relationshipFocus: Set<String> = []
    @Published var dailyCommitment: Int? = nil

    // FIXED: Now 9 steps total (0–8)
    private let totalSteps = 9

    // MARK: - Check Onboarding Status
    func checkOnboardingStatus(
        userId: String?,
        didJustSignUp: Bool,
        completion: @escaping () -> Void = {}
    ) {
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

        if currentStep < totalSteps - 1 {
            currentStep += 1
        } else {
            completeOnboarding(userId: userId)
        }
    }

    // MARK: - Request Notification Permission (FIXED)
    func requestNotificationPermission(userId: String?, completion: @escaping () -> Void) {
        NotificationManager.shared.requestPermission { success in
            DispatchQueue.main.async {
                print(success ? "Notification permission granted" : "Notification permission denied")
                // Move to next step after permission
                completion()
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

            guard let userId else { return }

            FirebaseManager.shared.setOnboardingCompleted(for: userId)

            // Persist onboarding answers
            let data: [String: Any] = [
                "referralSource": self.referralSource ?? "",
                "relationshipFocus": Array(self.relationshipFocus),
                "dailyCommitmentMinutes": self.dailyCommitment ?? 0
            ]

            Firestore.firestore()
                .collection("users")
                .document(userId)
                .setData(data, merge: true)
        }
    }
}
