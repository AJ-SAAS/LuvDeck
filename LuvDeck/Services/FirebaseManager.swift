import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

struct FirebaseManager {
    
    // MARK: - Singleton
    static let shared = FirebaseManager()
    private init() {}
    private let db = Firestore.firestore()
    
    // MARK: - True Logout
    func signOut() throws {
        try Auth.auth().signOut()
        Auth.auth().updateCurrentUser(nil)
        print("True sign out completed — user fully cleared")
    }
    
    // MARK: - Auth: Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let authUser = result?.user else {
                completion(.failure(NSError(domain: "", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "Unknown user"])))
                return
            }
            completion(.success(User(id: authUser.uid, email: authUser.email ?? "")))
        }
    }
    
    // MARK: - Auth: Sign Up
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let authUser = result?.user else {
                completion(.failure(NSError(domain: "", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "Unknown user"])))
                return
            }
            let user = User(id: authUser.uid, email: authUser.email ?? "")
            self.db.collection("users").document(user.id).setData([
                "email": user.email,
                "onboardingCompleted": false
            ], merge: true) { err in
                if let err = err { completion(.failure(err)) }
                else { completion(.success(user)) }
            }
        }
    }
    
    // MARK: - Update Username
    func updateUsername(_ username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { error in
            if let error = error { completion(.failure(error)) }
            else {
                self.db.collection("users").document(user.uid)
                    .setData(["username": username], merge: true) { err in
                        if let err = err { completion(.failure(err)) }
                        else { completion(.success(())) }
                    }
            }
        }
    }
    
    // MARK: - Re-authentication
    func reauthenticate(currentPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(.failure(NSError(domain: "", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "No user or email"])))
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }
    
    // MARK: - Ideas
    func fetchIdeas(completion: @escaping ([Idea]) -> Void) {
        db.collection("ideas").getDocuments { snapshot, _ in
            let ideas = snapshot?.documents.compactMap { doc -> Idea? in
                let data = doc.data()
                guard let title = data["title"] as? String,
                      let description = data["description"] as? String,
                      let category = data["category"] as? String,
                      let difficulty = data["difficulty"] as? Int,
                      let impressive = data["impressive"] as? Int,
                      let imageName = data["imageName"] as? String,
                      let levelStr = data["level"] as? String,
                      let level = Level(rawValue: levelStr) else { return nil }
                return Idea(
                    id: UUID(uuidString: doc.documentID) ?? UUID(),
                    title: title,
                    description: description,
                    category: category,
                    difficulty: difficulty,
                    impressive: impressive,
                    imageName: imageName,
                    level: level
                )
            } ?? []
            completion(ideas)
        }
    }
    
    func saveLikedIdea(_ idea: Idea, for userId: String) {
        let data = ideaToDictionary(idea)
        db.collection("users").document(userId)
            .collection("likedIdeas")
            .document(idea.id.uuidString)
            .setData(data)
    }
    
    func saveBookmarkedIdea(_ idea: Idea, for userId: String) {
        let data = ideaToDictionary(idea)
        db.collection("users").document(userId)
            .collection("bookmarkedIdeas")
            .document(idea.id.uuidString)
            .setData(data)
    }
    
    func removeBookmarkedIdea(_ idea: Idea, for userId: String, completion: ((Error?) -> Void)? = nil) {
        db.collection("users")
            .document(userId)
            .collection("bookmarkedIdeas")
            .document(idea.id.uuidString)
            .delete { error in
                if let error = error { print("Error removing bookmarked idea:", error.localizedDescription) }
                completion?(error)
            }
    }
    
    func fetchBookmarkedIdeas(for userId: String, completion: @escaping ([Idea]) -> Void) {
        db.collection("users").document(userId)
            .collection("bookmarkedIdeas")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching bookmarked ideas: \(error.localizedDescription)")
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
                          let imageName = data["imageName"] as? String,
                          let levelStr = data["level"] as? String,
                          let level = Level(rawValue: levelStr) else { return nil }
                    return Idea(
                        id: UUID(uuidString: doc.documentID) ?? UUID(),
                        title: title,
                        description: description,
                        category: category,
                        difficulty: difficulty,
                        impressive: impressive,
                        imageName: imageName,
                        level: level
                    )
                } ?? []
                completion(ideas)
            }
    }
    
    private func ideaToDictionary(_ idea: Idea) -> [String: Any] {
        [
            "id": idea.id.uuidString,
            "title": idea.title,
            "description": idea.description,
            "category": idea.category,
            "difficulty": idea.difficulty,
            "impressive": idea.impressive,
            "imageName": idea.imageName,
            "level": idea.level.rawValue
        ]
    }
    
    // MARK: - Events
    func saveEvent(_ event: FirebaseEvent, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try Firestore.Encoder().encode(event)
            db.collection("users").document(userId)
                .collection("userEvents")
                .document(event.id)
                .setData(data) { error in
                    if let error = error { completion(.failure(error)) }
                    else { completion(.success(())) }
                }
        } catch { completion(.failure(error)) }
    }
    
    func fetchEvents(for userId: String, completion: @escaping ([FirebaseEvent]) -> Void) {
        db.collection("users").document(userId)
            .collection("userEvents")
            .getDocuments { snapshot, _ in
                let events = snapshot?.documents.compactMap { doc in
                    try? Firestore.Decoder().decode(FirebaseEvent.self, from: doc.data())
                } ?? []
                completion(events)
            }
    }
    
    func deleteEvent(_ eventId: String, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users")
            .document(userId)
            .collection("userEvents")
            .document(eventId)
            .delete { error in
                if let error = error { completion(.failure(error)) }
                else { completion(.success(())) }
            }
    }
    
    // MARK: - Onboarding
    func checkOnboardingStatus(for userId: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(userId)
            .getDocument { document, _ in
                let completed = document?.data()?["onboardingCompleted"] as? Bool ?? false
                completion(completed)
            }
    }
    
    func setOnboardingCompleted(for userId: String, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("users").document(userId)
            .setData(["onboardingCompleted": true], merge: true) { _ in completion(true) }
    }
    
    func saveOnboardingAnswer(userId: String, key: String, value: String) {
        db.collection("users").document(userId)
            .setData(["onboardingAnswers.\(key)": value], merge: true)
    }
    
    func saveOnboardingStep(userId: String, step: Int) {
        db.collection("users").document(userId)
            .setData(["onboardingStep": step], merge: true)
    }
    
    func fetchOnboardingAnswers(userId: String, completion: @escaping ([String: String]) -> Void) {
        db.collection("users").document(userId)
            .getDocument { snapshot, _ in
                let answers = snapshot?.data()?["onboardingAnswers"] as? [String: String] ?? [:]
                completion(answers)
            }
    }
    
    // MARK: - Email / Password / Account
    func updateEmail(_ email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        user.sendEmailVerification(beforeUpdatingEmail: email) { error in
            if let error = error { completion(.failure(error)) }
            else {
                self.db.collection("users").document(user.uid)
                    .setData(["email": email], merge: true)
                completion(.success(()))
            }
        }
    }
    
    func updatePassword(_ password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        user.updatePassword(to: password) { error in
            if let error = error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        user.delete { error in
            if let error = error { completion(.failure(error)) }
            else {
                self.db.collection("users").document(user.uid).delete()
                completion(.success(()))
            }
        }
    }
    
    // MARK: - 🔥 Sparks
    func fetchUserSparks(userId: String, completion: @escaping ([Spark]) -> Void) {
        db.collection("users").document(userId)
            .collection("sparks")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching sparks: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let sparks = snapshot?.documents.compactMap { doc -> Spark? in
                    guard let data = try? JSONSerialization.data(withJSONObject: doc.data()) else { return nil }
                    return try? JSONDecoder().decode(Spark.self, from: data)
                } ?? []
                
                completion(sparks)
            }
    }
    
    func saveSpark(userId: String, spark: Spark) {
        do {
            let data = try JSONEncoder().encode(spark)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
            
            db.collection("users").document(userId)
                .collection("sparks")
                .document(spark.id.uuidString)
                .setData(dict, merge: true)
        } catch {
            print("Error saving spark: \(error.localizedDescription)")
        }
    }
}
