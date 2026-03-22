# Money Personality Quiz — 5-Question Onboarding Flow

Replace the existing 3-question mini quiz with a premium 5-question Money Personality Quiz that becomes the app's Day 0 viral moment.

**Features**
- 5 engaging money personality questions with emoji-enriched answer cards
- Auto-advance after selection with haptic feedback and scale animation
- Smooth gradient progress bar filling across all 5 questions
- Dramatic personality reveal with pulsing ring animation and 2-second suspense
- 5 distinct personalities: The Saver, The Builder, The Hustler, The Minimalist, The Generous — each with unique color and icon
- Premium glassmorphic personality result card with trait tags
- "Share My Personality" button that generates a beautiful shareable image
- "Start Managing Money" button to continue into the app

**Design**
- Welcome screen: dark background with floating particle dots in purple at low opacity, animated logo bounce-in, headline "Discover Your Money Personality", subtext in muted gray, full-width purple CTA button
- Quiz screens: thin gradient progress bar (purple → cyan) at top, question number in muted text, question in large semibold white text, 4 answer option cards with emoji + text — selected card gets purple border glow and subtle scale-up
- Result screen: pulsing ring reveal animation, then personality card slides up with blur background, thin white border at 20% opacity, personality icon at 48pt in the personality's color, bold personality name, 3 trait pills, brief description, share and continue buttons
- All animations use spring physics for natural feel
- Dark mode only, OLED-optimized

**Screens**
- **Welcome Screen** — animated intro with "Let's Go" button to start the quiz
- **Question 1** — "When you get unexpected money, you..." (4 options)
- **Question 2** — "Your ideal Saturday involves..." (4 options)
- **Question 3** — "Money makes you feel..." (4 options)
- **Question 4** — "Your friends say you're the one who..." (4 options)
- **Question 5** — "Your financial superpower is..." (4 options)
- **Result Screen** — dramatic reveal of personality type with shareable card

**Changes**
- Update the QuizResult model to support 5 answers and the new personality types (Saver, Builder, Hustler, Minimalist, Generous) with associated colors, icons, and traits
- Replace MiniQuizScreen with new MoneyPersonalityQuizView (welcome + 5 questions + result)
- Add floating particle background effect for the welcome screen
- Add pulsing ring reveal animation for the result screen
- Add shareable personality card image generation using UIGraphicsImageRenderer
- Wire into existing OnboardingView flow in place of the old mini quiz screen
