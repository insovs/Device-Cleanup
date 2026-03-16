# Device Cleanup
Scans and removes **ghost devices** left behind by previously connected hardware — reducing IRQ overhead, lowering input latency, and making input smoother.
Everything runs natively through Windows built-in tools. It is **safe**, **non-destructive**, and **fully reversible**.

> [!NOTE]
> Ghost devices are phantom registry entries from hardware that is no longer connected. They silently consume IRQ resources and can cause driver conflicts, input stutter, and slower USB initialization.

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
Head to the **[Releases](https://github.com/insovs/insopti-DeviceCleanup/releases)** section and download `DeviceCleanup.ps1`, then **right-click** it → **"Run with PowerShell"**.  
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
| **Ghost device scan** | Detects all devices with status `Unknown` (Error Code 45) — hardware no longer connected |
| **Affinity protection** | Automatically preserves any device with a CPU affinity / IRQ pinning configuration |
| **Safe removal** | Removes ghost entries using up to 5 fallback methods — `Remove-PnpDevice`, `pnputil`, SetupAPI, `reg.exe`, `devcon` |
| **Auto rescan** | Re-scans automatically after removal to reflect the updated device state |
| **Non-destructive** | Only targets disconnected phantom entries — never touches active or protected devices |

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
| **Lower input latency** | Fewer phantom IRQ entries competing for resources |
| **No IRQ conflicts** | Cleaner interrupt routing across active devices |
| **Faster USB initialization** | Windows no longer enumerates stale device entries |
| **Faster boot** | Reduced device enumeration on startup |
| **Cleaner registry** | Removes dead entries under `HKLM\SYSTEM\CurrentControlSet\Enum` |

## Additional info
> [!IMPORTANT]
> This tool requires **administrator privileges** — it reads device registry entries and calls Windows device management APIs.

> [!NOTE]
> No benchmarks are provided, as results vary depending on hardware history, number of devices ever connected, and overall system configuration. On systems where many peripherals have been swapped over time, the improvement can be significant. Feel free to run your own tests and share your results — feedback is always welcome.
> The tool does not modify any system files or active device drivers. All changes are limited to phantom registry entries for disconnected hardware.

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
