# SystemMonitor

A lightweight macOS system monitor implemented in Swift.  
Displays CPU usage, memory usage, and network speed in a **monospaced, fixed-width format** suitable for console or menu bar integration.

> ⚠️ This version is **not packaged as a standalone macOS app**. You can integrate the code into your own project.

## Features

- **CPU and memory usage** as percentages (3-digit fixed width, leading zeros replaced with visible placeholder)  
- **Network usage** with automatic unit conversion (Kbps / Mbps / Gbps), integer values, and color-coded quality  
- **Fixed-width display** for stable alignment  
- **Partially colorized output** (network only) using `NSAttributedString`  
- Configurable **update interval** using `MonitorTimer`

---

## File Structure

SystemMonitor/
├─ AppDelegate.swift # Application entry point (optional)
├─ StatusBarController.swift # Menu bar display and formatting
├─ SystemMonitor.swift # CPU, memory, network retrieval and formatting
├─ MonitorTimer.swift # Timer to update monitor periodically

---

## Usage (Command-Line)

You can test or run the monitor from the terminal using Swift scripts or a Playground:

1. Create a Swift file, e.g., `main.swift`, and copy the monitor files into the same folder:

SystemMonitor/
├─ SystemMonitor.swift
├─ MonitorTimer.swift
└─ main.swift

2. In `main.swift`:

```swift
import Foundation

let monitor = SystemMonitor()
let timer = MonitorTimer(monitor: monitor)

timer.start(interval: 1.0) {
    let cpu = monitor.cpuUsage()
    let mem = monitor.memoryUsage()
    let net = monitor.networkUsage()

    print("CPU: \(monitor.formatCPU(cpu)) / MEM: \(monitor.formatMemory(mem)) / NET: ↑\(monitor.formatNetworkSpeed(net.up)) ↓\(monitor.formatNetworkSpeed(net.down))")
}
```
// Keep the script running
RunLoop.main.run()
Run the script in the terminal:
swift main.swift
CPU / Memory are displayed as percentages in 3-digit fixed-width format, with placeholders for leading zeros (e.g., ··5%)
Network speed is displayed as integers with automatic unit conversion (Kbps / Mbps / Gbps), e.g., --5 Mbps


