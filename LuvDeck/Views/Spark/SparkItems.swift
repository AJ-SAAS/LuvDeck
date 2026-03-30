import Foundation

// =======================
// 🔹 ORIGINAL SPARK SYSTEM
// (Used for random prompt cards)
// =======================

struct SparkItem: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let category: SparkCategory
}

enum SparkCategory: String, CaseIterable {
    case conversation
    case deepQuestion
    case challenge
    case miniAction
}

let sparkDatabase: [SparkItem] = [
    SparkItem(text: "Ask about their favorite childhood memory.", category: .conversation),
    SparkItem(text: "What's something you've never told anyone?", category: .deepQuestion),
    SparkItem(text: "No phones for 30 minutes tonight.", category: .challenge),
    SparkItem(text: "Send a random appreciation text.", category: .miniAction)
]


// =======================
// 🔥 MOMENTUM SYSTEM
// (Used for the new Momentum page)
// =======================

enum MomentumCategory: String, Codable, CaseIterable {
    case playfulness = "Playfulness"
    case emotionalDepth = "Emotional Depth"
    case surpriseChemistry = "Surprise & Chemistry"
    case adventureMemory = "Adventure & Memory"
    case legendaryPartner = "Legendary Partner Level"
}

struct MomentumItem: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let category: MomentumCategory
}

let momentumDatabase: [MomentumItem] = {

    var all: [MomentumItem] = []

    // Chapter 1: Playfulness (free - keep at 10)
    let playfulness = [
        "Send them a random 'I appreciate this about you' text mid-day",
        "Do a 60-second slow hug without talking",
        "Make up a ridiculous couple nickname",
        "Ask: 'If we met today, would you still choose me?'",
        "Recreate your first selfie together",
        "Share one memory you've never told them",
        "Switch phones for 2 minutes and take 3 silly photos",
        "Sit next to each other and describe your dream Sunday",
        "High-five them for something small they did today",
        "Whisper something playful in their ear unexpectedly"
    ]
    playfulness.forEach { all.append(MomentumItem(text: $0, category: .playfulness)) }

    // Chapter 2: Emotional Depth (premium - 20 tasks)
    let emotionalDepth = [
        "Ask: 'When do you feel most loved by me?'",
        "Write 3 traits you admire and read them out loud",
        "Share one insecurity you rarely admit",
        "Ask: 'What's something you wish we did more of?'",
        "Talk about your favorite version of 'us'",
        "Ask about a childhood memory that shaped them",
        "Tell them one thing you're grateful for this year",
        "Describe your future home together",
        "Ask: 'What makes you feel safest with me?'",
        "Finish the sentence: 'I love when you…'",
        "Ask: 'What's a dream you've quietly given up on?'",
        "Share something you've never said out loud to anyone",
        "Ask: 'What's the hardest thing you've ever been through?'",
        "Tell them one way they've changed you for the better",
        "Ask: 'What does commitment mean to you right now?'",
        "Share a fear you've never fully admitted",
        "Ask: 'What do you need more of from me?'",
        "Tell them your favorite memory of the two of you",
        "Ask: 'How do you know when you feel truly understood?'",
        "Write down 5 things you love about them and swap lists"
    ]
    emotionalDepth.forEach { all.append(MomentumItem(text: $0, category: .emotionalDepth)) }

    // Chapter 3: Surprise & Chemistry (premium - 20 tasks)
    let surpriseChemistry = [
        "Leave a handwritten note somewhere unexpected",
        "Plan a 20-minute mystery activity (no hints)",
        "Change into something they love without announcing it",
        "Send a voice note instead of a text",
        "Randomly say: 'I'm proud of you'",
        "Text them a memory from early in your relationship",
        "Cook or order their favorite snack without asking",
        "Light candles on a random weekday",
        "Initiate a spontaneous slow dance in the kitchen",
        "Say: 'I've been thinking about you today'",
        "Hide a love note in their bag or pocket",
        "Recreate your first date at home",
        "Send them a playlist of songs that remind you of them",
        "Buy them something small they mentioned weeks ago",
        "Plan a surprise 30-minute activity tonight",
        "Write them a letter to open when they're having a bad day",
        "Show up somewhere they don't expect you",
        "Make breakfast in bed on a random Tuesday",
        "Send a photo of something that reminded you of them",
        "Plan a mystery evening — they find out the plan when it happens"
    ]
    surpriseChemistry.forEach { all.append(MomentumItem(text: $0, category: .surpriseChemistry)) }

    // Chapter 4: Adventure & Memory (premium - 20 tasks)
    let adventureMemory = [
        "Take a 30-minute evening walk somewhere new",
        "Go for coffee in a different neighborhood",
        "Visit a place from your first year together",
        "Watch the sunset together (phones away)",
        "Try a new dessert neither of you have had",
        "Create a 'future bucket list' of 5 places",
        "Take one photo that represents your relationship today",
        "Plan a 1-hour micro date this week",
        "Sit somewhere public and people-watch together",
        "Make a time capsule note to open in 1 year",
        "Try a cuisine neither of you has eaten before",
        "Drive somewhere with no destination — just explore",
        "Find a new walking trail and go this weekend",
        "Visit a local market or street fair together",
        "Book a night away — even just 30 minutes from home",
        "Do something neither of you has ever done before",
        "Create a shared photo album of your favorite memories",
        "Go stargazing somewhere dark and quiet",
        "Revisit the restaurant from your first date",
        "Plan your dream trip — even if it's years away"
    ]
    adventureMemory.forEach { all.append(MomentumItem(text: $0, category: .adventureMemory)) }

    // Chapter 5: Legendary Partner Level (premium - 20 tasks)
    let legendaryPartner = [
        "Ask: 'How can I support you better right now?'",
        "Surprise them with something thoughtful under $10",
        "Schedule a no-phone dinner",
        "Tell them specifically why you're committed",
        "Plan a 'first date' redo",
        "Create a 'relationship highlight reel' night",
        "Apologize for something small you've brushed off",
        "Share one big dream you haven't spoken about",
        "Ask them what romance means to them now",
        "Write a 5-sentence love letter",
        "Ask: 'What's one thing I do that makes you feel taken for granted?'",
        "Do one of their chores without being asked",
        "Plan an entire date around their interests, not yours",
        "Ask: 'What's one way I could be a better partner?'",
        "Put your phone away for the entire evening",
        "Tell them three specific reasons you chose them",
        "Ask: 'Is there anything between us that needs clearing up?'",
        "Take something off their plate this week without being asked",
        "Plan a monthly relationship check-in and do the first one tonight",
        "Tell them what your life would look like without them in it"
    ]
    legendaryPartner.forEach { all.append(MomentumItem(text: $0, category: .legendaryPartner)) }

    return all
}()
