import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {}
    
    func getCurrentUID() -> String? {
        let uid = Auth.auth().currentUser?.uid
        print("Current UID: \(uid ?? "None")")
        return uid
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("Firebase signIn called with email: \(email)")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Firebase signIn error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let authUser = result?.user else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"])
                print("Firebase signIn error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            let user = User(id: authUser.uid, email: authUser.email ?? "")
            print("Firebase signIn success: \(user.id)")
            completion(.success(user))
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("Firebase signUp called with email: \(email)")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Firebase signUp error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let authUser = result?.user else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"])
                print("Firebase signUp error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            let user = User(id: authUser.uid, email: authUser.email ?? "")
            print("Firebase signUp user created: \(user.id)")
            Firestore.firestore().collection("users").document(user.id).setData([
                "email": user.email,
                "onboardingCompleted": false
            ], merge: true) { error in
                if let error = error {
                    print("Firestore save user error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                print("Firestore save user success: \(user.id)")
                completion(.success(user))
            }
        }
    }
    
    func signOut() throws {
        print("Firebase signOut called")
        try Auth.auth().signOut()
        print("Firebase signOut success")
    }
    
    func fetchIdeas(completion: @escaping ([Idea]) -> Void) {
        print("Fetching ideas from Firestore")
        Firestore.firestore().collection("ideas").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching ideas: \(error.localizedDescription)")
                completion([])
                return
            }
            let ideas = snapshot?.documents.compactMap { doc -> Idea? in
                let data = doc.data()
                guard let title = data["title"] as? String,
                      let description = data["description"] as? String,
                      let category = data["category"] as? String else {
                    print("Invalid idea data for document: \(doc.documentID)")
                    return nil
                }
                return Idea(
                    id: UUID(uuidString: doc.documentID) ?? UUID(),
                    title: title,
                    description: description,
                    category: category
                )
            } ?? []
            print("Fetched \(ideas.count) ideas")
            completion(ideas)
        }
    }
    
    func saveEvent(_ event: Event, for userId: String) {
        let data: [String: Any] = [
            "title": event.title,
            "date": Timestamp(date: event.date)
        ]
        print("Saving event for user: \(userId), event: \(event.title)")
        Firestore.firestore().collection("events").document(userId).collection("userEvents").document(event.id.uuidString).setData(data) { error in
            if let error = error {
                print("Error saving event: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchEvents(for userId: String, completion: @escaping ([Event]) -> Void) {
        print("Fetching events for user: \(userId)")
        Firestore.firestore().collection("events").document(userId).collection("userEvents").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                completion([])
                return
            }
            let events = snapshot?.documents.compactMap { doc -> Event? in
                let data = doc.data()
                guard let title = data["title"] as? String,
                      let date = (data["date"] as? Timestamp)?.dateValue() else {
                    print("Invalid event data for document: \(doc.documentID)")
                    return nil
                }
                return Event(
                    id: UUID(uuidString: doc.documentID) ?? UUID(),
                    title: title,
                    date: date
                )
            } ?? []
            print("Fetched \(events.count) events")
            completion(events)
        }
    }
    
    func saveLikedIdea(_ idea: Idea, for userId: String) {
        let data: [String: Any] = [
            "title": idea.title,
            "description": idea.description,
            "category": idea.category
        ]
        print("Saving liked idea for user: \(userId), idea: \(idea.title)")
        Firestore.firestore().collection("users").document(userId).collection("likedIdeas").document(idea.id.uuidString).setData(data) { error in
            if let error = error {
                print("Error saving liked idea: \(error.localizedDescription)")
            }
        }
    }
    
    func setOnboardingCompleted(for userId: String, completion: @escaping (Bool) -> Void) {
        print("Setting onboarding completed for user: \(userId)")
        Firestore.firestore().collection("users").document(userId).setData(["onboardingCompleted": true], merge: true) { error in
            if let error = error {
                print("Error setting onboarding completed: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Onboarding completed set successfully")
                completion(true)
            }
        }
    }
    
    func checkOnboardingStatus(for userId: String, completion: @escaping (Bool) -> Void) {
        print("Checking onboarding status for user: \(userId)")
        Firestore.firestore().collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error checking onboarding status: \(error.localizedDescription)")
                completion(false)
                return
            }
            let data = document?.data()
            let completed = data?["onboardingCompleted"] as? Bool ?? false
            print("Onboarding status: \(completed)")
            completion(completed)
        }
    }
    
    func reauthenticate(currentPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                print("Re-authentication failed: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Re-authentication successful")
                completion(.success(()))
            }
        }
    }
    
    func updateUsername(_ username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { error in
            if let error = error {
                print("Failed to update username: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Username updated: \(username)")
                completion(.success(()))
            }
        }
    }
    
    func updateEmail(_ email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        user.sendEmailVerification(beforeUpdatingEmail: email) { error in
            if let error = error {
                print("Failed to send email verification: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Email verification sent for: \(email)")
                Firestore.firestore().collection("users").document(user.uid).setData(["email": email], merge: true) { error in
                    if let error = error {
                        print("Failed to update Firestore email: \(error.localizedDescription)")
                    }
                }
                completion(.success(()))
            }
        }
    }
    
    func updatePassword(_ password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        user.updatePassword(to: password) { error in
            if let error = error {
                print("Failed to update password: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Password updated")
                completion(.success(()))
            }
        }
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        user.delete { error in
            if let error = error {
                print("Failed to delete account: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Account deleted")
                Firestore.firestore().collection("users").document(user.uid).delete { error in
                    if let error = error {
                        print("Failed to delete Firestore user data: \(error.localizedDescription)")
                    }
                }
                completion(.success(()))
            }
        }
    }
}
