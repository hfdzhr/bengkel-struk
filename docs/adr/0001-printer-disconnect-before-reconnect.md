---
status: proposed
---

# Always disconnect() before connect() to the Bluetooth thermal printer

We use `print_bluetooth_thermal` v1.2.2 to talk to the Xantri BT-58D (58mm thermal, classic Bluetooth SPP/RFCOMM, no auto-cutter). Its native Android side has two bugs that make naive `connect()` unreliable:

1. **Stale connection blocks reconnect.** The native plugin keeps the printer's `OutputStream` in a variable that lives for the whole Android process. Its `connect` handler only opens a new socket when that variable is `null`; otherwise it just returns `false` immediately — it never retries or replaces a dead connection. If the socket dies silently (printer power-cycled, phone Bluetooth hiccup, backgrounded too long) the variable stays non-null, so every subsequent `connect()` call is a no-op failure until the whole app process restarts.
2. **Missing permission hangs forever.** On API 31+, if `BLUETOOTH_CONNECT` isn't granted, the native handler for *every* method (`connect`, `writebytes`, `pairedbluetooths`, ...) just `return`s without ever calling the Flutter `MethodChannel` result callback. `MethodChannel.invokeMethod` has no built-in timeout, so the awaiting Dart `Future` hangs forever — the UI would show "Mencetak..." indefinitely with no way out.

**Decision:** `PrinterService.reconnect(mac)` always calls `disconnect()` immediately before `connect()`, and every native call goes through a `_guard()` helper that wraps it in `.timeout()` (10s for connect/print, 5s for disconnect/status). All reconnect call sites (`printReceiptWithRetry`, `PrinterScreen._pick`, `autoConnect`) use `reconnect()`, never a bare `connect()`.

`printReceiptWithRetry` reconnects before *every* attempt, including the first — not just on retry after a failure. A classic-Bluetooth SPP socket to a thermal printer can die silently while idle (screen off, printer briefly powered off, phone's Bluetooth stack hiccups); the connection made once at app launch (`autoConnect`) can't be trusted to still be alive by the time the user presses "Cetak" minutes or hours later. This matches how a known-working reference app behaves: it (re)selects/connects the printer at the moment of printing, every time, rather than keeping a long-lived connection across the session. `autoConnect` at app launch is kept anyway, purely to drive the Bluetooth status icon on the home screen — not relied upon for the actual print call.

Alternatives considered: patching/forking the plugin (too much upkeep for a personal project over a two-line native bug) and switching printer plugins (no evidence a different plugin is actually needed — the workaround is cheap and the plugin otherwise works).

**Not yet verified on real hardware.** Reported symptom: printing fails on the owner's Samsung A56 while another app prints to the same BT-58D fine. This ADR's fix targets the most plausible cause found by reading the plugin source, but hasn't been confirmed to fix the actual device yet. If it still fails after this fix, next suspects: `BLUETOOTH_CONNECT` not actually granted (permission_handler status vs. reality on this Android version), or the BT-58D exposing a non-standard SPP UUID (plugin hardcodes `00001101-0000-1000-8000-00805F9B34FB`).

**Consequences:** every reconnect now costs one extra disconnect round-trip (a few hundred ms) — an acceptable tradeoff for a UI that no longer freezes or dies permanently. If `print_bluetooth_thermal` is ever upgraded, re-check whether these two bugs still exist before removing the workaround.
