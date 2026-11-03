AUDIT SERVER: SERVICES NOT STARTING AFTER A REBOOT (3 November)
===============================================================

Why it can happen: install.ps1 removed all five services at its start and re-created them one by one.
If a run stopped midway (a failed database update, a busy port), the services after that point were
simply gone, and nothing started with Windows. The API also had no dependency on the database service,
and Windows gives up after two failed restarts.

Files here (copy them into C:\audit-server, replacing install.ps1):
  diagnose.ps1  shows the services, how they start, ports, Windows service events and the log tails;
                writes diagnose.txt next to it - send me that file if anything is still down.
  start.ps1     starts the five services in the right order and waits for each port. Use it now.
  install.ps1   the fixed installer: services are only stopped up front and each is replaced right before
                its own install; delayed automatic start; the API waits for a local PostgreSQL service;
                three automatic restarts after a crash. Future bundles carry this version.

Now, in PowerShell as Administrator:
  cd C:\audit-server
  powershell -ExecutionPolicy Bypass -File .\diagnose.ps1      (send diagnose.txt)
  powershell -ExecutionPolicy Bypass -File .\start.ps1
If start.ps1 says a service is 'not installed', run the installer (it reinstalls everything in place):
  powershell -ExecutionPolicy Bypass -File .\install.ps1

CLOCK
The server's clock was about 2 hours ahead of real time on 3 November (the API's 'last activity' times
showed the future). diagnose.ps1 prints the offset. To fix, as Administrator:
  w32tm /resync
If that fails (no time service), set the time by hand so that [DateTime]::UtcNow in PowerShell matches
https://time.is/UTC. The time zone can stay as it is: what matters is that UTC is right.
