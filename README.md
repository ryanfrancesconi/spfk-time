# SPFKTime

[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-time)](https://github.com/ryanfrancesconi/spfk-time/tags)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-time%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-time)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-time%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-time)

Support vocabulary for time in media apps: real time, SMPTE timecode, and musical bars and beats,
with the conversions between them. The audio, video and metadata packages and both products'
timelines build on it; nothing embeds it alone.

It writes a position in whichever domain the user has chosen, parses typed timecode loosely, converts
between frame rates, maps between time and pixels for rulers, waveforms and filmstrips, and runs a
display-linked transport clock that follows playback rate changes. Timecode itself comes from
[swift-timecode](https://github.com/orchetect/swift-timecode), which this package extends rather than
replaces.

Frame-rate conversion offers both conventions the industry splits on, keeping the timecode values or
keeping the real-time position, and the caller chooses which.

Sample-level audio types belong in spfk-audio-base, tempo detection in spfk-tempo, and the views that
draw a timeline in spfk-audio-ui and spfk-video-ui. This package says where things are, not what
they look like.

The transport timer is macOS-only; everything else also builds for iOS.

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).
