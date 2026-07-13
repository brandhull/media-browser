# Bro

Native macOS app for browsing folders of photos and videos — a faster,
lighter replacement for Finder when reviewing a shoot. Open a folder, see
thumbnails, sort by name or date, click a file for Get Info–style details
(dimensions, duration, codec, frame rate, bit rate), double-click to play or
view full-size. Drill into subfolders with a breadcrumb trail; no sidebar
tree needed.

No Electron, no dependencies — a single small Swift/SwiftUI app that hands
off thumbnailing to QuickLook and playback to AVKit, so it gets native codec
support (including HEVC/.mov from iPhones) for free.

## Features

- Thumbnail grid for photos and videos, resizable via a Finder-style size
  slider
- Sort by name, date created, date modified, or last opened
- Click a file for a Get Info–style detail pane: kind, size, dimensions,
  duration, codec, frame rate, bit rate, and dates
- Double-click to open a lightbox (AVKit video playback / full-size image)
- Subfolder navigation with a clickable breadcrumb bar
- "Show in Finder" to jump to the real file
- Remembers the last folder you had open
- No data saved anywhere else — it's just a viewer

## Setup

Build and install (needs only Xcode Command Line Tools, not Xcode itself):

```sh
./build.sh --install
```

This builds a release binary, packages it into `Bro.app`, ad-hoc code-signs
it, and installs it to `/Applications`.

To just build without installing:

```sh
./build.sh
```

## Requirements

macOS 13 (Ventura) or later.
