import SwiftUI

struct Spline3DView: View {
    let sceneSource: SceneSource
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum SceneSource {
        case url(URL)
        case local(String)
    }

    init(sceneURL: URL) {
        self.sceneSource = .url(sceneURL)
    }

    init(localFile: String) {
        self.sceneSource = .local(localFile)
    }

    var body: some View {
        fallbackView
    }

    private var fallbackView: some View {
        ZStack {
            Theme.surface.clipShape(.rect(cornerRadius: 16))
            VStack(spacing: 12) {
                Image(systemName: "cube.transparent")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Theme.accent)
                    .symbolEffect(.pulse, isActive: !reduceMotion)
                Text("3D Scene")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    static func treasureChest(url: URL) -> Spline3DView {
        Spline3DView(sceneURL: url)
    }

    static func questReward(url: URL) -> Spline3DView {
        Spline3DView(sceneURL: url)
    }

    static func cardReveal(url: URL) -> Spline3DView {
        Spline3DView(sceneURL: url)
    }
}
