# Security Hardening

Goal: reduce the chance of compromise and limit impact if something goes wrong. No system is perfectly safe. This is a layered defense guide.

## Threat Model (Personal Laptop)
- Opportunistic malware, phishing, and drive-by downloads
- Credential theft and account takeovers
- Malicious USB or external media
- Network eavesdropping on public Wi-Fi

## Baseline Controls
- Keep OS and browsers up to date.
- Enable disk encryption (BitLocker if supported).
- Enable Windows Defender real-time protection.
- Ensure firewall is enabled for all profiles.
- Use strong, unique passwords and a password manager.
- Enable MFA on all critical accounts.

## Hardening Checklist
- Remove unused apps and browser extensions.
- Limit local admin accounts; use standard user by default.
- Disable autorun for removable media.
- Enable SmartScreen and reputation-based protection.
- Use application allow-listing where practical.
- Restrict RDP if not needed, or lock to trusted networks only.
- Disable SMBv1.
- Disable Remote Assistance if unused.
- Turn on Controlled Folder Access (Defender) if compatible.
- Enable Attack Surface Reduction (ASR) rules where possible.

## Network Hygiene
- Use a trusted DNS provider.
- Avoid unknown public Wi-Fi without a VPN.
- Turn off file/printer sharing on public networks.
- Disable IPv6 only if you understand the impact; otherwise leave it on.

## Identity and Access
- Prefer passkeys or MFA for all major accounts.
- Use a separate local admin account for installs only.
- Lock the screen automatically and require a password on wake.

## Browser and Email
- Keep one hardened browser for banking and admin portals.
- Block third‑party cookies and disable unnecessary permissions.
- Use DNS-over-HTTPS in the browser if supported.

## Device and USB
- Disable AutoPlay for all media.
- Use “Ask every time” for USB device access if available.

## Monitoring
- Review Defender protection history weekly.
- Check installed apps and startup items monthly.

## Backup and Recovery
- Keep 3-2-1 backups.
- Test restores periodically.
- Store recovery keys offline and in a secure place.

## Incident Response (If You Suspect Infection)
- Disconnect from the network.
- Do not log into sensitive accounts on the infected device.
- Run a full Defender scan.
- Restore from a clean backup if needed.

## Privacy and Exposure Reduction
- Reduce public posting of device details and software stack.
- Avoid running unknown binaries.
- Use separate browser profiles for sensitive tasks.
- Avoid sharing full logs publicly; redact usernames and paths.

## Notes
- Applied changes:
- Open items:
- Risks accepted:
