# Digital Lock — Verilog HDL (Vivado 2025.2)

Simple 4-bit digital lock with FSM control, written in synthesizable Verilog-2001 for Xilinx Vivado 2025.2. Matches the Digital Lock Controller poster design: FSM states Idle / Entry / Check / Unlocked / Alarm, 4-digit PIN, lockout after 3 wrong attempts.

## Files

- `digital_lock.v` — synthesizable RTL, top module `digital_lock`
- `digital_lock_tb.v` — self-checking testbench, top module `digital_lock_tb`
- `vivado_create_project.tcl` — creates the Vivado project and runs the simulation

## How it works

- Password: `1010` on `pass_in[3:0]`
- `enter` latches the password (IDLE → ENTRY → CHECK)
- Correct password → UNLOCKED (`unlock` = 1), attempt counter cleared
- Wrong password → one-cycle `deny` pulse, attempt counter +1, back to IDLE
- Third wrong password → ALARM (`locked` = 1), stays locked until reset
- `rst` clears the lock, the attempt counter and the state

Ports: `clk`, `rst`, `enter`, `pass_in[3:0]` in; `unlock`, `deny`, `locked`, `attempt_cnt[1:0]`, `state[2:0]` out.

## Run it in Vivado 2025.2

1. Open Vivado → Tools → Run Tcl Script → `vivado_create_project.tcl`, or create a project manually, Add Sources, add both files, set `digital_lock` as top.
2. Run Simulation → Run Behavioral Simulation (top `digital_lock_tb`).
3. Expected output: every check prints `PASS`, ending with `ALL TESTS PASSED`.

The Tcl script targets the Artix-7 100T part (`xc7a100tcsg324-1`, the part behind the poster's resource table). Change `-part` if your board uses a different device.

## Run it with Icarus Verilog

```text
iverilog -o digital_lock_tb.vvp digital_lock.v digital_lock_tb.v
vvp digital_lock_tb.vvp
```

## Test coverage

- Correct password unlocks; attempt counter stays 0
- Reset clears unlock, lock, counter and state
- Each wrong password raises a deny pulse and increments the counter (1, 2, 3)
- Third wrong password locks the system; correct password cannot unlock while locked
- Reset clears the lockout; wrong then correct unlocks and clears the counter
