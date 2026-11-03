A SECOND AUDIT SERVER ON THE SAME MACHINE
=========================================

new-instance.ps1 makes an independent copy: its own folder, PostgreSQL database and login, photo
storage, keys, Windows services and ports. Data is never shared between copies. The street map and
directions services are shared with the first copy (same Turkmenistan data) unless -OwnMapServices.

In PowerShell as Administrator, from the existing server folder:
  cd C:\audit-server
  powershell -ExecutionPolicy Bypass -File .\new-instance.ps1 -Name demo -PostgresPassword <postgres password>

What it does:
  1. Copies the folder to C:\audit-server-demo (without this copy's photos, logs and settings).
  2. Writes a settings.json with new ports (yours + 100: API 3100, web 3101, photos 8433 by default),
     a new database audit_demo with a generated password, and new keys.
  3. Creates the database (needs the postgres password; without it, run the written database.sql in
     pgAdmin and then install.ps1 in the new folder).
  4. Runs install.ps1 there: services audit-storage-demo, audit-api-demo, audit-web-demo, firewall rules.

Afterwards:
  - Web admin:  http://<server ip>:3101   first admin:  cd C:\audit-server-demo ; .\admin.ps1 create you@company.tm <password>
  - Mobile app: Server settings (login screen gear, or the account menu) -> IP <server ip>, port 3100, HTTPS off.
    Agents of the second company sign in with that server address; phones remember it.
  - Updates: update the first server as usual (unzip the bundle over C:\audit-server, run install.ps1).
    Its install.ps1 ends by bringing every other instance to the same version: it stops the copy's
    services, mirrors api, web, node and the scripts into its folder (its settings.json, photos, logs
    and updates folder are kept) and runs its install.ps1. To do only that step: update-instances.ps1.
    "updateInstances": false in the first server's settings.json turns the automatic part off.
  - Diagnose / start: diagnose.ps1 and start.ps1 in each folder know their own services.

Other ports or a different offset: -PortOffset 200, or -ApiPort 3200 -WebPort 3201 -StoragePort 8533.
Removing a copy: stop and delete its services (sc.exe delete audit-api-demo etc.), delete the folder,
drop the database and login in pgAdmin, remove its firewall rules.
