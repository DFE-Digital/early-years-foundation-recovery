# Connecting to PostgreSQL via Azure Bastion

This guide covers how to connect to the PostgreSQL database in dev and prod environments via Azure Bastion, both via CLI and GUI tools.

> ⚠️ **Security Note:** This document contains infrastructure identifiers (subscription IDs, IP addresses, resource IDs, and resource names). Treat it as internal documentation and restrict access accordingly. Do not share publicly or commit credentials.

---

## Prerequisites

- Azure CLI installed (`az` command)
- SSH client
- Either `psql` (CLI) or **Postico** (GUI recommended on macOS)
- Authenticated to the correct Azure subscription

---

## Quick Reference

| Env | SSH Host | SSH User | DB Host | DB User | DB Name |
|-----|----------|----------|---------|---------|---------|
| **Dev** | `4.180.77.140` | `psqladmin` | `s187d01-eyrecovery-psqlfs.postgres.database.azure.com` | `psqladminDexter` | `postgres` |
| **Prod** | `20.71.246.192` | `psqladmin` | `s187p01-eyrecovery-psqlfs.postgres.database.azure.com` | `psqladminTigger` | `s187p01-eyrecovery-moose-psqldb` |

---

## Method 1: CLI (psql via SSH Tunnel)

### Step 0: Login to Azure

```sh
az login
```

This opens a browser to authenticate. You'll be prompted to select a subscription if you have access to multiple.

### Step 1: Switch to the correct Azure subscription

**Dev:**
```sh
az account set --subscription "s187-eyrecovery-development"
```

**Prod:**
```sh
az account set --subscription "s187-eyrecovery-production"
```

### Step 2: Open Bastion tunnel (Terminal 1)

**Dev (port 2222):**
```sh
az network bastion tunnel \
  --name s187-azurebastion-dev \
  --resource-group s187d01-eyrecovery-rg \
  --target-resource-id /subscriptions/0ca14579-d277-4487-b360-ca670f946017/resourceGroups/s187d01-eyrecovery-rg/providers/Microsoft.Compute/virtualMachines/s187d01-eyrecovery-psqlfs-vm \
  --resource-port 22 \
  --port 2222
```

**Prod (port 2223):**
```sh
az network bastion tunnel \
  --name s187p01-eyrecovery-azbastion \
  --resource-group s187p01-eyrecovery-rg \
  --target-resource-id /subscriptions/38eec3c7-3a7f-42bb-a533-1418fdd7b969/resourceGroups/s187p01-eyrecovery-rg/providers/Microsoft.Compute/virtualMachines/s187p01-eyrecovery-psqlfs-vm \
  --resource-port 22 \
  --port 2223
```

> **Note:** Dev and prod use different local ports to avoid SSH host key conflicts (each environment has a different fingerprint).

Expected output:
```
Opening tunnel on port: 2222
Tunnel is ready, connect on port 2222
Ctrl + C to close
```

**Keep this terminal open.**

### Step 3: SSH port-forward (Terminal 2)

**Dev (use port 2222):**
```sh
ssh -p 2222 -L 5432:s187d01-eyrecovery-psqlfs.postgres.database.azure.com:5432 psqladmin@127.0.0.1 -N
```

**Prod (use port 2223):**
```sh
ssh -p 2223 -L 5432:s187p01-eyrecovery-psqlfs.postgres.database.azure.com:5432 psqladmin@127.0.0.1 -N
```

When prompted, enter the SSH password for `psqladmin`. The terminal will hang silently once connected — this is normal. **Keep this terminal open.**

### Step 4: Connect with psql (Terminal 3)

**Dev:**
```sh
psql "host=localhost port=5432 dbname=postgres user=psqladminDexter sslmode=require"
```

**Prod:**
```sh
psql "host=localhost port=5432 dbname=s187p01-eyrecovery-moose-psqldb user=psqladminTigger sslmode=require"
```

When prompted, enter the Postgres password for the respective user.

### Step 5: Query the database

```sql
\dt                    -- list tables
SELECT * FROM users LIMIT 5;  -- example query
\q                     -- quit psql
```

### Cleanup

When done:
1. Exit psql: `\q`
2. Stop SSH tunnel (Terminal 2): Ctrl+C
3. Stop Bastion tunnel (Terminal 1): Ctrl+C

---

## Method 2: Postico (GUI on macOS)

### Prerequisites

Install **Postico** from [eggerapps.at/postico2](https://eggerapps.at/postico2).

### Setup

1. Start only the Bastion tunnel from Method 1 Step 2.

2. Do not run Method 1 Step 3 (ssh -L) when using Postico.

3. Open Postico.

4. Click **New Favorite**.

5. In **General**, fill these fields exactly.

  **Prod:**
  - Name: `eyrecovery-prod`
  - Host (or Server): `s187p01-eyrecovery-psqlfs.postgres.database.azure.com`
  - Port: `5432`
  - User (or Username): `psqladminTigger`
  - Password: Postgres password for `psqladminTigger`
  - Database: `s187p01-eyrecovery-moose-psqldb`

  **Dev:**
  - Name: `eyrecovery-dev`
  - Host (or Server): `s187d01-eyrecovery-psqlfs.postgres.database.azure.com`
  - Port: `5432`
  - User (or Username): `psqladminDexter`
  - Password: Postgres password for `psqladminDexter`
  - Database: `postgres`

  **Important:** Do not set the General Host/Server field to `127.0.0.1`.

6. Open **SSH** in the same favorite and enable **Connect via SSH**.

7. In **SSH**, fill these fields exactly.

  **Prod:**
  - SSH Host: `127.0.0.1`
  - SSH Port: `2223`
  - SSH User: `psqladmin`
  - SSH Password: VM SSH password for `psqladmin`

  **Dev:**
  - SSH Host: `127.0.0.1`
  - SSH Port: `2222`
  - SSH User: `psqladmin`
  - SSH Password: VM SSH password for `psqladmin`

8. Open **SSL** and set **SSL Mode** to Require.

9. Click **Test**.

10. If test succeeds, click **Connect**.

11. If you want to reuse it later, save the favorite.

12. If test fails with timeout or route errors, verify the Bastion tunnel terminal is still running and retry.

### Cleanup

When done, close Postico and stop the Bastion/SSH tunnels (Ctrl+C in Terminals 1 & 2).

---

## Troubleshooting

### "Resource group not found"
Ensure you've switched to the correct Azure subscription:
```sh
az account set --subscription "s187-eyrecovery-development"  # or prod
```

### SSH tunnel hangs after password
This is normal with the `-N` flag (no shell). The tunnel is active. Proceed to Step 4.

### "Connection refused" when running psql
- Verify Terminal 2 (SSH tunnel) is still running.
- Check that both Bastion (Terminal 1) and SSH (Terminal 2) tunnels are open.

### Postico test fails
- Verify the Bastion tunnel terminal is still running.
- If Postico SSH is enabled, do not run a separate ssh -L tunnel.
- Re-check SSH Port is `2222` (dev) or `2223` (prod).

### psql not found
Install PostgreSQL client tools:
```sh
# macOS
brew install postgresql

# Linux
sudo apt install postgresql-client
```

### Postico "No route to host"
- Ensure Bastion tunnel is running.
- Verify SSH Host is `127.0.0.1` (not the VM IP or DB host).

---

## Common Queries

```sql
-- List all tables
\dt

-- Show current database
\c

-- List all users
SELECT usename FROM pg_user;

-- Export table to CSV
\copy table_name TO 'output.csv' CSV HEADER;

-- Count rows in a table
SELECT COUNT(*) FROM table_name;
```

---

## Notes

- Staging environment does not yet have a Bastion configured; use WebSSH or request infrastructure changes.
- Always keep both Bastion and SSH tunnels open while connected.
- Postico is recommended for macOS users because it supports built-in SSH tunneling.
- For security, store credentials securely (e.g., in macOS Keychain) rather than plain text.
