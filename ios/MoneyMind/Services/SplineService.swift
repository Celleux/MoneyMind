import SwiftUI
import SplineRuntime

struct Spline3DView: View {
    let sceneSource: SceneSource
    @State private var isLoading: Bool = true
    @State private var loadFailed: Bool = false
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
        Group {
            if loadFailed {
                fallbackView
            } else {
                splineContent
                    .overlay {
                        if isLoading {
                            loadingPlaceholder
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var splineContent: some View {
        switch sceneSource {
        case .url(let url):
            SplineView(sceneFileURL: url)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isLoading = false
                    }
                }
        case .local(let fileName):
            if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "splineswift") {
                SplineView(sceneFileURL: fileURL)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLoading = false
                        }
                    }
            } else {
                fallbackView
                    .onAppear { loadFailed = true }
            }
        }
    }

    private var loadingPlaceholder: some View {
        ZStack {
            Theme.surface
            VStack(spacing: 12) {
                ProgressView()
                    .tint(Theme.accent)
                Text("Loading 3D scene...")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.textMuted)
            }
        }
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
                Button {
                    loadFailed = false
                    isLoading = true
                } label: {
                    Text("Retry")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                }
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
