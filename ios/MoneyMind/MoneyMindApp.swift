import SwiftUI
import SwiftData

@main
struct SplurjApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var premiumManager = PremiumManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView {
                        withAnimation(.spring(response: 0.5)) {
                            hasCompletedOnboarding = true
                        }
                    }
                }
            }
            .environment(premiumManager)
            .preferredColorScheme(.dark)
            .onAppear { SoundManager.shared.preload() }
        }
        .modelContainer(for: [
            UserProfile.self,
            ImpulseLog.self,
            DailyCheckIn.self,
            ImplementationIntention.self,
            QuizResult.self,
            SpendingAutopsy.self,
            UrgeSurfSession.self,
            HALTCheckIn.self,
            CoolingOffSession.self,
            ImaginalSession.self,
            EveningReflection.self,
            DailyPledge.self,
            PGSIAssessment.self,
            CurriculumSession.self,
            EMACheckIn.self,
            Badge.self,
            HighRiskPattern.self,
            WatchHRVReading.self,
            WatchIntervention.self,
            CrisisRiskDataPoint.self,
            JITAIRecommendation.self,
            CoachMessage.self,
            CoachSession.self,
            VoiceSession.self,
            ACTExercise.self,
            SeekingSafetyEntry.self,
            CommunityPost.self,
            AccountabilityPartner.self,
            PartnerCheckIn.self,
            ChallengeGroup.self,
            ReferralCode.self,
            Transaction.self,
            BudgetCategory.self,
            SavingsChallenge.self,
            MerchantCategoryMapping.self,
            RecurringExpense.self,
            InAppNotification.self,
            VibeCheckEntry.self,
            ScratchCard.self,
            CollectedCard.self,
            GachaState.self,
            QuestProgress.self,
            PlayerProfile.self,
            DailyQuestSlot.self,
            QuestBuddy.self,
            FinancialDNAResult.self,
            WeeklyChallenge.self,
            ChallengeInvite.self
        ])
    }
}
