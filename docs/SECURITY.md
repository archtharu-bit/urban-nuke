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

## Network Hygiene
- Use a trusted DNS provider.
- Avoid unknown public Wi-Fi without a VPN.
- Turn off file/printer sharing on public networks.

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

## Notes
- Applied changes:
- Open items:
- Risks accepted:
