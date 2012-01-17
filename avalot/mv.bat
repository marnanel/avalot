rem @echo off
echo LZEXEing...
for %%t in (*.exe) do lzexe %%t
echo Deleting old avx files...
del *.avx
echo Renaming Avalot files...
ren avalot9.exe avalot.avx
ren bootstrp.exe avalot.exe
ren stars.exe stars.avx
ren intro.exe intro.avx
ren avmenu.exe avmenu.avx
ren slope.exe slope.avx
ren seu.exe seu.avx
ren g-room.exe g-room.avx
