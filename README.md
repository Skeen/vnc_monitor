VNC Monitor
-----------

# Preparing the host-machine

## Ensuring a VIRTUAL device is present.

Note this section concerns the [xorg.conf](https://xkcd.com/963/) file.

Check whether a `VIRTUAL` framebuffer device is already found, using:

    xrandr -q

The expected output if a virtual device is present is:

    VIRTUAL1 disconnected (normal left inverted right x axis y axis)
    VIRTUAL2 disconnected (normal left inverted right x axis y axis)
    ...

If this is not the case, a virtual device can be spawned using the `xorg.conf`
file, found within `usr/share/X11/xorg.conf.d/20-intel.conf`. This can simply
be copied to the equivalent system folder:

    cp usr/share/X11/xorg.conf.d/20-intel.conf /usr/share/X11/xorg.conf.d/20-intel.conf

After which the Xorg server should be restarted

    sudo killall Xorg

## Install VNC server

Install the VNC server package:

    sudo apt-get install tightvncserver x11vnc vnc4server

# Install nmap

Install the NMAP package:

    sudo apt-get install nmap

# Preparing the slave machine

## Setting output mode

The output mode of the *pi should fix the `VIRTUAL1` resolution.
This can be set using the `raspi-config` tool on raspberry pi, and using
similar tools on other hardware.

# Pairing

Run the `setup.sh` script with appropriate parameters.
