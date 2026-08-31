# SPFKTime

[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-time)](https://github.com/ryanfrancesconi/spfk-time/tags)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-time%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-time)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-time%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-time)

A Swift package for time representation, formatting, and high-precision timing across real-time, timecode (SMPTE), and musical domains. Designed for professional audio/video applications with support for multiple frame rates, tempo-based musical time, and display-linked transport timers.

## Overview

SPFKTime provides three core capabilities:

- **Time Domains** — Unified handling of real time (seconds), SMPTE timecode, and musical time (bars/beats) with conversion between domains.
- **Timecode Extensions** — Flexible timecode parsing, frame rate conversion, signed timecode, and CMTime interop built on top of [SwiftTimecode](https://github.com/orchetect/swift-timecode).
- **High-Precision Timers** — Display-linked transport timers synced to screen refresh rate, plus basic and one-shot timer variants.

## Key Types

### TimeFormatter

The primary interface for managing time across domains. It wraps a `TimecodeDomain` and a
`RealTimeDomain` together and produces the display string for whichever `primaryDomain` is active,
so a UI switching between real time and timecode reads one property rather than branching.
`TimeDomain` names the three — real time, timecode, bars — and carries a label for each.
`TimeDisplayFormat` says how a value is written out.

### TimecodeDomain

Manages SMPTE timecode state — frame rate, start offset, current position — and vends `Timecode`
values with consistent base settings. Frame-rate conversion offers both strategies the industry
splits on: preserving the timecode values as Pro Tools does, or converting through the real-time
position as Cubase does. `SignedTimecode` covers offset display, where a value can be negative.

### Timecode Parsing

Flexible string parsing across delimiter styles — colons, semicolons for drop-frame, periods — plus
undelimited shorthand, where digits fill frames first and then assign right to left, so `11015`
reads as `00:01:10:15` and `1:1` as `00:00:01:01`.

### TransportTimer

Display-linked playback timer bridging screen refresh to the audio sync domain via `AVAudioTime` /
`mach_absolute_time`. Uses `CADisplayLink` on macOS 14+ with an automatic `CVDisplayLink` fallback
on earlier systems. It reports `TransportTimerEvent` values — state changes, elapsed time and
completion — and `TransportTimerPlayState` says whether the transport is running.

### Musical Time

Types for tempo-aware musical time representation, position tracking and visual rendering.

| Type | Description |
|------|-------------|
| **`MusicalPulse`** | A note division — bar, quarter, eighth and the rest |
| **`TimeSignature`** | Numerator and denominator |
| **`MusicalMeasureDescription`** | Tempo and signature together — one bar's shape |
| **`MusicalPulseDescription`** | A 1-based bar/beat/subdivision position, updated from a time |
| **`VisualMusicalPulse`** | The pixel width of each division at a given zoom |
| **`VisualMusicalTime`** | Zoom, tempo and signature combined, recomputing the pulse when any changes |

## Timeline drawing

`TimelineDrawable` is what a view conforms to in order to map between pixel coordinates and time —
rulers, waveform displays, the video filmstrip. `TimelineRulerViewOptions` configures a ruler
header, and `TimelineRulerDrawingScale` picks which divisions are legible at the current zoom.

## Timer factory

`TimerFactory` builds general-purpose timers for non-transport use — a main-thread `NSTimer`, a
single-fire delayed one, and a background repeating one at a chosen QoS. All conform to
`TimerModel`.

## CMTime utilities

`CMTimeString` reads and writes the FCPXML `CMTime` form (`100/24s`), and builds one from a timecode
or from seconds at a frame rate.

## Dependencies

| Package | Purpose |
|---------|---------|
| [spfk-audio-base](https://github.com/ryanfrancesconi/spfk-audio-base) | Audio type definitions for timeline coordinates |
| [spfk-base](https://github.com/ryanfrancesconi/spfk-base) | Foundation extensions, logging, error utilities |
| [spfk-utils](https://github.com/ryanfrancesconi/spfk-utils) | String utilities, collection extensions |
| [swift-timecode](https://github.com/orchetect/swift-timecode) | Core timecode types and frame rate definitions |
| [spfk-testing](https://github.com/ryanfrancesconi/spfk-testing) | Test infrastructure (test target only) |

## Requirements

- **Platforms:** macOS 13+, iOS 16+
- **Swift:** 6.2+

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).
