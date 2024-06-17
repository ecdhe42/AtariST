# MemViewer

MemViewer is a tool designed to look for graphical resources in an Atari ST memory dump.

## How to create a memory dump in Steem SSR

- Open the debugger
- Go to Browser / New Memory Browser
- Set address to 0, the near "Dump->" to be either 512Kb or 1Mb
- Click on "Dump->" and select a filename

## How to use MemViewer

### Go up or down memory

- Page up/Page down: jump one page up or down
- Up/Down: move one line up or down
- Shift+Up/Down: move 16 pixels up or down (8 bytes)
- Crtl+Up/Down: move one byte up or down

### Adjust the screen length

Graphical resources may not be stored as 320 pixel-wide blocs. So you can adjust the width to .

- Left/right arrow: changes the number of 16-pixel blocks to display

### Cycle through multiple memory dumps

You can make several memory dumps (e.g. one at each Vertical Blank) and cycle through them to see any change in memory

- Ctrl+Page up/Page down: load the next binary file (e.g. if the current file is `mygame9.bin`, the next file will be `mygame10.bin`)


## JSON config file

When opening `mygame0.bin`, MemViewer will look for `mygame.json`. Such a JSON file contains information such as a custom color palette and custom memory locations.
