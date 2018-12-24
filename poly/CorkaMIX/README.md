# Contents

Sources and PoC of of the original [CorkaMIX.zip](https://www.virustotal.com/#/file/1fc14ab461828afd34f92c69e34dd05270c73b744de09ea97170c07616a78384/detection) from 2012.

[CorkaMIX.exe](https://www.virustotal.com/#/file/2a9c7a16cdb3c3f2285afaf61072dd5e7cc022e97f351cad6234a13e5216f389/details) is simultaneously a valid:
- Windows Portable Executable binary (doesn't work under Windows 8 and later).
- PDF document (since blacklisted by various readers).
- Oracle Java JAR (a CLASS inside a ZIP)/Python script

It serves no purpose, except proving that files format not starting at offset `0` are a bad idea.

Ange Albertini - August 2012