# SPFKTime

A Swift package for time representation, formatting, and high-precision timing across real-time, timecode (SMPTE), and musical domains. Designed for professional audio/video applications with support for multiple frame rates, tempo-based musical time, and display-linked transport timers.

## Overview

SPFKTime provides three core capabilities:

- **Time Domains** — Unified handling of real time (seconds), SMPTE timecode, and musical time (bars/beats) with conversion between domains.
- **Timecode Extensions** — Flexible timecode parsing, frame rate conversion, signed timecode, and CMTime interop built on top of [SwiftTimecode](https://github.com/orchetect/swift-timecode).
- **High-Precision Timers** — Display-linked transport timers synced to screen refresh rate, plus basic and one-shot timer variants.

## Key Types

### TimeFormatter

Primary interface for managing time across domains. Wraps both a `TimecodeDomain` and a `RealTimeDomain`, producing formatted strings for display based on the active `primaryDomain`.

```swift
var formatter = TimeFormatter(primaryDomain: .timecode)
formatter.update(frameRate: .fps24)
formatter.update(start: startTimecode)
formatter.update(elapsedTime: 3.5)
formatter.primaryString  // "00:00:03:12" (at 24fps)
```

### TimecodeDomain

Manages SMPTE timecode state including frame rate, start offset, and current position. Provides factory methods for creating `Timecode` values with consistent base settings and handles frame rate conversion with strategies matching Pro Tools (preserve values) and Cubase (convert values) behavior.

```swift
let domain = TimecodeDomain()

// Create timecode values using factory methods
let tc = domain.formNewTimecode(wrappingRealTimeSeconds: 10.0)
let fromString = try domain.formNewTimecode(string: "01:00:00:00")

// Frame rate conversion preserving timecode values (Pro Tools behavior)
let preserved = try domain.formNewTimecode(
    preservingValuesFrom: sourceTimecode
)

// Frame rate conversion using real-time position (Cubase behavior)
let converted = try domain.formNewTimecode(
    convertingFrom: sourceTimecode
)

// Signed timecode for offset display
let signed = domain.formNewSignedTimecode(
    seconds: -3.5,
    offsetFromStart: true
)
signed.stringValue()  // "-00:00:03:12"
```

### Timecode Parsing

Flexible timecode string parsing supporting multiple delimiter styles and undelimited shorthand entry (right-to-left digit assignment).

```swift
// Standard delimiters (: ; .)
Timecode.parseUnformattedTimecode(string: "01:00:10:15", frameRate: .fps24)
// -> h1 m0 s10 f15

// Semicolons (drop-frame style)
Timecode.parseUnformattedTimecode(string: "01;00;10;15", frameRate: .fps29_97d)

// Undelimited shorthand -- digits fill frames first, then right-to-left
Timecode.parseUnformattedTimecode(string: "11015", frameRate: .fps24)
// -> 00:01:10:15

// Short entry
Timecode.parseUnformattedTimecode(string: "1:1", frameRate: .fps24)
// -> 00:00:01:01
```

### TransportTimer

Display-linked playback timer that bridges screen refresh to the audio sync domain via `AVAudioTime` / `mach_absolute_time`. Uses `CADisplayLink` on macOS 14+ with automatic `CVDisplayLink` fallback on earlier systems.

```swift
// Bind to a view's display
let timer = TransportTimer(on: view)

timer.eventHandler = { event in
    switch event {
    case .state(let playState):
        print(playState.isPlaying)  // true for .start/.resume
    case .time(let elapsed):
        print(elapsed)  // seconds since start
    case .complete:
        break
    }
}

timer.start(at: 0.0)       // begin from 0s
timer.pause()               // freeze position
timer.resume()              // continue from paused position
timer.stop()                // stop playback
timer.currentTime           // last elapsed time
timer.fps                   // display refresh rate
```

### Musical Time

Types for tempo-aware musical time representation, position tracking, and visual rendering.

```swift
// Define a measure from tempo + time signature
let measure = MusicalMeasureDescription(
    timeSignature: ._4_4,
    tempo: Bpm(120)
)
measure.duration(pulse: .bar)       // 2.0 seconds
measure.duration(pulse: .quarter)   // 0.5 seconds
measure.barsPerSecond               // 0.5

// Snap to nearest musical boundary
let offset = MusicalMeasureDescription.timeToNearest(
    pulse: .quarter,
    measure: measure,
    at: 1.3,
    direction: .forward
)

// Musical position display (1-based bar/beat/subdivision)
var position = MusicalPulseDescription()
position.measure = measure
position.update(time: 5.0)
position.stringValue  // "3 1 1" (bar 3, beat 1, subdivision 1)

// Pixel layout for timeline drawing
let visual = try VisualMusicalPulse(
    pixelsPerSecond: 100,
    measure: measure
)
visual.width(of: .bar)      // 200.0 pixels
visual.width(of: .quarter)  // 50.0 pixels
```

### Timer Factory

General-purpose timers for non-transport use cases. All conform to the `TimerModel` protocol.

```swift
// Main-thread NSTimer
let basic = TimerFactory.createTimer(.basic(timeInterval: 1.0 / 30))

// Single-fire delayed execution
let oneShot = TimerFactory.createTimer(.oneShot(timeInterval: 0.5))

// Background repeating timer
let repeating = TimerFactory.createTimer(
    .repeating(timeInterval: TimerFactory.fps60, qos: .userInteractive)
)

repeating.eventHandler = { /* called each tick */ }
repeating.resume()
repeating.suspend()
repeating.dispose()
```

### CMTime Utilities

FCPXML-compatible `CMTime` string formatting and parsing.

```swift
// Format as FCPXML string
let time = CMTime(value: 100, timescale: 24)
time.stringValue  // "100/24s"

// Parse from FCPXML string
CMTimeString.parse(string: "100/24s")  // CMTime(value: 100, timescale: 24)

// Create from timecode or seconds
CMTimeString.create(timecode: tc)  // "3612/24s"
CMTimeString.create(seconds: 10.0, frameRate: .fps24)
```

## Architecture

```
Definitions/
  ├── TimeDomain                    — Time domain enum (realTime, timecode, musical)
  ├── TimeDisplayFormat             — Display format choice (timecode vs seconds)
  ├── TimeSignature                 — Musical time signatures with validation
  ├── MusicalPulse                  — Beat subdivision enum (bar, quarter, eighth, sixteenth)
  ├── MusicalPulseDescription       — Musical position from seconds (bar/beat/subdivision)
  ├── MusicalMeasureDescription     — Tempo + time signature -> pulse durations
  ├── VisualMusicalPulse            — Pixel widths for musical elements at a zoom level
  ├── VisualMusicalTime             — Combined zoom/tempo/signature -> visual pulse
  ├── TimelineDrawable              — Protocol for views mapping pixels <-> time
  ├── TimelineRulerDrawingScale     — Zoom-dependent ruler spacing multipliers
  └── TimelineRulerViewOptions      — Timeline ruler display configuration

TimeFormatter/
  ├── TimeFormatter                 — Multi-domain time display formatting
  └── TimecodeDomain                — Timecode state, factory methods, frame rate conversion

Timecode Extensions/
  ├── SignedTimecode                — Positive/negative timecode wrapper
  ├── Timecode Parse                — Flexible timecode string parsing
  ├── Timecode Properties           — Rounding, CMTime conversion, zero convenience
  └── FrameRate Extensions          — Float value, frame duration, legacy string init

Utilities/
  ├── CMTimeString                  — FCPXML time string parsing and creation
  ├── CMTime+Utilities              — CMTime extensions (stringValue, .one, video timescale)
  └── Timers/
      ├── TimerModel                — Timer protocol (resume, suspend, dispose)
      ├── TimerState                — Timer state enum (suspended, resumed)
      ├── TimerFactory              — Factory for creating timer instances
      ├── BasicTimer                — Main-thread NSTimer wrapper
      ├── OneShotTimer              — Single-fire DispatchWorkItem timer
      ├── RepeatingTimer            — DispatchSourceTimer wrapper (crash-safe resume)
      ├── TransportTimer            — Display-linked playback timer (AVAudioTime sync)
      ├── TransportTimerEvent       — Transport state and elapsed-time events
      ├── DisplayLinkTimer          — CADisplayLink wrapper (macOS 14+)
      ├── LegacyDisplayLinkTimer    — CVDisplayLink fallback (pre-macOS 14)
      └── DisplayLink               — Core CVDisplayLink wrapper (deprecated)
```

## Dependencies

| Package | Purpose |
|---------|---------|
| [spfk-base](https://github.com/ryanfrancesconi/spfk-base) | Foundation extensions, logging, error utilities |
| [spfk-utils](https://github.com/ryanfrancesconi/spfk-utils) | String utilities, collection extensions |
| [swift-timecode](https://github.com/orchetect/swift-timecode) | Core timecode types and frame rate definitions |
| [spfk-testing](https://github.com/ryanfrancesconi/spfk-testing) | Test infrastructure (test target only) |

## Requirements

- macOS 12+ / iOS 15+
- Swift 6.2+
