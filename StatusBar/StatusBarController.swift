import Cocoa

final class StatusBarController {

    private let statusItem: NSStatusItem
    private let monitor: SystemMonitor
    private let timer: MonitorTimer

    init() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: 350) // 幅は十分に
        self.monitor = SystemMonitor()
        self.timer = MonitorTimer(monitor: monitor)

        setupStatusItem()
        setupMenu()
        startMonitoring()
    }

    private func setupStatusItem() {
        statusItem.button?.title = ""
    }

    private func setupMenu() {
        let menu = NSMenu()
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    private func startMonitoring() {
        timer.start(interval: 1.0) { [weak self] in
            self?.updateStatus()
        }
    }

    private func updateStatus() {
        let cpu = monitor.cpuUsage()
        let mem = monitor.memoryUsage()
        let net = monitor.networkUsage()

        let quality = networkQuality(up: net.up, down: net.down)
        let netColor: NSColor
        switch quality {
        case .bad: netColor = .systemRed
        case .normal: netColor = .labelColor
        case .good: netColor = .systemGreen
        }

        let cpuStr = "CPU \(monitor.formatCPU(cpu))"
        let memStr = "MEM \(monitor.formatMemory(mem))"
        let netStr = "NET ↑\(monitor.formatNetworkSpeed(net.up)) ↓\(monitor.formatNetworkSpeed(net.down))"

        let attr = NSMutableAttributedString()
        let fontAttr: [NSAttributedString.Key: Any] = [.font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)]

        // CPU
        attr.append(NSAttributedString(string: cpuStr, attributes: fontAttr.merging([.foregroundColor: NSColor.labelColor]) { $1 }))
        attr.append(NSAttributedString(string: " / ", attributes: fontAttr))
        // MEM
        attr.append(NSAttributedString(string: memStr, attributes: fontAttr.merging([.foregroundColor: NSColor.labelColor]) { $1 }))
        attr.append(NSAttributedString(string: " / ", attributes: fontAttr))
        // NET
        attr.append(NSAttributedString(string: netStr, attributes: fontAttr.merging([.foregroundColor: netColor]) { $1 }))

        DispatchQueue.main.async {
            self.statusItem.button?.attributedTitle = attr
        }
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private enum NetworkQuality { case bad, normal, good }

    private func networkQuality(up: Double, down: Double) -> NetworkQuality {
        if up < 20_000 || down < 50_000 { return .bad }
        if up < 200_000 || down < 500_000 { return .normal }
        return .good
    }
}
