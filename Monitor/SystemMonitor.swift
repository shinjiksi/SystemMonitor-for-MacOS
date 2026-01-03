import Foundation
import Darwin
import SystemConfiguration

final class SystemMonitor {

    // MARK: - CPU
    private var previousCPULoad: host_cpu_load_info?

    func cpuUsage() -> Double {
        var load = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &load) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        guard let prev = previousCPULoad else { previousCPULoad = load; return 0 }

        let user = Double(load.cpu_ticks.0 - prev.cpu_ticks.0)
        let system = Double(load.cpu_ticks.1 - prev.cpu_ticks.1)
        let idle = Double(load.cpu_ticks.2 - prev.cpu_ticks.2)
        let nice = Double(load.cpu_ticks.3 - prev.cpu_ticks.3)

        let total = user + system + idle + nice
        let used = total - idle
        previousCPULoad = load
        guard total > 0 else { return 0 }
        return (used / total) * 100.0
    }

    // MARK: - Memory
    func memoryUsage() -> Double {
        var stats = vm_statistics64()
        var count = UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }

        let pageSize = Double(vm_kernel_page_size)
        let wired = Double(stats.wire_count) * pageSize
        let active = Double(stats.active_count) * pageSize
        let compressed = Double(stats.compressor_page_count) * pageSize
        let used = wired + active + compressed
        let total = Double(ProcessInfo.processInfo.physicalMemory)
        return (used / total) * 100.0
    }

    // MARK: - Network
    private var prevIn: UInt64 = 0
    private var prevOut: UInt64 = 0
    private var lastTime: Date = Date()

    func networkUsage() -> (down: Double, up: Double) {
        var ifaddrPtr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddrPtr) == 0, let firstPtr = ifaddrPtr else { return (0,0) }

        var inBytes: UInt64 = 0
        var outBytes: UInt64 = 0
        var ptr: UnsafeMutablePointer<ifaddrs>? = firstPtr
        while let current = ptr {
            let ifa = current.pointee
            if let data = ifa.ifa_data?.assumingMemoryBound(to: if_data.self) {
                inBytes += UInt64(data.pointee.ifi_ibytes)
                outBytes += UInt64(data.pointee.ifi_obytes)
            }
            ptr = ifa.ifa_next
        }
        freeifaddrs(ifaddrPtr)

        let now = Date()
        let interval = now.timeIntervalSince(lastTime)
        guard interval > 0 else { return (0,0) }

        let downSpeed = Double(inBytes - prevIn) * 8 / interval
        let upSpeed = Double(outBytes - prevOut) * 8 / interval
        prevIn = inBytes
        prevOut = outBytes
        lastTime = now

        return (downSpeed, upSpeed)
    }

    // MARK: - Formatting

    /// CPU / MEM: 常に3桁幅、0はスペース
    func formatCPU(_ cpu: Double) -> String {
        let intPart = Int(round(cpu))
        let hundreds = intPart / 100
        let tens = (intPart % 100) / 10
        let ones = intPart % 10

        let h = hundreds == 0 ? "-" : "\(hundreds)"
        let t = (tens == 0 && hundreds == 0) ? "-" : "\(tens)"
        let o = "\(ones)"
        return "\(h)\(t)\(o)%"
    }

    func formatMemory(_ mem: Double) -> String {
        let intPart = Int(round(mem))
        let hundreds = intPart / 100
        let tens = (intPart % 100) / 10
        let ones = intPart % 10

        let h = hundreds == 0 ? "-" : "\(hundreds)"
        let t = (tens == 0 && hundreds == 0) ? "-" : "\(tens)"
        let o = "\(ones)"
        return "\(h)\(t)\(o)%"
    }

    func formatNetworkSpeed(_ bitsPerSec: Double) -> String {
        var value: Double
        var unit: String
        if bitsPerSec >= 1_000_000_000 { value = bitsPerSec / 1_000_000_000; unit = "Gbps" }
        else if bitsPerSec >= 1_000_000 { value = bitsPerSec / 1_000_000; unit = "Mbps" }
        else { value = bitsPerSec / 1_000; unit = "Kbps" }

        let intVal = Int(round(value))
        let hundreds = intVal / 100
        let tens = (intVal % 100) / 10
        let ones = intVal % 10

        let h = hundreds == 0 ? "-" : "\(hundreds)"
        let t = (tens == 0 && hundreds == 0) ? "-" : "\(tens)"
        let o = "\(ones)"
        return "\(h)\(t)\(o) \(unit)"
    }

}
