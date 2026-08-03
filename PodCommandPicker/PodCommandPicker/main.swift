import SwiftUI
import AppKit
import Combine

final class XcodeInfo: ObservableObject {
    @Published var version: String = "(...)"

    init() {
        load()
    }

    private func load() {
        Task {
            let v = Self.fetch()
            await MainActor.run {
                self.version = v
            }
        }
    }

    private static func fetch() -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.launchPath = "/usr/bin/xcodebuild"
        task.arguments = ["-version"]

        do { try task.run() } catch { return "" }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        return output
            .split(separator: "\n")
            .first?
            .split(separator: " ")
            .dropFirst()
            .first
            .map { "(\($0))" } ?? ""
    }
}


let windowWidth: CGFloat = 620
let windowHeight: CGFloat = 520
let rowCornerRadius: CGFloat = 20

final class AppState: ObservableObject {
    @Published var selectedIndex: Int = 3
    @Published var showContent: Bool = false
    
    weak var delegate: AppDelegate?
    
    let options = [
        "输入 Pod 指令",
        "pod install",
        "pod update",
        "pod update --no-repo-update"
    ]
    
    func confirm() {
        delegate?.finish(with: options[selectedIndex])
    }
    
    func cancel() {
        delegate?.finish(with: "false")
    }
}

struct ContentView: View {
    @StateObject private var xcodeInfo = XcodeInfo()
    @ObservedObject var state: AppState
    let title: String
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 0) {
                HeaderView(title: title, xcodeVersion: xcodeInfo.version)
                    .scaleEffect(state.showContent ? 1.0 : 0.86)
                    .opacity(state.showContent ? 1.0 : 0.0)
                    .offset(y: state.showContent ? 0 : -18)
                    .padding(.bottom, 32)
                    .animation(
                        .interpolatingSpring(stiffness: 620, damping: 34).delay(0.005),
                        value: state.showContent
                    )
                
                VStack(spacing: 10) {
                    ForEach(state.options.indices, id: \.self) { index in
                        CommandRow(
                            title: state.options[index],
                            subtitle: subTitle(index),
                            iconName: icon(index),
                            number: index + 1,
                            selected: index == state.selectedIndex
                        )
                        .opacity(state.showContent ? 1.0 : 0.0)
                        .scaleEffect(state.showContent ? 1.0 : 0.90)
                        .offset(y: state.showContent ? 0 : 22)
                        .animation(
                            .interpolatingSpring(stiffness: 680, damping: 36)
                            .delay(0.015 + Double(index) * 0.012),
                            value: state.showContent
                        )
                        .onTapGesture {
                            if state.selectedIndex == index {
                                state.confirm()
                            } else {
                                state.selectedIndex = index
                            }
                        }
                    }
                }
                
                FooterView()
                    .opacity(state.showContent ? 1.0 : 0.0)
                    .scaleEffect(state.showContent ? 1.0 : 0.92)
                    .offset(y: state.showContent ? 0 : 16)
                    .padding(.top, 18)
                    .animation(
                        .interpolatingSpring(stiffness: 620, damping: 34).delay(0.07),
                        value: state.showContent
                    )
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            .padding(.bottom, 6)
        }
        .frame(width: windowWidth, height: windowHeight)
    }
    
    func subTitle(_ index: Int) -> String {
        switch index {
        case 0: return "执行自定义命令"
        case 1: return "同步当前项目依赖"
        case 2: return "更新所有依赖版本"
        default: return "快速更新（跳过索引）"
        }
    }
    
    func icon(_ index: Int) -> String {
        switch index {
        case 0: return "terminal"
        case 1: return "arrow.down.circle"
        case 2: return "arrow.triangle.2.circlepath"
        default: return "paperplane.fill"
        }
    }
}

struct HeaderView: View {
    let title: String
    let xcodeVersion: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            xcodeIcon
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .shadow(color: .green.opacity(0.8), radius: 6)
                    
                    Text("Xcode \(xcodeVersion)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.58))
                }
                
                Text(title.isEmpty ? "Current Project" : title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                .white,
                                Color.cyan.opacity(0.95),
                                Color.blue.opacity(0.88),
                                .white
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.35), radius: 14)
                    .shadow(color: .black.opacity(0.75), radius: 4)
                
                Text("Pod Command Center")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.42))
                    .tracking(0.5)
            }
            
            Spacer()
        }
    }
    
    var xcodeIcon: some View {
        Image(nsImage: NSWorkspace.shared.icon(forFile: "/Applications/Xcode.app"))
            .resizable()
            .interpolation(.high)
            .frame(width: 56, height: 56)
            .clipShape(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .blue.opacity(0.45), radius: 18)
    }
}

struct KeyLabel: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .black))
            .foregroundColor(.white.opacity(0.86))
            .padding(.horizontal, text.count > 1 ? 10 : 7)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.white.opacity(0.09))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

struct CommandRow: View {
    let title: String
    let subtitle: String
    let iconName: String
    let number: Int
    let selected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            IconView(iconName: iconName, selected: selected)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white.opacity(0.96))
                    .shadow(color: .black.opacity(0.7), radius: 3)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.58))
                    .shadow(color: .black.opacity(0.55), radius: 2)
            }
            
            Spacer()
            
            Text("\(number)")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white.opacity(0.88))
                .frame(width: 34, height: 34)
                .background(numberBackground)
                .overlay(numberBorder)
        }
        .padding(.horizontal, 18)
        .frame(height: 72)
        .background(rowFill)
        .overlay(rowBorder)
        .shadow(
            color: selected ? Color.cyan.opacity(0.46) : Color.black.opacity(0.26),
            radius: selected ? 18 : 8,
            y: selected ? 6 : 4
        )
        .scaleEffect(selected ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: selected)
    }
    
    var rowFill: some View {
        RoundedRectangle(cornerRadius: rowCornerRadius, style: .continuous)
            .fill(selected ? Color.blue.opacity(0.28) : Color.white.opacity(0.055))
            .background(
                RoundedRectangle(cornerRadius: rowCornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: rowCornerRadius, style: .continuous))
    }
    
    var rowBorder: some View {
        RoundedRectangle(cornerRadius: rowCornerRadius, style: .continuous)
            .stroke(
                selected ? Color.cyan.opacity(0.95) : Color.white.opacity(0.14),
                lineWidth: selected ? 2.0 : 1.0
            )
    }
    
    var numberBackground: some View {
        RoundedRectangle(cornerRadius: 11, style: .continuous)
            .fill(Color.white.opacity(0.075))
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }
    
    var numberBorder: some View {
        RoundedRectangle(cornerRadius: 11, style: .continuous)
            .stroke(Color.white.opacity(0.16), lineWidth: 1)
    }
}

struct IconView: View {
    let iconName: String
    let selected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(
                    selected
                    ? LinearGradient(
                        colors: [.cyan.opacity(0.9), .blue.opacity(0.95)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: [.white.opacity(0.14), .white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Image(systemName: iconName)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.45), radius: 3)
        }
        .frame(width: 50, height: 50)
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color.white.opacity(selected ? 0.42 : 0.14), lineWidth: 1)
        )
        .shadow(
            color: selected ? .cyan.opacity(0.42) : .black.opacity(0.20),
            radius: selected ? 14 : 7
        )
    }
}

struct FooterView: View {
    var body: some View {
        HStack(spacing: 7) {
            KeyLabel("↑")
            KeyLabel("↓")
            Text("选择，")
            KeyLabel("1-4")
            Text("或")
            KeyLabel("Enter")
            Text("执行，")
            KeyLabel("Esc")
            Text("退出")
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundColor(.white.opacity(0.58))
        .padding(.top, 2)
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.06, blue: 0.12),
                    Color(red: 0.04, green: 0.10, blue: 0.22),
                    Color(red: 0.14, green: 0.08, blue: 0.24),
                    Color(red: 0.03, green: 0.03, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Circle()
                .fill(Color.blue.opacity(0.50))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: -220, y: 150)
            
            Circle()
                .fill(Color.purple.opacity(0.40))
                .frame(width: 340, height: 340)
                .blur(radius: 100)
                .offset(x: 240, y: 130)
            
            Circle()
                .fill(Color.cyan.opacity(0.22))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .offset(x: -120, y: -210)
            
            Rectangle()
                .fill(Color.black.opacity(0.18))
                .background(.ultraThinMaterial)
        }
    }
}

final class KeyWindow: NSWindow {
    let state: AppState
    
    init(state: AppState, contentRect: NSRect) {
        self.state = state
        
        super.init(
            contentRect: contentRect,
            styleMask: [.fullSizeContentView, .titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        self.isMovableByWindowBackground = true
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
    }
    
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    
    override func keyDown(with event: NSEvent) {
        let chars = event.charactersIgnoringModifiers ?? ""
        
        if let number = Int(chars),
           number >= 1,
           number <= state.options.count {
            
            let index = number - 1
            
            if state.selectedIndex == index {
                state.confirm()
            } else {
                state.selectedIndex = index
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    self.state.confirm()
                }
            }
            
            return
        }
        
        if event.keyCode == 126 {
            state.selectedIndex = max(0, state.selectedIndex - 1)
            return
        }
        
        if event.keyCode == 125 {
            state.selectedIndex = min(state.options.count - 1, state.selectedIndex + 1)
            return
        }
        
        if event.keyCode == 36 ||
            event.keyCode == 76 ||
            chars == "\r" ||
            chars == "\n" {
            
            state.confirm()
            return
        }
        
        if event.keyCode == 53 {
            state.cancel()
            return
        }
        
        super.keyDown(with: event)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let title: String
    let state = AppState()
    var window: KeyWindow?
    var isTerminating = false
    
    init(title: String) {
        self.title = title
        super.init()
        self.state.delegate = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let rect = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        
        let window = KeyWindow(state: state, contentRect: rect)
        window.delegate = self
        window.title = title
        window.center()
        window.isReleasedWhenClosed = false
        window.isOpaque = true
        window.backgroundColor = NSColor.windowBackgroundColor
        window.alphaValue = 0.0
        window.hasShadow = true
        window.level = .floating
        
        let hostingView = NSHostingView(
            rootView: ContentView(state: state, title: title)
        )
        
        hostingView.wantsLayer = true
        hostingView.layer?.masksToBounds = true
        
        window.contentView = hostingView
        self.window = window
        
        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)
        
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(window)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.16
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().alphaValue = 0.99
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.state.showContent = true
        }
    }
    
    func finish(with result: String) {
        guard !isTerminating else { return }
        isTerminating = true
        
        guard let window = window else {
            print(result)
            fflush(stdout)
            NSApp.terminate(nil)
            return
        }
        
        state.showContent = false
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.13
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0.0
        }, completionHandler: {
            print(result)
            fflush(stdout)
            NSApp.terminate(nil)
        })
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        state.cancel()
        return false
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

let title = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ""

let app = NSApplication.shared
let delegate = AppDelegate(title: title)
app.delegate = delegate
app.run()


// 进入终端执行生成可执行文件：swiftc main.swift -o ~/Desktop/PodCommandPickerTool
