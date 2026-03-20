import SwiftUI
import CoreLocation
import HealthKit
import UserNotifications
import ObjectiveC

// MARK: - Step 1 — What is public health

struct OnboardingStep1View: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(alignment: .leading, spacing: 5) {
                Text("What is public health?")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#0D1B2A"))
                Text("Protecting communities through education, policy, and research — prevention first.")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#4A6274"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Rectangle()
                    .fill(Color(hex: "#00B4D8"))
                    .frame(height: 1)
                    .frame(maxWidth: 80, alignment: .leading)
                Text("ENDO WORLD uses technology to make you more informed daily.")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#0D1B2A"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text("W.H.O + The C.D.C are failing at this.")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(hex: "#4A6274"))
                Rectangle()
                    .fill(Color(hex: "#00B4D8"))
                    .frame(height: 1)
                    .frame(maxWidth: 60, alignment: .leading)
            }
            .padding(.bottom, 46)
            .contentShape(Rectangle())
            .onTapGesture { coordinator.advance() }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Button(action: { coordinator.advance() }) {
                        HStack(spacing: 4) {
                            Text("Swipe to learn")
                                .font(.system(size: 9))
                                .foregroundStyle(Color(hex: "#4A6274"))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8))
                                .foregroundStyle(Color(hex: "#00B4D8"))
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .background(Color(hex: "#E8F4F8"))
            }
        }
    }
}

// MARK: - Step 2 — The awareness gap

struct OnboardingStep2View: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(alignment: .leading, spacing: 5) {
                Text("The awareness gap")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#0D1B2A"))
                Text("Only 30–50% of people understand what public health actually means. Most confuse it with personal healthcare.")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#4A6274"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Rectangle()
                    .fill(Color(hex: "#00B4D8"))
                    .frame(height: 1)
                    .frame(maxWidth: 80, alignment: .leading)
                (Text("Instead of wondering what is affecting you — ")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#4A6274"))
                    + Text("see it, hear it, feel it")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: "#00B4D8"))
                    + Text(" before you walk out your door.")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#4A6274")))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.bottom, 40)
            .contentShape(Rectangle())
            .onTapGesture { coordinator.advance() }
            .safeAreaInset(edge: .bottom) {
                tapHint(onTap: { coordinator.advance() })
                    .background(Color(hex: "#E8F4F8"))
            }
        }
    }
}

// MARK: - Step 3 — What ENDO does

struct OnboardingStep3View: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(alignment: .leading, spacing: 6) {
                topoIllustration
                Text("Every wearable tells you about your body.")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#4A6274"))
                Text("None of them tell you about your block.")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: "#0D1B2A"))
                Rectangle()
                    .fill(Color(hex: "#00B4D8"))
                    .frame(height: 1)
                    .frame(maxWidth: 80, alignment: .leading)
                Text("ENDO maps what your environment is doing to human health in real time, at the neighborhood level.")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(hex: "#4A6274"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.bottom, 40)
            .contentShape(Rectangle())
            .onTapGesture { coordinator.advance() }
            .safeAreaInset(edge: .bottom) {
                tapHint(onTap: { coordinator.advance() })
                    .background(Color(hex: "#E8F4F8"))
            }
        }
    }

    private var topoIllustration: some View {
        Canvas { ctx, size in
            for i in 0..<5 {
                var path = Path()
                let y = size.height * (0.1 + 0.2 * Double(i))
                path.move(to: CGPoint(x: 0, y: y))
                path.addCurve(
                    to: CGPoint(x: size.width, y: y + 6),
                    control1: CGPoint(x: size.width * 0.25, y: y - 8 + Double(i) * 3),
                    control2: CGPoint(x: size.width * 0.75, y: y + 10 - Double(i) * 2)
                )
                ctx.stroke(path, with: .color(Color(hex: "#00B4D8").opacity(0.3)), lineWidth: 1)
            }
            let positions = [
                CGPoint(x: size.width * 0.2, y: size.height * 0.3),
                CGPoint(x: size.width * 0.6, y: size.height * 0.6),
                CGPoint(x: size.width * 0.8, y: size.height * 0.2)
            ]
            for pos in positions {
                let r = CGRect(x: pos.x - 3, y: pos.y - 3, width: 6, height: 6)
                ctx.fill(Path(ellipseIn: r), with: .color(Color(hex: "#0D1B2A").opacity(0.5)))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Step 4 — Location permission

struct OnboardingStep4View: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#00B4D8").opacity(0.1))
                            .frame(width: 22, height: 22)
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(hex: "#00B4D8"))
                    }
                    Text("Location access")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(hex: "#0D1B2A"))
                }
                Text("Block-level zones. Never stored on our servers.")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#4A6274"))
                    .lineSpacing(2)
                VStack(spacing: 3) {
                    HStack(spacing: 3) {
                        factCell(icon: "checkmark", color: Color(hex: "#34C759"), text: "AQI + noise")
                        factCell(icon: "checkmark", color: Color(hex: "#34C759"), text: "Zone pin")
                    }
                    HStack(spacing: 3) {
                        factCell(icon: "xmark", color: Color(hex: "#FF3B3B"), text: "Not stored")
                        factCell(icon: "xmark", color: Color(hex: "#FF3B3B"), text: "Not shared")
                    }
                }
                Spacer()
            }
            .padding(.bottom, 38)
            .safeAreaInset(edge: .bottom) {
                cyanButton("Allow Location") {
                    Task { await requestLocation() }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
                .background(Color(hex: "#E8F4F8"))
            }
        }
    }

    private func requestLocation() async {
        let manager = CLLocationManager()
        let granted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            let delegate = LocationAuthDelegate(continuation: cont)
            manager.delegate = delegate
            objc_setAssociatedObject(manager, &LocationAuthDelegate.key, delegate, .OBJC_ASSOCIATION_RETAIN)
            manager.requestWhenInUseAuthorization()
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                if delegate.continuation != nil {
                    let status = manager.authorizationStatus
                    delegate.continuation = nil
                    cont.resume(returning: status == .authorizedWhenInUse || status == .authorizedAlways)
                }
            }
        }
        if granted {
            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run { coordinator.advance() }
        }
    }
}

// MARK: - Step 5 — Health permission

struct OnboardingStep5View: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#FF3B3B").opacity(0.1))
                            .frame(width: 22, height: 22)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(hex: "#FF3B3B"))
                    }
                    Text("Apple Health")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(hex: "#0D1B2A"))
                }
                Text("Heart rate, HRV, SpO2. Read-only, stays on your device.")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#4A6274"))
                    .lineSpacing(2)
                VStack(spacing: 3) {
                    HStack(spacing: 3) {
                        factCell(icon: "checkmark", color: Color(hex: "#34C759"), text: "HR + HRV")
                        factCell(icon: "checkmark", color: Color(hex: "#34C759"), text: "SpO2")
                    }
                    HStack(spacing: 3) {
                        factCell(icon: "xmark", color: Color(hex: "#FF3B3B"), text: "Never uploaded")
                        factCell(icon: "xmark", color: Color(hex: "#FF3B3B"), text: "Read-only")
                    }
                }
                Spacer()
            }
            .padding(.bottom, 38)
            .safeAreaInset(edge: .bottom) {
                cyanButton("Connect Health") {
                    Task { await requestHealth() }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
                .background(Color(hex: "#E8F4F8"))
            }
        }
    }

    private func requestHealth() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            await MainActor.run { coordinator.advance() }
            return
        }
        let store = HKHealthStore()
        var readTypes = Set<HKObjectType>()
        for id in [HKQuantityTypeIdentifier.heartRate, .heartRateVariabilitySDNN, .oxygenSaturation, .respiratoryRate, .environmentalAudioExposure] {
            if let t = HKQuantityType.quantityType(forIdentifier: id) {
                readTypes.insert(t)
            }
        }
        let success = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            store.requestAuthorization(toShare: [], read: readTypes) { success, _ in
                cont.resume(returning: success)
            }
        }
        if success {
            try? await Task.sleep(nanoseconds: 800_000_000)
        }
        await MainActor.run { coordinator.advance() }
    }
}

// MARK: - Step 6 — Profile

struct OnboardingStep6View: View {
    @Bindable var coordinator: OnboardingCoordinator

    private let sexOptions = ["Male", "Female", "Non-binary", "—"]

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(alignment: .leading, spacing: 5) {
                Text("About you")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#0D1B2A"))
                Text("Calibrates your zone score thresholds.")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#4A6274"))
                VStack(spacing: 2) {
                    Text("Age — Digital Crown")
                        .font(.system(size: 8))
                        .foregroundStyle(Color(hex: "#4A6274"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(coordinator.profile.age == 0 ? "—" : "\(coordinator.profile.age)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: "#0D1B2A"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .focusable(true)
                        .digitalCrownRotation(
                            $coordinator.profile.ageDouble,
                            from: 13,
                            through: 99,
                            by: 1,
                            sensitivity: .medium
                        )
                        .onChange(of: coordinator.profile.ageDouble) { _, new in
                            coordinator.profile.age = Int(new)
                        }
                }
                .padding(8)
                .background(Color(hex: "#00B4D8").opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                Text("Biological sex")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(hex: "#4A6274"))
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 3) {
                    ForEach(sexOptions, id: \.self) { opt in
                        Button(action: { coordinator.profile.biologicalSex = opt }) {
                            Text(opt)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(coordinator.profile.biologicalSex == opt ? .white : Color(hex: "#4A6274"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 22)
                                .background(
                                    coordinator.profile.biologicalSex == opt
                                        ? Color(hex: "#00B4D8")
                                        : Color(hex: "#00B4D8").opacity(0.07)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
            }
            .padding(.bottom, 38)
            .safeAreaInset(edge: .bottom) {
                cyanButton("Continue") { coordinator.advance() }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                    .background(Color(hex: "#E8F4F8"))
            }
        }
    }
}

// MARK: - Step 7 — Condition selection (scrollable list)

struct OnboardingStep7View: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("What should ENDO watch for you?")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: "#0D1B2A"))
                    Text("Select conditions that apply to you.")
                        .font(.system(size: 9))
                        .foregroundStyle(Color(hex: "#4A6274"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 2) {
                        ForEach(HealthCondition.allCases, id: \.rawValue) { c in
                            conditionRow(c)
                        }
                        Button(action: { coordinator.profile.selectedConditions.removeAll() }) {
                            HStack {
                                Text("None of the above")
                                    .font(.system(size: 10))
                                    .foregroundStyle(
                                        coordinator.profile.selectedConditions.isEmpty
                                            ? Color(hex: "#00B4D8") : Color(hex: "#4A6274")
                                    )
                                Spacer()
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 5)
                            .background(
                                coordinator.profile.selectedConditions.isEmpty
                                    ? Color(hex: "#00B4D8").opacity(0.08)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 4)
                }
                .focusable()
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 3) {
                    cyanButton("Confirm Selection") { coordinator.advance() }
                    Text("Update anytime in settings.")
                        .font(.system(size: 8))
                        .foregroundStyle(Color(hex: "#4A6274"))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
                .background(Color(hex: "#E8F4F8"))
            }
        }
    }

    private func conditionRow(_ c: HealthCondition) -> some View {
        let sel = coordinator.profile.selectedConditions.contains(c)
        return HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(sel ? Color(hex: "#00B4D8").opacity(0.15) : Color(hex: "#0D1B2A").opacity(0.05))
                    .frame(width: 20, height: 20)
                Image(systemName: c.icon)
                    .font(.system(size: 9))
                    .foregroundStyle(sel ? Color(hex: "#00B4D8") : Color(hex: "#4A6274"))
            }
            Text(c.rawValue)
                .font(.system(size: 10, weight: sel ? .semibold : .regular))
                .foregroundStyle(sel ? Color(hex: "#0D1B2A") : Color(hex: "#4A6274"))
            Spacer()
            if sel {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "#00B4D8"))
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(sel ? Color(hex: "#00B4D8").opacity(0.07) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .contentShape(Rectangle())
        .onTapGesture { coordinator.profile.toggle(c) }
        .animation(.easeInOut(duration: 0.15), value: sel)
    }
}

// MARK: - Step 8 — Signal selection (scrollable)

struct OnboardingStep8View: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Track these signals")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: "#0D1B2A"))
                    Text("Toggle categories — tune individually later.")
                        .font(.system(size: 9))
                        .foregroundStyle(Color(hex: "#4A6274"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 2) {
                        ForEach(SignalCategory.allCases, id: \.rawValue) { cat in
                            signalCategoryRow(cat)
                        }
                        Text("28 total signals")
                            .font(.system(size: 8))
                            .foregroundStyle(Color(hex: "#4A6274"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 4)
                }
                .focusable()
            }
            .safeAreaInset(edge: .bottom) {
                cyanButton("Continue") { coordinator.advance() }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                    .background(Color(hex: "#E8F4F8"))
            }
        }
    }

    private func signalCategoryRow(_ cat: SignalCategory) -> some View {
        let enabled = coordinator.profile.signalCategoriesEnabled.contains(cat)
        return HStack(spacing: 6) {
            Circle()
                .fill(cat.dotColor)
                .frame(width: 4, height: 4)
            Text(cat.displayName)
                .font(.system(size: 10))
                .foregroundStyle(Color(hex: "#0D1B2A"))
            Text("\(cat.count)")
                .font(.system(size: 9))
                .foregroundStyle(Color(hex: "#4A6274"))
            Spacer()
            Toggle("", isOn: Binding(
                get: { enabled },
                set: { new in
                    if new {
                        coordinator.profile.signalCategoriesEnabled.insert(cat)
                    } else {
                        coordinator.profile.signalCategoriesEnabled.remove(cat)
                    }
                }
            ))
            .labelsHidden()
            .tint(Color(hex: "#00B4D8"))
            .scaleEffect(0.75)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color(hex: "#00B4D8").opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: - Step 9 — Data privacy

struct OnboardingStep9View: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Your data.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#0D1B2A"))
                Text("Choose how it is used.")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#4A6274"))
                privacyCard(
                    selected: coordinator.profile.anonymousDataOptIn,
                    title: "Share anonymously",
                    body: "Zone score · Block-level · No name",
                    onTap: {
                        coordinator.profile.anonymousDataOptIn = true
                        coordinator.profile.hasRespondedToDataPrompt = true
                    }
                )
                privacyCard(
                    selected: !coordinator.profile.anonymousDataOptIn && coordinator.profile.hasRespondedToDataPrompt,
                    title: "Keep private",
                    body: "Stays on device only",
                    onTap: {
                        coordinator.profile.anonymousDataOptIn = false
                        coordinator.profile.hasRespondedToDataPrompt = true
                    }
                )
                Text("Change anytime in Settings.")
                    .font(.system(size: 8))
                    .foregroundStyle(Color(hex: "#4A6274"))
                Spacer()
            }
            .padding(.bottom, 38)
            .safeAreaInset(edge: .bottom) {
                cyanButton("Confirm") { coordinator.advance() }
                    .opacity(coordinator.profile.hasRespondedToDataPrompt ? 1 : 0.4)
                    .disabled(!coordinator.profile.hasRespondedToDataPrompt)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                    .background(Color(hex: "#E8F4F8"))
            }
        }
    }

    private func privacyCard(selected: Bool, title: String, body: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundStyle(selected ? Color(hex: "#00B4D8") : Color(hex: "#C5D8E0"))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color(hex: "#0D1B2A"))
                    Text(body)
                        .font(.system(size: 9))
                        .foregroundStyle(Color(hex: "#4A6274"))
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selected ? Color(hex: "#00B4D8").opacity(0.07) : Color(hex: "#00B4D8").opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(selected ? Color(hex: "#00B4D8").opacity(0.5) : Color.clear, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: selected)
    }
}

// MARK: - Step 10 — Notifications

struct OnboardingStep10View: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Stay informed.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#0D1B2A"))
                notifRow("Zone changes", "Enter hostile or supportive area", dot: Color(hex: "#00B4D8"), binding: $coordinator.profile.zoneAlertsEnabled)
                notifRow("Air quality alerts", "AQI or PM2.5 spike", dot: Color(hex: "#00B4D8"), binding: $coordinator.profile.airQualityAlertsEnabled)
                notifRow("Biometric alerts", "HR or HRV threshold", dot: Color(hex: "#FF3B3B"), binding: $coordinator.profile.biometricAlertsEnabled)
                Spacer()
            }
            .padding(.bottom, 46)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 3) {
                    cyanButton("Allow Notifications") {
                        Task { await requestNotifications() }
                    }
                    Button("Skip for now") {
                        coordinator.advance()
                    }
                    .font(.system(size: 9))
                    .foregroundStyle(Color(hex: "#4A6274"))
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
                .background(Color(hex: "#E8F4F8"))
            }
        }
    }

    private func notifRow(_ title: String, _ sub: String, dot: Color, binding: Binding<Bool>) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dot)
                .frame(width: 5, height: 5)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(hex: "#0D1B2A"))
                Text(sub)
                    .font(.system(size: 8))
                    .foregroundStyle(Color(hex: "#4A6274"))
            }
            Spacer()
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(Color(hex: "#00B4D8"))
                .scaleEffect(0.7)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color(hex: "#00B4D8").opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func requestNotifications() async {
        do {
            _ = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch { }
        await MainActor.run { coordinator.advance() }
    }
}

// MARK: - Step 11 — All set

struct OnboardingStep11View: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        WatchOnboardingShell(stepIndex: coordinator.stepIndex, onBack: { coordinator.back() }) {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#00B4D8").opacity(0.12))
                        .frame(width: 36, height: 36)
                    Circle()
                        .strokeBorder(Color(hex: "#00B4D8").opacity(0.3), lineWidth: 0.5)
                        .frame(width: 36, height: 36)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: "#00B4D8"))
                }
                Text("You're ready.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#0D1B2A"))
                Text("Zone intelligence starts now.")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(hex: "#4A6274"))
                VStack(spacing: 2) {
                    summaryRow("Location", "On", valueColor: Color(hex: "#00B4D8"))
                    summaryRow("Health", "Connected", valueColor: Color(hex: "#00B4D8"))
                    summaryRow("Signals", "\(coordinator.profile.selectedSignalsCount) on", valueColor: Color(hex: "#0D1B2A"))
                    summaryRow(
                        "Data",
                        coordinator.profile.anonymousDataOptIn ? "Anonymous" : "Private",
                        valueColor: coordinator.profile.anonymousDataOptIn ? Color(hex: "#00B4D8") : Color(hex: "#4A6274")
                    )
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 38)
            .safeAreaInset(edge: .bottom) {
                cyanButton("Open ENDO") {
                    coordinator.finish()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
                .background(Color(hex: "#E8F4F8"))
            }
        }
    }

    private func summaryRow(_ label: String, _ value: String, valueColor: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(Color(hex: "#4A6274"))
            Spacer()
            Text(value)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color(hex: "#00B4D8").opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: - LocationAuthDelegate

private final class LocationAuthDelegate: NSObject, CLLocationManagerDelegate {
    static var key: UInt8 = 0
    nonisolated(unsafe) var continuation: CheckedContinuation<Bool, Never>?

    init(continuation: CheckedContinuation<Bool, Never>) {
        self.continuation = continuation
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let granted = manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways
        if let cont = continuation {
            continuation = nil
            cont.resume(returning: granted)
        }
    }
}
