import SwiftUI
import SwiftData

struct NotificationPermissionCard: View {
    @Query private var profiles: [UserProfile]
    @Query private var impulseLogs: [ImpulseLog]
    @State private var notifService = NotificationService.shared
    @State private var dismissed = false
    @State private var enabling = false

    private var profile: UserProfile? { profiles.first }

    private var shouldShow: Bool {
        guard !dismissed else { return false }
        guard let profile else { return false }
        guard !profile.notificationsEnabled else { return false }
        guard !profile.hasShownNotificationPrompt else { return false }
        guard !notifService.isAuthorized else { return false }
        let hasResisted = impulseLogs.contains(where: \.resisted)
        return hasResisted
    }

    var body: some View {
        if shouldShow {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Theme.teal.opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: "bell.badge.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.teal)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Stay on Track")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Want weekly savings reports and streak reminders?")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()
                }

                HStack(spacing: 12) {
                    Button {
                        enabling = true
                        Task {
                            let granted = await notifService.requestPermission()
                            if granted, let profile {
                                profile.notificationsEnabled = true
                                profile.hasShownNotificationPrompt = true
                                notifService.scheduleAllNotifications(profile: profile)
                            } else {
                                profile?.hasShownNotificationPrompt = true
                            }
                            enabling = false
                            withAnimation(.spring(response: 0.4)) {
                                dismissed = true
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if enabling {
                                ProgressView()
                                    .tint(Theme.background)
                                    .scaleEffect(0.8)
                            }
                            Text("Enable Notifications")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.accentGradient, in: .capsule)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(enabling)

                    Button {
                        profile?.hasShownNotificationPrompt = true
                        withAnimation(.spring(response: 0.4)) {
                            dismissed = true
                        }
                    } label: {
                        Text("Not now")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Theme.teal.opacity(0.06), Theme.cardSurface],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Theme.teal.opacity(0.15), lineWidth: 1)
            )
            .transition(.asymmetric(
                insertion: .scale(scale: 0.95).combined(with: .opacity),
                removal: .scale(scale: 0.9).combined(with: .opacity)
            ))
            .sensoryFeedback(.impact(weight: .medium), trigger: enabling)
        }
    }
}
