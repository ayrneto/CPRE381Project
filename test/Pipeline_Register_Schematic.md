# Pipeline Register Stalling and Flushing Schematic

## Ideal N-bit Register with Stall/Flush Control

```
Input Data (N-bits) ──┐
                      │
Clock ──┐             │
        │             │
Stall ──┼──[NOT]──┐   │
        │         │   │
Flush ──┼─────────┼─[OR]─── Write Enable
        │         │   │
        │         └─[AND]── Clock Enable
        │             │
        └─── Reset ────┼──── Clear
                       │
                       │    ┌─── Output Data (N-bits)
                       │    │
                       └──[REG]
                            │
                      Reset ─┘

Logic Equations:
- Write_Enable = NOT(Stall) OR Flush
- Clock_Enable = Clock AND NOT(Stall)  
- Clear = Reset OR Flush
```

## Control Logic Truth Table

| Stall | Flush | Reset | Action                    | Register Behavior     |
|-------|-------|-------|---------------------------|-----------------------|
|   0   |   0   |   0   | Normal Operation          | Load new data on clock|
|   0   |   0   |   1   | Reset                     | Clear to zeros        |
|   0   |   1   |   0   | Flush/Squash              | Clear to zeros        |
|   0   |   1   |   1   | Reset (Flush ignored)     | Clear to zeros        |
|   1   |   0   |   0   | Stall                     | Hold current data     |
|   1   |   0   |   1   | Reset (Stall ignored)     | Clear to zeros        |
|   1   |   1   |   0   | Flush (overrides Stall)   | Clear to zeros        |
|   1   |   1   |   1   | Reset (all others ignored)| Clear to zeros        |

## Key Implementation Notes:

1. **Stall Priority**: When stalled, register holds current value (no clock enable)
2. **Flush Priority**: Flush overrides stall - immediately clears register
3. **Reset Priority**: Reset overrides all other controls
4. **Clock Gating**: Stall prevents clock from reaching register flip-flops
5. **Combinational Clear**: Flush provides immediate asynchronous clear