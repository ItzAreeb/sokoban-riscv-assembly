# Sokoban - RISC-V Assembly Implementation

A complete implementation of the classic Sokoban puzzle game in RISC-V assembly, featuring multiplayer competitive mode, procedurally generated boards, and a leaderboard system.

## Features

- **Classic Sokoban gameplay** - Push boxes onto targets to solve puzzles
- **Multiplayer competitive mode** - Players take turns solving the same puzzle; fewest moves wins
- **Random board generation** - New layouts each game (configurable grid size)
- **Move tracking** - Count moves per player/session
- **Leaderboard system** - Ranks players by performance after each round
- **Forfeit option** - Skip impossible puzzles and stay competitive

## Controls

| Key | Action |
|-----|--------|
| W | Move up |
| A | Move left |
| S | Move down |
| D | Move right |
| R | Restart current board |
| N | Generate new random board |
| G | Forfeit current game |

## Running the Game

1. Open **CPUlator RISC-V Simulator**: https://cpulator.01xz.net/?sys=rv32-spim

2. Click **File** → **Open** and load `Assignment.s`

3. Click **Compile and Load** → **Continue**

4. Enter number of players when prompted:
   - `1` = Solo mode
   - `2+` = Multiplayer competitive mode

## Game Objects

| Symbol | Object |
|--------|--------|
| P | Character (you) |
| # | Box (push to target) |
| X | Target location |
| █ | Wall (impassable) |

## Customizing Grid Size

Edit the `.data` section in the assembly file:

```assembly
.data
gridsize: .byte 8,8    # Rows, Columns (min 6x6)
