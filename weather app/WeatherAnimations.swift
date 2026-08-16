import SwiftUI

// MARK: - Weather Animations

struct RainView: View {

    @State private var offsetY: CGFloat = -20

    var body: some View {
        Image(systemName: "cloud.rain.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white.opacity(0.8))
            .offset(y: offsetY)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                ) {
                    offsetY = 20
                }
            }
    }
}

struct MiniCloudView: View {

    @State private var offsetX: CGFloat = -20

    var body: some View {
        Image(systemName: "cloud.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white.opacity(0.8))
            .offset(x: offsetX)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                ) {
                    offsetX = 20
                }
            }
    }
}

struct CloudView: View {
    var body: some View {
        ZStack {
            MiniCloudView()
                .scaleEffect(1.0)

            MiniCloudView()
                .scaleEffect(0.7)
                .offset(x: 80, y: 30)

            MiniCloudView()
                .scaleEffect(0.6)
                .offset(x: -90, y: 20)
        }
    }
}

struct SunView: View {

    @State private var scale = 1.0

    var body: some View {
        Image(systemName: "sun.max.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.yellow)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                ) {
                    scale = 1.15
                }
            }
    }
}

struct MoonView: View {

    @State private var offsetX: CGFloat = 30
    @State private var opacity: Double = 0.5

    var body: some View {
        ZStack {
            Image(systemName: "cloud.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white.opacity(0.3))
                .offset(x: -60, y: -10)

            Image(systemName: "moon.stars.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.5), radius: 40)
                .offset(x: offsetX)
                .opacity(opacity)

            Image(systemName: "cloud.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white.opacity(0.2))
                .offset(x: 50, y: 5)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
            ) {
                offsetX = -30
                opacity = 1.0
            }
        }
    }
}

struct SnowView: View {

    @State private var offsetY: CGFloat = -20
    @State private var opacity: Double = 0.6

    var body: some View {
        Image(systemName: "snowflake")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white.opacity(opacity))
            .offset(y: offsetY)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                ) {
                    offsetY = 20
                    opacity = 1.0
                }
            }
    }
}

struct ThunderView: View {
    
    @State private var opacity: Double = 1.0
    @State private var offsetX: CGFloat = -20
    
    var body: some View {
        Image(systemName: "cloud.bolt.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white.opacity(opacity))
            .offset(x: offsetX)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                ) {
                    offsetX = 20
                    opacity = 0.4
                }
            }
    }
}
