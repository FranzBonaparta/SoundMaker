# 🎹 SoundMaker

Created by **Jojopov**  
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
[![Built with Love2D](https://img.shields.io/badge/Built%20with-Love2D-ff69b4)](https://love2d.org/)

2025

**SoundMaker** is a small interactive synthesizer built with Love2D.  
Play on a virtual keyboard, tweak sound parameters, and record/replay your own melodies.  
Now with **WAV export** and **MIDI export (beta)**.

## 📷 Screenshots

<p align="center">
  <img src="./pictures/screenshot3.png" alt="Main interface" width="400"/>
  <img src="./pictures/screenshot4.png" alt="Edit instrument" width="400"/>
  <img src="./pictures/screenshot5.png" alt="Save partition" width="400"/>
  <img src="./pictures/screenshot6.png" alt="Load partition" width="400"/>
</p>

---

## 📦 Latest updates

- 💾 **Export to WAV** — Save your current melody as an uncompressed `.wav` file (shortcut: **W**).
- 🎼 **Export to MIDI (beta)** — Save your melody as a Standard MIDI File `.mid` (shortcut: **M**).  
  _Note:_ uses default program/channel/velocity/tempo for now; a proper instrument/track picker is planned.
- 📜 **Partition viewer overhaul** — Correct scrollbar + clear “visible lines” window for long scores.
- 🧼 **General polish & fixes** — Small UI tweaks and stability improvements during record/playback.

_(Previous)_  

- 📝 **Per-note editing** — Buttons on each note to adjust its duration.  
- 💾 **Save/Load** — Instruments and partitions can be saved and reloaded.

---

## ✨ Features

- 🎹 Virtual keyboard (white & black keys, plus a rest key)
- 🎚️ Adjustable note frequencies via sliders
- 🔊 Waveform selection (sine, square, triangle, etc.)
- 📝 Recordable score → replay your melodies and edit each note’s duration
- 🎶 Visual highlighting of played notes
- 💾 Export: **WAV** (stable) & **MIDI** (beta)

---

## ⌨️ Key bindings

### 🎹 Piano controls

- **Left Click** — Play a black note  
- **Middle Click** — Play a white note  
- **Right Click** — Play a quaver (short note)

### 📝 Partition controls

- **Tab** — Play the current partition  
- **Backspace** — Remove the last note  
- **Delete** — Clear the entire partition  
- **Right Click** — On a note’s **+ / −** buttons to edit that note’s duration

### 📤 Export

- **W** — Export current melody to **WAV**  
- **M** — Export current melody to **MIDI** _(beta)_

### 🎧 Programmatic sounds (demo)

- **Space**, **A**, **Z**, **E**, **R**, **T**, **Y**, **1**, **2**, **3** — Trigger custom/synth sounds

---

## 🛠 Requirements

- Any code editor
- **Windows Vista and later** or **Linux**
- **Love2D** (for development or running the `.love` on Linux)

> 📥 Pre-built Windows zips are available in **Releases**.  
> Linux users can run the project directly with Love2D.

---

## 🚀 Run / Install

### Linux (development or run `.love`)
```bash
# Ensure Love2D 11.5 is installed
git clone https://github.com/FranzBonaparta/SoundMaker.git
cd SoundMaker
love .
