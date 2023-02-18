import Foundation
import Combine

extension Publisher where Failure == Never {
    
    internal func receiveOnMain() -> Publishers.ReceiveOn<Self, ImmediateMainScheduler>  {
        receive(on: ImmediateMainScheduler())
    }
}

internal struct ImmediateMainScheduler: Scheduler {
    
    public typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    public typealias SchedulerOptions = DispatchQueue.SchedulerOptions
    
    // DispatchTime(uptimeNanoseconds: 0) == .now())`. Use `1` for consistency.
    public let now: DispatchQueue.SchedulerTimeType = .init(.init(uptimeNanoseconds: 1))
    public let minimumTolerance: DispatchQueue.SchedulerTimeType.Stride = .zero
    
    public func schedule(
        after date: DispatchQueue.SchedulerTimeType,
        interval: DispatchQueue.SchedulerTimeType.Stride,
        tolerance: DispatchQueue.SchedulerTimeType.Stride,
        options: DispatchQueue.SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        fatalError("Schedule after isn't supported!")
    }
    
    public func schedule(
        after date: DispatchQueue.SchedulerTimeType,
        tolerance: DispatchQueue.SchedulerTimeType.Stride,
        options: DispatchQueue.SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        executeOnMainThread {
            action()
        }
    }
    
    public func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
        executeOnMainThread {
            action()
        }
    }
    
    private func executeOnMainThread(_ executable: @escaping () -> Void) {
        if Thread.current.isMainThread {
            executable()
        } else {
            DispatchQueue.main.async {
                executable()
            }
        }
    }
}

