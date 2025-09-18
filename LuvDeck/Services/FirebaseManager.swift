import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

struct FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}
    
    let db = Firestore.firestore()
    
    // MARK: - Auth
    
    func getCurrentUID() -> String? {
        Auth.auth().currentUser?.uid
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign in error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let authUser = result?.user else { return }
            let user = User(id: authUser.uid, email: authUser.email ?? "")
            completion(.success(user))
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign up error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let authUser = result?.user else { return }
            let user = User(id: authUser.uid, email: authUser.email ?? "")
            self.db.collection("users").document(user.id).setData([
                "email": user.email,
                "onboardingCompleted": false
            ], merge: true) { error in
                if let error = error {
                    print("Firestore set user error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                completion(.success(user))
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Username
    
    func updateUsername(_ username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No user for username update")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { error in
            if let error = error {
                print("Username update error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            self.db.collection("users").document(user.uid).setData(["username": username], merge: true) { error in
                if let error = error {
                    print("Firestore username update error: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("Username updated: \(username)")
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Re-authentication
    
    func reauthenticate(currentPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            print("No user or email for re-authentication")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user or email available"])))
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                print("Re-authentication error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Re-authentication successful")
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Ideas
    
    func fetchIdeas(completion: @escaping ([Idea]) -> Void) {
        db.collection("ideas").getDocuments { snapshot, error in
            if let error = error {
                print("Fetch ideas error: \(error.localizedDescription)")
                completion([])
                return
            }
            let ideas = snapshot?.documents.compactMap { doc -> Idea? in
                let data = doc.data()
                guard let title = data["title"] as? String,
                      let description = data["description"] as? String,
                      let category = data["category"] as? String,
                      let difficulty = data["difficulty"] as? Int,
                      let impressive = data["impressive"] as? Int,
                      let imageName = data["imageName"] as? String else {
                    print("Invalid idea data for document: \(doc.documentID)")
                    return nil
                }
                return Idea(
                    id: UUID(uuidString: doc.documentID) ?? UUID(),
                    title: title,
                    description: description,
                    category: category,
                    difficulty: difficulty,
                    impressive: impressive,
                    imageName: imageName
                )
            } ?? []
            print("Fetched \(ideas.count) ideas from Firestore")
            completion(ideas)
        }
    }
    
    func saveLikedIdea(_ idea: Idea, for userId: String) {
        let data: [String: Any] = [
            "id": idea.id.uuidString,
            "title": idea.title,
            "description": idea.description,
            "category": idea.category,
            "difficulty": idea.difficulty,
            "impressive": idea.impressive,
            "imageName": idea.imageName
        ]
        db.collection("users").document(userId).collection("likedIdeas").document(idea.id.uuidString).setData(data) { error in
            if let error = error {
                print("Error saving liked idea: \(error.localizedDescription)")
            } else {
                print("Saved liked idea: \(idea.title)")
            }
        }
    }
    
    func saveBookmarkedIdea(_ idea: Idea, for userId: String) {
        let data: [String: Any] = [
            "id": idea.id.uuidString,
            "title": idea.title,
            "description": idea.description,
            "category": idea.category,
            "difficulty": idea.difficulty,
            "impressive": idea.impressive,
            "imageName": idea.imageName
        ]
        db.collection("users").document(userId).collection("bookmarkedIdeas").document(idea.id.uuidString).setData(data) { error in
            if let error = error {
                print("Error saving bookmarked idea: \(error.localizedDescription)")
            } else {
                print("Saved bookmarked idea: \(idea.title)")
            }
        }
    }
    
    // MARK: - Events
    
    func saveEvent(_ event: Event, for userId: String) {
        let data: [String: Any] = [
            "id": event.id.uuidString,
            "title": event.title,
            "date": Timestamp(date: event.date)
        ]
        db.collection("users").document(userId).collection("userEvents").document(event.id.uuidString).setData(data) { error in
            if let error = error {
                print("Error saving event: \(error.localizedDescription)")
            } else {
                print("Saved event: \(event.title)")
            }
        }
    }
    
    func fetchEvents(for userId: String, completion: @escaping ([Event]) -> Void) {
        db.collection("users").document(userId).collection("userEvents").getDocuments { snapshot, error in
            if let error = error {
                print("Fetch events error: \(error.localizedDescription)")
                completion([])
                return
            }
            let events = snapshot?.documents.compactMap { doc -> Event? in
                let data = doc.data()
                guard let title = data["title"] as? String,
                      let timestamp = data["date"] as? Timestamp else {
                    print("Invalid event data for document: \(doc.documentID)")
                    return nil
                }
                return Event(
                    id: UUID(uuidString: doc.documentID) ?? UUID(),
                    title: title,
                    date: timestamp.dateValue()
                )
            } ?? []
            print("Fetched \(events.count) events for userId: \(userId)")
            completion(events)
        }
    }
    
    // MARK: - Onboarding
    
    func checkOnboardingStatus(for userId: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error checking onboarding status: \(error.localizedDescription)")
                completion(false)
                return
            }
            let completed = document?.data()?["onboardingCompleted"] as? Bool ?? false
            print("Onboarding status for userId \(userId): \(completed)")
            completion(completed)
        }
    }
    
    func setOnboardingCompleted(for userId: String, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("users").document(userId).setData(["onboardingCompleted": true], merge: true) { error in
            if let error = error {
                print("Error setting onboarding completed: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Onboarding completed set for userId: \(userId)")
                completion(true)
            }
        }
    }
    
    // MARK: - User Updates
    
    func updateEmail(_ email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No user for email update")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        user.sendEmailVerification(beforeUpdatingEmail: email) { error in
            if let error = error {
                print("Email update error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                self.db.collection("users").document(user.uid).setData(["email": email], merge: true)
                print("Email updated: \(email)")
                completion(.success(()))
            }
        }
    }
    
    func updatePassword(_ password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No user for password update")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        user.updatePassword(to: password) { error in
            if let error = error {
                print("Password update error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Password updated")
                completion(.success(()))
            }
        }
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No user for account deletion")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        user.delete { error in
            if let error = error {
                print("Account deletion error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            self.db.collection("users").document(user.uid).delete()
            print("Account deleted for userId: \(user.uid)")
            completion(.success(()))
        }
    }
}
