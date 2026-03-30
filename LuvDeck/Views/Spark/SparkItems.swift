import Foundation

// =======================
// 🔹 QUICK SPARK SYSTEM (Random Prompts)
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

// Full Prompt Arrays
let conversationStarters: [String] = [
    "If we were a power couple in a movie, what would our theme song be?",
    "Quick: give me your best villain laugh — then kiss me before I escape.",
    "What’s the most ridiculous thing we should do before we’re 80?",
    "You just won a lifetime supply of kisses — how are you spending them?",
    "If we opened a bar together, what drink would totally scream ‘us’?",
    "Tease me: what’s one little thing I do that secretly drives you wild?",
    "Let’s invent a secret handshake right now — go!",
    "What’s the cheesiest pickup line that would 100% work on you?",
    "If we had a couple superpower, what would it be?",
    "Describe our next spontaneous adventure in 5 words.",
    "Rate my outfit out of 10… but you have to flirt while doing it.",
    "What’s the most fun trouble we’ve ever gotten into together?",
    "You’re my celebrity crush for the day — what’s your red-carpet pose?",
    "If we made a TikTok duet right now, what song would make everyone jealous of our chemistry?",
    "Quick compliment battle: you go first, make it bold.",
    "Let’s invent a secret joke tonight — what’s our first one?",
    "If we were spies, what would our code names be?",
    "You just became a genie for 10 minutes — what three wishes do I get?",
    "Give me a nickname that would make me blush — only you could pull it off.",
    "Let’s plan the most ridiculous date ever — money no object.",
    "What emoji combo perfectly describes how you feel about me right now?",
    "Give me your best slow-motion hair flip and strut.",
    "If we started a band tomorrow, what would our first hit be called?",
    "You’re stuck on a desert island with me — first thing we do?",
    "What’s the sexiest accent you can pull off for 10 seconds?",
    "Quick: roast me in the most charming way possible.",
    "If we were cartoon characters, who would voice us?",
    "What’s the most spontaneous thing we’ve ever done — can we top it?",
    "You just won me in an auction — what do you do with your prize?",
    "Let’s make up a ridiculous couple hashtag right now."
]

let deepQuestions: [String] = [
    "When do you feel most alive and electric when we’re together?",
    "What’s one moment with me that still gives you butterflies?",
    "When have you felt the most proud to have me by your side?",
    "What’s a dream we haven’t said out loud yet?",
    "What’s something I do that makes you feel like the luckiest person alive?",
    "When do you feel the most irresistible version of yourself with me?",
    "What’s a fantasy adventure we should absolutely make real?",
    "What song lyric perfectly describes how you feel about us?",
    "When was the last time I made your heart race?",
    "What’s one thing you love about us that no one else sees?",
    "If we wrote a book about our love story, what’s chapter one called?",
    "What’s the boldest thing you’ve ever wanted to whisper to me?",
    "When do you feel the most turned on by who we are together?",
    "What’s a secret talent of yours I need to experience soon?",
    "What’s one way I make you feel completely unstoppable?",
    "If we could freeze one perfect moment forever, which would it be?",
    "What’s something playful you’ve always wanted to try in bed?",
    "When do you feel the most free to be your full, wild self with me?",
    "What’s a compliment you’re dying to give me right now?",
    "What’s the sexiest memory we’ve made so far?",
    "What’s one thing you love that I bring out in you?",
    "When do you feel the most adored and desired by me?",
    "What’s a future memory we haven’t created yet that excites you?",
    "What’s the most romantic risk you’d take for us?",
    "How has loving me made you feel more powerful?",
    "What’s one look I give you that instantly melts you?",
    "When do you feel the most playful and turned on at the same time?",
    "What’s a dream date you’ve never told anyone — until now?",
    "What’s something I do that makes you grin like an idiot?",
    "How do you want to be kissed tonight?"
]

let miniLoveActions: [String] = [
    "Wink + mouth ‘You’re in trouble tonight’ across the room.",
    "Send: ‘Thinking about your lips on mine right now.’",
    "Walk past, lightly smack their butt, keep walking.",
    "Hold eye contact 5 seconds longer than normal — smirk.",
    "Text: ‘You + me + later = perfect plan.’",
    "Bite your lip while looking at them.",
    "Send a playful selfie with just the caption ‘Yours.’",
    "Trace a heart on their hand or wrist — hold eye contact.",
    "Whisper ‘I want you’ as you pass by.",
    "Send a short voice note saying their name slowly — teasing.",
    "Kiss their neck from behind — no explanation.",
    "Text: ‘Cancel whatever you’re doing at 10pm. :) ’",
    "Pull them in by the waist for a 5-second hug.",
    "Send a close-up photo of your lips + ‘Missing you.’",
    "Playfully pin them against the wall for 3 seconds.",
    "Text: ‘I bet you can’t resist kissing me when you see this.’",
    "Run your fingers slowly down their arm — stare.",
    "Send: ‘Consider yourself warned…’",
    "Kiss their hand like royalty — then bite it softly.",
    "Text a single peach emoji + devil emoji.",
    "Walk by and whisper ‘Tonight you’re mine.’",
    "Send a mirror selfie flexing with ‘For your eyes only.’",
    "Grab their hand, put it on your heart, say ‘Feel that?’",
    "Text: ‘Thinking about what’s coming later…’",
    "Spin them into a surprise kiss.",
    "Text: ‘Counting down… can’t wait for you.’",
    "Smirk and say ‘You have no idea what I’m planning…’",
    "End any sentence today with a little tease: ‘…in bed.’"
]

let romanceChallenges: [String] = [
    "Slow-dance in the kitchen right now — no music required.",
    "Leave a trail of kisses from their neck to wherever you want.",
    "Send a voice note describing exactly what you want to do later.",
    "Recreate your first kiss — but make it 10× hotter.",
    "Blindfold them for 60 seconds and tease with just your voice.",
    "Write ‘I want you’ on their body with a marker or lipstick.",
    "Give them a 2-minute massage that ends in a deep kiss.",
    "Challenge: who can make the other blush harder in 30 seconds.",
    "Whisper your favorite dirty memory in their ear — right now.",
    "Send a photo of the body part you want kissed tonight.",
    "Play the ‘3 compliments, each bolder than the last’ game.",
    "Hide a love note somewhere they’ll find during the day.",
    "Pull them in for a kiss mid-sentence — no warning.",
    "Text them a fantasy and say ‘Tonight?’",
    "Stare into their eyes for 20 seconds — no laughing allowed.",
    "Leave a hickey in a place only you’ll see.",
    "Cook dinner wearing only an apron (or less).",
    "Create a 5-second couple handshake that ends in a kiss.",
    "Send ‘I’m not wearing…’ and finish the sentence.",
    "Re-enact your favorite movie kiss scene.",
    "Give them a lap dance — 30 seconds, full confidence.",
    "Write a 3-line love poem on their thigh with a pen.",
    "Bite their lower lip next time you kiss.",
    "Send a playlist called ‘What I want to do to you tonight’",
    "Kiss them like it’s the last time — every time.",
    "Whisper ‘You’re mine’ possessively during a hug.",
    "Challenge: no kissing on the lips until midnight — tease only.",
    "Leave lipstick kisses on the mirror spelling ‘Tonight’",
    "Tell them exactly how you want to be touched tonight.",
    "End the night with ‘Round two starts now.’"
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
