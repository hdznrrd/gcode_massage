# GCODE MASSAGE UTILITIES

by 2019 hadez@infuanfu.de

These scripts can be used to make Gcode produced by various tools usable by UCCNC.

## JSCut
https://jscut.org

This tool is quite neat but produces Gcode that has the wrong comment formatting. Specifically its format is "CMD; COMMENT" whereas UCCNC requires "CMD (COMMENT)".
Use ```fixgcode.sh <file>``` to remedy this.

## Inkcut standalone
https://codelv.com/projects/inkcut/

This is a tool to drive vinyl cutters and it also offers Gcode output.
However its output suffers from several shortcomings:

- No cutter lift/drop between lines to cut
- No feed rates defined
- Weird scaling artifacts (of by a factor of ~0.28)
- Wrong comment format for UCCNC (s. JSCut)

Use ```fixgcode_inkcut.sh``` to remedy this.
