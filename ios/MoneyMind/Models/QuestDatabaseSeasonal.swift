import Foundation

extension QuestDatabase {

    static let expandedSeasonalQuests: [QuestDefinition] = januaryQuests + februaryQuests + marchQuests + aprilQuests + mayQuests + juneQuests + julyQuests + augustQuests + septemberQuests + octoberQuests + novemberQuests + decemberQuests

    // MARK: - January: New Year Reset

    private static let januaryQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_jan_purge", title: "Annual Subscription Purge", subtitle: "Review ALL subscriptions for the new year",
            description: "New year, clean slate. Go through every single subscription — streaming, apps, memberships — and cancel anything you haven't used in the last 30 days.",
            category: .moneyRecovery, archetype: .kill, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$200-600/yr", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "jan_purge_1", instruction: "List every active subscription", verification: .selfReport, xpReward: 40),
                QuestStep(id: "jan_purge_2", instruction: "Rate each: essential, nice-to-have, or unused", verification: .selfReport, xpReward: 40),
                QuestStep(id: "jan_purge_3", instruction: "Cancel all unused subscriptions", verification: .selfReport, xpReward: 120)
            ],
            zone: .budgetForge, seasonalMonths: [1], tiktokMoment: "New year subscription purge — saving $X/month"),
        QuestDefinition(
            id: "seasonal_jan_blueprint", title: "365-Day Savings Blueprint", subtitle: "Create a yearly budget and savings plan",
            description: "Map out your entire financial year. Set monthly savings targets, plan for big expenses, and create the blueprint for your best financial year yet.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Year-long structure", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 300, scratchCardChance: 1.0, essenceReward: 20,
            steps: [
                QuestStep(id: "jan_blue_1", instruction: "Calculate your expected annual income", verification: .selfReport, xpReward: 40),
                QuestStep(id: "jan_blue_2", instruction: "List known big expenses by month", verification: .selfReport, xpReward: 60),
                QuestStep(id: "jan_blue_3", instruction: "Set monthly savings targets", verification: .selfReport, xpReward: 100),
                QuestStep(id: "jan_blue_4", instruction: "Write down 3 financial goals for the year", verification: .selfReport, xpReward: 100)
            ],
            zone: .savingsCitadel, seasonalMonths: [1]),
        QuestDefinition(
            id: "seasonal_jan_resolution", title: "Financial Resolution Quest", subtitle: "Set 3 specific money goals for the year",
            description: "Resolutions fail because they're vague. 'Save more' doesn't work. '$200/month into HYSA by auto-transfer' does. Set 3 specific, measurable goals.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Goal clarity", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "jan_res_1", instruction: "Write 3 financial goals with specific numbers", verification: .selfReport, xpReward: 50),
                QuestStep(id: "jan_res_2", instruction: "For each goal, write the first action step", verification: .selfReport, xpReward: 50),
                QuestStep(id: "jan_res_3", instruction: "Share one goal with someone for accountability", verification: .selfReport, xpReward: 50)
            ],
            zone: .awakening, seasonalMonths: [1]),
        QuestDefinition(
            id: "seasonal_jan_credit_yoy", title: "Credit Score Checkpoint", subtitle: "Check your credit score and compare year-over-year",
            description: "Start the year by knowing your number. Compare it to last January — has it gone up or down? This single metric tracks your financial health trajectory.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Awareness", estimatedTime: "5 minutes", verification: .selfReport,
            baseXP: 100, scratchCardChance: 0.5, essenceReward: 5,
            steps: [
                QuestStep(id: "jan_credit_1", instruction: "Check your current credit score", verification: .selfReport, xpReward: 40),
                QuestStep(id: "jan_credit_2", instruction: "Note the change from last year", verification: .selfReport, xpReward: 60)
            ],
            zone: .awakening, seasonalMonths: [1]),
        QuestDefinition(
            id: "seasonal_jan_fresh_start", title: "The Fresh Start", subtitle: "Close unused bank accounts and consolidate",
            description: "Old checking accounts with $3.47 in them, savings accounts you forgot about — close them, consolidate, and simplify your financial life.",
            category: .moneyRecovery, archetype: .kill, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Simplification", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.8, essenceReward: 12,
            steps: [
                QuestStep(id: "jan_fresh_1", instruction: "List all bank accounts you have", verification: .selfReport, xpReward: 30),
                QuestStep(id: "jan_fresh_2", instruction: "Identify accounts you no longer use", verification: .selfReport, xpReward: 30),
                QuestStep(id: "jan_fresh_3", instruction: "Transfer balances and close unused accounts", verification: .selfReport, xpReward: 140)
            ],
            zone: .budgetForge, seasonalMonths: [1]),
    ]

    // MARK: - February: Tax Prep & Love

    private static let februaryQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_feb_tax_docs", title: "Tax Document Treasure Hunt", subtitle: "Gather all W-2s, 1099s, and tax documents",
            description: "Tax documents trickle in throughout January and February. Hunt them all down now so filing is painless. Check mail, email, and employer portals.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Preparedness", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "feb_tax_1", instruction: "Check for W-2s from all employers", verification: .selfReport, xpReward: 30),
                QuestStep(id: "feb_tax_2", instruction: "Gather all 1099s (freelance, interest, investments)", verification: .selfReport, xpReward: 50),
                QuestStep(id: "feb_tax_3", instruction: "Organize all documents in one folder", verification: .selfReport, xpReward: 70)
            ],
            zone: .budgetForge, seasonalMonths: [2]),
        QuestDefinition(
            id: "seasonal_feb_money_date", title: "Couples Money Date", subtitle: "Have a 30-minute money talk with your partner",
            description: "February is about love — and nothing kills love faster than money fights. Schedule 30 minutes to talk finances over wine, not over a bill.",
            category: .socialQuests, archetype: .interaction, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Relationship health", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "feb_date_1", instruction: "Schedule a money date with your partner", verification: .selfReport, xpReward: 40),
                QuestStep(id: "feb_date_2", instruction: "Review your combined spending from last month", verification: .selfReport, xpReward: 80),
                QuestStep(id: "feb_date_3", instruction: "Set one shared financial goal", verification: .selfReport, xpReward: 130)
            ],
            zone: .savingsCitadel, seasonalMonths: [2]),
        QuestDefinition(
            id: "seasonal_feb_valentine", title: "Valentine Budget Shield", subtitle: "Set a V-Day spending limit before shopping",
            description: "The average American spends $185 on Valentine's Day. Set your limit BEFORE you start shopping. Thoughtful beats expensive every time.",
            category: .spendingDefense, archetype: .escort, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$50-150 saved", estimatedTime: "5 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "feb_val_1", instruction: "Set your total Valentine's Day budget", verification: .selfReport, xpReward: 40),
                QuestStep(id: "feb_val_2", instruction: "Shop within your budget — no guilt upgrades", verification: .selfReport, xpReward: 80)
            ],
            zone: .budgetForge, seasonalMonths: [2]),
        QuestDefinition(
            id: "seasonal_feb_refund_plan", title: "Tax Refund Allocation Plan", subtitle: "Plan how to use your tax refund before it arrives",
            description: "Don't let your refund evaporate. Decide NOW: 50% to savings, 30% to debt, 20% to something fun. Allocate it before the money hits your account.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Strategic allocation", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "feb_refund_1", instruction: "Estimate your expected tax refund", verification: .selfReport, xpReward: 30),
                QuestStep(id: "feb_refund_2", instruction: "Allocate percentages: savings, debt, fun", verification: .selfReport, xpReward: 60),
                QuestStep(id: "feb_refund_3", instruction: "Set up the transfers as soon as the refund arrives", verification: .selfReport, xpReward: 60)
            ],
            zone: .budgetForge, seasonalMonths: [2]),
        QuestDefinition(
            id: "seasonal_feb_deduction", title: "The Deduction Detective", subtitle: "Find 3 tax deductions you might be missing",
            description: "Most people miss deductions they're eligible for. Charitable donations, home office, student loan interest, medical expenses — research what applies to you.",
            category: .moneyRecovery, archetype: .exploration, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "$100-2,000+", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "feb_ded_1", instruction: "Research common tax deductions for your situation", verification: .selfReport, xpReward: 50),
                QuestStep(id: "feb_ded_2", instruction: "Identify at least 3 deductions you might qualify for", verification: .selfReport, xpReward: 100),
                QuestStep(id: "feb_ded_3", instruction: "Gather supporting documents for each", verification: .selfReport, xpReward: 100)
            ],
            zone: .savingsCitadel, seasonalMonths: [2]),
    ]

    // MARK: - March: Spring Cleaning

    private static let marchQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_mar_spring_clean", title: "Financial Spring Clean", subtitle: "Organize all financial files and documents",
            description: "Spring cleaning isn't just for closets. Organize your financial documents: tax returns, insurance policies, account statements. Digital and physical.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Organization", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "mar_clean_1", instruction: "Create folders for each financial category", verification: .selfReport, xpReward: 30),
                QuestStep(id: "mar_clean_2", instruction: "Sort and file all financial documents", verification: .selfReport, xpReward: 60),
                QuestStep(id: "mar_clean_3", instruction: "Shred old documents you no longer need", verification: .selfReport, xpReward: 60)
            ],
            zone: .budgetForge, seasonalMonths: [3]),
        QuestDefinition(
            id: "seasonal_mar_sub_prune", title: "Subscription Garden Prune", subtitle: "Cancel 1+ subscriptions you've been meaning to cancel",
            description: "Spring is for pruning. That subscription you've been 'meaning to cancel' for months? Today's the day. Every dollar saved is a dollar earned.",
            category: .moneyRecovery, archetype: .kill, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$10-50/mo", estimatedTime: "5 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "mar_prune_1", instruction: "Identify at least 1 subscription to cancel", verification: .selfReport, xpReward: 30),
                QuestStep(id: "mar_prune_2", instruction: "Cancel it right now", verification: .selfReport, xpReward: 90)
            ],
            zone: .budgetForge, seasonalMonths: [3]),
        QuestDefinition(
            id: "seasonal_mar_insurance", title: "Insurance Refresh", subtitle: "Get 2 new insurance quotes and compare",
            description: "Insurance rates change yearly. Getting fresh quotes takes 15 minutes and could save hundreds. Car, home, renters — pick one and shop.",
            category: .moneyRecovery, archetype: .exploration, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "$200-500/yr", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "mar_ins_1", instruction: "Choose an insurance policy to shop", verification: .selfReport, xpReward: 30),
                QuestStep(id: "mar_ins_2", instruction: "Get 2 competing quotes", verification: .selfReport, xpReward: 100),
                QuestStep(id: "mar_ins_3", instruction: "Switch if better, or use quotes to negotiate current rate", verification: .selfReport, xpReward: 120)
            ],
            zone: .savingsCitadel, seasonalMonths: [3]),
        QuestDefinition(
            id: "seasonal_mar_warranty", title: "The Warranty Audit", subtitle: "Check warranties on all major electronics",
            description: "That expensive gadget that broke? It might still be under warranty. Check every major electronic purchase from the last 2 years.",
            category: .moneyRecovery, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$50-300", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "mar_war_1", instruction: "List all major electronics purchased in the last 2 years", verification: .selfReport, xpReward: 30),
                QuestStep(id: "mar_war_2", instruction: "Check warranty status for each", verification: .selfReport, xpReward: 50),
                QuestStep(id: "mar_war_3", instruction: "File any eligible warranty claims", verification: .selfReport, xpReward: 40)
            ],
            zone: .budgetForge, seasonalMonths: [3]),
        QuestDefinition(
            id: "seasonal_mar_beneficiary", title: "Beneficiary Update", subtitle: "Review life insurance and 401k beneficiaries",
            description: "Life changes — marriages, births, divorces — mean your beneficiaries might be outdated. A 5-minute check ensures your money goes where you want.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Protection", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 100, scratchCardChance: 0.5, essenceReward: 5,
            steps: [
                QuestStep(id: "mar_ben_1", instruction: "Check beneficiaries on your 401k/IRA", verification: .selfReport, xpReward: 40),
                QuestStep(id: "mar_ben_2", instruction: "Check beneficiaries on any life insurance", verification: .selfReport, xpReward: 30),
                QuestStep(id: "mar_ben_3", instruction: "Update any that are outdated", verification: .selfReport, xpReward: 30)
            ],
            zone: .savingsCitadel, seasonalMonths: [3]),
    ]

    // MARK: - April: Tax Season Final

    private static let aprilQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_apr_file", title: "Tax Filing Quest", subtitle: "File your taxes",
            description: "The deadline is real. File your taxes — whether yourself or with a professional. Early filers get refunds faster and avoid the stress spiral.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Compliance + refund", estimatedTime: "1-3 hours", verification: .selfReport,
            baseXP: 400, scratchCardChance: 1.0, essenceReward: 30, bossHP: 20,
            steps: [
                QuestStep(id: "apr_file_1", instruction: "Gather all tax documents", verification: .selfReport, xpReward: 50),
                QuestStep(id: "apr_file_2", instruction: "File your taxes (self or professional)", verification: .selfReport, xpReward: 250),
                QuestStep(id: "apr_file_3", instruction: "Set up direct deposit for any refund", verification: .selfReport, xpReward: 100)
            ],
            zone: .savingsCitadel, seasonalMonths: [4]),
        QuestDefinition(
            id: "seasonal_apr_refund_split", title: "Refund Split Strategy", subtitle: "Save at least 50% of your tax refund",
            description: "The average refund is $3,000. Saving at least half turns a windfall into wealth. The other half? Enjoy it guilt-free.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$500-1,500+", estimatedTime: "5 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.8, essenceReward: 15,
            steps: [
                QuestStep(id: "apr_split_1", instruction: "When refund arrives, transfer 50%+ to savings", verification: .selfReport, xpReward: 150),
                QuestStep(id: "apr_split_2", instruction: "Allocate the rest intentionally", verification: .selfReport, xpReward: 50)
            ],
            zone: .savingsCitadel, seasonalMonths: [4]),
        QuestDefinition(
            id: "seasonal_apr_portfolio", title: "Quarterly Portfolio Check", subtitle: "Review your investments for Q1",
            description: "Check your investment performance, rebalance if needed, and ensure your allocation still matches your goals. Quick quarterly check keeps you on track.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Portfolio health", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.8, essenceReward: 12,
            steps: [
                QuestStep(id: "apr_port_1", instruction: "Log into your investment accounts", verification: .selfReport, xpReward: 30),
                QuestStep(id: "apr_port_2", instruction: "Review performance and allocation", verification: .selfReport, xpReward: 80),
                QuestStep(id: "apr_port_3", instruction: "Rebalance if any category is off by 5%+", verification: .selfReport, xpReward: 90)
            ],
            zone: .incomeFrontier, seasonalMonths: [4]),
        QuestDefinition(
            id: "seasonal_apr_dragon_slayer", title: "The Tax Dragon Slayer", subtitle: "File taxes before April 15",
            description: "Don't be a last-minute filer. Slay the tax dragon early and enjoy the peace of mind that comes with being done before the deadline.",
            category: .financialLiteracy, archetype: .bossBattle, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Peace of mind", estimatedTime: "Variable", verification: .selfReport,
            baseXP: 300, scratchCardChance: 1.0, essenceReward: 20,
            steps: [
                QuestStep(id: "apr_drag_1", instruction: "File your taxes before April 15", verification: .selfReport, xpReward: 300)
            ],
            zone: .savingsCitadel, seasonalMonths: [4], tiktokMoment: "Filed my taxes early. Tax Dragon: slain."),
        QuestDefinition(
            id: "seasonal_apr_q1_review", title: "Q1 Financial Review", subtitle: "Review Q1 spending vs budget",
            description: "The first quarter is done. How did you do? Compare your actual spending to your budget across all categories. Adjust for Q2.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Course correction", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "apr_q1_1", instruction: "Calculate total spending for Jan-Mar", verification: .selfReport, xpReward: 40),
                QuestStep(id: "apr_q1_2", instruction: "Compare to your budget in each category", verification: .selfReport, xpReward: 50),
                QuestStep(id: "apr_q1_3", instruction: "Adjust Q2 budget based on learnings", verification: .selfReport, xpReward: 60)
            ],
            zone: .budgetForge, seasonalMonths: [4]),
    ]

    // MARK: - May: Summer Planning

    private static let mayQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_may_summer", title: "Summer Budget Blueprint", subtitle: "Plan summer spending before it starts",
            description: "Summer spending sneaks up: vacations, BBQs, activities. Plan it now so you enjoy summer without the September credit card surprise.",
            category: .spendingDefense, archetype: .escort, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$200-500 saved", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "may_sum_1", instruction: "List planned summer activities and trips", verification: .selfReport, xpReward: 30),
                QuestStep(id: "may_sum_2", instruction: "Estimate costs for each", verification: .selfReport, xpReward: 50),
                QuestStep(id: "may_sum_3", instruction: "Set a total summer budget", verification: .selfReport, xpReward: 70)
            ],
            zone: .budgetForge, seasonalMonths: [5]),
        QuestDefinition(
            id: "seasonal_may_travel", title: "Travel Fund Setup", subtitle: "Open a separate travel savings account",
            description: "Separate your travel money from your regular savings. When the account hits your target, you travel. When it's empty, you plan from home.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Guilt-free travel", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "may_trav_1", instruction: "Open a dedicated travel savings account", verification: .selfReport, xpReward: 80),
                QuestStep(id: "may_trav_2", instruction: "Set up automatic monthly transfers", verification: .selfReport, xpReward: 70)
            ],
            zone: .savingsCitadel, seasonalMonths: [5]),
        QuestDefinition(
            id: "seasonal_may_grill", title: "Grill vs Restaurant Calc", subtitle: "Compare the cost of grilling vs eating out",
            description: "A restaurant burger: $15. A grilled burger at home: $3. Do the math for your next gathering and see how much backyard cooking saves.",
            category: .spendingDefense, archetype: .exploration, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$30-100 per event", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 100, scratchCardChance: 0.5, essenceReward: 5,
            steps: [
                QuestStep(id: "may_grill_1", instruction: "Price out a restaurant meal for your group", verification: .selfReport, xpReward: 30),
                QuestStep(id: "may_grill_2", instruction: "Price the same meal as a home cookout", verification: .selfReport, xpReward: 30),
                QuestStep(id: "may_grill_3", instruction: "Host the cookout and save the difference", verification: .selfReport, xpReward: 40)
            ],
            zone: .budgetForge, seasonalMonths: [5]),
        QuestDefinition(
            id: "seasonal_may_ac", title: "The AC Audit", subtitle: "Check HVAC efficiency before summer heat",
            description: "Replace air filters, check for leaks, program your thermostat. A well-maintained system saves 15-25% on summer cooling bills.",
            category: .moneyRecovery, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$50-200/summer", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "may_ac_1", instruction: "Replace or clean your air filters", verification: .selfReport, xpReward: 40),
                QuestStep(id: "may_ac_2", instruction: "Program your thermostat for efficiency", verification: .selfReport, xpReward: 40),
                QuestStep(id: "may_ac_3", instruction: "Check for air leaks around windows and doors", verification: .selfReport, xpReward: 40)
            ],
            zone: .budgetForge, seasonalMonths: [5]),
        QuestDefinition(
            id: "seasonal_may_freeze", title: "Membership Freeze", subtitle: "Freeze unused gym/club memberships for summer",
            description: "Going to exercise outside this summer? Freeze your gym membership instead of paying for both. Most gyms allow 1-3 month freezes.",
            category: .moneyRecovery, archetype: .kill, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$30-100/mo", estimatedTime: "5 minutes", verification: .selfReport,
            baseXP: 100, scratchCardChance: 0.5, essenceReward: 5,
            steps: [
                QuestStep(id: "may_freeze_1", instruction: "Identify memberships you won't use this summer", verification: .selfReport, xpReward: 30),
                QuestStep(id: "may_freeze_2", instruction: "Call and freeze or cancel them", verification: .selfReport, xpReward: 70)
            ],
            zone: .budgetForge, seasonalMonths: [5]),
    ]

    // MARK: - June: Mid-Year Review

    private static let juneQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_jun_checkpoint", title: "Half-Year Financial Checkpoint", subtitle: "Review all 6-month progress",
            description: "You're halfway through the year. How are your January goals tracking? This checkpoint lets you course-correct before it's too late.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Course correction", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "jun_check_1", instruction: "Review your January financial goals", verification: .selfReport, xpReward: 40),
                QuestStep(id: "jun_check_2", instruction: "Calculate progress on each goal", verification: .selfReport, xpReward: 80),
                QuestStep(id: "jun_check_3", instruction: "Adjust targets for the remaining 6 months", verification: .selfReport, xpReward: 130)
            ],
            zone: .savingsCitadel, seasonalMonths: [6]),
        QuestDefinition(
            id: "seasonal_jun_raise", title: "Raise Research", subtitle: "Check your salary market value",
            description: "Mid-year is raise season at many companies. Know your market rate before your review. Knowledge is negotiation power.",
            category: .incomeEarning, archetype: .exploration, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Career awareness", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "jun_raise_1", instruction: "Research salary data for your role on Glassdoor/Levels.fyi", verification: .selfReport, xpReward: 50),
                QuestStep(id: "jun_raise_2", instruction: "Note if you're above, at, or below market rate", verification: .selfReport, xpReward: 70)
            ],
            zone: .incomeFrontier, seasonalMonths: [6]),
        QuestDefinition(
            id: "seasonal_jun_401k", title: "The 401k Optimizer", subtitle: "Increase retirement contribution by 1%",
            description: "A 1% increase barely affects your paycheck but compounds massively over decades. If you earn $50k, 1% more = $500/year = $38,000+ by retirement.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$38,000+ lifetime", estimatedTime: "5 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.8, essenceReward: 12,
            steps: [
                QuestStep(id: "jun_401_1", instruction: "Check your current 401k contribution %", verification: .selfReport, xpReward: 40),
                QuestStep(id: "jun_401_2", instruction: "Increase it by 1%", verification: .selfReport, xpReward: 160)
            ],
            zone: .incomeFrontier, seasonalMonths: [6]),
        QuestDefinition(
            id: "seasonal_jun_health", title: "Health Insurance Audit", subtitle: "Check if FSA/HSA is maximized",
            description: "FSA and HSA are tax-free money for health expenses. If you're not maxing your employer contribution, you're leaving tax savings on the table.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "$500-2,000 tax savings", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.8, essenceReward: 12,
            steps: [
                QuestStep(id: "jun_health_1", instruction: "Check your current FSA/HSA contribution", verification: .selfReport, xpReward: 40),
                QuestStep(id: "jun_health_2", instruction: "Review if you're on track to use your full FSA", verification: .selfReport, xpReward: 60),
                QuestStep(id: "jun_health_3", instruction: "Increase contributions if you have room", verification: .selfReport, xpReward: 100)
            ],
            zone: .savingsCitadel, seasonalMonths: [6]),
        QuestDefinition(
            id: "seasonal_jun_goal_adjust", title: "Mid-Year Goal Adjust", subtitle: "Update financial goals based on H1 results",
            description: "Goals set in January may need adjusting. Life changes, income shifts, priorities evolve. Update your goals to stay realistic and motivated.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Realistic planning", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "jun_goal_1", instruction: "Review each financial goal from January", verification: .selfReport, xpReward: 30),
                QuestStep(id: "jun_goal_2", instruction: "Adjust targets based on current reality", verification: .selfReport, xpReward: 50),
                QuestStep(id: "jun_goal_3", instruction: "Set specific actions for Q3", verification: .selfReport, xpReward: 40)
            ],
            zone: .budgetForge, seasonalMonths: [6]),
    ]

    // MARK: - July: Independence

    private static let julyQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_jul_freedom", title: "Financial Freedom Score", subtitle: "Calculate months of emergency fund coverage",
            description: "How many months could you survive without income? Divide your savings by monthly expenses. That number is your financial freedom score.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Awareness", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "jul_free_1", instruction: "Calculate your monthly essential expenses", verification: .selfReport, xpReward: 40),
                QuestStep(id: "jul_free_2", instruction: "Divide your savings by that number", verification: .selfReport, xpReward: 40),
                QuestStep(id: "jul_free_3", instruction: "Set a target to increase it by 1 month", verification: .selfReport, xpReward: 40)
            ],
            zone: .savingsCitadel, seasonalMonths: [7]),
        QuestDefinition(
            id: "seasonal_jul_hustle", title: "Side Hustle Sprint", subtitle: "Earn $50+ outside your main job this month",
            description: "Freelance, sell items, tutoring, dog walking — earn $50 from a non-primary source. Proving you can generate alternative income is liberating.",
            category: .incomeEarning, archetype: .delivery, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "$50+", estimatedTime: "Variable", verification: .selfReport,
            baseXP: 250, scratchCardChance: 1.0, essenceReward: 15,
            steps: [
                QuestStep(id: "jul_hustle_1", instruction: "Identify a way to earn money outside your job", verification: .selfReport, xpReward: 40),
                QuestStep(id: "jul_hustle_2", instruction: "Take action and complete your first gig/sale", verification: .selfReport, xpReward: 120),
                QuestStep(id: "jul_hustle_3", instruction: "Earn at least $50 from non-primary income", verification: .selfReport, xpReward: 90)
            ],
            zone: .incomeFrontier, seasonalMonths: [7], tiktokMoment: "Side hustle sprint: earned $50+ this month outside my day job"),
        QuestDefinition(
            id: "seasonal_jul_declutter", title: "Declutter & Sell", subtitle: "List 5+ items on marketplace",
            description: "Independence Day declutter: find 5 things you don't need and list them for sale. Clean space, clean mind, extra cash.",
            category: .incomeEarning, archetype: .delivery, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$25-200", estimatedTime: "20 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "jul_dec_1", instruction: "Find 5+ items to sell", verification: .selfReport, xpReward: 30),
                QuestStep(id: "jul_dec_2", instruction: "Photo, price, and list them", verification: .selfReport, xpReward: 60),
                QuestStep(id: "jul_dec_3", instruction: "Complete at least one sale", verification: .selfReport, xpReward: 60)
            ],
            zone: .incomeFrontier, seasonalMonths: [7]),
        QuestDefinition(
            id: "seasonal_jul_zero_budget", title: "The Patriot's Budget", subtitle: "Create a zero-based budget for July",
            description: "Every dollar gets a job. Income minus all allocations (bills, savings, fun, etc.) equals zero. Total control, total intention.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Complete control", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.8, essenceReward: 12,
            steps: [
                QuestStep(id: "jul_zero_1", instruction: "List all income for the month", verification: .selfReport, xpReward: 30),
                QuestStep(id: "jul_zero_2", instruction: "Allocate every dollar to a category", verification: .selfReport, xpReward: 80),
                QuestStep(id: "jul_zero_3", instruction: "Ensure income minus allocations = $0", verification: .selfReport, xpReward: 90)
            ],
            zone: .budgetForge, seasonalMonths: [7]),
        QuestDefinition(
            id: "seasonal_jul_energy", title: "Energy Audit", subtitle: "Find ways to reduce your utility bill",
            description: "Summer utility bills can spike 40%+. Simple changes — LED bulbs, smart thermostat, sealing drafts — save $20-50/month.",
            category: .moneyRecovery, archetype: .exploration, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$20-50/mo", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "jul_energy_1", instruction: "Review your last 3 utility bills", verification: .selfReport, xpReward: 20),
                QuestStep(id: "jul_energy_2", instruction: "Identify 3 ways to reduce usage", verification: .selfReport, xpReward: 50),
                QuestStep(id: "jul_energy_3", instruction: "Implement at least 2 changes", verification: .selfReport, xpReward: 50)
            ],
            zone: .budgetForge, seasonalMonths: [7]),
    ]

    // MARK: - August: Back to School

    private static let augustQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_aug_bts_budget", title: "Back-to-School Budget Shield", subtitle: "Set school spending limits before shopping",
            description: "The average family spends $890 on back-to-school. Create a budget BEFORE entering any store. Impulse purchases love the school supply aisle.",
            category: .spendingDefense, archetype: .escort, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$200-400 saved", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "aug_bts_1", instruction: "List everything needed for back-to-school", verification: .selfReport, xpReward: 30),
                QuestStep(id: "aug_bts_2", instruction: "Set a total budget and per-item limits", verification: .selfReport, xpReward: 50),
                QuestStep(id: "aug_bts_3", instruction: "Shop within budget — no impulse additions", verification: .selfReport, xpReward: 70)
            ],
            zone: .budgetForge, seasonalMonths: [8]),
        QuestDefinition(
            id: "seasonal_aug_textbook", title: "Textbook Savings Quest", subtitle: "Find 3 cheaper textbook sources",
            description: "New textbooks are a scam. Used, rental, library reserve, international editions, older editions — there are always cheaper options.",
            category: .moneyRecovery, archetype: .exploration, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$100-500", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "aug_text_1", instruction: "List required textbooks and their retail prices", verification: .selfReport, xpReward: 30),
                QuestStep(id: "aug_text_2", instruction: "Find 3 cheaper alternatives for each", verification: .selfReport, xpReward: 60),
                QuestStep(id: "aug_text_3", instruction: "Buy from the cheapest source", verification: .selfReport, xpReward: 60)
            ],
            zone: .budgetForge, seasonalMonths: [8]),
        QuestDefinition(
            id: "seasonal_aug_lunch_prep", title: "Lunch Prep Week", subtitle: "Meal prep lunches for 5 days",
            description: "Start the school/work year with a strong habit. Prep 5 days of lunches in one session. Saves $40-75/week and takes less time than daily lunch runs.",
            category: .spendingDefense, archetype: .escort, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$40-75/wk", estimatedTime: "1 hour", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "aug_lunch_1", instruction: "Plan 5 days of lunches", verification: .selfReport, xpReward: 20),
                QuestStep(id: "aug_lunch_2", instruction: "Grocery shop for ingredients", verification: .selfReport, xpReward: 30),
                QuestStep(id: "aug_lunch_3", instruction: "Prep and pack all 5 lunches", verification: .selfReport, xpReward: 70)
            ],
            zone: .budgetForge, seasonalMonths: [8]),
        QuestDefinition(
            id: "seasonal_aug_supply", title: "The Supply Audit", subtitle: "Inventory what you have before buying new",
            description: "Before buying school/office supplies, check what you already own. That junk drawer has 47 pens and 12 notebooks. Don't buy duplicates.",
            category: .spendingDefense, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$20-50", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 80, scratchCardChance: 0.4, essenceReward: 5,
            steps: [
                QuestStep(id: "aug_supply_1", instruction: "Inventory existing supplies", verification: .selfReport, xpReward: 30),
                QuestStep(id: "aug_supply_2", instruction: "Cross off items you already have from shopping list", verification: .selfReport, xpReward: 50)
            ],
            zone: .awakening, seasonalMonths: [8]),
        QuestDefinition(
            id: "seasonal_aug_college", title: "College Fund Check", subtitle: "Review 529 or education savings plan",
            description: "If you have kids, check your 529 plan. Are contributions on track? Is the allocation age-appropriate? A yearly check keeps education savings healthy.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Education funding", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.8, essenceReward: 12,
            steps: [
                QuestStep(id: "aug_college_1", instruction: "Log into your 529 or education savings", verification: .selfReport, xpReward: 30),
                QuestStep(id: "aug_college_2", instruction: "Check if contributions are on track", verification: .selfReport, xpReward: 60),
                QuestStep(id: "aug_college_3", instruction: "Increase contributions if possible", verification: .selfReport, xpReward: 110)
            ],
            zone: .savingsCitadel, seasonalMonths: [8]),
    ]

    // MARK: - September: Fall Reset

    private static let septemberQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_sep_refresh", title: "Fall Financial Refresh", subtitle: "Update budget for the new season",
            description: "Summer spending patterns differ from fall. Update your budget categories, adjust for new routines, and prepare for the holiday season ahead.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Budget accuracy", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "sep_ref_1", instruction: "Review summer spending patterns", verification: .selfReport, xpReward: 30),
                QuestStep(id: "sep_ref_2", instruction: "Adjust budget for fall activities and costs", verification: .selfReport, xpReward: 60),
                QuestStep(id: "sep_ref_3", instruction: "Set new fall savings targets", verification: .selfReport, xpReward: 60)
            ],
            zone: .budgetForge, seasonalMonths: [9]),
        QuestDefinition(
            id: "seasonal_sep_enrollment", title: "Open Enrollment Prep", subtitle: "Research health plan options before enrollment",
            description: "Open enrollment is coming. Research your options NOW so you're not rushing to pick a plan. Compare premiums, deductibles, and networks.",
            category: .financialLiteracy, archetype: .exploration, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "$500-2,000/yr", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "sep_enroll_1", instruction: "List your current plan details and costs", verification: .selfReport, xpReward: 30),
                QuestStep(id: "sep_enroll_2", instruction: "Research 2-3 alternative plan options", verification: .selfReport, xpReward: 100),
                QuestStep(id: "sep_enroll_3", instruction: "Compare costs and coverage side-by-side", verification: .selfReport, xpReward: 120)
            ],
            zone: .savingsCitadel, seasonalMonths: [9]),
        QuestDefinition(
            id: "seasonal_sep_holiday_vault", title: "Holiday Savings Vault", subtitle: "Start a dedicated holiday fund",
            description: "Start saving for the holidays NOW. $100/month for 3 months = $300 holiday budget without debt. Future-you will be grateful.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$300+ by December", estimatedTime: "5 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "sep_hol_1", instruction: "Estimate your total holiday spending budget", verification: .selfReport, xpReward: 30),
                QuestStep(id: "sep_hol_2", instruction: "Set up automatic transfers to a holiday fund", verification: .selfReport, xpReward: 120)
            ],
            zone: .savingsCitadel, seasonalMonths: [9]),
        QuestDefinition(
            id: "seasonal_sep_career", title: "Career Development Budget", subtitle: "Allocate money for learning and certifications",
            description: "Investing in skills has the highest ROI of any investment. Set aside money for courses, certifications, or conferences that grow your earning power.",
            category: .incomeEarning, archetype: .interaction, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Career growth", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "sep_career_1", instruction: "Identify one skill that would increase your income", verification: .selfReport, xpReward: 30),
                QuestStep(id: "sep_career_2", instruction: "Research courses or certifications", verification: .selfReport, xpReward: 40),
                QuestStep(id: "sep_career_3", instruction: "Budget for it and start saving", verification: .selfReport, xpReward: 50)
            ],
            zone: .incomeFrontier, seasonalMonths: [9]),
        QuestDefinition(
            id: "seasonal_sep_credit_report", title: "Annual Credit Report Pull", subtitle: "Get your free annual credit report",
            description: "You're entitled to a free credit report from each bureau annually. Pull one and review for errors — 25% of reports have mistakes that could cost you.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Error detection", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "sep_credit_1", instruction: "Go to annualcreditreport.com", verification: .selfReport, xpReward: 20),
                QuestStep(id: "sep_credit_2", instruction: "Pull your report from one bureau", verification: .selfReport, xpReward: 40),
                QuestStep(id: "sep_credit_3", instruction: "Review for errors and dispute any you find", verification: .selfReport, xpReward: 60)
            ],
            zone: .awakening, seasonalMonths: [9]),
    ]

    // MARK: - October: Halloween Frights

    private static let octoberQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_oct_scary_sub", title: "The Scary Subscription", subtitle: "Find the subscription you forgot about",
            description: "Somewhere in your bank statement lurks a subscription you completely forgot about. Find it. It's been silently draining your account for months.",
            category: .moneyRecovery, archetype: .exploration, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$5-30/mo", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "oct_scary_1", instruction: "Review your last 3 months of bank statements", verification: .selfReport, xpReward: 40),
                QuestStep(id: "oct_scary_2", instruction: "Find at least one forgotten recurring charge", verification: .selfReport, xpReward: 40),
                QuestStep(id: "oct_scary_3", instruction: "Cancel it immediately", verification: .selfReport, xpReward: 40)
            ],
            zone: .budgetForge, seasonalMonths: [10]),
        QuestDefinition(
            id: "seasonal_oct_zombie", title: "Zombie Debt Check", subtitle: "Look for old debts in collections",
            description: "Old debts can come back from the dead. Check if any forgotten debts are in collections — they could be hurting your credit score right now.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Credit health", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 200, scratchCardChance: 0.8, essenceReward: 12,
            steps: [
                QuestStep(id: "oct_zombie_1", instruction: "Check your credit report for collections", verification: .selfReport, xpReward: 50),
                QuestStep(id: "oct_zombie_2", instruction: "If any exist, verify the debt is legitimate", verification: .selfReport, xpReward: 50),
                QuestStep(id: "oct_zombie_3", instruction: "Create a plan to resolve or dispute", verification: .selfReport, xpReward: 100)
            ],
            zone: .savingsCitadel, seasonalMonths: [10]),
        QuestDefinition(
            id: "seasonal_oct_phantom", title: "Phantom Fee Hunter", subtitle: "Find hidden fees on your accounts",
            description: "Banks and services love hiding fees: maintenance fees, paper statement fees, inactivity fees. Hunt them down and eliminate them.",
            category: .moneyRecovery, archetype: .exploration, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$50-200/yr", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "oct_phantom_1", instruction: "Review all bank and investment account fees", verification: .selfReport, xpReward: 40),
                QuestStep(id: "oct_phantom_2", instruction: "Identify fees you can eliminate or reduce", verification: .selfReport, xpReward: 50),
                QuestStep(id: "oct_phantom_3", instruction: "Call to remove fees or switch to fee-free options", verification: .selfReport, xpReward: 60)
            ],
            zone: .budgetForge, seasonalMonths: [10]),
        QuestDefinition(
            id: "seasonal_oct_spooky", title: "Spooky Spending Audit", subtitle: "Review your last 30 days of spending",
            description: "The scariest thing in October isn't ghosts — it's your spending report. Face the numbers. Review every transaction from the last 30 days.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Awareness", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "oct_spooky_1", instruction: "Review every transaction from the last 30 days", verification: .selfReport, xpReward: 40),
                QuestStep(id: "oct_spooky_2", instruction: "Highlight any purchases you regret", verification: .selfReport, xpReward: 40),
                QuestStep(id: "oct_spooky_3", instruction: "Calculate total spent vs your budget", verification: .selfReport, xpReward: 40)
            ],
            zone: .awakening, seasonalMonths: [10]),
        QuestDefinition(
            id: "seasonal_oct_haunted_cart", title: "The Haunted Cart", subtitle: "Clear all online shopping carts without buying",
            description: "Your shopping carts are haunted by items whispering 'buy me.' Exorcise them all. Open every saved cart and clear it. Feel the freedom.",
            category: .spendingDefense, archetype: .kill, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$50-500 saved", estimatedTime: "5 minutes", verification: .selfReport,
            baseXP: 100, scratchCardChance: 0.5, essenceReward: 5,
            steps: [
                QuestStep(id: "oct_cart_1", instruction: "Open every shopping app and website with saved carts", verification: .selfReport, xpReward: 20),
                QuestStep(id: "oct_cart_2", instruction: "Clear every single cart without buying anything", verification: .selfReport, xpReward: 80)
            ],
            zone: .budgetForge, seasonalMonths: [10]),
    ]

    // MARK: - November: Gratitude & Black Friday

    private static let novemberQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_nov_bf_shield", title: "Black Friday 48-Hour Shield", subtitle: "No impulse purchases for 48 hours",
            description: "Survive Black Friday and Cyber Monday without a single impulse purchase. Everything goes on a wish list. Revisit in 48 hours. Most 'deals' are manufactured urgency.",
            category: .spendingDefense, archetype: .escort, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "$100-500+ saved", estimatedTime: "48 hours", verification: .selfReport,
            baseXP: 300, scratchCardChance: 1.0, essenceReward: 20,
            steps: [
                QuestStep(id: "nov_bf_1", instruction: "Add desired items to a wish list — buy nothing", verification: .selfReport, xpReward: 50),
                QuestStep(id: "nov_bf_2", instruction: "Survive 48 hours without buying", verification: .selfReport, xpReward: 150),
                QuestStep(id: "nov_bf_3", instruction: "After 48 hours, buy only what you still need", verification: .selfReport, xpReward: 100)
            ],
            zone: .savingsCitadel, seasonalMonths: [11], tiktokMoment: "Survived Black Friday with the 48-hour rule. Saved hundreds."),
        QuestDefinition(
            id: "seasonal_nov_gratitude", title: "The Gratitude Budget", subtitle: "List 10 things you already have that money bought",
            description: "Before spending on more stuff, appreciate what you have. List 10 things you own that genuinely improve your life. Gratitude reduces impulse spending by 30%.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Perspective shift", estimatedTime: "5 minutes", verification: .selfReport,
            baseXP: 80, scratchCardChance: 0.4, essenceReward: 5,
            steps: [
                QuestStep(id: "nov_grat_1", instruction: "List 10 things you own that you're grateful for", verification: .selfReport, xpReward: 50),
                QuestStep(id: "nov_grat_2", instruction: "For each, note how much it cost and the value it brought", verification: .selfReport, xpReward: 30)
            ],
            zone: .awakening, seasonalMonths: [11]),
        QuestDefinition(
            id: "seasonal_nov_giving", title: "Giving Tuesday Plan", subtitle: "Choose a charity and set a donation amount",
            description: "Generosity is most powerful when it's planned, not impulsive. Choose your cause, set an amount, and give intentionally.",
            category: .generosity, archetype: .interaction, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Intentional giving", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "nov_give_1", instruction: "Choose a charity or cause you care about", verification: .selfReport, xpReward: 30),
                QuestStep(id: "nov_give_2", instruction: "Set a donation amount that fits your budget", verification: .selfReport, xpReward: 40),
                QuestStep(id: "nov_give_3", instruction: "Make the donation on Giving Tuesday", verification: .selfReport, xpReward: 50)
            ],
            zone: .savingsCitadel, seasonalMonths: [11]),
        QuestDefinition(
            id: "seasonal_nov_gift_budget", title: "Holiday Gift Budget", subtitle: "Set per-person gift spending limits",
            description: "Before holiday shopping begins, set a specific dollar limit for each person on your list. This prevents the emotional overspending spiral.",
            category: .spendingDefense, archetype: .escort, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "$200-500 saved", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "nov_gift_1", instruction: "List everyone you plan to buy gifts for", verification: .selfReport, xpReward: 30),
                QuestStep(id: "nov_gift_2", instruction: "Set a spending limit for each person", verification: .selfReport, xpReward: 50),
                QuestStep(id: "nov_gift_3", instruction: "Calculate your total gift budget", verification: .selfReport, xpReward: 70)
            ],
            zone: .budgetForge, seasonalMonths: [11]),
        QuestDefinition(
            id: "seasonal_nov_anti_fomo", title: "The Anti-FOMO Challenge", subtitle: "Ignore 5 sale notification emails",
            description: "Every 'LAST CHANCE' and 'FLASH SALE' email is designed to trigger FOMO. Ignore 5 of them today. Delete without opening. Take back control.",
            category: .spendingDefense, archetype: .kill, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Impulse prevention", estimatedTime: "2 minutes", verification: .selfReport,
            baseXP: 80, scratchCardChance: 0.4, essenceReward: 5,
            steps: [
                QuestStep(id: "nov_fomo_1", instruction: "Delete 5 sale emails without opening them", verification: .selfReport, xpReward: 40),
                QuestStep(id: "nov_fomo_2", instruction: "Unsubscribe from 3 of those senders", verification: .selfReport, xpReward: 40)
            ],
            zone: .awakening, seasonalMonths: [11]),
    ]

    // MARK: - December: Holiday & Year-End

    private static let decemberQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "seasonal_dec_fortress", title: "Holiday Budget Fortress", subtitle: "Track all holiday spending in real-time",
            description: "Track every holiday purchase as it happens. Running total visible at all times. When you hit your limit, you're done. No exceptions.",
            category: .spendingDefense, archetype: .escort, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "$200-500 saved", estimatedTime: "Ongoing", verification: .selfReport,
            baseXP: 250, scratchCardChance: 0.9, essenceReward: 15,
            steps: [
                QuestStep(id: "dec_fort_1", instruction: "Set your total holiday spending budget", verification: .selfReport, xpReward: 30),
                QuestStep(id: "dec_fort_2", instruction: "Log every holiday purchase as it happens", verification: .selfReport, xpReward: 100),
                QuestStep(id: "dec_fort_3", instruction: "Stay within your total budget", verification: .selfReport, xpReward: 120)
            ],
            zone: .savingsCitadel, seasonalMonths: [12]),
        QuestDefinition(
            id: "seasonal_dec_tax_move", title: "Year-End Tax Move", subtitle: "Maximize retirement contributions before Dec 31",
            description: "The tax year closes December 31. If you have room, max your retirement contributions. Every dollar contributed reduces your taxable income.",
            category: .financialLiteracy, archetype: .delivery, difficulty: .hard, cadence: .seasonal,
            estimatedImpact: "$500-6,000+ tax benefit", estimatedTime: "10 minutes", verification: .selfReport,
            baseXP: 350, scratchCardChance: 1.0, essenceReward: 25,
            steps: [
                QuestStep(id: "dec_tax_1", instruction: "Check your year-to-date retirement contributions", verification: .selfReport, xpReward: 50),
                QuestStep(id: "dec_tax_2", instruction: "Calculate how much room you have before the max", verification: .selfReport, xpReward: 50),
                QuestStep(id: "dec_tax_3", instruction: "Make an additional contribution if possible", verification: .selfReport, xpReward: 250)
            ],
            zone: .legacy, seasonalMonths: [12]),
        QuestDefinition(
            id: "seasonal_dec_experience", title: "The Gift of Experience", subtitle: "Give 1 experience gift instead of material",
            description: "Research shows experiences bring more lasting happiness than things. Give one person an experience — concert tickets, cooking class, spa day, adventure.",
            category: .generosity, archetype: .delivery, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Better gifting", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 120, scratchCardChance: 0.6, essenceReward: 8,
            steps: [
                QuestStep(id: "dec_exp_1", instruction: "Choose one person to give an experience gift", verification: .selfReport, xpReward: 20),
                QuestStep(id: "dec_exp_2", instruction: "Research experience gifts within your budget", verification: .selfReport, xpReward: 40),
                QuestStep(id: "dec_exp_3", instruction: "Purchase the experience gift", verification: .selfReport, xpReward: 60)
            ],
            zone: .savingsCitadel, seasonalMonths: [12]),
        QuestDefinition(
            id: "seasonal_dec_net_worth", title: "Annual Net Worth Update", subtitle: "Calculate your year-end net worth",
            description: "The most important number of the year: your net worth on December 31. Compare it to January 1. Did it go up? That's the only metric that matters.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .easy, cadence: .seasonal,
            estimatedImpact: "Annual tracking", estimatedTime: "15 minutes", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.7, essenceReward: 10,
            steps: [
                QuestStep(id: "dec_nw_1", instruction: "List all assets and their current values", verification: .selfReport, xpReward: 40),
                QuestStep(id: "dec_nw_2", instruction: "List all debts and current balances", verification: .selfReport, xpReward: 40),
                QuestStep(id: "dec_nw_3", instruction: "Calculate net worth and compare to last year", verification: .selfReport, xpReward: 70)
            ],
            zone: .awakening, seasonalMonths: [12]),
        QuestDefinition(
            id: "seasonal_dec_review", title: "Financial Year in Review", subtitle: "Review all 12 months of financial progress",
            description: "The ultimate year-end quest. Review every month: total income, total spending, savings rate, best decisions, worst decisions. Write your financial story.",
            category: .financialLiteracy, archetype: .fetch, difficulty: .medium, cadence: .seasonal,
            estimatedImpact: "Complete perspective", estimatedTime: "30 minutes", verification: .selfReport,
            baseXP: 300, scratchCardChance: 1.0, essenceReward: 20,
            steps: [
                QuestStep(id: "dec_rev_1", instruction: "Review income and spending for each month", verification: .selfReport, xpReward: 60),
                QuestStep(id: "dec_rev_2", instruction: "Identify your best and worst financial decisions", verification: .selfReport, xpReward: 60),
                QuestStep(id: "dec_rev_3", instruction: "Calculate your annual savings rate", verification: .selfReport, xpReward: 80),
                QuestStep(id: "dec_rev_4", instruction: "Write 3 lessons learned for next year", verification: .selfReport, xpReward: 100)
            ],
            zone: .savingsCitadel, seasonalMonths: [12], tiktokMoment: "My financial year in review — what a journey"),
    ]
}
