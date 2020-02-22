# set screen resolution to 1440x900
cvt 1440 900 60
xrandr -s 1440x900

# use the defaults
. /etc/X11/Xsession

# launch i3 window manager
exec i3
