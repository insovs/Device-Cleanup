# Device Cleanup
Scans and removes **ghost devices** left behind by previously connected hardware — reducing IRQ overhead, lowering input latency, and making input smoother.
Everything runs natively through Windows built-in tools. It is **safe**, and **non-destructive**.

- Ghost devices are phantom registry entries from hardware that is no longer connected.
- They silently consume IRQ resources and can cause input stutter, slower USB initialization, and driver conflicts.

> [!NOTE]
> Not sure what it does? Check the **[video preview](https://youtu.be/q63XYpYXOiQ)** to see it in action. the whole process takes under 10 seconds.

![preview](https://imgur.com/WNTaUvM.png)

<details>
<summary><b>📸 Screenshots</b></summary>

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

## Support
If you need any help or have questions, feel free to join the **[Discord support server](https://discord.com/invite/fayeECjdtb)** — I'll be happy to assist you.

## Installation & Launch
Download `DeviceCleanup.ps1`, then **right-click** it → **"Run with PowerShell"**.  
The script will automatically request administrator privileges.

> [!CAUTION]
> If you are not allowed to run PowerShell scripts, enable it first:
> ```
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```
> Or refer to [EnablePowerShellScript](https://github.com/insovs/EnablePowerShellScript).

## Usage
1. Click **Scan System** — the tool scans all devices registered in Windows, including disconnected ones.
2. Review the list — ghost devices are listed as **GHOST**, protected devices as **AFFINITY CONFIGURED**.
3. Select the devices to remove (all ghosts are pre-checked by default).
4. Click **Remove Selected** and confirm.
5. The tool automatically re-scans after removal to confirm they are gone.

## What the tool does
| Feature | Description |
|---|---|
| **Ghost device scan** | Detects all devices with status `Unknown` (Error Code 45) — hardware no longer connected. |
| **Affinity protection** | Automatically preserves any device with a CPU affinity / IRQ pinning configuration. |
| **Safe removal** | Removes ghost entries using up to 5 fallback methods — `Remove-PnpDevice`, `pnputil`, SetupAPI, `reg.exe`, `devcon`. |

## Device categories
| Label | Meaning |
|---|---|
| **`GHOST`** | Phantom device — previously connected, no longer present. Safe to remove. |
| **`AFFINITY CONFIGURED`** | Device has IRQ / CPU affinity pinning configured. Protected by default, removable manually. |

> [!IMPORTANT]
> Devices marked **AFFINITY CONFIGURED** are unchecked by default. Removing them will delete your IRQ affinity configuration. Only do so intentionally.

## Benefits
Gains scale with the number of devices removed. Results are most noticeable on systems with a large number of previously connected peripherals.

| Improvement | Details |
|---|---|
| **Lower input latency** | Fewer phantom IRQ entries competing for resources. |
| **No IRQ conflicts** | Cleaner interrupt routing across active devices. |
| **Faster USB initialization** | Windows no longer enumerates stale device entries. |
| **Faster boot** | Reduced device enumeration on startup. |
| **Cleaner registry** | Removes dead entries under `HKLM\SYSTEM\CurrentControlSet\Enum`. |

## Removal method chain
The tool attempts removal using the following methods in order, stopping at the first success:

1. `Remove-PnpDevice` — native PowerShell cmdlet
2. `pnputil.exe /remove-device` — Windows built-in PnP utility
3. **SetupAPI** `SetupDiRemoveDevice` — direct Win32 API call, bypasses PnP manager lock
4. `reg.exe delete` — brute-force registry key removal
5. `devcon.exe remove` — if present on system or in script directory

---
<p align="center">
  <sub>©insopti — <a href="https://guns.lol/inso.vs">guns.lol/inso.vs</a> | For personal use only.</sub>
</p>
