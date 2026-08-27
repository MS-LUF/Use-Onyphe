<img src="https://www.onyphe.com/assets/img/logo/Onyphe-Logo-Official-Light-Theme.svg" alt="Onyphe" style="width:40%;">

# Use-Onyphe configuration file

This document explains the JSON configuration file used internally by the Use-Onyphe
PowerShell module. A ready-to-read sample lives alongside this file at
[`Use-Onyphe-Config.sample.json`](./Use-Onyphe-Config.sample.json).

**You do not normally need to hand-write or hand-edit this file.** Every field in it is
written by a dedicated cmdlet (`Set-OnypheAPIKey`, `Update-OnypheFacetsFilters`, or by directly
editing the `Logging` section - see below). This document exists so you know what the file
contains, why, and how to recover if something about it looks wrong.

## Where it lives

`Private/Config/Get-OnypheConfigPath.ps1` resolves the path to:

```
$home\Use-Onyphe\Use-Onyphe-Config.json
```

`$home` is used (not `%APPDATA%`) so the same path works on Windows PowerShell, PowerShell
Core on Windows, and PowerShell Core on Linux/macOS. The file is **read fresh from disk on
every call** (`Read-OnypheConfigFile`) - there is no in-memory caching, so editing it by hand
(e.g. to change `Logging` settings) takes effect on the very next cmdlet call, no need to
restart your session.

Writes go through `Save-OnypheConfigFile`, which writes to a temporary file in the same
directory first and then renames it into place - so a crash or a killed process mid-write
cannot leave you with a truncated/corrupted config file.

## Legacy migration

Versions of this module before the JSON config existed stored the same information as two
Clixml files, `Use-Onyphe-Config.xml` and `Onyphe-Data-Model.xml`, in the same `$home\Use-Onyphe\`
folder. The first time `Read-OnypheConfigFile` runs and finds **no** JSON file yet, it checks
for those legacy files and, if found, transparently migrates their content into a new
`Use-Onyphe-Config.json`. **Neither legacy file is deleted by the migration** - they are simply
no longer read afterward, so it's safe to remove them yourself once you've confirmed the new
JSON file has what you expect.

## If the file is corrupted

`Read-OnypheConfigFile` wraps the JSON parse in a `try/catch` and throws a clear error naming
the file path if it isn't valid JSON, instead of letting a cryptic `ConvertFrom-Json` exception
bubble up. If you ever hit that error: either hand-fix the JSON (it's small enough to read), or
just delete the file - the module will recreate an empty default config on the next call, and
`Set-OnypheAPIKey`/`Update-OnypheFacetsFilters` will happily repopulate it.

## Top-level shape

```json
{
  "version": "1.0",
  "APIKey": { "Salt": null, "EncryptedAPIKey": null },
  "Proxy": {},
  "DataModel": { "apis": null, "filters": null, "functions": null },
  "Logging": {}
}
```

This is exactly what `Read-OnypheConfigFile` hands back on a fresh install with no config file
and no legacy files to migrate - every section present, every field empty/null. Nothing in the
module requires any section to be pre-populated; each one fills in independently the first time
its owning cmdlet is used.

### `version`

A fixed string (`"1.0"`), reserved for a future schema migration if the shape of this file ever
needs to change in a breaking way. Not currently read or checked by anything - don't rely on it
to detect the module version (see `Use-Onyphe.psd1`'s `ModuleVersion` for that instead).

### `APIKey` - written by `Set-OnypheAPIKey -EncryptKeyInLocalFile`

```json
"APIKey": {
  "Salt": "StiFJpXYIJYMeslnh/mBZ2/dV6bXVJlwONtH/sCHh4k=",
  "EncryptedAPIKey": "76492d1116743f0423413b16050a5345MgB8..."
}
```

*(the values above are illustrative only - generated from a throwaway fake API key and password,
purely to show the real shape/length of these fields; they decrypt to nothing usable)*

This section only gets written when you explicitly ask the module to persist your API key to
disk:

```powershell
Set-OnypheAPIKey -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
    -MasterPassword (ConvertTo-SecureString -String "YourP@ssw0rd" -AsPlainText -Force) `
    -EncryptKeyInLocalFile
```

- `Salt` - 32 random bytes, base64-encoded, generated fresh every time you run the command above.
- `EncryptedAPIKey` - your API key, encrypted with a key derived from your `-MasterPassword` and
  the salt via `Rfc2898DeriveBytes` (PBKDF2-HMAC-SHA256, **210,000 iterations**), then further
  protected by `ConvertFrom-SecureString`. **Both are useless without the exact master password
  you supplied** - there is no way to recover the API key from this file alone.

To load it back into your session (typically from your PowerShell profile script, so it happens
automatically at shell startup):

```powershell
Import-Module Use-Onyphe -DisableNameChecking
Import-OnypheEncryptedIKey
```

`Import-OnypheEncryptedIKey` prompts for the master password (unless you pass one) and sets
`$global:OnypheAPIKey` for the rest of the session - it does not print or return the decrypted
key.

**Security note:** the iteration count (210,000) was chosen deliberately high to make offline
brute-forcing of a weak master password expensive, but the whole scheme still depends entirely
on your master password being strong - a weak, guessable master password undermines it no
matter how many PBKDF2 iterations are used. Treat this file the same way you'd treat any other
credential-adjacent file: don't commit it to source control, don't share it, and back it up only
somewhere you'd also trust with the API key itself.

### `Proxy` - currently unused, reserved

```json
"Proxy": {}
```

This section is **not read or written by anything in the current module** - it exists as a
placeholder for a possible future feature. Proxy settings you configure today with
`Set-OnypheProxy` are **session-only**: they populate `$global:OnypheProxyParams` in memory and
are read by `Invoke-OnypheAPIV2` on every request, but nothing persists them to this file. If
you need your proxy configured automatically every session, put the `Set-OnypheProxy` call in
your PowerShell profile script instead of expecting this file to remember it.

### `DataModel` - written by `Update-OnypheFacetsFilters`

```json
"DataModel": {
  "apis": [ "user", "search", "search/datascan", "simple/geoloc", "..." ],
  "filters": [ "ip", "port", "protocol", "domain", "country", "..." ],
  "functions": [ "exists", "wildcard", "orwildcard", "monthago", "sort", "..." ]
}
```

*(the sample file truncates `apis`/`filters` to a handful of representative entries for
readability - your real cache will contain every API, filter, and function your account can
currently use, which for `filters` alone is typically 200+ entries)*

This is a **cache of your own account's live capabilities**, fetched from Onyphe's own
`/v2/user` endpoint (via `Get-OnypheUserInfo`) and refreshed on demand:

```powershell
Update-OnypheFacetsFilters -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

It drives **every dynamically-validated `-Category`/`-SummaryAPIType`/`-SearchType`/
`-FilterFunction` parameter in the module** - `Get-OnypheSimpleAPIName`,
`Get-OnypheSimpleBestAPIName`, `Get-OnypheSummaryAPIName`, `Get-OnypheSearchCategories`,
`Get-OnypheSearchFilters`, `Get-OnypheSearchFunctions`, `Get-OnypheBulkAPIType`,
`Get-OnypheBulkCategories`, and `Get-OnypheDiscoveryCategories` all read straight from this
cache, and every `DynamicParam` block that builds a tab-completed `ValidateSet` (on
`Get-OnypheInfo`, `Search-OnypheInfo`, `Export-OnypheInfo`, `Export-OnypheDiscoveryInfo`, etc.)
calls one of them. **If this cache is empty or stale, those parameters simply accept any string
with no validation** (the module treats an empty cache as "nothing to validate against" rather
than blocking you) - so a category that genuinely isn't available to your account will only be
rejected server-side, not by PowerShell tab-completion.

**Re-run `Update-OnypheFacetsFilters` whenever:**
- this is your first time using the module (the cache starts empty)
- Onyphe adds a new API, filter, or function you want tab-completion/validation for
- your subscription tier changes (for example, gaining a **Griffin View** subscription unlocks
  the `bulk/discovery/*` entries that make `Export-OnypheDiscoveryInfo`'s `-Category` parameter
  show any valid values at all)

### `Logging` - opt-in, off by default

```json
"Logging": {
  "Enabled": true,
  "MinimumLevel": "Information",
  "Mode": "File",
  "File": {
    "Path": "%USERPROFILE%\\Documents\\Use-Onyphe\\Logs",
    "FileName": "Use-Onyphe-{yyyyMMdd}.log"
  },
  "EventLog": {
    "LogName": "Application",
    "Source": "Use-Onyphe",
    "EventIdInformation": 1000,
    "EventIdWarning": 2000,
    "EventIdError": 3000
  }
}
```

Unlike the other sections, this one is meant to be **hand-edited** - there's no cmdlet that
writes it for you. `Config.Logging` is missing entirely from a fresh/pre-logging-feature config
(shown as `{}` above), which `Get-OnypheLoggingConfig` normalizes to every field's default -
**every key below is optional and falls back to its default if omitted**, so you only need to
add the keys you want to change.

| Key | Default | Notes |
|---|---|---|
| `Enabled` | `false` | Master on/off switch. Everything below is ignored while this is `false`. |
| `MinimumLevel` | `"Information"` | One of `Debug`, `Information`, `Warning`, `Error`. Entries below this severity are dropped. |
| `Mode` | `"File"` | Either `"File"` or `"EventLog"` - picks which of the two sections below is actually used. An unrecognized value falls back to `"File"` with one `Write-Warning` per session. |
| `File.Path` | `"%USERPROFILE%\Documents\Use-Onyphe\Logs"` | Environment variables (`%USERPROFILE%`, etc.) are expanded at write time. The directory is created automatically if it doesn't exist. |
| `File.FileName` | `"Use-Onyphe-{yyyyMMdd}.log"` | `{...}` placeholders are evaluated as [.NET date format strings](https://learn.microsoft.com/dotnet/standard/base-types/custom-date-and-time-format-strings) against the current date/time on every write - e.g. `{yyyyMMdd}` gives you one file per day; use a fixed name with no `{}` for a single ever-growing file. |
| `EventLog.LogName` | `"Application"` | Windows Event Log to write to. Ignored unless `Mode` is `"EventLog"`. |
| `EventLog.Source` | `"Use-Onyphe"` | Event source; registered automatically via `New-EventLog` the first time it's needed (requires an elevated session **the first time only**, to create the source). |
| `EventLog.EventIdInformation` / `EventIdWarning` / `EventIdError` | `1000` / `2000` / `3000` | Event IDs used per severity. `Debug`-level entries are logged as `Information` (Windows Event Log has no Debug entry type), prefixed `[DEBUG]` in the message text. |

**Platform note:** `Mode: "EventLog"` needs `Write-EventLog`/`New-EventLog`, which don't exist on
PowerShell Core (Linux/macOS, and Windows PowerShell Core installs) - the module detects this,
logs one `Write-Warning`, and silently skips logging for the rest of the session rather than
throwing. Use `Mode: "File"` if you need logging on a non-Windows-PowerShell-5.1 host.

**What gets logged:** every public cmdlet logs a `Debug`-level "Cmdlet invoked" entry with its
bound parameters as soon as it starts, with any parameter named `Credential`/`Password`/
`Secret`/`Token`/`APIKey` (or containing one of those words) redacted to `<redacted>` before
being written - your API key never reaches a log file or the Windows Event Log this way. A
handful of cmdlets (`Set-OnypheAPIKey`, `Import-OnypheEncryptedIKey`,
`Update-OnypheFacetsFilters`, `Get-OnypheInfo`, `Get-OnypheSummary`) additionally log an
`Information`-level completion message. **A logging failure never breaks your actual Onyphe API
call** - every logging function catches its own errors, warns once per session, and gives up
silently rather than interrupting the cmdlet you actually ran.

## Regenerating this document

This file and `Use-Onyphe-Config.sample.json` are hand-maintained documentation, not
auto-generated - if the config schema changes (a new top-level section, a new `Logging` key,
etc.), update both files together as part of that change.
