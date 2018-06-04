# Help Wanted
I need assistance in getting this working under VHBL.
I have included older revisions of ONElua and ONEmenu that are able to run through VHBL, but are unable to fully parse the scripts.

# Likely Issues
ONElua seems to be bundling a kernel exploit to allow it to run on OFW, which causes VHBL to instantly close the game.
Either the kernel exploit needs to be removed, or the homebrew needs to be re-written based on [ONEmenu](https://github.com/ONElua/ONEmenu/)'s EBOOT.PBP which uses a lower(?) version of ONElua that doesn't bundle a kexploit.

# Notes
There are 9 apps included, and up to 16 are supported.

There are 2 gadgets included, and up to 3 seem to be supported.

Sticky Note supports up to 54 characters.

Date is listed in MM/DD/YY format.

Doing anything while listening to music slows the music down.

Pressing Note takes a screenshot.

# Bugs
Not having an MP3 ms0:/music crashes the Music Player

Disabling WiFi then Enabling it results in "Connected to access point Searching" being displayed

# Unsure Bugs
Either large MP3s, or MP3 Covers crash the Music Player

Only MP3s seem to work, despite OGG and others being listed (under filer)

Audio files with 48.000 KHz may slow down