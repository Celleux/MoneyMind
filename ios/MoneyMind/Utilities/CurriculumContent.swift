import Foundation

nonisolated struct CurriculumSessionContent: Sendable {
    let number: Int
    let title: String
    let subtitle: String
    let duration: String
    let iconName: String
    let color: String
    let sections: [CurriculumContentSection]
    let keyTakeaways: [String]
    let reflectionPrompt: String
}

nonisolated struct CurriculumContentSection: Sendable {
    let heading: String
    let body: String
}

nonisolated enum CurriculumContent: Sendable {
    static let sessions: [CurriculumSessionContent] = [
        CurriculumSessionContent(
            number: 1,
            title: "Understanding Your Money Brain",
            subtitle: "Psychoeducation on behavior chains, triggers, and dopamine pathways",
            duration: "15 min",
            iconName: "brain.fill",
            color: "teal",
            sections: [
                CurriculumContentSection(
                    heading: "The Behavior Chain",
                    body: "Every impulse purchase or gambling episode follows a predictable pattern: Trigger → Thought → Urge → Behavior → Consequence. Understanding this chain is the first step to breaking it.\n\nTriggers can be external (seeing an ad, walking past a store, getting a notification) or internal (boredom, stress, loneliness, excitement). The key insight is that there's always a gap between the trigger and the behavior — and that gap is where your power lives."
                ),
                CurriculumContentSection(
                    heading: "Your Brain on Dopamine",
                    body: "Dopamine isn't actually the 'pleasure chemical' — it's the anticipation chemical. Your brain releases dopamine when it expects a reward, not when it receives one. This is why the thrill of gambling comes from the bet, not the win. And why clicking 'Buy Now' feels better than opening the package.\n\nOver time, your brain adapts. It needs more intense experiences to get the same dopamine hit. This is called tolerance, and it's why spending or gambling can escalate."
                ),
                CurriculumContentSection(
                    heading: "Rewiring Is Possible",
                    body: "Neuroplasticity means your brain can change at any age. Every time you notice an urge and choose differently, you're literally creating new neural pathways. The first few times are the hardest — but each conscious choice makes the next one slightly easier.\n\nResearch shows that after 66 days of consistent new behavior, the neural pathway becomes strong enough to feel automatic. You're not fighting forever — you're building a bridge."
                )
            ],
            keyTakeaways: [
                "Impulse behavior follows a predictable chain you can interrupt",
                "Dopamine drives anticipation, not satisfaction — the chase is the hook",
                "Your brain can rewire with consistent practice — it gets easier"
            ],
            reflectionPrompt: "Think about your most recent impulse. Can you trace the behavior chain? What was the trigger? What thought followed?"
        ),
        CurriculumSessionContent(
            number: 2,
            title: "Catching Irrational Thoughts",
            subtitle: "Identify cognitive distortions about spending and gambling",
            duration: "15 min",
            iconName: "lightbulb.fill",
            color: "gold",
            sections: [
                CurriculumContentSection(
                    heading: "Cognitive Distortions",
                    body: "Our brains take shortcuts that sometimes lead us astray. These mental shortcuts — called cognitive distortions — can fuel impulsive spending and gambling. Learning to spot them is like gaining a superpower.\n\nThe good news: once you can name a distortion, it loses much of its power over you."
                ),
                CurriculumContentSection(
                    heading: "Common Money Distortions",
                    body: "Gambler's Fallacy: 'I've lost 5 times, so I'm due for a win.' Each event is independent — past losses don't affect future odds.\n\nEmotional Reasoning: 'I feel like I deserve this purchase.' Feelings aren't facts — feeling deserving doesn't mean spending is the right choice.\n\nMagnification: 'This deal is too good to pass up!' Most 'limited time' deals come back. The urgency is manufactured.\n\nAll-or-Nothing: 'I already slipped up today, so I might as well keep going.' One mistake doesn't erase your progress. Recovery is about the pattern, not perfection.\n\nFortune Telling: 'I just know this bet will pay off.' / 'I'll never be able to save.' Neither extreme prediction is based on evidence."
                ),
                CurriculumContentSection(
                    heading: "The Thought Record",
                    body: "When you notice an urge, try this exercise:\n\n1. What's the situation? (Where are you, what happened?)\n2. What thought popped up? (Write it exactly)\n3. What distortion is this? (Name it from the list above)\n4. What's a more balanced thought?\n5. How do you feel now?\n\nThis simple practice creates distance between you and your automatic thoughts. With time, you'll catch distortions faster and faster."
                )
            ],
            keyTakeaways: [
                "Cognitive distortions are automatic — they feel true even when they're not",
                "Naming the distortion weakens its power",
                "A thought record creates healthy distance from impulses"
            ],
            reflectionPrompt: "Which cognitive distortion resonates most with you? When did you last experience it?"
        ),
        CurriculumSessionContent(
            number: 3,
            title: "Building Your Coping Toolkit",
            subtitle: "Create a personalized toolkit from proven strategies",
            duration: "12 min",
            iconName: "wrench.and.screwdriver.fill",
            color: "green",
            sections: [
                CurriculumContentSection(
                    heading: "Your Personal Toolkit",
                    body: "Not every coping strategy works for every person or every situation. The key is having multiple tools ready, so you can reach for the right one in the moment.\n\nThink of your toolkit like a first-aid kit for urges. You wouldn't treat every injury with a bandage — and you shouldn't fight every urge with the same strategy."
                ),
                CurriculumContentSection(
                    heading: "The Tools Available to You",
                    body: "Urge Surfing: Ride the wave of craving without acting on it. Best for: moderate urges when you have 5-10 minutes.\n\nHALT Check: Ask yourself — am I Hungry, Angry, Lonely, or Tired? Often the real need isn't money-related at all. Best for: when urges come 'out of nowhere.'\n\nCooling Off Timer: Set a mandatory waiting period before any purchase. Best for: online shopping and spontaneous spending.\n\nImplementation Intentions: Pre-planned 'if-then' responses to triggers. Best for: predictable high-risk situations.\n\nGrounding (5-4-3-2-1): Use your senses to anchor yourself in the present moment. Best for: intense cravings or anxiety."
                ),
                CurriculumContentSection(
                    heading: "Building Your Plan",
                    body: "Choose your top 3 go-to tools from the list above. Consider:\n\n• Which situations trigger you most? Match tools to triggers.\n• What feels natural to you? You're more likely to use tools that feel comfortable.\n• What's practical? Some tools need time and privacy; others work anywhere.\n\nWrite your plan: 'When I feel [trigger], my first response will be [tool]. If that doesn't work, I'll try [backup tool].'"
                )
            ],
            keyTakeaways: [
                "Multiple tools > one strategy — different situations need different responses",
                "Match your tools to your specific triggers and lifestyle",
                "Having a plan before the urge hits makes you 3x more likely to succeed"
            ],
            reflectionPrompt: "Which 3 tools from your Splurj toolkit feel most natural to you? Why?"
        ),
        CurriculumSessionContent(
            number: 4,
            title: "Problem-Solving High-Risk Situations",
            subtitle: "Identify your top 3 risky situations and plan specific responses",
            duration: "15 min",
            iconName: "exclamationmark.shield.fill",
            color: "emergency",
            sections: [
                CurriculumContentSection(
                    heading: "Mapping Your Risk Landscape",
                    body: "High-risk situations are the moments when your defenses are lowest and temptation is highest. They're predictable — and that's actually good news, because predictable means preventable.\n\nMost people have 3-5 recurring high-risk situations. Common ones include: payday (sudden access to money), Friday nights (routine gambling/spending time), social events (peer pressure), emotional lows (stress, loneliness, boredom), and digital triggers (notifications, ads, apps).\n\nThe goal isn't to avoid life — it's to walk into these moments with a plan instead of hope."
                ),
                CurriculumContentSection(
                    heading: "The Problem-Solving Framework",
                    body: "For each high-risk situation, work through these five steps:\n\n1. Define the situation precisely: Not 'weekends are hard' but 'Saturday afternoons when I'm home alone with nothing planned.'\n\n2. Brainstorm responses: List every possible action — practical, creative, even silly. Don't judge yet.\n\n3. Evaluate each option: What's realistic? What fits your life? What have you tried before?\n\n4. Choose your top 2 responses: A primary plan and a backup.\n\n5. Rehearse mentally: Visualize yourself in the situation, then see yourself executing your plan. This mental rehearsal activates the same neural pathways as actually doing it.\n\nResearch shows that people who identify specific high-risk situations and plan responses in advance are 2-3x more likely to maintain behavior change."
                ),
                CurriculumContentSection(
                    heading: "Your Top 3 Action Plan",
                    body: "Write down your three most dangerous situations and your planned response for each:\n\nSituation 1: ___\nMy plan: ___\nBackup plan: ___\n\nSituation 2: ___\nMy plan: ___\nBackup plan: ___\n\nSituation 3: ___\nMy plan: ___\nBackup plan: ___\n\nKeep this somewhere visible. Review it weekly. Update it as you learn what works.\n\nRemember: the plan doesn't have to be perfect. Having any plan is dramatically better than having none. You can refine it as you go."
                )
            ],
            keyTakeaways: [
                "High-risk situations are predictable — identify your personal top 3",
                "For each situation, have a primary plan AND a backup",
                "Mental rehearsal activates the same pathways as real action — visualize success"
            ],
            reflectionPrompt: "What are your top 3 high-risk situations? For the most dangerous one, what's your plan and backup plan?"
        ),
        CurriculumSessionContent(
            number: 5,
            title: "Your Support Network",
            subtitle: "Map your support resources and involve an accountability partner",
            duration: "10 min",
            iconName: "person.3.fill",
            color: "teal",
            sections: [
                CurriculumContentSection(
                    heading: "You Don't Have to Do This Alone",
                    body: "Recovery and behavior change are not solo sports. Research consistently shows that social support is one of the strongest predictors of long-term success — stronger than willpower, motivation, or even the severity of the problem.\n\nBut asking for help can feel vulnerable. Many people feel shame about their spending or gambling habits. Here's the truth: asking for support is not weakness — it's strategy. The strongest people build the strongest teams."
                ),
                CurriculumContentSection(
                    heading: "Mapping Your Support Circle",
                    body: "Think of your support network as concentric circles:\n\nInner Circle (1-2 people): These are your accountability partners. They know your full situation. You can text them at 2am when an urge hits. Choose someone trustworthy, non-judgmental, and consistent.\n\nMiddle Circle (3-5 people): Friends or family who know you're working on financial wellness. They don't need every detail, but they can provide distraction, company, or encouragement.\n\nOuter Circle: Professional resources — therapists, financial counselors, support groups, hotlines. These are backup when your personal network isn't available.\n\nDigital Support: Apps like Splurj, online communities, forums. Available 24/7 when humans aren't."
                ),
                CurriculumContentSection(
                    heading: "The Accountability Conversation",
                    body: "Approaching someone to be your accountability partner can feel daunting. Here's a template:\n\n'I'm working on being more intentional with my money. I'm using an app called Splurj to help. Would you be open to being someone I can check in with? It would mean a lot to have someone I trust in my corner.'\n\nWhat to agree on:\n• How often you'll check in (weekly is a good start)\n• How they should respond if you reach out in a crisis (listen, don't lecture)\n• What information you're comfortable sharing\n• That relapse doesn't mean failure — it means you need support, not judgment\n\nIf you don't have someone you trust for this role, professional support groups are an excellent alternative. Many are free and confidential."
                )
            ],
            keyTakeaways: [
                "Social support is the #1 predictor of long-term behavior change success",
                "Build concentric circles: inner accountability, middle support, outer professional",
                "Asking for help is strategy, not weakness — the strongest people build teams"
            ],
            reflectionPrompt: "Who would you trust as an accountability partner? What would you want them to know about your journey?"
        ),
        CurriculumSessionContent(
            number: 6,
            title: "Financial Consequences Audit",
            subtitle: "Review your actual financial impact with compassion, not punishment",
            duration: "15 min",
            iconName: "chart.line.downtrend.xyaxis",
            color: "gold",
            sections: [
                CurriculumContentSection(
                    heading: "Why Look at the Numbers?",
                    body: "This session asks you to do something uncomfortable: look honestly at the financial impact of past behavior. This is NOT about guilt or punishment. It's about clarity.\n\nWhen we avoid looking at consequences, we allow our brain to minimize them. 'It wasn't that bad' becomes the story we tell ourselves. But vague denial keeps the door open for repetition.\n\nClarity, on the other hand, strengthens your resolve. When you know the real number, your future self has a concrete reason to pause in moments of temptation.\n\nApproach this exercise with the same compassion you'd show a friend. The past is information, not a verdict."
                ),
                CurriculumContentSection(
                    heading: "The Audit Framework",
                    body: "Work through these categories honestly. Estimates are fine — precision isn't the point, awareness is.\n\nDirect Financial Costs:\n• Money lost to gambling in the past year: $___\n• Impulse purchases you regret in the past year: $___\n• Interest paid on debt from these behaviors: $___\n• Fees, penalties, or overdrafts: $___\n\nOpportunity Costs:\n• If that money had been saved: $___\n• If invested at 7% average return over 10 years: $___ (multiply total by 2)\n• What could that money have bought? (vacation, down payment, education, freedom)\n\nNon-Financial Costs:\n• Hours spent gambling, shopping, or worrying about money\n• Relationships strained or damaged\n• Sleep lost, stress carried, opportunities missed\n\nIf you're using the Money Time Machine in Splurj, check your Alternate Timeline — it shows the cumulative expected losses you've been avoiding."
                ),
                CurriculumContentSection(
                    heading: "From Audit to Motivation",
                    body: "Now that you have your number, reframe it as fuel — not shame.\n\nThe Reframe: 'In the past year, my old patterns cost me approximately $___. Every day I choose differently, I'm redirecting that money toward the life I actually want.'\n\nYour Future Self Exercise:\nImagine yourself one year from today. You've maintained the changes you're making now. Calculate what you'll have saved. What does that number mean to you? What does it buy? What does it feel like?\n\nWrite a brief letter from your future self to your present self. What would they say? What would they thank you for?\n\nThis isn't fantasy — it's the mathematically likely outcome if you continue on your current path with Splurj. The audit proves that small daily choices compound into life-changing amounts."
                )
            ],
            keyTakeaways: [
                "Clarity about consequences strengthens resolve — vague denial enables repetition",
                "The audit is information, not a verdict — approach it with compassion",
                "Reframe the number as fuel: every day you choose differently redirects that money toward your real life"
            ],
            reflectionPrompt: "What's the approximate total financial impact of your past patterns? How does knowing that concrete number change your motivation?"
        ),
        CurriculumSessionContent(
            number: 7,
            title: "Building Alternative Behaviors",
            subtitle: "Substitution planning — replace old habits with rewarding alternatives",
            duration: "12 min",
            iconName: "arrow.triangle.swap",
            color: "green",
            sections: [
                CurriculumContentSection(
                    heading: "The Substitution Principle",
                    body: "You can't just remove a behavior — you have to replace it. Your brain allocated time, energy, and anticipation to gambling or impulsive spending. If you leave that space empty, cravings will rush in to fill it.\n\nThe key is finding alternatives that meet the same underlying need. Gambling often meets needs for excitement, escape, or social connection. Impulse spending often meets needs for reward, comfort, or identity expression.\n\nThe best substitution isn't the 'healthiest' option — it's the one you'll actually do. A good-enough alternative you use consistently beats a perfect one you never start."
                ),
                CurriculumContentSection(
                    heading: "Your Substitution Map",
                    body: "Match each old behavior to alternatives that meet the same need:\n\nIf gambling was about EXCITEMENT:\n→ Competitive gaming, sports, rock climbing, martial arts, escape rooms\n→ Learning a challenging new skill (instrument, language, coding)\n→ Volunteer for high-energy roles (event coordination, coaching)\n\nIf spending was about REWARD/COMFORT:\n→ Create a reward ritual that's free (favorite walk, bath, cooking)\n→ 'Window shopping' lists — browse, save to wishlist, revisit in 30 days\n→ Treat yourself with time, not money (sleep in, long lunch, phone-free hour)\n\nIf the behavior was about ESCAPE:\n→ Immersive activities: novels, podcasts, nature hikes, art\n→ Physical exercise (releases similar neurochemicals)\n→ Meditation or breathwork (the Urge Surf tool in Splurj)\n\nIf it was about SOCIAL CONNECTION:\n→ Join a club, team, or group aligned with a new interest\n→ Schedule regular catch-ups with supportive friends\n→ Engage with the Splurj community"
                ),
                CurriculumContentSection(
                    heading: "Your Weekly Schedule",
                    body: "Identify your highest-risk times and pre-fill them with alternatives:\n\nMonday: ___\nTuesday: ___\nWednesday: ___\nThursday: ___\nFriday: ___\nSaturday: ___\nSunday: ___\n\nPay special attention to:\n• Payday routines — what will you do instead of spending/gambling when money arrives?\n• Weekend evenings — the highest-risk window for most people\n• Transition moments — getting home from work, finishing a meal, lying in bed\n\nThe schedule doesn't need to be rigid. It's a default — something to fall back on when your brain whispers 'I'm bored, let's just...'\n\nReview and adjust weekly. What worked? What didn't? Swap in new alternatives as you discover what genuinely satisfies you."
                )
            ],
            keyTakeaways: [
                "You can't just remove a behavior — you must replace it with something that meets the same need",
                "The best substitute is the one you'll actually do, not the 'healthiest' option",
                "Pre-fill your highest-risk time slots with specific alternatives"
            ],
            reflectionPrompt: "If you used to gamble or impulse-spend on Friday nights, what will you do instead? Design your ideal Friday evening."
        ),
        CurriculumSessionContent(
            number: 8,
            title: "Your Relapse Prevention Plan",
            subtitle: "A comprehensive plan to protect everything you've built",
            duration: "20 min",
            iconName: "shield.checkered",
            color: "purple",
            sections: [
                CurriculumContentSection(
                    heading: "Why Relapse Prevention Matters",
                    body: "You've done extraordinary work over the past seven sessions. You understand your triggers, you can catch distorted thinking, you have coping tools, a support network, and alternative behaviors. That's real, lasting progress.\n\nBut here's the honest truth: the risk never fully disappears. Life will throw curveballs — stress, celebration, boredom, grief — and old patterns can resurface when you least expect them.\n\nThis isn't a failure of willpower. It's how the brain works. Neural pathways you built over months or years don't vanish — they fade with disuse but can reactivate under pressure.\n\nThe good news? Having a prevention plan is the single strongest predictor of long-term success. People with a written, specific plan are 3-4x more likely to maintain their gains after one year. This session is about building that plan — your personal safety net."
                ),
                CurriculumContentSection(
                    heading: "Building Your Personal Prevention Plan",
                    body: "Your plan draws from everything you've learned. Let's bring it all together:\n\nPart 1 — My Warning Signs\nWhat are the earliest signals that you're sliding? Common ones: increased screen time on shopping/betting apps, telling yourself 'just once,' withdrawing from your support network, skipping Splurj check-ins, rationalizing ('I deserve this'), disrupted sleep or eating.\nMy top 3 warning signs:\n1. ___\n2. ___\n3. ___\n\nPart 2 — My Trigger Map (from Session 4)\nHigh-risk situation 1: ___ → My response: ___\nHigh-risk situation 2: ___ → My response: ___\nHigh-risk situation 3: ___ → My response: ___\n\nPart 3 — My Coping Sequence (from Session 3)\nWhen an urge hits: Step 1: ___ Step 2: ___ Step 3: ___\n\nPart 4 — My Support Contacts (from Session 5)\nAccountability partner: ___ (phone: ___)\nBackup support: ___\nCrisis line: ___\n\nPart 5 — My Implementation Intentions (from throughout the program)\nIf I feel _____, I will _____.\nIf I notice warning sign _____, I will _____.\n\nPart 6 — If I Slip\nA slip is NOT a relapse. It's a data point. My plan if I slip:\n1. Stop. Don't escalate. One slip ≠ failure.\n2. Contact: ___ (my accountability partner)\n3. Open Splurj and log a Spending Autopsy — no judgment, just learning.\n4. Review this prevention plan within 24 hours.\n5. Identify what I'll do differently next time.\n\nRemember: the research is clear — most people who achieve lasting change experience setbacks along the way. What separates success from relapse isn't perfection — it's how quickly you return to your plan."
                ),
                CurriculumContentSection(
                    heading: "Your Commitment & Certificate",
                    body: "You've completed all 8 sessions of the Splurj Program. Based on the UCLA Gambling CBT manual and internet-delivered CBT research (80% completion rate, Frontiers 2023), completing this program puts you in a strong position for lasting change.\n\nYour Final Exercise — Letter to Your Future Self:\nImagine yourself six months from now. You've maintained your gains. Your savings have grown. Your relationship with money feels different — calmer, more intentional.\n\nWrite a brief letter from that future self to your present self. What would they say? What would they thank you for? What would they remind you of on a hard day?\n\nDear present me,\n___\n\nYour Commitment Statement:\nI, ___, commit to using the tools and strategies I've learned in this program. I understand that recovery is a journey, not a destination. I have a plan, I have support, and I have the skills to navigate challenges. I choose to be mindful with my money — one day at a time.\n\nCongratulations. You've earned this."
                )
            ],
            keyTakeaways: [
                "A written prevention plan is the #1 predictor of long-term success",
                "Warning signs appear before relapse — learn to recognize yours early",
                "A slip is data, not destiny — your response determines the outcome"
            ],
            reflectionPrompt: "What is your #1 commitment going forward? Write the single most important thing you'll do to protect the progress you've made."
        )
    ]

    static func session(for number: Int) -> CurriculumSessionContent? {
        sessions.first(where: { $0.number == number })
    }
}
