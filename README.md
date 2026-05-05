# 🛠️ Copilot Skills for Power Platform

[![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-Skills-blue?logo=githubcopilot)](https://github.com/PowerThomas/copilot-skills)
[![PAC CLI](https://img.shields.io/badge/PAC_CLI-required-0078D4?logo=microsoftazure)](https://aka.ms/PowerAppsCLI)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-2-blueviolet)](#skills)

A personal collection of GitHub Copilot skills for Power Platform development via PAC CLI.
Each skill is a self-contained, slash-command-invocable workflow — no manual steps required.

## Skills

| Skill | Description |
|-------|-------------|
| 🔄 [`pac-flow-dev`](skills/pac-flow-dev/) | Develop and deploy Power Automate cloud flows via PAC CLI mini-solutions |
| 📦 [`pac-data-migrate`](skills/pac-data-migrate/) | Migrate Dataverse table data between environments with auto-generated CMT schema |

---

### 🔄 `pac-flow-dev`

Edit Power Automate cloud flows locally as JSON using a lightweight mini-solution roundtrip.

- Avoids exporting the entire solution — fast and targeted
- Covers the full cycle: create mini-solution → export → edit JSON → pack → import
- Works with existing flows or creates new ones from scratch

**Use when:** modifying flow definitions, bulk-editing expressions, or when the Power Automate designer is too limited.

---

### 📦 `pac-data-migrate`

Migrate data from a Dataverse table between Power Platform environments.

- Automatically builds the CMT schema via `pac modelbuilder` — no manual field input
- Interactively asks for source environment, target environment, and table name
- Handles export and import end-to-end in a single command

**Use when:** copying data between environments, syncing reference tables, migrating dev data to tst/acc/prd.

---

## Installation

Copy one or more skills to your user-level skills folder so they're available in every workspace:

```powershell
# pac-data-migrate
Copy-Item -Path "skills\pac-data-migrate" -Destination "$env:USERPROFILE\.copilot\skills\pac-data-migrate" -Recurse -Force

# pac-flow-dev
Copy-Item -Path "skills\pac-flow-dev" -Destination "$env:USERPROFILE\.copilot\skills\pac-flow-dev" -Recurse -Force
```

> **Tip:** You can also clone this repo and open it in VS Code — skills in the workspace root are automatically picked up by Copilot.

## Prerequisites

[![PAC CLI](https://img.shields.io/badge/PAC_CLI-install-0078D4?logo=microsoftazure)](https://aka.ms/PowerAppsCLI)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://github.com/PowerShell/PowerShell)
[![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-VS_Code-blue?logo=githubcopilot)](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot)

- **PAC CLI** installed and authenticated — run `pac auth list` to verify
- **PowerShell** 5.1+ or PowerShell Core
- **GitHub Copilot** extension in VS Code

## Usage

Type `/` in any Copilot chat to invoke a skill:

```
/pac-data-migrate
/pac-flow-dev
```

The agent guides you through the required inputs and runs everything automatically.

## Contributing

Pull requests welcome. Each skill lives in its own folder under `skills/` and must contain a `SKILL.md` with the required frontmatter.

## License

MIT
