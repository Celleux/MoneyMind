import SwiftUI

struct AccountCreationScreen: View {
    let savedAmount: Double
    let onNext: () -> Void

    @State private var email: String = ""
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.accentGradient)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.6)

                VStack(spacing: 8) {
                    Text("Protect Your Progress")
                        .font(Theme.headingFont(.title))
                        .foregroundStyle(Theme.textPrimary)

                    if savedAmount > 0 {
                        Text("Save the $\(savedAmount, specifier: "%.0f") you just logged.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.gold)
                    }
                }
                .opacity(appeared ? 1 : 0)

                VStack(spacing: 16) {
                    TextField("Email address", text: $email)
                        .font(.body)
                        .padding(16)
                        .background(Theme.cardSurface, in: .rect(cornerRadius: 8))
                        .foregroundStyle(Theme.textPrimary)
                        .tint(Theme.accentGreen)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    Button {
                        onNext()
                    } label: {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button {
                        onNext()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo")
                            Text("Sign in with Apple")
                        }
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white.opacity(0.1), in: .rect(cornerRadius: 12))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            Button {
                onNext()
            } label: {
                Text("Skip for now")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.bottom, 48)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}
