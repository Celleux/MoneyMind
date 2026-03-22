import Foundation

nonisolated enum CrisisKeywords: Sendable {
    static let phrases: [String] = [
        "suicide", "kill myself", "end it all", "no reason to live",
        "self-harm", "want to die", "can't go on", "what's the point",
        "nobody cares", "better off without me", "hurt myself",
        "don't want to be here", "ending it", "no way out"
    ]

    static func containsCrisisLanguage(_ text: String) -> Bool {
        let lower = text.lowercased()
        return phrases.contains { lower.contains($0) }
    }
}

nonisolated struct GamblingDistortion: Sendable {
    let pattern: String
    let name: String
    let correction: String
}

nonisolated enum DistortionPatterns: Sendable {
    static let all: [GamblingDistortion] = [
        GamblingDistortion(
            pattern: "due for a win",
            name: "Gambler's Fallacy",
            correction: "Each event is independent. Past losses don't increase future chances of winning. The odds reset every time."
        ),
        GamblingDistortion(
            pattern: "i have a system",
            name: "Illusion of Control",
            correction: "Games of chance can't be controlled by any system. The house edge is mathematical and consistent regardless of strategy."
        ),
        GamblingDistortion(
            pattern: "almost won",
            name: "Near-Miss Bias",
            correction: "A near-miss is still a loss. Our brains treat 'almost winning' as encouraging, but the outcome is the same as any other loss."
        ),
        GamblingDistortion(
            pattern: "just one more",
            name: "Chasing Losses",
            correction: "Chasing losses is how small losses become devastating ones. The urge to 'win it back' is one of the strongest and most dangerous impulses."
        ),
        GamblingDistortion(
            pattern: "feeling lucky",
            name: "Superstitious Thinking",
            correction: "Luck isn't a real force that influences outcomes. Random events don't respond to feelings, rituals, or patterns."
        ),
        GamblingDistortion(
            pattern: "win it back",
            name: "Chasing Losses",
            correction: "The money lost is gone. Trying to recover it through more gambling statistically leads to greater losses."
        ),
        GamblingDistortion(
            pattern: "hot streak",
            name: "Hot Hand Fallacy",
            correction: "Past wins don't predict future wins. Each event is independent. A 'streak' is just a pattern our brains impose on randomness."
        ),
        GamblingDistortion(
            pattern: "know when to stop",
            name: "Overconfidence Bias",
            correction: "Most people overestimate their ability to stop. The neurochemistry of gambling makes it harder to quit while ahead than we expect."
        )
    ]

    static func detectDistortion(in text: String) -> GamblingDistortion? {
        let lower = text.lowercased()
        return all.first { lower.contains($0.pattern) }
    }
}

nonisolated struct ScriptedResponse: Sendable {
    let triggers: [String]
    let response: String
    let followUp: String?
}

nonisolated enum ScriptedCoachTree: Sendable {
    static let greeting = "Welcome to your coaching session. I'm here to help you explore your relationship with money in a supportive, non-judgmental space. What's on your mind today?"

    static let disclaimer = "I'm an AI wellness coach, not a therapist. If you're in crisis, tap SOS anytime."

    static let sessionEndingSummary = "Our time is wrapping up. You showed real courage today by reflecting on your experiences. Remember: every moment of awareness is a step forward. Take one insight from today and carry it with you."

    static let nineMinuteWarning = "We have about a minute left in this session. Is there anything important you'd like to share before we wrap up?"

    static let responses: [ScriptedResponse] = [
        ScriptedResponse(
            triggers: ["urge", "craving", "want to gamble", "want to spend", "tempted"],
            response: "It sounds like you're experiencing an urge right now. That takes real awareness to notice. Urges are like waves — they rise, peak, and fall. On a scale of 0-10, how intense is this urge?",
            followUp: "Whatever number it is, that's okay. The urge will naturally decrease if you don't act on it. Would you like to try the Urge Surf tool, or talk through what triggered this feeling?"
        ),
        ScriptedResponse(
            triggers: ["stressed", "anxious", "worried", "overwhelmed", "panic"],
            response: "I hear that you're feeling stressed. Your feelings are completely valid. Let's take a moment — can you take three slow, deep breaths with me? In for 4 seconds, hold for 4, out for 4.",
            followUp: "How are you feeling now? Sometimes just pausing helps. Would it help to explore what's driving the stress, or would you prefer a grounding exercise?"
        ),
        ScriptedResponse(
            triggers: ["relapse", "gave in", "failed", "slipped", "messed up"],
            response: "Thank you for being honest about this. It takes genuine courage to share that. A slip doesn't erase your progress — it's information about what you need. Recovery isn't a straight line.",
            followUp: "Can you walk me through what happened? Understanding the sequence — trigger, thought, feeling, action — helps us build better strategies for next time."
        ),
        ScriptedResponse(
            triggers: ["bored", "nothing to do", "lonely"],
            response: "Boredom and loneliness are two of the most common triggers. Your brain is looking for stimulation, and old habits offer a quick fix. What's one thing you enjoy that you haven't done in a while?",
            followUp: "Building a list of alternative activities is one of the most effective strategies. Even small things — a walk, a podcast, calling someone — can redirect that energy."
        ),
        ScriptedResponse(
            triggers: ["money", "debt", "bills", "broke", "financial"],
            response: "Financial stress is incredibly difficult. It can feel like a weight that never lifts. But you're here, working on it, and that matters. Would you like to talk about what's causing the most pressure right now?",
            followUp: "Sometimes breaking big financial worries into smaller, actionable steps makes them feel more manageable. What's one small thing you could do this week?"
        ),
        ScriptedResponse(
            triggers: ["proud", "good", "happy", "win", "saved", "resisted"],
            response: "That's wonderful! You should feel proud — that took real strength. Every time you make a conscious choice, you're literally rewiring your brain. How does it feel to recognize that win?",
            followUp: "Savoring positive moments like this is important. Your brain needs to register that choosing differently feels good too. Would you like to log this win in your wallet?"
        ),
        ScriptedResponse(
            triggers: ["angry", "frustrated", "mad"],
            response: "Anger is a powerful emotion, and it's often masking something underneath — hurt, fear, or feeling out of control. It's okay to feel angry. What happened that brought this on?",
            followUp: "When we understand what's beneath the anger, we can address the real need. Would a HALT check help right now to see what might be driving this?"
        ),
        ScriptedResponse(
            triggers: ["can't sleep", "insomnia", "nighttime", "late night"],
            response: "Late nights can be a vulnerable time. The quiet and lack of distraction can amplify urges. You're smart to reach out instead of acting on impulse. What's keeping you up?",
            followUp: "A brief breathing exercise might help settle your mind. Or we could talk through what's weighing on you. What feels right?"
        ),
        ScriptedResponse(
            triggers: ["relationship", "partner", "family", "friend"],
            response: "Relationships are deeply connected to how we handle money and stress. It takes courage to reflect on how our patterns affect the people we care about. What's going on?",
            followUp: "Sometimes our loved ones are affected by our struggles in ways we don't fully see. Would it help to think about how to have an honest conversation with them?"
        ),
        ScriptedResponse(
            triggers: ["help", "what should i do", "advice", "lost"],
            response: "You've already taken an important step by being here and asking. Let me understand what you're dealing with — can you tell me more about what's going on right now?",
            followUp: "Based on what you've shared, we have some great tools available. Would you like to explore them, or would it help to keep talking through this?"
        )
    ]

    static let defaultResponse = "Thank you for sharing that. Can you tell me more about what you're experiencing? Understanding the full picture helps us find the best path forward."

    static let defaultFollowUp = "Remember, there's no wrong answer here. This is your space to explore and reflect."

    static func findResponse(for text: String) -> (String, String?) {
        let lower = text.lowercased()
        for scripted in responses {
            if scripted.triggers.contains(where: { lower.contains($0) }) {
                return (scripted.response, scripted.followUp)
            }
        }
        return (defaultResponse, defaultFollowUp)
    }
}

nonisolated struct SeekingSafetyTopic: Sendable, Identifiable {
    let id: String
    let title: String
    let icon: String
    let intro: String
    let reflectionPrompts: [String]
    let keyTakeaway: String
    let journalPrompt: String
}

nonisolated enum SeekingSafetyContent: Sendable {
    static let topics: [SeekingSafetyTopic] = [
        SeekingSafetyTopic(
            id: "safety",
            title: "Safety",
            icon: "shield.fill",
            intro: "Safety is the priority in early recovery. This means creating physical, emotional, and financial safety in your life. When we feel safe, we can begin to heal.",
            reflectionPrompts: [
                "What does 'feeling safe' mean to you right now?",
                "Are there situations where you feel unsafe with money?",
                "What's one thing you could do today to increase your sense of safety?"
            ],
            keyTakeaway: "Safety isn't selfish — it's the foundation everything else is built on. You deserve to feel safe.",
            journalPrompt: "Write about one area of your life where you'd like to feel more safe. What small step could you take?"
        ),
        SeekingSafetyTopic(
            id: "taking_back_power",
            title: "Taking Back Power",
            icon: "bolt.fill",
            intro: "Addiction and impulsive patterns can make us feel powerless. But you have more power than you think. Every conscious choice is an act of reclaiming control over your life.",
            reflectionPrompts: [
                "When do you feel most in control of your decisions?",
                "What situations make you feel powerless around money?",
                "Think of a time you successfully resisted an urge. What helped?"
            ],
            keyTakeaway: "Power isn't about being perfect. It's about making one conscious choice at a time.",
            journalPrompt: "Describe a moment when you felt powerful in your recovery. What strengths did you use?"
        ),
        SeekingSafetyTopic(
            id: "detaching_from_pain",
            title: "Detaching from Pain",
            icon: "cloud.fill",
            intro: "Pain — emotional, financial, relational — can drive destructive behavior. Learning to observe pain without being controlled by it is a core recovery skill.",
            reflectionPrompts: [
                "What emotional pain most often triggers your urges?",
                "Can you notice the pain without trying to fix it right now?",
                "What does it feel like to sit with discomfort for even 30 seconds?"
            ],
            keyTakeaway: "You are not your pain. You are the one observing it. Pain passes when we stop fighting it.",
            journalPrompt: "Write about a painful emotion you've been carrying. How has it influenced your spending or gambling?"
        ),
        SeekingSafetyTopic(
            id: "asking_for_help",
            title: "Asking for Help",
            icon: "hand.raised.fill",
            intro: "Asking for help isn't weakness — it's one of the bravest things you can do. Isolation fuels addiction. Connection is the antidote.",
            reflectionPrompts: [
                "Who in your life could you ask for support?",
                "What makes asking for help difficult for you?",
                "Have you ever helped someone else? How did that feel?"
            ],
            keyTakeaway: "No one recovers alone. Reaching out is an act of courage, not weakness.",
            journalPrompt: "Think of one person you trust. What would you want to tell them about your journey?"
        ),
        SeekingSafetyTopic(
            id: "honesty",
            title: "Honesty",
            icon: "eye.fill",
            intro: "Secrecy and shame are fuel for destructive patterns. Honesty — with yourself and others — breaks the cycle. It starts with small truths.",
            reflectionPrompts: [
                "Is there something about your spending or gambling you haven't told anyone?",
                "What would it feel like to be fully honest with yourself about where you are?",
                "What's one small truth you could acknowledge today?"
            ],
            keyTakeaway: "Honesty doesn't have to happen all at once. One small truth at a time builds a foundation of integrity.",
            journalPrompt: "Write something honest about your relationship with money that you haven't said out loud before."
        ),
        SeekingSafetyTopic(
            id: "setting_boundaries",
            title: "Setting Boundaries",
            icon: "rectangle.badge.checkmark",
            intro: "Boundaries protect your recovery. They might mean saying no to certain people, places, or apps. Boundaries aren't walls — they're guardrails that keep you safe.",
            reflectionPrompts: [
                "What boundaries could protect your financial wellbeing?",
                "Are there people or situations that weaken your resolve?",
                "What would it look like to set one new boundary this week?"
            ],
            keyTakeaway: "Boundaries are an act of self-respect. The people who matter will understand.",
            journalPrompt: "Describe one boundary you'd like to set. What's stopping you, and what would help you follow through?"
        )
    ]
}

nonisolated struct ACTExerciseStep: Sendable {
    let instruction: String
    let prompt: String?
    let isReflection: Bool
}

nonisolated enum ACTContent: Sendable {
    static let valuesSteps: [ACTExerciseStep] = [
        ACTExerciseStep(
            instruction: "Values are directions, not destinations. They're about who you want to be, not what you want to have.",
            prompt: "What matters most to you about money? Not how much — but what role do you want it to play in your life?",
            isReflection: true
        ),
        ACTExerciseStep(
            instruction: "Consider these areas of life. Rate how important each is to you (1-10):",
            prompt: nil,
            isReflection: false
        ),
        ACTExerciseStep(
            instruction: "Now think about your recent actions. Are they moving you toward or away from what matters?",
            prompt: "What's one thing you did this week that aligned with your values?",
            isReflection: true
        ),
        ACTExerciseStep(
            instruction: "A committed action is a concrete step you take based on your values, even when it's uncomfortable.",
            prompt: "Complete this: 'This week, I commit to ___ because ___ matters to me.'",
            isReflection: true
        )
    ]

    static let valuesAreas = [
        "Family & Relationships",
        "Financial Security",
        "Personal Growth",
        "Health & Wellbeing",
        "Freedom & Independence",
        "Generosity & Giving"
    ]

    static let defusionSteps: [ACTExerciseStep] = [
        ACTExerciseStep(
            instruction: "Our minds constantly produce thoughts. Some are helpful, some aren't. The goal isn't to stop thoughts — it's to change your relationship with them.",
            prompt: "What unhelpful thought about money or spending keeps showing up for you?",
            isReflection: true
        ),
        ACTExerciseStep(
            instruction: "Now, take that thought and add this prefix: 'I notice I'm having the thought that...'",
            prompt: nil,
            isReflection: false
        ),
        ACTExerciseStep(
            instruction: "Say it again, but this time: 'My mind is telling me that...'",
            prompt: "How does the thought feel different with this distance? Does it feel less 'true' or less urgent?",
            isReflection: true
        ),
        ACTExerciseStep(
            instruction: "Finally, imagine placing that thought on a leaf floating down a stream. Watch it drift away. It's still there — you're just not holding it.",
            prompt: "What did you notice during this exercise?",
            isReflection: true
        )
    ]

    static let willingnessSteps: [ACTExerciseStep] = [
        ACTExerciseStep(
            instruction: "Willingness means making room for discomfort without trying to control or eliminate it. It's the opposite of avoidance.",
            prompt: nil,
            isReflection: false
        ),
        ACTExerciseStep(
            instruction: "Think about the discomfort you feel when resisting an urge. Where do you feel it in your body?",
            prompt: "Rate your current discomfort from 0 (none) to 10 (extreme):",
            isReflection: false
        ),
        ACTExerciseStep(
            instruction: "Now, instead of fighting it, can you sit with this feeling for 2 minutes? Breathe slowly. Don't try to change anything. Just notice.",
            prompt: nil,
            isReflection: false
        ),
        ACTExerciseStep(
            instruction: "Two minutes have passed. Take a moment to check in.",
            prompt: "Rate your discomfort again. Did it change? What did you notice?",
            isReflection: true
        )
    ]
}
