@testable import SPFKTime
import SPFKUtils
import Testing
import TimecodeKit

final class TimerTests {
    @Test func testTypeEquatable() {
        let timerType1: TimerFactory.TimerType = .repeating(timeInterval: TimerFactory.fps30, qos: .default, leeway: 10)
        let timerType2: TimerFactory.TimerType = .repeating(timeInterval: TimerFactory.fps60, qos: .default, leeway: 10)

        #expect(timerType1 != timerType2)
    }
}
