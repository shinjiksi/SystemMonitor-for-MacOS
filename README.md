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

## Usage

### Integration

1. Copy the following files into your project:  

   - `SystemMonitor.swift`  
   - `StatusBarController.swift`  
   - `MonitorTimer.swift`  

2. Initialize the monitor in your project:

```swift
let monitor = SystemMonitor()
let timer = MonitorTimer(monitor: monitor)

timer.start(interval: 1.0) {
    let cpu = monitor.cpuUsage()
    let mem = monitor.memoryUsage()
    let net = monitor.networkUsage()
    
    print("CPU: \(monitor.formatCPU(cpu)) MEM: \(monitor.formatMemory(mem)) NET: ↑\(monitor.formatNetworkSpeed(net.up)) ↓\(monitor.formatNetworkSpeed(net.down))")
}
The formatted strings are 3-digit fixed width.
CPU / Memory: ·25% (leading placeholders for alignment)
Network: -10 Mbps (unit automatically adjusted)
Network Quality Coloring
Network speed is classified as:
Status    Condition
Good    ↑ ≥ 200 Mbps and ↓ ≥ 500 Mbps
Normal    ↑ 20–200 Mbps or ↓ 50–500 Mbps
Bad    ↑ < 20 Mbps or ↓ < 50 Mbps
In StatusBarController, this is reflected with color coding:
Red for bad
White for normal
Green for good
Requirements
macOS 10.15+
Swift 5+
Xcode recommended for integration
Note: This is not a standalone app. To make it an app, integrate into a macOS App project with NSApplication and a status bar controller.
License
MIT License
MIT License
...
Notes
Network speed measurement uses en0 / en1 interfaces (Ethernet/Wi-Fi).
CPU calculation uses host_cpu_load_info for differential computation.
Memory calculation uses vm_statistics64 for accurate usage stats.
