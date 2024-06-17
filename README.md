# Atari ST Memory Viewer

A Java-based tool that helps find graphical resources in an ST program memory dump.

# Atari ST scrolling

A series of scrolling demos written in 68000 assembly:

- `scroll1.s` (`ascroll1.tos`): a simple scrolling demo which gauges how many lines can the 68000 copy to the screen using assembly instruction `move.l` within a single screen refresh. On a 60Hz screen the animation will start at 60 fps (i.e. the bitmap scrolls at a rate of 60 pixels/second) as long as the CPU can copy data fast enough within a single screen refresh. Once this is no longer the case, the animation will suddenly slow down to 30 fps (i.e. it takes between one and two screen refreshes to copy the data). On a stock Atari ST (68000 at 8MHz), the CPU can copy up to 156 lines without slowdown, or 78% of the screen
- `scroll2.s` (graphical assets not provided): the recreation of the Goldrunner vertical scrolling using a tiling system (press space to accelerate)
- `scroll3.s` (graphical assets not provided): the recreation of the Return To Genesis horizontal parallax scrolling (press space to accelerate)
- `scroll4.s` (`ascroll4.tos`): same as `scroll1.s` but with a triple scrolling
- `scroll5.s` (`ascroll5.tos`): same as above but uses TT-RAM to store the bitmap to copy
