# copilot-skills

A collection of GitHub Copilot skills for Power Platform development.

## Skills

### [`pac-data-migrate`](skills/pac-data-migrate/)

Migrate data from a Dataverse table between Power Platform environments using PAC CLI.

- Automatically builds the CMT schema via `pac modelbuilder` — no manual field input
- Asks interactively for source environment, target environment, and table name
- Handles export and import in a single command

**Use when:** copying data between environments, syncing reference tables, migrating dev data to tst/acc/prd.

## Installation

### Option A — Install as a personal skill (recommended)

Copy the skill to your user-level skills folder:

```powershell
$dest = "$env:USERPROFILE\.copilot\skills\pac-data-migrate"
Copy-Item -Path "skills\pac-data-migrate" -Destination $dest -Recurse -Force
```

The skill is now available as `/pac-data-migrate` in any GitHub Copilot chat session.

### Option B — Use directly from a cloned workspace

Clone this repo and open the folder in VS Code. Skills in `.github/skills/` are automatically available in that workspace.

You can also symlink or copy the skill folder into your project's `.github/skills/` directory.

## Prerequisites

- [PAC CLI](https://aka.ms/PowerAppsCLI) installed and authenticated (`pac auth list`)
- PowerShell 5.1+ or PowerShell Core
- GitHub Copilot (VS Code extension)

## Usage

In any Copilot chat session, type:

```
/pac-data-migrate
```

The agent will ask for:
1. Source environment
2. Target environment  
3. Table logical name

Then runs the migration fully automatically.

Or invoke with arguments:

```
/pac-data-migrate migrate account from dev to tst
```

## Contributing

Pull requests welcome. Each skill lives in its own folder under `skills/` and must contain a `SKILL.md`.

## License

MIT
