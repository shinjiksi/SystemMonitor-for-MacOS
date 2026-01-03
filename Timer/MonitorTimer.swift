import Foundation

final class MonitorTimer {

    private let monitor: SystemMonitor
    private var timer: Timer?

    init(monitor: SystemMonitor) {
        self.monitor = monitor
    }

    func start(interval: TimeInterval, handler: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            handler()
        }
        print("MonitorTimer started")
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
