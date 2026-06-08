# Security Policy

## ⚠️ Corporate / managed-device disclaimer

This project is designed to set up a developer environment on Windows, including on
**company-managed laptops**. Even when you have local administrator rights, **admin
rights are not the same as authorization**: your employer's IT/security policy still applies.

Some optional packages offered by this project — network sniffers (Wireshark, Nmap),
process/memory tools (System Informer / Process Hacker), unmanaged remote access
(RustDesk), P2P clients, bootable-media creators (Rufus, Ventoy), encrypted-container
tools (VeraCrypt), and remote-filesystem mounts (SSHFS-Win) — can:

- trigger your endpoint protection (EDR) or DLP and raise a security incident, and/or
- violate your acceptable-use policy, with possible disciplinary consequences.

These tools are **never installed by default**. They live in an explicit, opt-in
category that defaults to **No** and shows a warning. **You are responsible for
checking your employer's IT and HR policy before installing anything.**

## Supply chain

Installers are obtained through `winget` (signed, verified by the OS) wherever possible.
Where a binary is downloaded directly, the project aims to verify its Authenticode
signature before execution. If you find a step that runs an unverified download with
elevated rights, please report it (see below).

## Reporting a vulnerability

If you discover a security issue in the scripts (e.g. an unverified privileged
download, a destructive operation, a path-injection), please open a
[GitHub Security Advisory](https://docs.github.com/en/code-security/security-advisories)
on the repository, or open a private issue. Do not include secrets in reports.

We aim to acknowledge reports within a few days.
