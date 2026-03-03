# SPFKTime

A Swift package for time representation, formatting, and high-precision timing across real-time, timecode (SMPTE), and musical domains. Designed for professional audio/video applications with support for multiple frame rates, tempo-based musical time, and display-linked transport timers.

## Overview

SPFKTime provides three core capabilities:

- **Time Domains** — Unified handling of real time (seconds), SMPTE timecode, and musical time (bars/beats) with conversion between domains.
- **Timecode Extensions** — Flexible timecode parsing, frame rate conversion, signed timecode, and CMTime interop built on top of [SwiftTimecode](https://github.com/orchetect/swift-timecode).
- **High-Precision Timers** — Display-linked transport timers synced to screen refresh rate, plus basic and one-shot timer variants.

## Key Types

### TimeFormatter

Primary interface for managing time across domains. Wraps both a `TimecodeDomain` and real-time tracking, producing formatted strings for display.

```swift
let formatter = TimeFormatter()
formatter.update(frameRate: .fps24)
formatter.update(start: startTimecode)
formatter.update(elapsedTime: 3.5)
formatter.primaryString  // formatted time output
```

### TimecodeDomain

Advanced timecode state management with frame rate conversion strategies, start timecode offsets, and subframe precision.

```swift
let domain = TimecodeDomain(frameRate: .fps25)
domain.update(elapsedTime: 10.0)
domain.timecode  // current Timecode value

// Frame rate conversion preserving timecode values
let converted = domain.formNewTimecode(
    preservingValuesFrom: sourceTimecode,
    at: .fps24
)
```

### SignedTimecode

Wraps `Timecode` with an optional negative sign for values that can be offset from a reference point.

```swift
let signed = SignedTimecode(timecode: tc, sign: .minus)
signed.stringValue  // "-01:00:00:00"
```

### Timecode Parsing

Flexible timecode string parsing supporting multiple delimiter styles and shorthand entry.

```swift
// Standard delimiters
Timecode.parseUnformattedTimecode(string: "01:00:10:15", frameRate: .fps24)

// Semicolons (drop-frame style)
Timecode.parseUnformattedTimecode(string: "01;00;10;15", frameRate: .fps29_97d)

// Undelimited shorthand (right-to-left)
Timecode.parseUnformattedTimecode(string: "11015", frameRate: .fps24)
// -> 00:01:10:15
```

### TransportTimer

High-precision timer for media playback, synced to the display refresh rate via `CADisplayLink` (macOS 14+) or `CVDisplayLink` (legacy).

```swift
let timer = TransportTimer()
timer.eventHandler = { event in
    switch event {
    case .state(let state): // .start, .stop, .pause, .resume
    case .time(let seconds): // elapsed time update
    case .complete: break
    }
}
timer.start(at: 0.0)
timer.pause()
timer.resume()
timer.stop()
```

### Musical Time

Types for tempo-aware musical time representation:

```swift
// Define a measure
let measure = MusicalMeasureDescription(
    tempo: Bpm(120),
    timeSignature: .default  // 4/4
)
measure.duration(pulse: .bar)       // 2.0 seconds
measure.duration(pulse: .quarter)   // 0.5 seconds

// Snap to nearest beat
measure.timeToNearest(time: 1.3, pulse: .quarter)  // 1.5

// Visual rendering
let visual = VisualMusicalPulse(
    pixelsPerSecond: 100,
    measure: measure
)
visual.width(of: .bar)      // 200.0 pixels
visual.width(of: .quarter)  // 50.0 pixels
```

### CMTime Utilities

FCPXML-compatible `CMTime` string formatting and parsing.

```swift
// Format
let time = CMTimeMake(value: 100, timescale: 24)
time.stringValue  // "100/24s"

// Parse
CMTimeString.parse(string: "100/24s")  // CMTime(value: 100, timescale: 24)

// Create from timecode
CMTimeString.create(timecode: tc)  // FCPXML time string
```

## Architecture

```
Definitions/
  ├── TimeSignature.swift             — Musical time signatures with validation
  ├── MusicalPulse.swift              — Beat division enum (bar, quarter, eighth, sixteenth)
  ├── MusicalPulseDescription.swift   — Musical position tracking (bar/beat/subdivision)
  ├── MusicalMeasureDescription.swift — Tempo + time signature -> pulse durations
  ├── VisualMusicalPulse.swift        — Pixel dimensions for musical elements
  ├── VisualMusicalTime.swift         — Combined visual rendering parameters
  ├── TimeDomain.swift                — Time domain enum (realTime, timecode, musical)
  ├── TimeDisplayFormat.swift         — Display format enum (timecode, seconds)
  ├── TimelineRulerDrawingScale.swift — Zoom-dependent ruler spacing
  ├── TimelineRulerViewOptions.swift  — Timeline ruler display options
  └── TimelineDrawable.swift          — Protocol for timeline-drawable elements

TimeFormatter/
  ├── TimeFormatter.swift             — Multi-domain time display formatting
  └── TimecodeDomain.swift            — Timecode state, frame rate conversion

Timecode Extensions/
  ├── SignedTimecode.swift             — Positive/negative timecode wrapper
  ├── Timecode Parse.swift            — Flexible timecode string parsing
  ├── Timecode Properties.swift       — Rounding, CMTime conversion, zero
  └── FrameRate Extensions.swift      — Float value, frame duration, legacy strings

Utilities/
  ├── CMTimeString.swift              — FCPXML time string parsing and creation
  ├── CMTime+Utilities.swift          — CMTime extensions (stringValue, .one)
  └── Timers/
      ├── TimerModel.swift            — Timer protocol (state, resume, suspend)
      ├── TimerState.swift            — Timer state enum (suspended, resumed)
      ├── TimerFactory.swift          — Factory for creating timer instances
      ├── BasicTimer.swift            — Main-thread NSTimer wrapper
      ├── OneShotTimer.swift          — Single-fire DispatchWorkItem timer
      ├── RepeatingTimer.swift        — DispatchSourceTimer wrapper
      ├── TransportTimer.swift        — Display-linked playback timer
      ├── TransportTimerEvent.swift   — Transport state and time events
      ├── DisplayLinkTimer.swift      — CADisplayLink wrapper (macOS 14+)
      ├── LegacyDisplayLinkTimer.swift — CVDisplayLink fallback
      └── DisplayLink.swift           — Core CVDisplayLink wrapper
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
