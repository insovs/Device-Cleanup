<div align="center">

# Device Cleanup

Scans and removes **ghost devices** left behind by previously connected hardware.<br>
Reduces IRQ overhead, lowers input latency, and makes input smoother.<br>
Runs natively through Windows built-in tools. Everything is **safe** and **non-destructive**.

[![Discord](https://img.shields.io/badge/Support-Discord-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/fayeECjdtb)
[![Preview](https://img.shields.io/badge/Video-Preview-FF0000?logo=youtube&logoColor=white)](https://youtu.be/q63XYpYXOiQ)

</div>

---

Ghost devices are phantom registry entries from hardware that is no longer connected. They silently consume IRQ resources and can cause input stutter, slower USB initialization, and driver conflicts.

![preview](https://imgur.com/WNTaUvM.png)

<details>
<summary><b>► Screenshots</b></summary>

---

**Scan results — ghost devices detected and listed, protected devices preserved**
> All detected devices are displayed with their status. Ghost devices (`GHOST`) are pre-checked and ready for removal. Devices with CPU affinity / IRQ pinning (`AFFINITY CONFIGURED`) are listed separately and unchecked by default.

![Scan results](https://github.com/user-attachments/assets/83c7c105-f800-4751-9724-e89ed543301a)

---

**Confirm removal — one-click removal with confirmation dialog**
> Before any deletion, a confirmation popup displays the exact number of devices to be removed. The action cannot be undone through this tool — though devices will re-appear if the hardware is reconnected.

![Confirm removal](https://github.com/user-attachments/assets/ca34460b-8a2a-4fc5-893e-56667025b984)

---

**After removal — clean state, only protected devices remain**
> After removal, the tool automatically re-scans. Ghost count drops to `0`, removed count updates to reflect the session total. Only `AFFINITY CONFIGURED` devices remain, fully intact.

![After removal](https://github.com/user-attachments/assets/71da8c18-de17-476e-bbe4-9a05476c72ae)

</details>

---

## Why it matters

Every time you plug in a peripheral — mouse, keyboard, USB hub, headset — Windows registers it. When you unplug it, the entry stays. Over time, these stale entries pile up silently in the registry, consuming IRQ resources and creating noise in the device enumeration process.

Device Cleanup scans every registered device on your system, identifies the ones no longer physically present, and removes them in a single operation. The result is a cleaner interrupt table, faster USB initialization, and smoother input — with zero guesswork.

All changes are limited to phantom entries. Active devices and any device with CPU affinity or IRQ pinning configured are never touched. If a removed device is reconnected, Windows will simply re-detect it as new — no data is permanently lost.

---

## Installation

Download `DeviceCleanup.ps1`, then **right-click** it → **Run with PowerShell**

The script will automatically request administrator privileges.

> [!CAUTION]
> If PowerShell scripts are blocked on your system, enable execution first:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```
> Or use **[EnablePowerShellScript](https://github.com/insovs/EnablePowerShellScript)** for a one-click solution.

---

## Usage

1. Click **Scan System** — the tool scans all devices registered in Windows, including disconnected ones.
2. Review the list — ghost devices are listed as **GHOST**, protected devices as **AFFINITY CONFIGURED**.
3. Select the devices to remove (all ghosts are pre-checked by default).
4. Click **Remove Selected** and confirm.
5. The tool automatically re-scans after removal to confirm they are gone.

---

## What the tool does

| Feature | Description |
|---|---|
| **Ghost device scan** | Detects all devices with status `Unknown` (Error Code 45) — hardware no longer connected |
| **Affinity protection** | Automatically preserves any device with a CPU affinity / IRQ pinning configuration |
| **Safe removal** | Removes ghost entries using up to 5 fallback methods — `Remove-PnpDevice`, `pnputil`, SetupAPI, `reg.exe`, `devcon` |

## Device labels

| Label | Meaning |
|---|---|
| **`GHOST`** | Phantom device — previously connected, no longer present. Safe to remove. |
| **`AFFINITY CONFIGURED`** | Device has IRQ / CPU affinity pinning configured. Protected by default, removable manually. |

> [!IMPORTANT]
> Devices marked **AFFINITY CONFIGURED** are unchecked by default. Removing them will delete your IRQ affinity configuration. Only do so intentionally.

---

## Benefits

Gains scale with the number of devices removed. Results are most noticeable on systems with a large number of previously connected peripherals.

| Improvement | Details |
|---|---|
| **Lower input latency** | Fewer phantom IRQ entries competing for resources |
| **No IRQ conflicts** | Cleaner interrupt routing across active devices |
| **Faster USB initialization** | Windows no longer enumerates stale device entries |
| **Faster boot** | Reduced device enumeration on startup |
| **Cleaner registry** | Removes dead entries under `HKLM\SYSTEM\CurrentControlSet\Enum` |

## Removal method chain

The tool attempts removal using the following methods in order, stopping at the first success:

1. `Remove-PnpDevice` — native PowerShell cmdlet
2. `pnputil.exe /remove-device` — Windows built-in PnP utility
3. **SetupAPI** `SetupDiRemoveDevice` — direct Win32 API call, bypasses PnP manager lock
4. `reg.exe delete` — brute-force registry key removal
5. `devcon.exe remove` — if present on system or in script directory

---

## About this project

This is an improved and redesigned version of the original [Device Cleanup Tool](https://www.uwe-sieber.de/misc_tools_e.html) by Uwe Sieber. Built from scratch with a modern GUI, it adds automatic protection for devices with CPU affinity / IRQ pinning configured — keeping them clearly identified and unchecked by default, so nothing gets removed by accident. The interface also provides a clearer real-time view of what is happening at each step, making the whole process more intuitive for everyone.

---

<div align="center">
  <sub>©insopti — <a href="https://guns.lol/inso.vs">guns.lol/inso.vs</a> · For personal use only.</sub>
</div>
