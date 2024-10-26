# q_ignite - Vehicle Engine Control System

A comprehensive vehicle engine management system that enhances realism by requiring manual engine control. Players must explicitly start and stop their vehicle's engine, bringing a more immersive driving experience to FiveM servers.

## Features
- **Manual Engine Control**: Engines are off by default when entering vehicles and must be started manually
- **Smart Engine Status UI**: 
  - Shows engine ignition prompt when entering vehicles
  - Displays engine shutdown option after being stationary for 6 seconds
  - Smooth UI transitions with configurable delays
- **Vehicle Exclusion System**: Ability to exclude specific vehicle models (e.g., emergency vehicles)
- **Fully Configurable**:
  - Customizable key bindings
  - Adjustable UI position and appearance
  - Configurable timings for all features
  - Toggle-able sound effects

## Dependencies
- ox_lib

## Installation
1. Ensure you have `ox_lib` installed on your server
2. Drop the `q_ignite` folder into your server's resources directory
3. Add `ensure q_ignite` to your `server.cfg`
4. Configure settings in `config.lua` as needed

## Default Controls
- `F5` - Toggle engine on/off
- Engine automatically turns off when exiting vehicles
- Must manually start engine when entering vehicles

## Configuration
All settings can be adjusted in `config.lua`, including:
- Key bindings
- UI appearance and position
- Timing delays
- Sound effects
- Vehicle blacklist

## Credits
Created by quantum.
