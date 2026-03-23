import Foundation

extension QuestDatabase {

    static let lifeEventQuests: [QuestDefinition] =
        movingQuests + newJobQuests + newRelationshipQuests + havingBabyQuests + buyingCarQuests + startingBusinessQuests

    // MARK: - Moving / New Apartment

    private static let movingQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "life_move_budget", title: "The Move Budget", subtitle: "Plan all moving costs before you move",
            description: "Moving costs surprise everyone. Security deposit, movers, supplies, first/last month rent, utility deposits — plan it all before signing that lease.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .medium, cadence: .story,
            estimatedImpact: "$200-1,000 saved", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "move_bud_1", instruction: "List every moving expense (deposit, movers, supplies, etc.)", verification: .selfReport, xpReward: 50),
                QuestStep(id: "move_bud_2", instruction: "Get quotes for movers or truck rental", verification: .selfReport, xpReward: 80),
                QuestStep(id: "move_bud_3", instruction: "Set a total moving budget and timeline", verification: .selfReport, xpReward: 120)
            ],
            zone: .budgetForge),
        QuestDefinition(
            id: "life_move_utilities", title: "Utility Setup Quest", subtitle: "Compare utility providers before signing up",
            description: "Don't just accept the default provider. Compare internet, electricity, and gas rates. 10 minutes of comparison can save $30-50/month.",
            category: .moneyRecovery, archetype: .exploration, difficulty: .easy, cadence: .story,
            estimatedImpact: "$30-50/mo", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "move_util_1", instruction: "Research internet providers in your new area", verification: .selfReport, xpReward: 40),
                QuestStep(id: "move_util_2", instruction: "Compare rates for electricity and gas", verification: .selfReport, xpReward: 40),
                QuestStep(id: "move_util_3", instruction: "Sign up with the best value providers", verification: .selfReport, xpReward: 70)
            ],
            zone: .budgetForge),
        QuestDefinition(
            id: "life_move_renters", title: "Renter's Insurance Shield", subtitle: "Get a renter's insurance policy",
            description: "Renter's insurance costs $15-25/month and covers $10,000-50,000 in belongings. Your landlord's insurance does NOT cover your stuff.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .easy, cadence: .story,
            estimatedImpact: "Asset protection", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "move_rent_1", instruction: "Get 3 renter's insurance quotes", verification: .selfReport, xpReward: 60),
                QuestStep(id: "move_rent_2", instruction: "Choose a policy and sign up", verification: .selfReport, xpReward: 90)
            ],
            zone: .savingsCitadel),
        QuestDefinition(
            id: "life_move_emergency", title: "First Month Emergency", subtitle: "Save 1 extra month of rent as a buffer",
            description: "Moving is expensive and surprises happen. Having one extra month of rent saved gives you a safety net during the transition.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .medium, cadence: .story,
            estimatedImpact: "$500-2,000 buffer", estimatedTime: "Variable", verification: .selfReport,
            baseXP: 300, scratchCardChance: 1.0, essenceReward: 20,
            steps: [
                QuestStep(id: "move_emerg_1", instruction: "Calculate one month of rent + utilities", verification: .selfReport, xpReward: 50),
                QuestStep(id: "move_emerg_2", instruction: "Save that amount in a separate buffer fund", verification: .selfReport, xpReward: 250)
            ],
            zone: .savingsCitadel),
        QuestDefinition(
            id: "life_move_deposit", title: "The Deposit Recovery", subtitle: "Request your old security deposit back",
            description: "Your old security deposit is YOUR money. Document the move-out condition, request the deposit, and follow up if it doesn't arrive within 30 days.",
            category: .moneyRecovery, archetype: .interaction, difficulty: .easy, cadence: .story,
            estimatedImpact: "$300-2,000", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "move_dep_1", instruction: "Document your old apartment's condition with photos", verification: .selfReport, xpReward: 30),
                QuestStep(id: "move_dep_2", instruction: "Send a formal deposit return request to your landlord", verification: .selfReport, xpReward: 60),
                QuestStep(id: "move_dep_3", instruction: "Follow up until deposit is returned", verification: .selfReport, xpReward: 60)
            ],
            zone: .savingsCitadel),
    ]

    // MARK: - New Job

    private static let newJobQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "life_job_negotiate", title: "Salary Negotiation Quest", subtitle: "Research and prepare for salary negotiation",
            description: "The best time to negotiate is before you accept. Research market rates, prepare your talking points, and know your minimum. This conversation is worth thousands.",
            category: .incomeEarning, archetype: .interaction, difficulty: .hard, cadence: .story,
            estimatedImpact: "$2,000-15,000+", estimatedTime: "1 hour", verification: .selfReport,
            baseXP: 500, scratchCardChance: 1.0, essenceReward: 40, bossHP: 40,
            steps: [
                QuestStep(id: "job_neg_1", instruction: "Research market salary for your new role", verification: .selfReport, xpReward: 80),
                QuestStep(id: "job_neg_2", instruction: "Prepare 3 talking points for why you deserve more", verification: .selfReport, xpReward: 80),
                QuestStep(id: "job_neg_3", instruction: "Negotiate your salary or total compensation", verification: .selfReport, xpReward: 240),
                QuestStep(id: "job_neg_4", instruction: "Get the final offer in writing", verification: .selfReport, xpReward: 100)
            ],
            zone: .incomeFrontier, tiktokMoment: "Negotiated my starting salary at my new job"),
        QuestDefinition(
            id: "life_job_benefits", title: "Benefits Optimization", subtitle: "Maximize 401k match, HSA, and all benefits",
            description: "New job benefits are free money waiting to be claimed. Max your 401k match, set up HSA contributions, and understand every benefit available.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .medium, cadence: .story,
            estimatedImpact: "$1,000-5,000+/yr", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 350, scratchCardChance: 1.0, essenceReward: 25,
            steps: [
                QuestStep(id: "job_ben_1", instruction: "Read your full benefits package", verification: .selfReport, xpReward: 50),
                QuestStep(id: "job_ben_2", instruction: "Set 401k contribution to at least the full employer match", verification: .selfReport, xpReward: 120),
                QuestStep(id: "job_ben_3", instruction: "Enroll in HSA/FSA if available", verification: .selfReport, xpReward: 80),
                QuestStep(id: "job_ben_4", instruction: "Check for additional perks (commuter benefits, gym, education)", verification: .selfReport, xpReward: 100)
            ],
            zone: .incomeFrontier),
        QuestDefinition(
            id: "life_job_commute", title: "Commute Cost Calc", subtitle: "Compare transit options for your new commute",
            description: "Your commute cost is a hidden salary reduction. Compare driving, transit, biking — the cheapest option might save $200+/month.",
            category: .moneyRecovery, archetype: .exploration, difficulty: .easy, cadence: .story,
            estimatedImpact: "$100-300/mo", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "job_comm_1", instruction: "Calculate driving cost (gas + parking + wear)", verification: .selfReport, xpReward: 40),
                QuestStep(id: "job_comm_2", instruction: "Check transit pass costs and time", verification: .selfReport, xpReward: 40),
                QuestStep(id: "job_comm_3", instruction: "Choose the best cost/time balance", verification: .selfReport, xpReward: 70)
            ],
            zone: .budgetForge),
        QuestDefinition(
            id: "life_job_wardrobe", title: "Work Wardrobe Budget", subtitle: "Set a clothing budget for your new role",
            description: "New job often means new clothes. Set a budget before you shop. Buy versatile pieces that mix and match — you need fewer items than you think.",
            category: .spendingDefense, archetype: .escort, difficulty: .easy, cadence: .story,
            estimatedImpact: "$100-300 saved", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 100, scratchCardChance: 0.5, essenceReward: 5,
            steps: [
                QuestStep(id: "job_ward_1", instruction: "Assess what you already own that works", verification: .selfReport, xpReward: 20),
                QuestStep(id: "job_ward_2", instruction: "Set a total wardrobe budget for the transition", verification: .selfReport, xpReward: 40),
                QuestStep(id: "job_ward_3", instruction: "Shop within budget for versatile pieces", verification: .selfReport, xpReward: 40)
            ],
            zone: .budgetForge),
        QuestDefinition(
            id: "life_job_first_paycheck", title: "The First Paycheck Plan", subtitle: "Allocate your first paycheck before it arrives",
            description: "Your first paycheck at a new job feels like a windfall. Plan every dollar BEFORE it hits your account to prevent the 'new money' spending spree.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .easy, cadence: .story,
            estimatedImpact: "Structural", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "job_pay_1", instruction: "Calculate your expected first net paycheck", verification: .selfReport, xpReward: 30),
                QuestStep(id: "job_pay_2", instruction: "Allocate every dollar: bills, savings, fun, debt", verification: .selfReport, xpReward: 60),
                QuestStep(id: "job_pay_3", instruction: "Set up auto-transfers before payday", verification: .selfReport, xpReward: 60)
            ],
            zone: .budgetForge),
    ]

    // MARK: - New Relationship

    private static let newRelationshipQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "life_rel_money_talk", title: "The Money Talk", subtitle: "Discuss finances openly with your partner",
            description: "Money is the #1 cause of relationship stress. Having an open conversation early prevents 90% of money fights. Start with curiosity, not judgment.",
            category: .socialQuests, archetype: .interaction, difficulty: .medium, cadence: .story,
            estimatedImpact: "Relationship foundation", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "rel_talk_1", instruction: "Share your financial goals with your partner", verification: .selfReport, xpReward: 60),
                QuestStep(id: "rel_talk_2", instruction: "Ask about their financial goals and concerns", verification: .selfReport, xpReward: 60),
                QuestStep(id: "rel_talk_3", instruction: "Discuss spending styles and money values", verification: .selfReport, xpReward: 130)
            ],
            zone: .savingsCitadel),
        QuestDefinition(
            id: "life_rel_split", title: "Expense Split System", subtitle: "Set up a fair expense splitting system",
            description: "50/50 isn't always fair. If incomes differ, proportional splitting feels more equitable. Agree on a system that works for both of you.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .easy, cadence: .story,
            estimatedImpact: "Fairness", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "rel_split_1", instruction: "List shared expenses (rent, food, utilities, dates)", verification: .selfReport, xpReward: 30),
                QuestStep(id: "rel_split_2", instruction: "Agree on a split method (50/50, proportional, alternating)", verification: .selfReport, xpReward: 60),
                QuestStep(id: "rel_split_3", instruction: "Set up a system to track and settle (Splitwise, joint account, etc.)", verification: .selfReport, xpReward: 60)
            ],
            zone: .budgetForge),
        QuestDefinition(
            id: "life_rel_date_budget", title: "Date Night Budget", subtitle: "Set a monthly dating budget together",
            description: "Early relationship spending can spiral fast. Set a monthly date budget together — it's not about limiting fun, it's about being intentional.",
            category: .spendingDefense, archetype: .escort, difficulty: .easy, cadence: .story,
            estimatedImpact: "$50-200/mo saved", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "rel_date_1", instruction: "Discuss monthly dating budget with your partner", verification: .selfReport, xpReward: 40),
                QuestStep(id: "rel_date_2", instruction: "Plan a mix of free and paid date ideas", verification: .selfReport, xpReward: 40),
                QuestStep(id: "rel_date_3", instruction: "Stick to the budget for one month", verification: .selfReport, xpReward: 40)
            ],
            zone: .budgetForge),
        QuestDefinition(
            id: "life_rel_joint_goal", title: "Joint Goals Quest", subtitle: "Create 1 shared financial goal together",
            description: "A shared goal bonds you financially. A vacation fund, a savings target, a debt payoff — working toward something together strengthens both the relationship and your finances.",
            category: .socialQuests, archetype: .interaction, difficulty: .easy, cadence: .story,
            estimatedImpact: "Shared purpose", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "rel_goal_1", instruction: "Discuss what you'd both like to save for", verification: .selfReport, xpReward: 40),
                QuestStep(id: "rel_goal_2", instruction: "Set a specific amount and deadline", verification: .selfReport, xpReward: 50),
                QuestStep(id: "rel_goal_3", instruction: "Open a joint savings fund and make first deposit", verification: .selfReport, xpReward: 60)
            ],
            zone: .savingsCitadel),
        QuestDefinition(
            id: "life_rel_emergency_contact", title: "Emergency Contact Finance", subtitle: "Share key financial info with your partner",
            description: "If something happened to you tomorrow, could your partner access your accounts? Share key financial info — not for control, but for safety.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .medium, cadence: .story,
            estimatedImpact: "Safety", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.8, essenceReward: 12,
            steps: [
                QuestStep(id: "rel_emerg_1", instruction: "List your key financial accounts and contacts", verification: .selfReport, xpReward: 50),
                QuestStep(id: "rel_emerg_2", instruction: "Share this info securely with your partner", verification: .selfReport, xpReward: 80),
                QuestStep(id: "rel_emerg_3", instruction: "Ask them to do the same", verification: .selfReport, xpReward: 70)
            ],
            zone: .savingsCitadel),
    ]

    // MARK: - Having a Baby

    private static let havingBabyQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "life_baby_blueprint", title: "Baby Budget Blueprint", subtitle: "Estimate year-1 costs of having a baby",
            description: "The average first year costs $12,000-15,000. Diapers, formula, daycare, medical — plan for the reality so it doesn't blindside your budget.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .medium, cadence: .story,
            estimatedImpact: "Preparedness", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 300, scratchCardChance: 1.0, essenceReward: 20,
            steps: [
                QuestStep(id: "baby_blue_1", instruction: "Research average year-1 baby costs in your area", verification: .selfReport, xpReward: 60),
                QuestStep(id: "baby_blue_2", instruction: "Create a monthly baby budget", verification: .selfReport, xpReward: 100),
                QuestStep(id: "baby_blue_3", instruction: "Identify which costs can be reduced (used items, hand-me-downs)", verification: .selfReport, xpReward: 140)
            ],
            zone: .savingsCitadel),
        QuestDefinition(
            id: "life_baby_insurance", title: "Insurance Upgrade", subtitle: "Add dependent to your health insurance",
            description: "Adding a dependent changes your insurance math. Compare plans, check if your current plan covers everything, and prepare for increased premiums.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .medium, cadence: .story,
            estimatedImpact: "Coverage", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "baby_ins_1", instruction: "Review your current health plan's maternity coverage", verification: .selfReport, xpReward: 50),
                QuestStep(id: "baby_ins_2", instruction: "Calculate cost difference of adding a dependent", verification: .selfReport, xpReward: 80),
                QuestStep(id: "baby_ins_3", instruction: "Make the necessary plan changes", verification: .selfReport, xpReward: 120)
            ],
            zone: .savingsCitadel),
        QuestDefinition(
            id: "life_baby_fund", title: "The Baby Fund", subtitle: "Save $1,000 in a dedicated baby fund",
            description: "$1,000 won't cover everything, but it's a crucial buffer for unexpected baby expenses. Start building it now, before the baby arrives.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .hard, cadence: .story,
            estimatedImpact: "$1,000 buffer", estimatedTime: "Variable", verification: .selfReport,
            baseXP: 400, scratchCardChance: 1.0, essenceReward: 30, bossHP: 30,
            steps: [
                QuestStep(id: "baby_fund_1", instruction: "Open a dedicated baby savings fund", verification: .selfReport, xpReward: 50),
                QuestStep(id: "baby_fund_2", instruction: "Save $1,000 in the fund", verification: .selfReport, xpReward: 350)
            ],
            zone: .savingsCitadel, tiktokMoment: "Saved $1,000 in our baby fund before the due date"),
        QuestDefinition(
            id: "life_baby_used_vs_new", title: "Used vs New Calc", subtitle: "Compare baby gear costs: used vs new",
            description: "Babies outgrow everything in months. A used crib, stroller, and clothes cost 60-80% less than new. Only car seats MUST be bought new.",
            category: .spendingDefense, archetype: .exploration, difficulty: .easy, cadence: .story,
            estimatedImpact: "$500-2,000 saved", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "baby_used_1", instruction: "List essential baby gear needed", verification: .selfReport, xpReward: 30),
                QuestStep(id: "baby_used_2", instruction: "Price each item new vs used/hand-me-down", verification: .selfReport, xpReward: 50),
                QuestStep(id: "baby_used_3", instruction: "Buy used for everything except car seats", verification: .selfReport, xpReward: 70)
            ],
            zone: .budgetForge),
        QuestDefinition(
            id: "life_baby_leave", title: "Parental Leave Prep", subtitle: "Plan for reduced income during leave",
            description: "Parental leave often means reduced or zero income. Plan your finances to cover the gap — save extra, reduce spending, and know your benefits.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .medium, cadence: .story,
            estimatedImpact: "Income gap coverage", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "baby_leave_1", instruction: "Check your employer's parental leave policy", verification: .selfReport, xpReward: 40),
                QuestStep(id: "baby_leave_2", instruction: "Calculate the income gap during leave", verification: .selfReport, xpReward: 60),
                QuestStep(id: "baby_leave_3", instruction: "Save to cover the gap or reduce expenses to match", verification: .selfReport, xpReward: 150)
            ],
            zone: .savingsCitadel),
    ]

    // MARK: - Buying a Car

    private static let buyingCarQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "life_car_preapproval", title: "The Pre-Approval Quest", subtitle: "Get a loan pre-approval before visiting dealers",
            description: "Dealer financing often has higher rates. Getting pre-approved from your bank or credit union gives you negotiating power and a rate to beat.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .medium, cadence: .story,
            estimatedImpact: "$500-3,000 saved on interest", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "car_pre_1", instruction: "Check your credit score", verification: .selfReport, xpReward: 30),
                QuestStep(id: "car_pre_2", instruction: "Apply for pre-approval from your bank or credit union", verification: .selfReport, xpReward: 100),
                QuestStep(id: "car_pre_3", instruction: "Compare with at least one online lender", verification: .selfReport, xpReward: 120)
            ],
            zone: .savingsCitadel),
        QuestDefinition(
            id: "life_car_insurance", title: "Insurance Shopping Spree", subtitle: "Get 5 car insurance quotes before buying",
            description: "Insurance costs vary wildly between companies. Getting 5 quotes before buying ensures you don't overpay by hundreds per year.",
            category: .moneyRecovery, archetype: .exploration, difficulty: .medium, cadence: .story,
            estimatedImpact: "$300-800/yr saved", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "car_ins_1", instruction: "Get quotes from 5 different insurance companies", verification: .selfReport, xpReward: 120),
                QuestStep(id: "car_ins_2", instruction: "Compare coverage levels, not just price", verification: .selfReport, xpReward: 60),
                QuestStep(id: "car_ins_3", instruction: "Choose the best value option", verification: .selfReport, xpReward: 70)
            ],
            zone: .savingsCitadel),
        QuestDefinition(
            id: "life_car_hidden_costs", title: "The Hidden Costs", subtitle: "Calculate total ownership cost beyond the sticker price",
            description: "The sticker price is just the beginning. Insurance, maintenance, fuel, registration, depreciation — the true cost of ownership is 50-100% more.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .easy, cadence: .story,
            estimatedImpact: "Complete picture", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "car_hidden_1", instruction: "Calculate monthly insurance cost", verification: .selfReport, xpReward: 25),
                QuestStep(id: "car_hidden_2", instruction: "Estimate annual maintenance and fuel costs", verification: .selfReport, xpReward: 50),
                QuestStep(id: "car_hidden_3", instruction: "Add registration, taxes, and depreciation", verification: .selfReport, xpReward: 35),
                QuestStep(id: "car_hidden_4", instruction: "Calculate true monthly cost of ownership", verification: .selfReport, xpReward: 40)
            ],
            zone: .budgetForge),
        QuestDefinition(
            id: "life_car_negotiate", title: "Negotiation Prep", subtitle: "Research dealer tactics before walking in",
            description: "Dealers are professional negotiators. You need to be prepared. Research tactics, know the invoice price, and never negotiate on monthly payments.",
            category: .incomeEarning, archetype: .interaction, difficulty: .medium, cadence: .story,
            estimatedImpact: "$1,000-5,000 saved", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 300, scratchCardChance: 1.0, essenceReward: 20,
            steps: [
                QuestStep(id: "car_neg_1", instruction: "Research the invoice price of your target car", verification: .selfReport, xpReward: 60),
                QuestStep(id: "car_neg_2", instruction: "Learn 3 common dealer negotiation tactics", verification: .selfReport, xpReward: 60),
                QuestStep(id: "car_neg_3", instruction: "Set your maximum price and walk-away point", verification: .selfReport, xpReward: 80),
                QuestStep(id: "car_neg_4", instruction: "Negotiate and hold firm on your limit", verification: .selfReport, xpReward: 100)
            ],
            zone: .incomeFrontier),
        QuestDefinition(
            id: "life_car_financing", title: "The Financing Detective", subtitle: "Compare at least 3 loan terms before signing",
            description: "A 1% difference in interest rate on a $25,000 car loan = $700 over 5 years. Compare terms from your pre-approval, dealer, and online lender.",
            category: .financialLiteracy, archetype: .exploration, difficulty: .easy, cadence: .story,
            estimatedImpact: "$500-2,000 saved", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "car_fin_1", instruction: "Compare your pre-approval rate with the dealer rate", verification: .selfReport, xpReward: 40),
                QuestStep(id: "car_fin_2", instruction: "Check one online auto lender", verification: .selfReport, xpReward: 40),
                QuestStep(id: "car_fin_3", instruction: "Choose the lowest total cost option (not just monthly payment)", verification: .selfReport, xpReward: 70)
            ],
            zone: .savingsCitadel),
    ]

    // MARK: - Starting a Business

    private static let startingBusinessQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "life_biz_runway", title: "The Runway Calculator", subtitle: "Calculate how many months you can survive",
            description: "Before going all-in, know your runway. Monthly expenses ÷ savings = months you can survive without income. This number determines your timeline.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .medium, cadence: .story,
            estimatedImpact: "Critical awareness", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "biz_run_1", instruction: "Calculate your monthly essential expenses", verification: .selfReport, xpReward: 50),
                QuestStep(id: "biz_run_2", instruction: "Divide your savings by that number", verification: .selfReport, xpReward: 50),
                QuestStep(id: "biz_run_3", instruction: "Set a milestone: 'I need revenue by month X'", verification: .selfReport, xpReward: 150)
            ],
            zone: .incomeFrontier),
        QuestDefinition(
            id: "life_biz_separate", title: "Business vs Personal", subtitle: "Separate business and personal finances",
            description: "Mixing business and personal finances is a recipe for tax nightmares. Open a separate business checking account on day one.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .easy, cadence: .story,
            estimatedImpact: "Tax clarity", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.8, essenceReward: 12,
            steps: [
                QuestStep(id: "biz_sep_1", instruction: "Open a dedicated business checking account", verification: .selfReport, xpReward: 100),
                QuestStep(id: "biz_sep_2", instruction: "Set up a system to track business expenses separately", verification: .selfReport, xpReward: 100)
            ],
            zone: .incomeFrontier),
        QuestDefinition(
            id: "life_biz_entity", title: "Tax Entity Research", subtitle: "Research LLC vs sole proprietorship",
            description: "Your business structure affects taxes, liability, and complexity. Research the options before defaulting to sole proprietorship.",
            category: .financialLiteracy, archetype: .exploration, difficulty: .medium, cadence: .story,
            estimatedImpact: "Legal protection + tax savings", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "biz_ent_1", instruction: "Research sole proprietorship pros/cons", verification: .selfReport, xpReward: 40),
                QuestStep(id: "biz_ent_2", instruction: "Research LLC pros/cons", verification: .selfReport, xpReward: 40),
                QuestStep(id: "biz_ent_3", instruction: "Decide on your entity type (or consult an accountant)", verification: .selfReport, xpReward: 170)
            ],
            zone: .incomeFrontier),
        QuestDefinition(
            id: "life_biz_first_dollar", title: "First Customer Quest", subtitle: "Earn your first $1 from a customer",
            description: "The most important dollar in business is the first one. It proves someone will pay for what you offer. Find one customer and make the sale.",
            category: .incomeEarning, archetype: .delivery, difficulty: .hard, cadence: .story,
            estimatedImpact: "Proof of concept", estimatedTime: "Variable", verification: .selfReport,
            baseXP: 400, scratchCardChance: 1.0, essenceReward: 30, bossHP: 30,
            steps: [
                QuestStep(id: "biz_first_1", instruction: "Define your product or service clearly", verification: .selfReport, xpReward: 50),
                QuestStep(id: "biz_first_2", instruction: "Find your first potential customer", verification: .selfReport, xpReward: 100),
                QuestStep(id: "biz_first_3", instruction: "Make the sale and collect payment", verification: .selfReport, xpReward: 250)
            ],
            zone: .incomeFrontier, tiktokMoment: "Earned my first $1 from my own business"),
        QuestDefinition(
            id: "life_biz_double_emergency", title: "The Emergency-Emergency Fund", subtitle: "Double your emergency fund before going full-time",
            description: "A business needs a bigger safety net. Double your personal emergency fund before making the leap. This is the difference between surviving and thriving.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .legendary, cadence: .story,
            estimatedImpact: "6+ months runway", estimatedTime: "Variable", verification: .selfReport,
            baseXP: 600, scratchCardChance: 1.0, essenceReward: 50, bossHP: 50,
            steps: [
                QuestStep(id: "biz_emerg_1", instruction: "Calculate your current emergency fund coverage in months", verification: .selfReport, xpReward: 50),
                QuestStep(id: "biz_emerg_2", instruction: "Set a target to double it", verification: .selfReport, xpReward: 50),
                QuestStep(id: "biz_emerg_3", instruction: "Reach the doubled emergency fund target", verification: .selfReport, xpReward: 500)
            ],
            zone: .legacy),
    ]
}
