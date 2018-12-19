#include once "dir.bi"

if dir("lib", fbDirectory) <> "lib" then
    mkdir("lib")
end if

dim pathToFbc as string = "C:\Program Files (x86)\FreeBASIC\fbc.exe"
dim args(20) as string

args(0)  = "modules/timer.bas       -lib -x lib/libtimer.a"
args(1)  = "modules/easing.bas      -lib -x lib/libeasing.a"
args(2)  = "modules/gfont.bas       -lib -x lib/libgfont.a"
args(3)  = "modules/vector.bas      -lib -x lib/libvector.a"
args(4)  = "modules/rgb.bas         -lib -x lib/librgb.a"
args(5)  = "modules/mesh.bas        -lib -x lib/libmesh.a"
args(6)  = "modules/flatmapcell.bas -lib -x lib/libflatmapcell.a"
args(7)  = "modules/flatmap.bas     -lib -x lib/libflatmap.a"
args(8)  = "modules/bsp.bas         -lib -x lib/libbsp.a"
args(9)  = "modules/dart.bas        -lib -x lib/libdart.a"
args(10) = "modules/dartmanager.bas -lib -x lib/libdartmanager.a"
args(11) = "modules/mob.bas         -lib -x lib/libmob.a"
args(12) = "modules/mobmanager.bas  -lib -x lib/libmobmanager.a"
args(13) = "modules/sound.bas       -lib -x lib/libsound.a"

print "Building modules..."
dim i as integer
dim percent as double
dim s as string
for i = 0 to 13
    if exec(pathToFbc, args(i)) = -1 then
        print "ERROR while running fbc with: "+args(i)
    else
        percent = (i/13)
        s = "["
        s += string(int(percent*25), "=")
        s += string(25-int(percent*25), " ")
        s += "] "
        s += str(int(percent*100))+"%"
        print s+chr(13);
    end if
next i

print ""
print "Compiling program..."
if exec(pathToFbc, "-w all rcast.bas -p lib/ -exx") = -1 then
    print "ERROR while running fbc with: -w all rcast.bas -p lib/"
end if
print "Done!"
