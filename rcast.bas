#include once "SDL2/SDL.bi"

randomize timer

#define FULLSCREEN 1
#define SCREEN_X   532'352'352'1280'532'352'532'1920'352
#define SCREEN_Y   300'198'198'720'300'198'300'1080'198
#define HALF_X     SCREEN_X \ 2
#define HALF_Y     SCREEN_Y \ 2
#define PREC         (2^14)
#define PREC_SHIFT   14
dim shared MAX_DISTANCE as integer = (1024 shl PREC_SHIFT) '300
#define MAX_INT      (2^16)

dim shared HEIGHT_RATIO as integer
HEIGHT_RATIO = SCREEN_Y shl PREC_SHIFT

#include once "modules/inc/timer.bi"
#include once "modules/inc/easing.bi"
#include once "modules/inc/gfont.bi"
#include once "modules/inc/vector.bi"
#include once "modules/inc/mesh.bi"
#include once "modules/inc/flatmapcell.bi"
#include once "modules/inc/flatmap.bi"
#include once "modules/inc/bsp.bi"
#include once "modules/inc/rgb.bi"
#include once "modules/inc/dartmanager.bi"
#include once "modules/inc/mob.bi"
#include once "modules/inc/mobmanager.bi"
#include once "modules/inc/sound.bi"

#include once "game/inc/mobs.bi"
#include once "game/inc/draw.bi"

'// GRAPHICS FUNCTIONS  ================================================
declare sub gfx_dice(sprites() as SDL_RECT, filename as string, img_w as integer, img_h as integer, sp_w as integer, sp_h as integer, scale_x as double=1.0, scale_y as double=0)
declare sub drawLine(x0 as integer, y0 as integer, x1 as integer, y1 as integer, colr as integer, pixels as integer ptr, pitch as integer)
declare sub drawTriangle(x0 as integer, y0 as integer, x1 as integer, y1 as integer, x2 as integer, y2 as integer, z as integer, colr as integer, pixels as integer ptr, pitch as integer)
declare sub drawTriangleTop(x0 as integer, y0 as integer, x1 as integer, y1 as integer, x2 as integer, y2 as integer, z as integer, colr as integer, pixels as integer ptr, pitch as integer)
declare sub drawTriangleBtm(x0 as integer, y0 as integer, x1 as integer, y1 as integer, x2 as integer, y2 as integer, z as integer, colr as integer, pixels as integer ptr, pitch as integer)
declare sub loadMeshFile(filename as string, meshIndex as integer = 0)
'// END GRAPHICS FUNCTIONS  ============================================

declare sub main()
declare sub loadMap(highres as FlatMap, medres as FlatMap, lowres as FlatMap)

#define MAP_WIDTH  1024
#define MAP_HEIGHT 1024

'// SHARED  ============================================================
dim shared highres as FlatMap = FlatMap(MAP_WIDTH, MAP_HEIGHT)
dim shared medres as FlatMap = FlatMap(MAP_WIDTH \ 2, MAP_HEIGHT \ 2)
dim shared lowres as FlatMap = FlatMap(MAP_WIDTH \ 4, MAP_HEIGHT \ 4)
dim shared subres as FlatMap = FlatMap(MAP_WIDTH \ 8, MAP_HEIGHT \ 8)
'//=====================================================================

'// INIT SDL SYSTEM AND GRAPHICS  ======================================
dim shared gfxWindow as SDL_Window ptr
dim shared gfxRenderer as SDL_Renderer ptr
dim shared gfxSprites as SDL_Texture ptr

'SDL_Init( SDL_INIT_AUDIO or SDL_INIT_JOYSTICK or SDL_INIT_HAPTIC )
if SDL_Init( SDL_INIT_AUDIO ) = 0 then
    SOUND_Init
else
    print "sound error"
    end
end if

SDL_Init( SDL_INIT_VIDEO )

if FULLSCREEN then SDL_ShowCursor( 0 )

gfxWindow = SDL_CreateWindow( "White Horse", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_X, SCREEN_Y, SDL_WINDOW_FULLSCREEN_DESKTOP )
gfxRenderer = SDL_CreateRenderer( gfxWindow, -1, null )
SDL_RenderSetLogicalSize( gfxRenderer, SCREEN_X, SCREEN_Y )
SDL_SetRenderDrawBlendMode( gfxRenderer, SDL_BLENDMODE_NONE )

dim shared game_font as GFONT = GFONT(@gfxRenderer)
game_font.load("font.bmp", 256, 256, 8, 8, GFONT_W/8)

'//=====================================================================

dim shared tileColors(1023) as integer

function addTileColor( colr as integer ) as integer

    dim r as integer
    dim g as integer
    dim b as integer

    'r = red(colr) shr 3
    'g = grn(colr) shr 3
    'b = blu(colr) shr 3
    
    'colr = rgb(r shl 3, g shl 3, b shl 3)
    if colr = 0 then return 0

    dim i as integer
    for i = 1 to 1023
        if tileColors(i) = colr then
            return i
        end if
        if tileColors(i) = 0 then
            tileColors(i) = colr
            return i
        end if
    next i
    
    return 0

end function

enum CellFlags
    water  = &h01
    clouds = &h02
end enum

type ColorScheme
    base as integer
    
end type

dim shared colorFloor as integer
dim shared colorWall as integer
dim shared colorSky as integer
dim shared colorWater as integer
dim shared atmosphereFactor as double

colorFloor = &h8db27c
colorWall  = &hffe4d8
colorSky   = &hbec2ff '&h1e2252 '&hbec2ff
colorWater = &h5c73ab

dim ang as double
ang = rnd(1)*360
'ang = 250
'ang = 240
'ang = 200
'ang = 220
ang = 230
colorSky   = rgbMix(hue(ang+0.0, 1.0), &hffffff, 1.0, 1.5)
colorFloor = rgbMix(hue(ang+240, 0.5), &hffffff, 1.0, 1.0)
colorWall  = rgbMix(hue(ang+120, 0.8), &hffffff, 0.1, 1.5)
colorWater = rgbMix(hue(ang+340, 0.8), colorSky, 1.0, 0.5)

atmosphereFactor = 0.005 '0.015 '0.005

SOUND_SetMusicVolume 0.0'1.0
SOUND_SetSoundVolume 0.0'1.0

SOUND_SetMusic "ogg/explore.ogg"
SOUND_AddSound "huh", "sfx/huh.wav", , , 0.3333
SOUND_AddSound "step", "sfx/step.wav", , , 0.25
SOUND_AddSound "step0", "sfx/step0.wav", , , 0.50
SOUND_AddSound "step1", "sfx/step1.wav", , , 0.50
SOUND_AddSound "step2", "sfx/dirtystep.wav", , , 0.50
SOUND_AddSound "shoot0", "sfx/shoot1.wav", , , 1.00
SOUND_AddSound "shoot1", "sfx/shoot5.wav", , , 1.00
'SOUND_AddSound "shoot2", "sfx/boom3.wav", , , 1.00
SOUND_AddSound "shoot2", "sfx/shoot8.wav", , , 1.00
SOUND_AddSound "boom", "sfx/boom1.wav", , , 1.00

SOUND_PlayMusic

loadMap highres, medres, lowres

dim shared meshCount as integer = 0
dim shared meshes(64) as Mesh
dim shared meshPositions(64) as Vector
dim i as integer
for i = 0 to 8
    meshPositions(i).x = 80+rnd(1)*700
    meshPositions(i).y = 80+rnd(1)*700
    meshPositions(i).z = highres.getCell(int(meshPositions(i).x)+0.5, int(meshPositions(i).y)+0.5)->getFloorHeight()*0.01+0.75
    'highres.getCell(int(meshPositions(i).x), int(meshPositions(i).y), &hffff00)
next i

main

'// SHUTDOWN SDL  ======================================================
SDL_DestroyTexture( gfxSprites )
SDL_DestroyRenderer( gfxRenderer )
SDL_DestroyWindow( gfxWindow )
    
SDL_Quit
'//=====================================================================

end

enum MeshIds
    horse = 0
end enum

enum Datas
    water = 1
    clouds
end enum

type Game_Session
    position as Vector
    forward as Vector
    angleX as double
    angleY as double
    angleZ as double
    midline as double
    height as double
end type

dim shared Game as Game_Session
dim shared pixels as integer ptr
dim shared pitch as integer

function getForwardVector() as Vector

    dim v as Vector

    v = Vector(1, 0, 0)
    v = vectorRotateY(v,  Game.angleZ)
    v = vectorRotateZ(v,  Game.angleY)
    v = vectorRotateX(v,  Game.angleX)
    Game.forward = vectorUnit(v)
    
    return v

end function

function getForwardFlatVector() as Vector

    dim v as Vector

    v = Vector(1, 0, 0)
    v = vectorRotateZ(v,  Game.angleY)
    Game.forward = vectorUnit(v)
    
    return v

end function

function getRightVector() as Vector

    dim v as Vector

    v = Vector(0, -1, 0)
    v = vectorRotateY(v,  Game.angleZ)
    v = vectorRotateZ(v,  Game.angleY)
    v = vectorRotateX(v,  Game.angleX)
    
    return v

end function

function getUpVector() as Vector

    dim v as Vector

    v = Vector(0, 0, 1)
    v = vectorRotateY(v,  Game.angleZ)
    v = vectorRotateZ(v,  Game.angleY)
    v = vectorRotateX(v,  Game.angleX)
    
    return v

end function

function rndint(from as integer, too as integer) as integer
    return int(((too-from)+1)*rnd(1))+from
end function

static shared dartRenderCount as integer = 0

sub dart_move_shrapnel(d as Dart ptr, delta as double)

    d->setAngleZ( d->getAngleZ() + delta*500 )
    d->moveSimple(delta)

end sub

sub dart_move_simple(d as Dart ptr, delta as double)

    d->moveSimple(delta)

end sub

function mapToProj(u as Vector) as Vector

    dim v as Vector
    
    v.x = u.y
    v.y = u.z
    v.z = u.x
    
    return v

end function

sub dart_render(d as Dart ptr)

'	DrawOnMap Game.sprites(d->getFrameStart()+int(d->getCount())), d->getX(), d->getY(), 0
    dim u as Vector
    dim v3 as Vector3
    dim hd as double
    dim dist as integer
    dim dot as double
    
    'm.translate(py-512, -(ph-hh), 512-px)
    
    u.x = Game.position.y-d->getY()
    u.y = -(Game.position.z-d->getZ())
    u.z = d->getX()-Game.position.x
    'hd = 0' Game.position.z' - d->getZ()
    
    v3.v(0).x = -0.25
    v3.v(1).x =  0.0
    v3.v(2).x =  0.25
    v3.v(0).y =  0.0
    v3.v(1).y =  0.0
    v3.v(2).y =  0.0
    v3.v(0).z = -1.0
    v3.v(1).z =  0.0
    v3.v(2).z = -1.0
    
    v3.rotateX(-d->getAngleZ())
    v3.rotateY(d->getAngleY())
    v3.rotateZ(d->getAngleX())
    v3.translate(u.x, u.y, u.z)
    
    'dim pv as Vector = Vector(d->getX()-Game.position.x, 0, d->getY()-Game.position.y)
    'dim fv as Vector = vectorUnit(Vector(Game.forward.x, 0, Game.forward.y))
    'dot = vectorDot(fv, vectorUnit(pv)): if dot < 0 then return
    
    dim size as double
    
    'v = vectorTranslate(v, Game.position.y-512, -hd, 512-Game.position.x)
    v3.rotateY(-Game.angleY)
    
    dist = (int((u.z))\4) and 255
    
    v3.make2d(SCREEN_X, SCREEN_Y, SCREEN_Y)
    v3.translate(0, Game.midline-HALF_Y, 0)
    
    'dim vx as double, vy as double
    'vx = cos(d->getAngle()*TO_RAD)*size
    'vy = sin(d->getAngle()*TO_RAD)*size
    
    'size *= 0.5
    drawTriangle(v3.v(0).x, v3.v(0).y, v3.v(1).x, v3.v(1).y, v3.v(2).x, v3.v(2).y, dist, tileColors(d->getFrameStart()), pixels, pitch)
    
    dartRenderCount += 1

end sub

sub dart_renderRGB(d as Dart ptr)

'	DrawOnMap Game.sprites(d->getFrameStart()+int(d->getCount())), d->getX(), d->getY(), 0
    dim u as Vector
    dim v3 as Vector3
    dim hd as double
    dim dist as integer
    dim dot as double
    
    'm.translate(py-512, -(ph-hh), 512-px)
    
    u.x = Game.position.y-d->getY()
    u.y = -(Game.position.z-d->getZ())
    u.z = d->getX()-Game.position.x
    'hd = 0' Game.position.z' - d->getZ()
    
    v3.v(0).x = -0.25
    v3.v(1).x =  0.0
    v3.v(2).x =  0.25
    v3.v(0).y =  0.0
    v3.v(1).y =  0.0
    v3.v(2).y =  0.0
    v3.v(0).z = -1.0
    v3.v(1).z =  0.0
    v3.v(2).z = -1.0
    
    v3.rotateX(d->getAngleX())
    v3.rotateZ(d->getAngleZ())
    v3.rotateY(d->getAngleY())
    v3.translate(u.x, u.y, u.z)
    
    'dim pv as Vector = Vector(d->getX()-Game.position.x, 0, d->getY()-Game.position.y)
    'dim fv as Vector = vectorUnit(Vector(Game.forward.x, 0, Game.forward.y))
    'dot = vectorDot(fv, vectorUnit(pv)): if dot < 0 then return
    'if vectorFacesPoint(Game.forward, Vector(d->getX()-Game.position.x, 0, d->getY()-Game.position.y)) then return
    
    dim size as double
    
    'v = vectorTranslate(v, Game.position.y-512, -hd, 512-Game.position.x)
    v3.rotateY(-Game.angleY)
    v3.rotateX( Game.angleZ)
    
    dist = (int((u.z))\4) and 255
    
    v3.make2d(SCREEN_X, SCREEN_Y, SCREEN_Y)
    'v3.translate(0, Game.midline-HALF_Y, 0)
    
    'dim vx as double, vy as double
    'vx = cos(d->getAngle()*TO_RAD)*size
    'vy = sin(d->getAngle()*TO_RAD)*size
    
    'size *= 0.5
    drawTriangle(v3.v(0).x, v3.v(0).y, v3.v(1).x, v3.v(1).y, v3.v(2).x, v3.v(2).y, dist, d->getFrameStart(), pixels, pitch)
    
    dartRenderCount += 1

end sub

sub dart_renderRGB_static(d as Dart ptr)

	dim u as Vector
    dim v3 as Vector3
    
    u.x = d->getX()
    u.y = d->getY()
    u.z = d->getZ()
    
    v3.v(0).x = -0.25
    v3.v(1).x =  0.0
    v3.v(2).x =  0.25
    v3.v(0).y =  0.0
    v3.v(1).y =  0.0
    v3.v(2).y =  0.0
    v3.v(0).z = -1.0
    v3.v(1).z =  0.0
    v3.v(2).z = -1.0
    
    v3.rotateZ(d->getAngleZ())
    v3.rotateX(-d->getAngleX())
    v3.rotateY(d->getAngleY())
    v3.translate(u.x, u.y, u.z)
    
    v3.make2d(SCREEN_X, SCREEN_Y, SCREEN_Y)
    
    drawTriangle(v3.v(0).x, v3.v(0).y, v3.v(1).x, v3.v(1).y, v3.v(2).x, v3.v(2).y, -1, d->getFrameStart(), pixels, pitch)
    
    dartRenderCount += 1

end sub

'// inaccurate, but close enough for some things
function quick_dist(u as Vector, v as Vector) as double

    return abs(u.x-v.x)+abs(u.y-v.y)+abs(u.z-v.z)

end function

function dart_collide(d as Dart ptr, extra as any ptr) as integer

    dim top as double
    dim cell as FlatMapCell ptr
    dim darts as DartManager ptr
    
    cell = highres.getCell(d->getX(), d->getY())
    top = cell->getFloorHeight()*0.01
    
    if d->getZ() <= top then
        darts = cast(DartManager ptr, extra)
        darts->fire(Vector(d->getX(), d->getY(), top), Vector(1-rnd(1)*2, 1-rnd(1)*2, rnd(1)), 25, cell->getFloorTile())_
            ->setCollideCallback(0)_
            ->setExpiresInSeconds(1.0)_
            ->setMoveCallback( @dart_move_shrapnel )
        darts->fire(Vector(d->getX(), d->getY(), top), Vector(1-rnd(1)*2, 1-rnd(1)*2, rnd(1)), 25, cell->getFloorTile())_
            ->setCollideCallback(0)_
            ->setExpiresInSeconds(1.0)_
            ->setMoveCallback( @dart_move_shrapnel )
        darts->fire(Vector(d->getX(), d->getY(), top), Vector(1-rnd(1)*2, 1-rnd(1)*2, rnd(1)), 25, cell->getFloorTile())_
            ->setCollideCallback(0)_
            ->setExpiresInSeconds(1.0)_
            ->setMoveCallback( @dart_move_shrapnel )
        SOUND_PlaySound "boom", 1-quick_dist(Vector(d->getX(), d->getY(), d->getZ()), Game.position)*0.005
        cell->setFloorTile( addTileColor(rgbMix(tileColors(cell->getFloorTile()), &h000000, 1.0, 0.2)) )
        return 1
    else
        return 0
    end if
    
end function

sub loadHorse()
    restore horse
    dim x as integer, y as integer
    dim m as Mesh
    dim c as integer
    dim row as string
    dim scale as double
    scale = .1
    for y = 15 to 0 step -1
        read row
        for x = 1 to 16
            if mid(row, x, 1) = "#" then
                'm.addCube((x-7.5)*1, (y-7.5)*1, 0, 1, 1, 1)
                meshes(MeshIds.horse).addCube((x-7.5), (y-7.5), 0, scale, scale, scale)
            end if
        next x
    next y
    'meshes(MeshIds.horse) = m.copy()
    meshCount += 1
end sub

sub loadRunes(meshStartId as integer)
    dim x as integer, y as integer
    dim m as Mesh
    dim c as integer
    dim row as string
    dim scale as double
    scale = .1
    restore runes
    dim i as integer
    for i = 0 to 8
        for y = 4 to 0 step -1
            read row
            for x = 1 to 18
                if mid(row, x, 1) = "#" then
                    meshes(meshStartId+i).addCube((x-7.5), (y-7.5), 0, scale, scale, scale)
                end if
            next x
        next y
        meshCount += 1
    next i
    
end sub

sub loadMeshFile(filename as string, meshIndex as integer=0)

    dim idx as integer
    dim x as double, y as double, z as double
    dim vertexCount as integer
    dim normalCount as integer
    dim triangleCount as integer
    dim i as integer
    dim p0 as integer, p1 as integer, p2 as integer
    dim n0 as integer, n1 as integer, n2 as integer
    dim v as Vector
    
    if meshIndex = 0 then
        meshIndex = meshCount
        meshCount += 1
    end if
    
    idx = meshIndex
    
    open filename for input as #1
        input #1, vertexCount
        vertexCount \= 3
        for i = 0 to vertexCount-1
            input #1, v.z, v.x, v.y 'v.x, v.y, v.z
            meshes(idx).addVertexFast(@v)
        next i
        input #1, normalCount
        normalCount \= 3
        for i = 0 to normalCount-1
            input #1, v.z, v.x, v.y  'v.x, v.y, v.z
            meshes(idx).addNormalFast(@v)
        next i
        input #1, triangleCount
        for i = 0 to triangleCount-1
            input #1, p0, n0, p1, n1, p2, n2
            meshes(idx).addPolyByVertices(p0, p1, p2, n0)
        next i
    close #1

end sub

sub doCollisionCheckX(forward as Vector)

    dim map as FlatMap ptr
    dim hx as integer
    dim hit as integer
    dim p as Vector
    dim hgt as double
    dim nph as double
    dim g as double
    g = 0.1656
    
    map = @highres
    
    p   = Game.position
    hgt = Game.height
    hit = 0
    
    nph = map->getCell(int(p.x-g), int(p.y-g))->getFloorHeight()*0.01+hgt: if nph-p.z > 0.1375 then hit = 1: hx = int(p.x-g)
    nph = map->getCell(int(p.x+g), int(p.y-g))->getFloorHeight()*0.01+hgt: if nph-p.z > 0.1375 then hit = 1: hx = int(p.x+g)
    nph = map->getCell(int(p.x-g), int(p.y+g))->getFloorHeight()*0.01+hgt: if nph-p.z > 0.1375 then hit = 1: hx = int(p.x-g)
    nph = map->getCell(int(p.x+g), int(p.y+g))->getFloorHeight()*0.01+hgt: if nph-p.z > 0.1375 then hit = 1: hx = int(p.x+g)
    nph = map->getCell(int(p.x-g), int(p.y-g))->getCeilHeight()*0.01+hgt: if nph-p.z < hgt then hit = 1: hx = int(p.x-g)
    nph = map->getCell(int(p.x+g), int(p.y-g))->getCeilHeight()*0.01+hgt: if nph-p.z < hgt then hit = 1: hx = int(p.x+g)
    nph = map->getCell(int(p.x-g), int(p.y+g))->getCeilHeight()*0.01+hgt: if nph-p.z < hgt then hit = 1: hx = int(p.x-g)
    nph = map->getCell(int(p.x+g), int(p.y+g))->getCeilHeight()*0.01+hgt: if nph-p.z < hgt then hit = 1: hx = int(p.x+g)
    if hit then
        Game.position.x = iif(forward.x > 0, hx-(g+0.0001), hx+(1+g+0.0001))
    end if

end sub

sub doCollisionCheckY(forward as Vector)

    dim map as FlatMap ptr
    dim hy as integer
    dim hit as integer
    dim p as Vector
    dim hgt as double
    dim nph as double
    dim g as double
    g = 0.1656
    
    map = @highres
    
    p   = Game.position
    hgt = Game.height
    hit = 0
    
    nph = map->getCell(int(p.x-g), int(p.y-g))->getFloorHeight()*0.01+hgt: if nph-p.z > 0.1375 then hit = 1: hy = int(p.y-g)
    nph = map->getCell(int(p.x+g), int(p.y-g))->getFloorHeight()*0.01+hgt: if nph-p.z > 0.1375 then hit = 1: hy = int(p.y-g)
    nph = map->getCell(int(p.x-g), int(p.y+g))->getFloorHeight()*0.01+hgt: if nph-p.z > 0.1375 then hit = 1: hy = int(p.y+g)
    nph = map->getCell(int(p.x+g), int(p.y+g))->getFloorHeight()*0.01+hgt: if nph-p.z > 0.1375 then hit = 1: hy = int(p.y+g)
    nph = map->getCell(int(p.x-g), int(p.y-g))->getCeilHeight()*0.01+hgt: if nph-p.z < hgt then hit = 1: hy = int(p.y-g)
    nph = map->getCell(int(p.x+g), int(p.y-g))->getCeilHeight()*0.01+hgt: if nph-p.z < hgt then hit = 1: hy = int(p.y-g)
    nph = map->getCell(int(p.x-g), int(p.y+g))->getCeilHeight()*0.01+hgt: if nph-p.z < hgt then hit = 1: hy = int(p.y+g)
    nph = map->getCell(int(p.x+g), int(p.y+g))->getCeilHeight()*0.01+hgt: if nph-p.z < hgt then hit = 1: hy = int(p.y+g)
    if hit then
        Game.position.y = iif(forward.y > 0, hy-(g+0.0001), hy+(1+g+0.0001))
    end if

end sub

sub doCollisionCheckZ(forward as Vector)

    dim ph as double
    dim nph as double
    dim p as Vector
    dim hgt as double
    dim map as FlatMap ptr
    
    return
    
    map = @highres
    
    p   = Game.position
    hgt = Game.height
    
    nph = map->getCell(int(p.x), int(p.y))->getFloorHeight()*0.01+hgt
    if p.z < nph then
       Game.position.z = nph
    end if
    nph = map->getCell(int(p.x), int(p.y))->getCeilHeight()*0.01
    if nph-p.z < 0 and nph-p.z >= -hgt then
       Game.position.z = nph-0.01
    end if

end sub

sub main()

    dim px as double, py as double, pz as double
    dim pa as double
    dim ph as double
    dim f as double
    dim a as double
    
    Game.position.x = 155.5 'MAP_WIDTH * 0.5 + 0.5
    Game.position.y = 512.5 'MAP_HEIGHT * 0.5 + 0.5
    Game.position.z = 10
    Game.height     = 0.25
    pa = 0
    
    dim vf as Vector
    dim vr as Vector
    dim vu as Vector
    dim vrayTop as Vector
    dim vrayBtm as Vector
    
    'dim topFovPosX as Vector
    'dim btmFovPosX as Vector
    'dim topFovPosY as Vector
    'dim btmFovPosY as Vector
    'dim topFovIncX as Vector
    'dim btmFovIncX as Vector
    'dim topFovIncY as Vector
    'dim btmFovIncY as Vector
    'dim topFovAdjX as Vector
    'dim btmFovAdjX as Vector
    'dim topFovAdjY as Vector
    'dim btmFovAdjY as Vector
    
    dim x_tx as uinteger, x_ty as uinteger, x_tz as uinteger '// top FOV ray coordinates  -- X intersections
    dim x_bx as uinteger, x_by as uinteger, x_bz as uinteger '// btm FOV ray coordinates  -- X intersections
    dim y_tx as uinteger, y_ty as uinteger, y_tz as uinteger '// top FOV ray coordinates  -- Y intersections
    dim y_bx as uinteger, y_by as uinteger, y_bz as uinteger '// btm FOV ray coordinates  -- Y intersections
    dim x_atx as integer, x_aty as integer, x_atz as integer '// top FOV increment amount -- X intersections
    dim x_abx as integer, x_aby as integer, x_abz as integer '// btm FOV increment amount -- X intersections
    dim y_atx as integer, y_aty as integer, y_atz as integer '// top FOV increment amount -- Y intersections
    dim y_abx as integer, y_aby as integer, y_abz as integer '// btm FOV increment amount -- Y intersections
    dim x_etx as uinteger, x_ety as uinteger '// top FOV extra increment amount -- X intersections
    dim x_ebx as uinteger, x_eby as uinteger '// btm FOV extra increment amount -- X intersections
    dim y_etx as uinteger, y_ety as uinteger '// top FOV extra increment amount -- Y intersections
    dim y_ebx as uinteger, y_eby as uinteger '// btm FOV extra increment amount -- Y intersections
    
    dim tx as uinteger, ty as uinteger, tz as uinteger '// temporary ray coordinate values for top FOV ray coordinates (used for closest X/Y intersection)
    dim bx as uinteger, by as uinteger, bz as uinteger '// temporary ray coordinate values for btm FOV ray coordinates (used for closest X/Y intersection)
    dim etx as integer, ety as integer                 '// temporary ray increment  values for top FOV ray coordinates (used for closest X/Y intersection)
    dim ebx as integer, eby as integer                 '// temporary ray increment  values for top FOV ray coordinates (used for closest X/Y intersection)
    
    dim ftx as double, fty as double, ftz as double
    dim fbx as double, fby as double, fbz as double
    dim fdist as double
    
    dim lx as uinteger, ly as uinteger
    dim tmx as uinteger, tmy as uinteger
    dim bmx as uinteger, bmy as uinteger
    dim xtDist as uinteger, ytDist as uinteger
    dim xbDist as uinteger, ybDist as uinteger
    dim tDist as uinteger, bDist as uinteger
    dim dist as uinteger
    dim dc as double
    dim sliceSize as double
    
    dim event as SDL_Event
	dim keys as const ubyte ptr
    dim mousestate as long
    dim mx as long, my as long
    
    dim fps as integer
    dim fps_count as integer
    dim fps_timer as double
    dim seconds as double
    
    dim top as integer
    dim bottom as integer
    dim ctop as integer
    dim cbottom as integer
    
    dim mousedown_left as integer
    dim mousedown_right as integer
    
    dim fov as double: fov = 1
    
    dim midline as double: midline = HALF_Y
    
    dim map as FlatMap ptr
    dim delta as double
    
    dim darts as DartManager
    darts.setBounds(0, 0, -50, highres.getWidth(), highres.getHeight(), 50)
    darts.setRenderCallback(@dart_render)
    
    dim centerDist as double
    
    dim mobs as MobManager
    
    dim nph as double
    midline += (HALF_Y/2)
    
    dim ha as double
    dim height as double
    
    dim rayCallback as sub(byref x_dx as uinteger, byref x_dy as uinteger, byref y_dx as uinteger, byref y_dy as uinteger)
    
    dim walkingSpeed as double = 4.0 '3.5 '5.0
    dim flyingSpeed as double = 30
    'dim pitch as double
    dim mode as integer = 1
    dim strafeAngle as double
    dim strafeValue as double
    
    dim texture as SDL_Texture ptr
    texture = SDL_CreateTexture(gfxRenderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, SCREEN_X, SCREEN_Y)
    
    'loadHorse()
    loadMeshFile "shopvac.dae", 0
    loadRunes 1
    
    UpdateSpeed()
    seconds = 0
    SDL_SetRelativeMouseMode(1)
    mousestate = SDL_GetRelativeMouseState(@mx, @my)
    pa = 0
    midline = HALF_Y
    my = 0
    dim rotateZ as double
    do
        px = Game.position.x
        py = Game.position.y
        ph = Game.position.z
        pz = Game.position.z
        height = Game.height
    
        if px <= 65 then
            atmosphereFactor = 0.005+(75-px)*0.002
            colorSky   = &hffc2be
            colorSky   = rgbAdd(&hffc2be, -128)
            MAX_DISTANCE = 100 SHL PREC_SHIFT
        elseif px <= 75 then
            colorSky   = &hffc2be
            colorSky   = rgbAdd(&hffc2be, -128)
            colorSky   = rgbMix(colorSky, &h000000, abs(px-75))
            MAX_DISTANCE = 1024 SHL PREC_SHIFT
        else
            atmosphereFactor = 0.005
            colorSky = &hbec2ff
            'colorSky   = rgbMix(&hbec2ff, &h000000, 1.0-(0.5*(1-(seconds mod 600)/300)), 2.0*(1-(seconds mod 600)/300))
        end if
    
        delta = UpdateSpeed()
        seconds += delta
        
        fps_count += 1
        fps_timer += delta
        if fps_timer >= 1 then
            fps = fps_count
            fps_count = 0
            fps_timer = 0
        end if
		
		while( SDL_PollEvent( @event ) )
			select case event.type
			case SDL_QUIT_
				return
			end select
		wend
        
        keys = SDL_GetKeyboardState(0)
        mousestate = SDL_GetRelativeMouseState(@mx, @my)
        mousedown_left = mousestate and SDL_BUTTON(SDL_BUTTON_LEFT)
		mousedown_right = mousestate and SDL_BUTTON(SDL_BUTTON_RIGHT)
        
        pa -= mx*0.20
        
        midline -= my*(SCREEN_Y/300)
        if midline <  0 then midline = 0
        if midline >  HALF_Y*0.5 then midline = HALF_Y*0.5
        
        rotateZ -= my*(SCREEN_Y/300)*0.3333
        if rotateZ < -90 then rotateZ = -90
        if rotateZ >  90 then rotateZ =  90
        if rotateZ = 0 then rotateZ = 0.0001
        'if midline < -HALF_Y then midline = -HALF_Y
        'if midline >  SCREEN_Y*1.5 then midline = SCREEN_Y*1.5
        'if midline > HALF_Y*10 then midline = HALF_Y*10
        fov = 1'1+abs(midline-HALF_Y)*0.00125*(300/SCREEN_Y)
        
        Game.angleY = pa
        Game.angleZ = rotateZ
        vf = Vector(1, 0, 0)
        vf = vectorRotateY(vf, rotateZ)
        vf = vectorRotateZ(vf, pa)
        Game.forward = vectorUnit(vf)
        
        map = @highres
        
        ha = (midline-HALF_Y)*(300/SCREEN_Y)
        
        '//  FALLING!!!!!!  ============================================
        static dv as double
        dim cheight as double
        dim fheight as double
        if mode = 2 then
            dim g as double
            g = 10
            dv += g*delta
            ph -= dv*delta
        
            nph = map->getCell(int(px), int(py))->getFloorHeight()*0.01
            fheight = nph
            nph += height
            if ph < nph then
               ph = nph
               dv = 0
            end if
            nph = map->getCell(int(px), int(py))->getCeilHeight()*0.01
            cheight = nph
            if nph-ph < 0 and nph-ph >= -height then
               ph = nph-0.01
               dv = g*delta
            end if
            Game.position.z = ph
        end if
        '//=============================================================
        
        dim speed as double
        
        speed = iif(mode = 1, flyingSpeed, walkingSpeed)
        
        if keys[SDL_SCANCODE_ESCAPE] then
            return
        end if
        
        static fireTimer as double
        static mouseLetGo as integer
        static dAngleZ as double
        'fireTimer = iif(fireTimer-delta < 0, 0, fireTimer-delta)
        fireTimer -= delta
        if fireTimer < 0 then fireTimer = 0
        if (mousedown_left and (fireTimer = 0)) or (mousedown_left and mouseLetGo) then
            fireTimer = 0.45
            dim position as Vector
            dim forward as Vector
            
            position = Game.position
            forward  = Game.forward
            
            'forward.z = forward.z * (midline-HALF_Y)*
            
            'forward.z *= 0.6325
            'forward.z = ha*0.0029
            
            'centerDist = *(pixels+HALF_Y*pitch+HALF_X-1) shr 24
            'forward = vectorUnit((Game.forward*cast(double, centerDist))-vectorRight(Game.forward)*0.50)
            
            '// add player's velocity to forward vector
            
            darts.fire(position, forward, 125, rgb(208+rnd(1)*47, 208+rnd(1)*47, 108+rnd(1)*147))_
                ->setCollideCallback(@dart_collide)_
                ->setRenderCallback(@dart_renderRGB)_
                ->setAngleY( Game.angleY )_
                ->setAngleX(-Game.angleZ )'_
                '->setMoveCallback(@dart_move_simple)
            'darts.fire(Vector(0.25, -0.25, -1.0), Vector(0, 0, 1), 125, rgb(208+rnd(1)*47, 208+rnd(1)*47, 108+rnd(1)*147))_
            '    ->setRenderCallback(@dart_renderRGB_static)_
            '    ->setAngleY(30)_
            '    ->setAngleX(30)_
            '    ->setExpiresInSeconds(0.20)_
            '    ->setMoveCallback(@dart_move_simple)_
            '    ->setCheckBounds(false)
            
            dAngleZ = Game.angleZ
            SOUND_PlaySound "shoot2"
            mouseLetGo = 0
        end if
        if mousedown_left = 0 then
            mouseLetGo = 1
        end if
        
        dim hit as integer
        dim hx as integer, hy as integer
        
        if keys[SDL_SCANCODE_LEFT] then
            pa += 100*delta
        end if
        if keys[SDL_SCANCODE_RIGHT] then
            pa -= 100*delta
        end if
        if keys[SDL_SCANCODE_PAGEUP] then
            'midline += 300*delta
            rotateZ += 60*delta
            if rotateZ < -90 then rotateZ = -90
            if rotateZ >  90 then rotateZ =  90
            if rotateZ = 0 then rotateZ = 0.0001
        end if
        if keys[SDL_SCANCODE_PAGEDOWN] then
            'midline -= 300*delta
            rotateZ -= 60*delta
            if rotateZ < -90 then rotateZ = -90
            if rotateZ >  90 then rotateZ =  90
            if rotateZ = 0 then rotateZ = 0.0001
        end if
        
        if keys[SDL_SCANCODE_LSHIFT]  then
            height = 0.125
            speed *= 0.25
        else
            height = 0.25
        end if
        'if keys[SDL_SCANCODE_LSHIFT] then speed *= 0.25
        if keys[SDL_SCANCODE_LCTRL] then speed *= 1.45
        
        Game.height = height
        
        if keys[SDL_SCANCODE_A] then
            select case mode
            case 1
                Game.position -= getRightVector() * speed * 0.75 * delta
            case 2
                vf  = -vectorRight(Game.forward) * speed * 0.75 * delta
                Game.position.x += vf.x: doCollisionCheckX(vf)
                Game.position.y += vf.y: doCollisionCheckY(vf)
            end select
        end if
        if keys[SDL_SCANCODE_D] then
            select case mode
            case 1
                Game.position += getRightVector() * speed * 0.75 * delta
            case 2
                vf  = vectorRight(Game.forward) * speed * 0.75 * delta
                Game.position.x += vf.x: doCollisionCheckX(vf)
                Game.position.y += vf.y: doCollisionCheckY(vf)
            end select
        end if
        if keys[SDL_SCANCODE_LEFTBRACKET] then
            select case mode
            case 1
                Game.angleX -= 300 * delta
            end select
        end if
        if keys[SDL_SCANCODE_RIGHTBRACKET] then
            select case mode
            case 1
                Game.angleX += 300 * delta
            end select
        end if
        'static stepTimer as double
        'static stepo as integer
        dim last as double
        last = strafeAngle mod 180
        'stepTimer -= delta * iif(keys[SDL_SCANCODE_LCTRL], 1.45, 1)
        'if stepTimer < 0 then stepTimer = 0
        if keys[SDL_SCANCODE_UP] or keys[SDL_SCANCODE_W] then
            select case mode
            case 1
                Game.position += Game.forward * speed * delta
            case 2
                vf = Game.forward * speed * delta
                Game.position.x += vf.x: doCollisionCheckX(vf)
                Game.position.y += vf.y: doCollisionCheckY(vf)
                Game.position.z += vf.z: doCollisionCheckZ(vf)
                if dv = 0 then
                    strafeAngle += delta*150*iif(keys[SDL_SCANCODE_LSHIFT], speed*6, speed)
                end if
                'if stepTimer = 0 then
                '    SOUND_PlaySound iif(stepo and 1, "step", "step0")
                '    stepo += 1
                '    stepTimer = 0.3333
                'end if
            end select
        end if
        if keys[SDL_SCANCODE_DOWN] or keys[SDL_SCANCODE_S] then
            select case mode
            case 1
                Game.position -= Game.forward * speed * delta
            case 2
                vf = -Game.forward * speed * 0.75 * delta
                Game.position.x += vf.x: doCollisionCheckX(vf)
                Game.position.y += vf.y: doCollisionCheckY(vf)
                Game.position.z += vf.z*0.2222: doCollisionCheckZ(vf)
                if dv = 0 then
                    strafeAngle -= delta*150*iif(keys[SDL_SCANCODE_LSHIFT], speed*6, speed)
                end if
                'if stepTimer = 0 then
                '    SOUND_PlaySound iif(stepo and 1, "step", "step0")
                '    stepo += 1
                '    stepTimer = 0.3333
                'end if
            end select
        end if
        static stepo as integer
        if (dv = 0) and ((strafeAngle mod 180) >= 90) and (last < 90) then
            SOUND_PlaySound iif(stepo and 1, "step0", "step0")
            stepo += 1
        end if
        if keys[SDL_SCANCODE_SPACE] and (dv = 0) then
            if mode = 1 then
                Game.position.z += speed * 0.5 * delta: doCollisionCheckZ(Game.forward)
            else
                dv = -3*(1+(speed-walkingSpeed)*0.2)
                SOUND_PlaySound "huh"
            end if
        end if
        if keys[SDL_SCANCODE_TAB] then
            Game.position.z -= speed * delta: doCollisionCheckZ(Game.forward)
        end if
        if keys[SDL_SCANCODE_1] then
            mode = 1
        end if
        if keys[SDL_SCANCODE_2] then
            mode = 2
        end if
        
        if pa >= 360 or pa < 0 then pa = pa mod 360
        
        strafeValue = cos(strafeAngle*TO_RAD)*0.01
        
        'dim za as double
        'za = ha*(90/SCREEN_Y)
        '
        'if za <= -45 then za = -45
        'if za >=  45 then za =  45
        'if za = 0 then za = 0.0001
        
        Game.angleY  = pa
        'Game.angleX  = rotateZ
        Game.forward = getForwardVector()
        Game.midline = midline
        
        if keys[SDL_SCANCODE_0] then
            midline = HALF_Y
            pa = 0
            rotateZ = 0
            Game.angleX = 0
            Game.angleY = 0
            Game.angleZ = 0
            Game.forward.x = 1
            Game.forward.y = 0
            Game.forward.z = 0
        end if
        
        px = Game.position.x
        py = Game.position.y
        ph = Game.position.z
        pz = Game.position.z
        
        '// RAYCAST BEGIN  =============================================
        'dim vps as Vector
        'dim vpr as Vector
        
        'vf    = getForwardVector()
        'vr    = getRightVector()
        'vup   = getUpVector()
        '
        'vray = vf-vr
        'vr /= HALF_X
        
        dim vraytop as Vector
        dim vraybtm as Vector
        
        vf = getForwardVector()
        vr = getRightVector()
        vu = getUpVector()
        vraytop = vf-vr+vu
        vraybtm = vf-vr-vu
        
        vr /= HALF_X
        
        'vrayTop = vectorRotate
        
        
        'dim gz as double
        'gz = Game.forward.z
        'Game.forward.z = 0 '- leave value for looking straight down/up
        '
        'vray = vf-vr*cos(Game.angleZ*TO_RAD) '(1-abs(Game.forward.z))
        'vps.x = -vf.x-vr.x
        'vps.y = -vf.y-vr.y
        'vps *= abs(Game.forward.z)*dz
        'vpr = vr*abs(Game.forward.z)*dz
        'vr *= cos(Game.angleZ*TO_RAD) '(1-abs(Game.forward.z))
        'vr /= HALF_X
        'vpr /= HALF_X
        '
        'dim zdistAdd as double
        'dim yAdd as double
        'zdistAdd = vectorSize(vf)*dz*0.5
        'yAdd = -Game.forward.z*HALF_Y
        '
        'down = Game.forward*(dz/abs(Game.forward.z))
        '
        'dim downSize as double
        'downSize = vectorSize(down)
        '
        '
        'Game.forward.z = gz
        
        dim colr as uinteger
        dim xDistMax as integer, yDistMax as integer
        dim distMax as integer
        dim i as integer
        
        '// DRAW SKY  ==================================================
        dim y as integer
        dim r as integer, g as integer, b as integer
        dim rr as integer
        r = (colorSky shr 16) and &hff
        g = (colorSky shr  8) and &hff
        b = (colorSky       ) and &hff
        'bottom = midline-HALF_Y-1
        'if bottom >= 0 then
        '    for y = 0 to bottom
        '        drawLine 0, y, SCREEN_X-1, y, rgb(r-100, g, b)
        '    next y
        'end if
        'top = midline-HALF_Y
        'if top < SCREEN_Y then
        '    for y = top to SCREEN_Y-1
        '        rr = r+y-midline: if rr > 255 then rr = 255
        '        if rr < 0 then r = 0
        '        drawLine 0, y, SCREEN_X-1, y, rgb(rr, g, b)
        '    next y
        'end if
        'SDL_SetRenderDrawColor(gfxRenderer, r, g, b, &hff)
        'SDL_RenderClear(gfxRenderer)
        
        dim wallR as integer, wallG as integer, wallB as integer
        dim skyR as integer, skyG as integer, skyB as integer
        dim ic as integer
        
        dim dc1 as double
        
        dim pixelNow as integer ptr
        dim cpixelNow as integer ptr
        dim xPix as integer, yPix as integer
        dim cyPix as integer
        dim pt as integer
        dim zBufferValue as uinteger
        
        dim mdn as double
        mdn = HALF_Y+SCREEN_Y*Game.forward.z
        
        SDL_LockTexture(texture, null, @pixels, @pitch)
        pitch = (pitch shr 2)
        
        xPix = 0: yPix = 0
        cyPix = 0
        pt = pitch-SCREEN_X
        pixelNow = pixels
        colr = rgb(r, g, b)
        
        dim xStop as integer ptr
        dim yStop as integer ptr
        
        
        dim sk as integer
        sk = (midline-HALF_Y)
        'if sk > 0 then sk = 0
        'colr = colorSky
        'if sk < 0 then
        '    colr += &h010100*sk
        'end if
        'dim colstop as integer
        'colstop = colorSky-&h010100*12
        '
        'yStop = pixels+iif(sk >= 0, sk, 0)*pitch
        'while pixelNow < yStop
        '    xStop = pixelNow + SCREEN_X
        '    while pixelNow < xStop: *pixelNow = colr: pixelNow += 1: wend
        '    pixelNow += pt
        'wend
        yStop = pixels+SCREEN_Y*pitch
        colr = (colr and &h00ffffff) or &h7f000000
        while pixelNow < yStop
            xStop = pixelNow + SCREEN_X
            while pixelNow < xStop: *pixelNow = colr: pixelNow += 1: wend
            pixelNow += pt
            'colr -= &h010100
            'if colr < colstop then colr = colstop
        wend
        pixelNow = pixels
        
        dim c as integer    
        dim ix as integer, iy as integer
        'dim savePx as double, savePy as double
        dim tcell as FlatMapCell ptr
        dim bcell as FlatMapCell ptr
        xPix = -1
        
        dim vrotatex as Vector
        vrotatex = vectorFromAngle(Game.angleZ)
    
        for f = 0 to SCREEN_X-1
            xPix += 1
            map = @highres
            
            'savePx = px: savePy = py
            'px = px+vps.x: py = py+vps.y
            
        
            bottom  = SCREEN_Y-1
            cbottom = 0
            
            '// EDGE-OF-MAP INTERSECTION ===============================
            'xDistMax = 0
            'yDistMax = 0
            '
            'if px < 0 or px >= map->getWidth() then
            '    fx += abs(iif(vray.x > 0, -px, MAP_WIDTH-px)/vray.x)
            'end if
            '
            'fx += abs(iif(vray.x > 0, map->getWidth()-1-px, -px)/vray.x)
            '
            'if fx > MAX_INT then fx = MAX_INT
            'xDistMax = fx*PREC
            '
            'if py < 0 or py >= map->getHeight() then
            '    fy += abs(iif(vray.y > 0, -py, MAP_HEIGHT-py)/vray.y)
            'end if
            '
            'fy += abs(iif(vray.y > 0, map->getHeight()-1-py, -py)/vray.y)
            '
            'if fy > MAX_INT then fy = MAX_INT
            'yDistMax = fy*PREC
            '
            'distMax = iif(xDistMax < yDistMax, xDistMax, yDistMax)'-1000000
            'if distMax > MAX_DISTANCE then distMax = MAX_DISTANCE
            
            'distMax = MAX_DISTANCE
            distMax = 300 shl PREC_SHIFT
            
            '===========================================================
            '  CLOSEST INTERSECTION
            '===========================================================
            '
            '  \\  //
            '   \\//
            '   //\\
            '  //  \\
            '
            '===========================================================
            if px >= 0 and px < map->getWidth() then
                ftx = iif(vraytop.x > 0, int(px+1)-px, int(px)-px)
                fbx = iif(vraybtm.x > 0, int(px+1)-px, int(px)-px)
            else
                ftx = iif(vraytop.x > 0, -px, MAP_WIDTH-px)
                fbx = iif(vraybtm.x > 0, -px, MAP_WIDTH-px)
            end if
            
            fdist = abs(ftx/vraytop.x): if fdist > MAX_INT then fdist = MAX_INT
            xtDist = fdist*PREC
            
            fty = vraytop.y*fdist
            if fty >  MAX_INT then fty =  MAX_INT
            if fty < -MAX_INT then fty = -MAX_INT
            ftz = vraytop.z*fdist
            if ftz >  MAX_INT then ftz =  MAX_INT
            if ftz < -MAX_INT then ftz = -MAX_INT
            
            fdist = abs(fbx/vraybtm.x): if fdist > MAX_INT then fdist = MAX_INT
            xbDist = fdist*PREC
            
            fby = vraybtm.y*fdist
            if fby >  MAX_INT then fby =  MAX_INT
            if fby < -MAX_INT then fby = -MAX_INT
            fbz = vraybtm.z*fdist
            if fbz >  MAX_INT then fbz =  MAX_INT
            if fbz < -MAX_INT then fbz = -MAX_INT
            
            x_tx  = (ftx+px)*PREC: x_ty = (fty+py)*PREC: x_tz = (ftz+pz)*PREC
            x_bx  = (fbx+px)*PREC: x_by = (fby+py)*PREC: x_bz = (fbz+pz)*PREC
            x_etx = iif(vraytop.x >= 0, 0, -1): x_ety = 0
            x_ebx = iif(vraybtm.x >= 0, 0, -1): x_eby = 0
            
            '===========================================================
            '  CLOSEST INTERSECTION
            '===========================================================
            '
            '  \\  //
            '   \\//
            '    ||
            '    ||
            '
            '===========================================================
            if py >= 0 and py < map->getHeight() then
                fty = iif(vraytop.y > 0, int(py+1)-py, int(py)-py)
                fby = iif(vraybtm.y > 0, int(py+1)-py, int(py)-py)
            else
                fty = iif(vraytop.y > 0, -py, MAP_HEIGHT-py)
                fby = iif(vraybtm.y > 0, int(py+1)-py, int(py)-py)
            end if
            
            fdist = abs(fty/vraytop.y): if fdist > MAX_INT then fdist = MAX_INT
            ytDist = fdist*PREC
            
            ftx = vraytop.x*fdist
            if ftx >  MAX_INT then ftx =  MAX_INT
            if ftx < -MAX_INT then ftx = -MAX_INT
            ftz = vraytop.z*fdist
            if ftz >  MAX_INT then ftz =  MAX_INT
            if ftz < -MAX_INT then ftz = -MAX_INT
            
            fdist = abs(fby/vraybtm.y): if fdist > MAX_INT then fdist = MAX_INT
            ybDist = fdist*PREC
            
            fbx = vraybtm.x*fdist
            if fbx >  MAX_INT then fbx =  MAX_INT
            if fbx < -MAX_INT then fbx = -MAX_INT
            fbz = vraybtm.z*fdist
            if fbz >  MAX_INT then fbz =  MAX_INT
            if fbz < -MAX_INT then fbz = -MAX_INT
            
            y_tx = (ftx+px)*PREC: y_ty = (fty+py)*PREC: y_tz = (ftz+pz)*PREC
            y_bx = (fbx+px)*PREC: y_by = (fby+py)*PREC: y_bz = (fbz+pz)*PREC
            y_ety = iif(vraytop.y >= 0, 0, -1): y_etx = 0
            y_eby = iif(vraybtm.y >= 0, 0, -1): y_ebx = 0
            
            '===========================================================
            '
            '  ??? WHO IS CLOSER ???
            '
            '===========================================================
            if xtDist < ytDist then
                tx    = x_tx : ty  = x_ty : tz = x_tz
                etx   = x_etx: ety = x_ety
                tDist = xtDist
            else
                ty    = y_tx : ty  = y_ty : tz = y_tz
                ety   = y_etx: ety = y_ety
                tDist = ytDist
            end if
            
            if xbDist < ybDist then
                bx    = x_bx : by  = x_by : bz = x_bz
                ebx   = x_ebx: eby = x_eby
                bDist = xbDist
            else
                by    = y_bx : by  = y_by : bz = y_bz
                eby   = y_ebx: eby = y_eby
                bDist = ybDist
            end if
            
            dim h as double
            dim ch as double
            dim zdist as double
            dim rxy as double
            dim roy as double, roz as double
            dim x as double, y as double, z as double
            
            dist  = tDist '// shouldn't matter -- tDist and bDist should be the same
            zdist = dist / PREC
            
            '===========================================================
            '
            '  WE HAVE MAP X
            '  WE HAVE MAP Y
            '  NOW GET Y and Z in 3D SPACE
            '    * Y is floor/ceil height
            '    * Z is distance
            '  IF 3D POINT IS INSIDE FOV
            '    * Rotate Y and Z
            '    * Get SCREEN Y from Y/Z
            '
            '===========================================================
            h   = map->getCell(int(px), int(py))->getFloorHeight()*0.01
            ch  = map->getCell(int(px), int(py))->getCeilHeight()*0.01
                        
            '-----------------------------------------------------------
            ' check should change to dot product calculations
            ' to support 360 degree rotation
            ' (would need to check FOV lft/rgt if angle > 45)
            '-----------------------------------------------------------
            dim doFloor as integer
            dim doCeil  as integer
            doFloor = 1
            doCeil  = 1
            
            'if h >= tz and h <= bz then '// should only need to be h < bz
                y       = pz-h+strafeValue
                roy     = y* vrotatex.x + zdist*vrotatex.y
                roz     = y*-vrotatex.y + zdist*vrotatex.x
                top     = iif(roz < 0.0001, SCREEN_Y, int(SCREEN_Y*roy/roz+HALF_Y))
            'else
            '    doFloor = 0
            'end if
            
            'if ch >= tz and ch <= bz then '// should only need to be h > tz
                y       = pz-ch+strafeValue
                roy     = y* vrotatex.x + zdist*vrotatex.y
                roz     = y*-vrotatex.y + zdist*vrotatex.x
                cbottom = iif(roz < 0.0001, -1, int(SCREEN_Y*roy/roz+HALF_Y))
            'else
            '    doCeil  = 0
            'end if
            
            zBufferValue =  (((dist shr PREC_SHIFT)\4) and 255) shl 24
            
            ctop = 0
            yPix = bottom
            cyPix = ctop
            pixelNow = pixels+pitch*yPix+xPix
            cPixelNow = pixels+pitch*cyPix+xPix
            tcell = map->getCell(int(px), int(py))
            bcell = tcell
            
            if doCeil  and (cbottom >= bottom) then cbottom = bottom
            if doFloor and (top <= ctop)       then top = ctop
            
            '===========================================================
            '
            '  DRAW CEILING
            '
            '===========================================================
            if doCeil then
                if cbottom >= ctop then
                    colr = tileColors(tcell->getCeilTile())
                    if cbottom >= SCREEN_Y then cbottom = SCREEN_Y-1
                    if colr <> &hff00ff then
                        'colr = rgbAdd(colr, map->normals(int(px), int(py)))
                        colr = ((colr and &h00ffffff) or zBufferValue)
                        while cyPix <= cbottom: *(cpixelNow) = colr: cpixelNow += pitch: cyPix +=1: wend
                    else
                        cPixelNow += pitch*(cbottom-cyPix)
                        cyPix = cbottom
                    end if
                    ctop = cbottom+1
                end if
            end if
            '===========================================================
            '
            '  DRAW FLOOR
            '
            '===========================================================
            if doFloor then
                if top <= bottom then
                    colr = tileColors(bcell->getFloorTile())
                    colr = rgbAdd(colr, bcell->getNormal())
                                    
                    dc = (dist shr PREC_SHIFT)*atmosphereFactor
                    dc = dc*dc*dc
                    dc1 = 1/(dc+1)
                    skyR  = (colorSky  shr 16) and 255: skyG  = (colorSky  shr 8) and 255: skyB  = (colorSky  and 255)
                    if bcell->hasFlag( CellFlags.water ) then
                        dim add as integer
                        add = 7-(int(((cos(int(px)+seconds*0.002)*TO_RAD)*(sin(seconds*0.002-int(py))*TO_RAD)*3000000)) and 15)
                        r = &h5c+add: g = &h53+add: b = &hdb+add
                        wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                        colr = rgb((r+wallR)*0.5, (g+wallG)*0.5, (b+wallB)*0.5)
                        wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                    else
                        wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                    end if
                    r = (wallR+(skyR*dc))*dc1
                    g = (wallG+(skyG*dc))*dc1
                    b = (wallB+(skyB*dc))*dc1
                    if r > 255 then r = 255: if r < 0 then r = 0
                    if g > 255 then g = 255: if g < 0 then g = 0
                    if b > 255 then b = 255: if b < 0 then b = 0
                    colr = rgb(r, g, b)
                    if top < 0 then top = 0
                    colr = ((colr and &h00ffffff) or zBufferValue)
                    while yPix >= top: *(pixelNow) = colr: pixelNow -= pitch: yPix -=1: wend
                    bottom = top-1
                end if
            end if
            '// draw side
            
            tmx = (tx shr PREC_SHIFT)+etx: tmy = (ty shr PREC_SHIFT)+ety
            bmx = (bx shr PREC_SHIFT)+ebx: bmy = (by shr PREC_SHIFT)+eby
            
            tcell = map->getCell(tmx, tmy)
            h = tcell->getFloorHeight()*0.01
            ch = tcell->getCeilHeight()*0.01
            
            doFloor = 1
            doCeil  = 1
            
            'if h >= tz and h <= bz then '// should only need to be h < bz
                y       = pz-h+strafeValue
                roy     = y* vrotatex.x + zdist*vrotatex.y
                roz     = y*-vrotatex.y + zdist*vrotatex.x
                top     = iif(roz < 0.0001, SCREEN_Y, int(SCREEN_Y*roy/roz+HALF_Y))
            'else
            '    doFloor = 0
            'end if
            
            if (tmx <> bmx) or (tmy <> bmy) then '// then rays have split, need to do another ceil/floor/side-ceil/side-floor calculation for second ray
                bcell = map->getCell(bmx, bmy)
                h     = bcell->getFloorHeight()*0.01
                ch    = bcell->getCeilHeight()*0.01
            else
                bcell = tcell
            end if
            
            'if ch >= tz and ch <= bz then '// should only need to be h > tz
                y       = pz-ch+strafeValue
                roy     = y* vrotatex.x + zdist*vrotatex.y
                roz     = y*-vrotatex.y + zdist*vrotatex.x
                cbottom = iif(roz < 0.0001, -1, int(SCREEN_Y*roy/roz+HALF_Y))
            'else
            '    doCeil  = 0
            'end if
            
            zBufferValue =  (((dist shr PREC_SHIFT)\4) and 255) shl 24
            
            if doCeil  and (cbottom >= bottom) then cbottom = bottom
            if doFloor and (top <= ctop)       then top = ctop
            
            '===========================================================
            '
            '  DRAW SIDE FLOOR
            '
            '===========================================================
            if doFloor then
                if top <= bottom then
                    colr = tileColors(tcell->getFloorTile())
                    colr = rgbAdd(colr, tcell->getNormal())
                    colr = rgbAdd(colr, iif(xbDist > ybDist, 10, -10))
                    if top < 0 then top = 0
                    colr = ((colr and &h00ffffff) or zBufferValue)
                    while yPix >= top: *(pixelNow) = colr: pixelNow -= pitch: yPix -=1: wend
                    bottom = top-1
                end if
            end if
            '===========================================================
            '
            '  DRAW SIDE CEILING
            '
            '===========================================================
            if doCeil then
                if cbottom >= ctop then
                    colr = tileColors(bcell->getCeilTile())
                    if cbottom >= SCREEN_Y then cbottom = SCREEN_Y-1
                    if colr <> &hff00ff then
                        'colr = rgbAdd(colr, map->normals(lx, ly))
                        colr = rgbAdd(colr, iif(xtDist > ytDist, 10, -10))
                        colr = ((colr and &h00ffffff) or zBufferValue)
                        while cyPix <= cbottom: *(cpixelNow) = colr: cpixelNow += pitch: cyPix +=1: wend
                    else
                        cPixelNow += pitch*(cbottom-cyPix)
                        cyPix = cbottom
                    end if
                    ctop = cbottom+1
                end if
            end if
            
            '===========================================================
            '
            '  INTERSECTIONS UNTIL EDGE-OF-MAP/MAX-DISTANCE
            '
            '  INITIAL CALCULATIONS
            '
            '===========================================================
            dim x_tdi as uinteger, x_bdi as uinteger '// top/btm distance increments for X intersections
            dim y_tdi as uinteger, y_bdi as uinteger '// top/btm distance increments for Y intersections
            
            x_atx = iif(vraytop.x >= 0, 1, -1)*PREC
            x_aty = (vraytop.y / abs(vraytop.x))*PREC
            x_atz = (vraytop.z / abs(vraytop.x))*PREC
            x_etx = iif(vraytop.x >= 0, 0, -1): x_ety = 0
            x_tdi = abs(PREC/vraytop.x)
            
            x_abx = iif(vraybtm.x >= 0, 1, -1)*PREC
            x_aby = (vraybtm.y / abs(vraybtm.x))*PREC
            x_abz = (vraybtm.z / abs(vraybtm.x))*PREC
            x_ebx = iif(vraybtm.x >= 0, 0, -1): x_eby = 0
            x_bdi = abs(PREC/vraybtm.x)
            
            y_aty = iif(vraytop.y >= 0, 1, -1)*PREC
            y_atx = (vraytop.x / abs(vraytop.y))*PREC
            y_atz = (vraytop.z / abs(vraytop.y))*PREC
            y_ety = iif(vraytop.y >= 0, 0, -1): y_etx = 0
            y_tdi = abs(PREC/vraytop.y)
            
            y_aby = iif(vraybtm.y >= 0, 1, -1)*PREC
            y_abx = (vraybtm.x / abs(vraybtm.y))*PREC
            y_abz = (vraybtm.z / abs(vraybtm.y))*PREC
            y_eby = iif(vraybtm.y >= 0, 0, -1): y_ebx = 0
            y_bdi = abs(PREC/vraybtm.y)
            
            dim switchCount as integer
            dim nextDist as double
            switchCount = 0: nextDist = 160*PREC'96'160'32'160
            
            dist = tDist
            
            '===========================================================
            '
            '  INTERSECTIONS UNTIL EDGE-OF-MAP/MAX-DISTANCE
            '
            '  TARGET THAT EXPLOSION AND FIRE!!!
            '
            '===========================================================
            do while dist < distMax
                
                if xtDist < ytDist then
                    x_tx   += x_atx: x_ty += x_aty: x_tz += x_atz
                    xtDist += x_tdi
                else
                    y_tx   += y_atx: y_ty += y_aty: y_tz += y_atz
                    ytDist += y_tdi
                end if
                
                if xbDist < ybDist then
                    x_bx   += x_abx: x_by += x_aby: x_bz += x_abz
                    xbDist += x_bdi
                else
                    y_bx   += y_abx: y_by += y_aby: y_bz += y_abz
                    ybDist += y_bdi
                end if
                
                if xtDist < ytDist then
                    tx    =  x_tx: ty  = x_ty: tz = x_tz
                    etx   = x_etx: ety = x_ety
                    tDist = xtDist
                else
                    tx  =  y_tx: ty  = y_ty: tz = y_tz
                    etx = y_etx: ety = y_ety
                    tDist = ytDist
                end if
                
                if xbDist < ybDist then
                    bx    =  x_bx: by  = x_by: bz = x_bz
                    ebx   = x_ebx: eby = x_eby
                    bDist = xbDist
                else
                    bx    =  y_bx: by  = y_by: bz = y_bz
                    ebx   = y_ebx: eby = y_eby
                    bDist = ybDist
                end if
                
                dist  = tdist
                zdist = dist / PREC
                
                if dist > distMax then exit do
                
                'if h >= tz and h <= bz then '// should only need to be h < bz
                    y       = pz-h+strafeValue
                    roy     = y* vrotatex.x + zdist*vrotatex.y
                    roz     = y*-vrotatex.y + zdist*vrotatex.x
                    top     = iif(roz < 0.0001, SCREEN_Y, int(SCREEN_Y*roy/roz+HALF_Y))
                'else
                '    doFloor = 0
                'end if
                
                'if ch >= tz and ch <= bz then '// should only need to be h > tz
                    y       = pz-ch+strafeValue
                    roy     = y* vrotatex.x + zdist*vrotatex.y
                    roz     = y*-vrotatex.y + zdist*vrotatex.x
                    cbottom = iif(roz < 0.0001, -1, int(SCREEN_Y*roy/roz+HALF_Y))
                'else
                '    doCeil  = 0
                'end if
                
                zBufferValue =  (((dist shr PREC_SHIFT)\4) and 255) shl 24
                
                dc = 0
                if cbottom >= bottom then cbottom = bottom
                if top <= ctop then top = ctop
                if cbottom >= ctop then
                    colr = tileColors(bcell->getCeilTile())
                    if cbottom >= SCREEN_Y then cbottom = SCREEN_Y-1
                    if colr <> &hff00ff then
                        if dc = 0 then
                            dc = (dist shr PREC_SHIFT)*atmosphereFactor
                            dc = dc*dc*dc
                            dc1 = 1/(dc+1)
                            colr = rgbMix(colr, colorSky, 1, dc)
                            colr = rgbMix(colr, colr, 1, dc1)
                        end if
                        'colr = rgbAdd(colr, map->normals(lx, ly))
                        colr = ((colr and &h00ffffff) or zBufferValue)
                        while cyPix <= cbottom: *(cpixelNow) = colr: cpixelNow += pitch: cyPix +=1: wend
                    else
                        cPixelNow += pitch*(cbottom-cyPix)
                        cyPix = cbottom
                    end if
                    ctop = cbottom+1
                end if
                if top <= bottom then
                
                    colr = tileColors(tcell->getFloorTile())
                    colr = rgbAdd(colr, tcell->getNormal())
                    
                    dc = (dist shr PREC_SHIFT)*atmosphereFactor
                    dc = dc*dc*dc
                    dc1 = 1/(dc+1)
                    skyR  = (colorSky  shr 16) and 255: skyG  = (colorSky  shr 8) and 255: skyB  = (colorSky  and 255)
                    if tcell->hasFlag( CellFlags.water ) then
                        dim add as integer
                        add = 7-(int(((cos(lx+seconds*0.002)*TO_RAD)*(sin(seconds*0.002-ly)*TO_RAD)*3000000)) and 15)
                        r = &h5c+add: g = &h53+add: b = &hdb+add
                        wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                        colr = rgb((r+wallR)*0.5, (g+wallG)*0.5, (b+wallB)*0.5)
                        wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                    else
                        wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                    end if
                    r = (wallR+(skyR*dc))*dc1
                    g = (wallG+(skyG*dc))*dc1
                    b = (wallB+(skyB*dc))*dc1
                    if r > 255 then r = 255: if r < 0 then r = 0
                    if g > 255 then g = 255: if g < 0 then g = 0
                    if b > 255 then b = 255: if b < 0 then b = 0
                    colr = rgb(r, g, b)
                
                    'drawLine f, top, f, bottom, colr, 0
                    if top < 0 then top = 0
                    colr = ((colr and &h00ffffff) or zBufferValue)
                    while yPix >= top: *(pixelNow) = colr: pixelNow -= pitch: yPix -=1: wend
                    bottom = top-1
                end if
                
                'if (dist > nextDist) then
                '    switchCount += 1
                '    select case switchCount
                '    case 1
                '        map = @medres
                '        nextDist = 320*PREC'160'320'64'320
                '    case 2
                '        map = @lowres
                '        nextDist = 480*PREC'320'480'256'480
                '    case 3
                '        map = @subres
                '        nextDist = &h7fffffff
                '    end select
                '    xAlign = 1: yAlign = 1
                '    x_tx  \= 2: x_ty  \= 2: x_tz  \= 2
                '    x_bx  \= 2: x_by  \= 2: x_bz  \= 2
                '    y_tx  \= 2: y_ty  \= 2: y_tz  \= 2
                '    y_bx  \= 2: y_by  \= 2: y_bz  \= 2
                '    x_tdi *= 2: y_tdi *= 2
                '    x_bdi *= 2: y_bdi *= 2
                '    tmx   \= 2: tmy   \= 2
                '    bmx   \= 2: bmy   \= 2
                '    if x_tx-((x_tx shr PREC_SHIFT) shl PREC_SHIFT) <> 0 then
                '        x_tx   += x_atx\2: x_ty += x_aty\2: x_tz += x_atz\2
                '        xtDist += x_tdi\2
                '    end if
                '    if x_bx-((x_bx shr PREC_SHIFT) shl PREC_SHIFT) <> 0 then
                '        x_bx   += x_abx\2: x_by += x_aby\2: x_bz += x_abz\2
                '        xbDist += x_bdi\2
                '    end if
                '    if y_ty-((y_ty shr PREC_SHIFT) shl PREC_SHIFT) <> 0 then
                '        y_ty   += y_aty\2: y_tx += y_atx\2: y_tz += y_atz\2
                '        ytDist += y_tdi\2
                '    end if
                '    if y_by-((y_by shr PREC_SHIFT) shl PREC_SHIFT) <> 0 then
                '        y_by   += y_aby\2: y_bx += y_abx\2: y_bz += y_abz\2
                '        ybDist += y_bdi\2
                '    end if
                '    
                '    if xtDist < ytDist then
                '        tx  =  x_tx: ty  = x_ty: tz = x_tz
                '        etx = x_etx: ety = x_ety
                '        tdist = xtDist
                '    else
                '        tx  =  y_tx: ty  = y_ty: tz = y_tz
                '        etx = y_etx: ety = y_ety
                '        tdist = ytDist
                '    end if
                '    
                '    if xbDist < ybDist then
                '        bx  =  x_bx: by  = x_by: bz = x_bz
                '        ebx = x_ebx: eby = x_eby
                '        bdist = xbDist
                '    else
                '        bx  =  y_bx: by  = y_by: bz = y_bz
                '        ebx = y_ebx: eby = y_eby
                '        bdist = ybDist
                '    end if
                '    
                'end if
                
                '// draw side
                
                tmx = (tx shr PREC_SHIFT)+etx: tmy = (ty shr PREC_SHIFT)+ety
                bmx = (bx shr PREC_SHIFT)+ebx: bmy = (by shr PREC_SHIFT)+eby
                
                tcell = map->getCell(tmx, tmy)
                h     = tcell->getFloorHeight()*0.01
                ch    = tcell->getCeilHeight()*0.01
                
                doFloor = 1
                doCeil  = 1
                
                'if h >= tz and h <= bz then '// should only need to be h < bz
                    y       = pz-h+strafeValue
                    roy     = y* vrotatex.x + zdist*vrotatex.y
                    roz     = y*-vrotatex.y + zdist*vrotatex.x
                    top     = iif(roz < 0.0001, SCREEN_Y, int(SCREEN_Y*roy/roz+HALF_Y))
                'else
                '    doFloor = 0
                'end if
            
                if (tmx <> bmx) or (tmy <> bmy) then '// then rays have split, need to do another ceil/floor/side-ceil/side-floor calculation for second ray
                    bcell = map->getCell(bmx, bmy)
                    h     = bcell->getFloorHeight()*0.01
                    ch    = bcell->getCeilHeight()*0.01
                else
                    bcell = tcell
                end if
                
                'if ch >= tz and ch <= bz then '// should only need to be h > tz
                    y       = pz-ch+strafeValue
                    roy     = y* vrotatex.x + zdist*vrotatex.y
                    roz     = y*-vrotatex.y + zdist*vrotatex.x
                    cbottom = iif(roz < 0.0001, -1, int(SCREEN_Y*roy/roz+HALF_Y))
                'else
                '    doCeil  = 0
                'end if

                
                zBufferValue =  (((dist shr PREC_SHIFT)\4) and 255) shl 24
                
                if cbottom >= bottom then cbottom = bottom
                if top <= ctop then top = ctop
                if cbottom >= ctop then
                    colr = tileColors(tcell->getCeilTile())
                    if cbottom >= SCREEN_Y then cbottom = SCREEN_Y-1
                    if colr <> &hff00ff then
                        if tcell->hasFlag( CellFlags.clouds ) then
                            'colr = rgbAdd(colr, map->normals(lx, ly)+iif(xDist > yDist, 10, -10))
                            colr = rgbAdd(colr, iif(xtDist > ytDist, 10, -10))
                        end if
                        'if dc = 0 then
                            dc = (dist shr PREC_SHIFT)*atmosphereFactor
                            dc = dc*dc*dc
                            dc1 = 1/(dc+1)
                            colr = rgbMix(colr, colorSky, 1, dc)
                            colr = rgbMix(colr, colr, 1, dc1)
                        'end if
                        colr = ((colr and &h00ffffff) or zBufferValue)
                        while cyPix <= cbottom: *(cpixelNow) = colr: cpixelNow += pitch: cyPix +=1: wend
                    else
                        cPixelNow += pitch*(cbottom-cyPix)
                        cyPix = cbottom
                    end if
                    ctop = cbottom+1
                end if
                if top <= bottom then
                    colr = tileColors(bcell->getFloorTile())
                    colr = rgbAdd(colr, bcell->getNormal())
                    colr = rgbAdd(colr, iif(xbDist > ybDist, 10, -10))
                    'if dc = 0 then
                        dc = (dist shr PREC_SHIFT)*atmosphereFactor
                        dc = dc*dc*dc
                        dc1 = 1/(dc+1)
                    'end if
                    'ic = iif(xDist > yDist, 10, -10)
                    
                    wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                    skyR  = (colorSky  shr 16) and 255: skyG  = (colorSky  shr 8) and 255: skyB  = (colorSky  and 255)
                    'wallR += ic: wallG += ic: wallB += ic
                    if wallR > 255 then wallR = 255
                    if wallG > 255 then wallG = 255
                    if wallB > 255 then wallB = 255
                    if wallR < 0 then wallR = 0
                    if wallG < 0 then wallG = 0
                    if wallB < 0 then wallB = 0
                    r = (wallR+(skyR*dc))*dc1
                    g = (wallG+(skyG*dc))*dc1
                    b = (wallB+(skyB*dc))*dc1
                    if r > 255 then r = 255: if r < 0 then r = 0
                    if g > 255 then g = 255: if g < 0 then g = 0
                    if b > 255 then b = 255: if b < 0 then b = 0
                    colr = rgb(r, g, b)
                    'drawLine f, top, f, bottom, colr, 0
                    if top < 0 then top = 0
                    colr = ((colr and &h00ffffff) or zBufferValue)
                    while yPix >= top: *(pixelNow) = colr: pixelNow -= pitch: yPix -=1: wend
                    bottom = top-1
                end if
                
                if bottom < 0 then exit do
                if ctop >= SCREEN_Y then exit do
                if ctop >= bottom then exit do
                
            loop
            
            'end
            '// draw sky
            'if bottom >= 0 then
            '    drawLine f, 0, f, bottom, colorSky
            'end if
            'dim y as integer
            'dim r as integer, g as integer, b as integer
            'for y = -1 to bottom step 3
            '    r = (colorSky shr 16) and &hff
            '    g = (colorSky shr  8) and &hff
            '    b = (colorSky       ) and &hff
            '    r += y-midline: if r > 255 then r = 255
            '    if r < 0 then r = 0
            '    if y+9 <= bottom then
            '        drawLine f, y, f, y+2, rgb(r, g, b)
            '    else
            '        drawLine f, y, f, bottom, rgb(r, g, b)
            '    end if
            'next y
            if bottom > midline then
                top = midline
                if top < 0 then top = 0
                'while yPix >= top: *(pixelNow) = colr: pixelNow -= pitch: yPix -=1: wend
            end if
            
            vraytop += vr
            vraybtm += vr
            
            'vray.x += vr.x: vray.y += vr.y
            'vps.x  += vpr.x: vps.y += vpr.y
            
            'if f = HALF_X then
            '    game_font.writeText( "MAX: "+str(int(dist)), 3, 12 )
            'end if
            
            'px = savePx: py = savePy
            
        next f
        
        '// draw meshes
            dim m as Mesh
            dim mp as MeshPoly ptr
            dim mv as Vector ptr
            'dim fx as double, fy as double
            'dim ix as integer, iy as integer
            dim v3 as Vector3
            dim v4 as Vector3
            dim vCenter as Vector
            dim showNormals as integer
            dim vc as Vector, dot as double
            
            showNormals = 0
            
            vCenter = Vector(0, 0, 0)
            
            SDL_SetRenderDrawColor(gfxRenderer, &hff, 0, 0, 0)
            dim mc as integer
            mc = 0
            for i = 0 to meshCount-1
                if i > 0 then
                    dim pv as Vector = Vector(meshPositions(i).x-Game.position.x, 0, meshPositions(i).y-Game.position.y)
                    dim fv as Vector = vectorUnit(Vector(Game.forward.x, 0, Game.forward.y))
                    dot = vectorDot(fv, vectorUnit(pv)): if dot < 0 then continue for
                end if
                '- idea -- low-poly meshes for ones further out
                mc += 1
                
                m.copy(@meshes(i))
                if i > 0 then
                    m.rotateY((seconds*120) mod 360)
                    m.translate(Game.position.y-meshPositions(i).y, meshPositions(i).z-Game.position.z, meshPositions(i).x-Game.position.x)
                    m.rotateY(-pa)
                else
                    m.rotateY(180)
                    m.rotateX(-Easing.quad_easein(fireTimer*2)*10)
                    m.rotateX(-90)
                    m.rotateX(90)
                    if fireTimer = 0 then
                        m.translate(2-strafeValue*70, -2-abs(strafeValue*50), 5-strafeValue*20)
                    else
                        m.translate(2, -2, 5-Easing.quad_easein(fireTimer*2)*3)
                    end if
                end if
                m.sort()
                m.startOver()
                
                c = 0
                do
                    mp = m.getNext()
                    if mp = 0 then exit do
                    
                    v3 = mp->copy()
                    
                    if i = 0 then
                        vc = v3.v(3)
                        dot = vectorDot(vc, vectorUnit(Vector(0, 0, 1)))
                    else
                        vc = vectorUnit(vectorCross(v3.v(2)-v3.v(0), v3.v(1)-v3.v(0)))
                        dot = vectorDot(vc, Vector(0, 0, 1))
                    end if
                    
                    if dot <= 0 or i = 0 then
                        dot = (vectorDot(vc, Vector(1, -1, 1)))
                        
                        if showNormals then
                            v4.v(0) = (v3.v(0)+v3.v(1)+v3.v(2))/3
                            v4.v(1) = v4.v(0)
                            v4.v(2) = v3.v(2)
                            v4.v(1) += vc*0.1
                        end if
                        
                        if (v3.v(0).z > 0) and (v3.v(1).z > 0) and (v3.v(2).z > 0) then
                            dim z as integer
                            z = (int((v3.v(0).z))\4) and 255 ' do mesh positions - player (should already be this?)
                            v3.make2d(SCREEN_X, SCREEN_Y, SCREEN_Y)
                            if i > 0 then v3.translate(0, mdn-HALF_Y, 0)
                            'fx = v3.v(0).x: fy = v3.v(0).y
                            'ix = cast(integer, fx): iy = cast(integer, fy)
                            'if ix >= 0 and ix < SCREEN_X and iy >= 0 and iy < SCREEN_Y then
                                'pixelNow = pixels+ix+iy*pitch
                                '*pixelNow = rgb(255, 0, 0)
                            'end if
                            'print c, ix, iy
                            'fx = v3.v(1).x: fy = v3.v(1).y
                            'ix = cast(integer, fx): iy = cast(integer, fy)
                            'if ix >= 0 and ix < SCREEN_X and iy >=0 and iy < SCREEN_Y then
                                'pixelNow = pixels+ix+iy*pitch
                                '*pixelNow = rgb(255, 255, 0)
                            'end if
                            'print c, ix, iy
                            'fx = v3.v(2).x: fy = v3.v(2).y
                            'ix = cast(integer, fx): iy = cast(integer, fy)
                            'if ix >= 0 and ix < SCREEN_X and iy >=0 and iy < SCREEN_Y then
                                'pixelNow = pixels+ix+iy*pitch
                                '*pixelNow = rgb(255, 0, 255)
                            'end if
                            if i = 0 then
                                'cell = 0' highres.getCell(int(px), int(py))
                                dc = 0'tileColors(cell->getCeilTile()) '// SHOULD BE RGBADD!!!
                                dc += iif(dc < 96, (96-25)+fireTimer*25, fireTimer*25)
                                r = &hff+dot*50
                                g = &he4+dot*50
                                b = &hd8+dot*50
                                z = -1
                            else
                                r = &hff+dot*30
                                g = &he4+dot*30
                                b = &hd8+dot*30
                            end if
                            if r > 255 then r = 255
                            if g > 255 then g = 255
                            if b > 255 then b = 255
                            r *= 0.85: g *= 0.85: b *= 0.85
                            if i = 0 then
                                colr = rgbMix(rgb(r, g, b), dc, 1.0, 2.0)
                            else
                                colr = rgb(r, g, b)
                            end if
                            drawTriangle(v3.v(0).x, v3.v(0).y, v3.v(1).x, v3.v(1).y, v3.v(2).x, v3.v(2).y, z, colr, pixels, pitch)
                            
                            if showNormals then
                                v4.make2d(SCREEN_X, SCREEN_Y, SCREEN_Y)
                                if i > 0 then v4.translate(0, midline-HALF_Y, 0)
                                drawLine(v4.v(0).x, v4.v(0).y, v4.v(1).x, v4.v(1).y, &hff0000, pixels, pitch)
                            end if
                            
                            'SDL_RenderDrawLine(gfxRenderer, v3.v(0).x, v3.v(0).y, v3.v(1).x, v3.v(1).y)
                            'SDL_RenderDrawLine(gfxRenderer, v3.v(1).x, v3.v(1).y, v3.v(2).x, v3.v(2).y)
                            'SDL_RenderDrawLine(gfxRenderer, v3.v(2).x, v3.v(2).y, v3.v(0).x, v3.v(0).y)
                            'c += 1
                            'ix = cast(integer, fx): iy = cast(integer, fy)
                            ix = v3.v(0).x: iy = v3.v(0).z
                        end if
                    end if
                    'print c, ix, iy
                loop
            next i
            
            centerDist = cast(ubyte, *(pixels+HALF_Y*pitch+HALF_X-1) shr 24)
            
            dartRenderCount = 0
            darts.cycle(delta)
            mobs.cycle(delta)
        
        SDL_UnlockTexture(texture)
        SDL_RenderCopy(gfxRenderer, texture, null, null)
        
        
        '// RAYCAST END  ===============================================
        'game_font.writeText( str(int(strafeAngle)), 3, 3 )
        game_font.writeText( "FPS: "+str(fps), 3, 3 )
        game_font.writeText( "X: "+str(cast(single, px)), 3, 15 )
        game_font.writeText( "Y: "+str(cast(single, py)), 3, 27 )
        game_font.writeText( "Z: "+str(cast(single, pz)), 3, 39 )
        game_font.writeText( "AX: "+str(cast(single, Game.angleX)), 3, 51 )
        game_font.writeText( "AY: "+str(cast(single, Game.angleY)), 3, 63 )
        game_font.writeText( "AZ: "+str(cast(single, Game.angleZ))+", "+str(cast(single, dAngleZ)), 3, 75 )
        game_font.writeText( "VX: "+str(cast(single, Game.forward.x)), 3, 87  )
        game_font.writeText( "VY: "+str(cast(single, Game.forward.y)), 3, 99  )
        game_font.writeText( "VZ: "+str(cast(single, Game.forward.z)), 3, 111 )
        'game_font.writeText( "MSH: "+str(mc), 3, 123 )
        'game_font.writeText( "DRT: "+str(darts.getCount()), 3, 51 )
        'game_font.writeText( "DRC: "+str(dartRenderCount), 3, 63 )
        'game_font.writeText( "DST: "+str(cast(single, centerDist)), 3, 123 )
        if 0 then
        game_font.writeText( "FPS: "+str(fps), 3, 3 )
        game_font.writeText( "X: "+str(cast(single, px)), 3, 15 )
        game_font.writeText( "Y: "+str(cast(single, py)), 3, 27 )
        game_font.writeText( "Z: "+str(cast(single, ph)), 3, 39 )
        game_font.writeText( "FZ: "+str(cast(single, fheight)), 3, 51 )
        game_font.writeText( "CZ: "+str(cast(single, cheight)), 3, 63 )
        game_font.writeText( "VX: "+str(cast(single, Game.forward.x)), 3, 75 )
        game_font.writeText( "VY: "+str(cast(single, Game.forward.y)), 3, 87 )
        game_font.writeText( "VZ: "+str(cast(single, Game.forward.z)), 3, 99 )
        game_font.writeText( "PITCH: "+str(cast(single, ha*(90/SCREEN_Y))), 3, 111 )
        game_font.writeText( "HA: "+str(cast(single, ha)), 3, 123 )
        end if
        
        'game_font.writeText( "ZDI  : "+str(z_di), 3, 99 )
        'game_font.writeText( "MLINE: "+str(midline), 3, 15 )
        game_font.writeText( "+", HALF_X-4, HALF_Y-4 )
        'game_font.writeText( str(int(512-px)), 3, 51 )
        'game_font.writeText( str(int(512-py)), 3, 63 )
        'game_font.writeText( str((-(ph-hh))), 3, 51 )
        'game_font.writeText( str(int(iy)), 3, 63 )
        
        SDL_RenderPresent gfxRenderer
        
    loop

end sub

sub drawTriangleTop(x0 as integer, y0 as integer, x1 as integer, y1 as integer, x2 as integer, y2 as integer, z as integer, colr as integer, pixels as integer ptr, pitch as integer)

    dim dx as double, dy as double
    dim sx0 as double, sy0 as double
    dim sx1 as double, sy1 as double
    dim vx0 as double, vy0 as double
    dim vx1 as double, vy1 as double
    dim vm as double
    
    dim x as integer, y as integer
    dim pixelNow as integer ptr   
     
    if y0 > y1 then swap y0, y1: swap x0, x1
    if y0 > y2 then swap y0, y2: swap x0, x2
    if y1 > y2 then swap y1, y2: swap x1, x2
    if y0 > y1 then swap y0, y1: swap x0, x1
    
    dx = iif(x1-x0 <> 0, x1-x0, 0.0001): dy = iif(y1-y0 <> 0, y1-y0, 0.0001): vx0 = dx/dy
    
    if x0 < 0 then y0 = y0-(dy/dx)*x0: x0 = 0
    if x0 >= SCREEN_X then y0 = y0+(dy/dx)*(SCREEN_X-x0): x0 = SCREEN_X-1
    if y0 < 0 then x0 = x0-(dx/dy)*y0: y0 = 0
    if y0 >= SCREEN_Y then x0 = x0+(dx/dy)*(SCREEN_Y-y0): y0 = SCREEN_Y-1
    if x1 < 0 then y1 = y1-(dy/dx)*x1: x1 = 0
    if x1 >= SCREEN_X then y1 = y1+(dy/dx)*(SCREEN_X-x1): x1 = SCREEN_X-1
    if y1 < 0 then x1 = x1-(dx/dy)*y1: y1 = 0
    if y1 >= SCREEN_Y then x1 = x1+(dx/dy)*(SCREEN_Y-y1): y1 = SCREEN_Y-1
    
    dx = iif(x2-x0 <> 0, x2-x0, 0.0001): dy = iif(y2-y0 <> 0, y2-y0, 0.0001): vx1 = dx/dy
    
    if x2 < 0 then y2 = y2-(dy/dx)*x2: x2 = 0
    if x2 >= SCREEN_X then y2 = y2+(dy/dx)*(SCREEN_X-x2): x2 = SCREEN_X-1
    if y2 < 0 then x2 = x2-(dx/dy)*y2: y2 = 0
    if y2 >= SCREEN_Y then x2 = x2+(dx/dy)*(SCREEN_Y-y2): y2 = SCREEN_Y-1
    
    dx = iif(x1-x0 <> 0, x1-x0, 0.0001): dy = iif(y1-y0 <> 0, y1-y0, 0.0001): vx0 = dx/dy
    dx = iif(x2-x0 <> 0, x2-x0, 0.0001): dy = iif(y2-y0 <> 0, y2-y0, 0.0001): vx1 = dx/dy
    
    sx0 = x0+0.5: sy0 = y0+0.5
    sx1 = x0+0.5: sy1 = y0+0.5
    
	dim i as integer
    dim n as integer
    dim l as integer
	for i = y0 to y1
		l = int(abs(int(sx1)-int(sx0)))'+1
        n = 0
        x = int(iif(sx0 < sx1, sx0, sx1))
        y = int(iif(sx0 < sx1, sy0, sy1))
        sx0 += vx0: sy0 += 1
        sx1 += vx1: sy1 += 1
        if (y < 0) or (y >= SCREEN_Y) or (x >= SCREEN_X) then
            continue for
        end if
        if x < 0 then
            l += x
            x  = 0
        end if
        if (x+l) >= SCREEN_X then
            l += (SCREEN_X-(x+l))
        end if
        pixelNow = pixels+x+y*pitch
        if z > -1 then
            while n <= l
                if (*(pixelNow) shr 24) >= z then
                    *(pixelNow) = colr
                end if
                pixelNow += 1
                n += 1
            wend
        else
            while n <= l
                *(pixelNow) = colr
                pixelNow += 1
                n += 1
            wend
        end if
	next i

end sub

sub drawTriangleBtm(x0 as integer, y0 as integer, x1 as integer, y1 as integer, x2 as integer, y2 as integer, z as integer, colr as integer, pixels as integer ptr, pitch as integer)

    dim dx as double, dy as double
    dim sx0 as double, sy0 as double
    dim sx1 as double, sy1 as double
    dim vx0 as double, vy0 as double
    dim vx1 as double, vy1 as double
    dim vm as double
    
    dim x as integer, y as integer
    dim pixelNow as integer ptr   
     
    if y0 > y1 then swap y0, y1: swap x0, x1
    if y0 > y2 then swap y0, y2: swap x0, x2
    if y1 > y2 then swap y1, y2: swap x1, x2
    if y0 > y1 then swap y0, y1: swap x0, x1
    
    dx = iif(x2-x0 <> 0, x2-x0, 0.0001): dy = iif(y2-y0 <> 0, y2-y0, 0.0001): vx0 = dx/dy
    
    if x0 < 0 then y0 = y0-(dy/dx)*x0: x0 = 0
    if x0 >= SCREEN_X then y0 = y0+(dy/dx)*(SCREEN_X-x0): x0 = SCREEN_X-1
    if y0 < 0 then x0 = x0-(dx/dy)*y0: y0 = 0
    if y0 >= SCREEN_Y then x0 = x0+(dx/dy)*(SCREEN_Y-y0): y0 = SCREEN_Y-1
    if x2 < 0 then y2 = y2-(dy/dx)*x2: x2 = 0
    if x2 >= SCREEN_X then y2 = y2+(dy/dx)*(SCREEN_X-x2): x2 = SCREEN_X-1
    if y2 < 0 then x2 = x2-(dx/dy)*y2: y2 = 0
    if y2 >= SCREEN_Y then x2 = x2+(dx/dy)*(SCREEN_Y-y2): y2 = SCREEN_Y-1
    
    dx = iif(x2-x1 <> 0, x2-x1, 0.0001): dy = iif(y2-y1 <> 0, y2-y1, 0.0001): vx1 = dx/dy
    
    if x1 < 0 then y1 = y1-(dy/dx)*x1: x1 = 0
    if x1 >= SCREEN_X then y1 = y1+(dy/dx)*(SCREEN_X-x1): x1 = SCREEN_X-1
    if y1 < 0 then x1 = x1-(dx/dy)*y1: y1 = 0
    if y1 >= SCREEN_Y then x1 = x1+(dx/dy)*(SCREEN_Y-y1): y1 = SCREEN_Y-1
    
    dx = iif(x2-x0 <> 0, x2-x0, 0.0001): dy = iif(y2-y0 <> 0, y2-y0, 0.0001): vx0 = dx/dy
    dx = iif(x2-x1 <> 0, x2-x1, 0.0001): dy = iif(y2-y1 <> 0, y2-y1, 0.0001): vx1 = dx/dy
    
    sx0 = x0+0.5: sy0 = y0+0.5
    sx1 = x1+0.5: sy1 = y1+0.5
    
	dim i as integer
    dim n as integer
    dim l as integer
	for i = y0 to y2
		l = int(abs(int(sx1)-int(sx0)))'+1
        n = 0
        x = int(iif(sx0 < sx1, sx0, sx1))
        y = int(iif(sx0 < sx1, sy0, sy1))
        sx0 += vx0: sy0 += 1
        sx1 += vx1: sy1 += 1
        if (y < 0) or (y >= SCREEN_Y) or (x >= SCREEN_X) then
            continue for
        end if
        if x < 0 then
            l += x
            x  = 0
        end if
        if (x+l) >= SCREEN_X then
            l += (SCREEN_X-(x+l))
        end if
        pixelNow = pixels+x+y*pitch
        if z > -1 then
            while n <= l
                if (*(pixelNow) shr 24) >= z then
                    *(pixelNow) = colr
                end if
                pixelNow += 1
                n += 1
            wend
        else
            while n <= l
                *(pixelNow) = colr
                pixelNow += 1
                n += 1
            wend
        end if
	next i

end sub

'// drawTriangleFast()    -- for triangles that don't need to be clipped -- discard any that have points out-of-bounds
'// drawTriangleMed()     -- for triangles that are further out -- can be clipped with lower precision
'// drawTrianglePerfect() -- for triangles that are really close to z=0 and need to be clipped nicely
sub drawTriangle(x0 as integer, y0 as integer, x1 as integer, y1 as integer, x2 as integer, y2 as integer, z as integer, colr as integer, pixels as integer ptr, pitch as integer)

    dim mx as integer, my as integer
    
    if (x0 < 0) and (x1 < 0) and (x2 < 0) then return
    if (y0 < 0) and (y1 < 0) and (y2 < 0) then return
    if (x0 >= SCREEN_X) and (x1 >= SCREEN_X) and (x2 >= SCREEN_X) then return
    if (y0 >= SCREEN_Y) and (y1 >= SCREEN_Y) and (y2 >= SCREEN_Y) then return
    
    '// add clip line method here -- clip the three lines
    
    if y0 > y1 then swap y0, y1: swap x0, x1
    if y0 > y2 then swap y0, y2: swap x0, x2
    if y1 > y2 then swap y1, y2: swap x1, x2
    if y0 > y1 then swap y0, y1: swap x0, x1
        
    if (y0 <> y1) and (y1 <> y2) then
        my = y1
        mx = int(x0+((x2-x0)/(y2-y0))*(my-y0))
        drawTriangleTop(x0, y0, x1, y1, mx, my, z, colr, pixels, pitch)
        drawTriangleBtm(mx, my, x1, y1, x2, y2, z, colr, pixels, pitch)
    else
        if y1 = y2 then
            drawTriangleTop(x0, y0, x1, y1, x2, y2, z, colr, pixels, pitch)
        else
            drawTriangleBtm(x0, y0, x1, y1, x2, y2, z, colr, pixels, pitch)
        end if
    end if

end sub

sub drawLine(x0 as integer, y0 as integer, x1 as integer, y1 as integer, colr as integer, pixels as integer ptr, pitch as integer)

    dim vx as double, vy as double
	dim sx as double, sy as double
	dim dx as integer, dy as integer
	dim vm as double
    
    if (x0 < 0) and (x1 < 0) then return
    if (y0 < 0) and (y1 < 0) then return
    if (x0 >= SCREEN_X) and (x1 >= SCREEN_X) then return
    if (y0 >= SCREEN_Y) and (y1 >= SCREEN_Y) then return
    
    dx = x1-x0
	dy = y1-y0
    
    if dx = 0 then dx = 0.0001
    if dy = 0 then dy = 0.0001
	
	vm = sqr(dx*dx+dy*dy)
	vx = dx / vm
	vy = dy / vm
    
    if x0 < 0 then y0 = y0-(dy/dx)*x0: x0 = 0
    if x0 >= SCREEN_X then y0 = y0+(dy/dx)*(SCREEN_X-x0): x0 = SCREEN_X-1
    if y0 < 0 then x0 = x0-(dx/dy)*y0: y0 = 0
    if y0 >= SCREEN_Y then x0 = x0+(dx/dy)*(SCREEN_Y-y0): y0 = SCREEN_Y-1
    if x1 < 0 then y1 = y1-(dy/dx)*x1: x1 = 0
    if x1 >= SCREEN_X then y1 = y1+(dy/dx)*(SCREEN_X-x1): x1 = SCREEN_X-1
    if y1 < 0 then x1 = x1-(dx/dy)*y1: y1 = 0
    if y1 >= SCREEN_Y then x1 = x1+(dx/dy)*(SCREEN_Y-y1): y1 = SCREEN_Y-1
    
    dx = x1-x0
	dy = y1-y0
    
    if dx = 0 then dx = 0.0001
    if dy = 0 then dy = 0.0001
    
    vm = sqr(dx*dx+dy*dy)
	vx = dx / vm
	vy = dy / vm
    
    sx = x0+0.5: sy = y0+0.5
    dim pixelStop as integer ptr
    dim pixelNow as integer ptr
    pixelStop = pixels+SCREEN_Y*pitch
	dim i as integer
	dim x as integer, y as integer
	for i = 0 to vm
		x = int(sx)
		y = int(sy)
        '*(pixels+x+y*pitch) = colr
        pixelNow = pixels+x+y*pitch
        if pixelNow >= pixels and pixelNow < pixelStop then
            *(pixels+x+y*pitch) = colr
        end if
		sx += vx: sy += vy
	next i

end sub

sub rayTeleport(byref x_dx as integer, byref x_dy as integer, byref y_dx as integer, byref y_dy as integer)

end sub

function fractalSomething(x as double, i as integer = 0) as double

    if i > 10 then return x
    
    return fractalSomething(x+log(x), i+1)

end function

function fractalSomething2(x as double, i as integer = 0) as double

    if i > 10 then return x
    
    return fractalSomething2(x+cos(x)*sin(x), i+1)

end function

sub fractalDrill(startX as double, startY as double, startZ as integer = 0, u as Vector = Vector(0, 0, 0), size as integer = 0, l as double = 0, i as integer=0)

    dim j as integer
    dim x as double
    dim y as double
    dim z as double
    dim xx as integer
    dim yy as integer
    dim m as double
    dim v as Vector
    
    if i > 900 then return
    
    if size = 0 then
        size = 3-rnd(1)*6
    else
        size += 1-rnd(1)*2
    end if
    if startZ = 0 then
        startZ = 1000-rnd(1)*2000
    end if
    
    if size < 20 then size = 20
    
    '// don't drill in reverse direction as last vector
    do
        v.x = 4'rndint(0,2)+3
        v.y = 0
        v.z = 0 'rndint(0,10)+5
        v = vectorRotateZ(v, rndint(0,3)*90)
    loop while vectorDot(vectorUnit(u), vectorUnit(v)) < 0
    
    v.z = 10-rndint(0,20)
    
    m = vectorSize(v)
    v = vectorUnit(v)
    
    x = startX
    y = startY
    z = startZ
    
    dim yborder0 as integer
    dim yborder1 as integer
    dim xborder0 as integer
    dim xborder1 as integer
    dim height as double
    dim cell as FlatMapCell ptr
    
    height = rnd(1)*3+1
    'if l < -64 then l = -64
    for j = 0 to m
        yborder0 = iif(size > 50, y-size*0.01, y)
        yborder1 = iif(size > 50, y+size*0.01, y)
        xborder0 = iif(size > 50, x-size*0.01, x)
        xborder1 = iif(size > 50, x+size*0.01, x)
        for yy = yborder0 to yborder1 step 1
            for xx = xborder0 to xborder1
                l = (75-xx)*(75-xx)*0.0005
                if not (xx > 75) then
                    cell = highres.getCell(xx, yy)
                    if cell = 0 then continue for
                    if ((cell->getFloorHeight() = 0) and (cell->getCeilHeight() = 0))_
                    or (abs(cell->getFloorHeight()-int(z-size)) < 2) then
                        cell->setFloorHeight( int(z-size) )
                        cell->setCeilHeight( int(z+size*height) )
                        'highres.setColor(xx, yy, rgbMix(highres.colors(xx, yy), colorSky, 1.0, 0.2))
                        'highres.setCeilColor(xx, yy, rgbMix(highres.colors(xx, yy), colorSky, 1.0, 0.2))
                        'if (xx = xborder0) or (xx = xborder1) or (yy = yborder0) or (yy = yborder1) then
                        '    if xx = xborder0 then
                        '        highres.setColor(xx-1, yy, rgbMix(highres.colors(xx-1, yy), &h000000, 1.0, l))
                        '        highres.setCeilColor(xx-1, yy, rgbMix(highres.colors(xx-1, yy), &h000000, 1.0, l))
                        '    end if
                        '    if xx = xborder1 then
                        '        highres.setColor(xx+1, yy, rgbMix(highres.colors(xx+1, yy), &h000000, 1.0, l))
                        '        highres.setCeilColor(xx+1, yy, rgbMix(highres.colors(xx+1, yy), &h000000, 1.0, l))
                        '    end if
                        '    if yy = yborder0 then
                        '        highres.setColor(xx, yy-1, rgbMix(highres.colors(xx, yy-1), &h000000, 1.0, l))
                        '        highres.setCeilColor(xx, yy-1, rgbMix(highres.colors(xx, yy-1), &h000000, 1.0, l))
                        '    end if
                        '    if yy = yborder1 then
                        '        highres.setColor(xx, yy+1, rgbMix(highres.colors(xx, yy+1), &h000000, 1.0, l))
                        '        highres.setCeilColor(xx, yy+1, rgbMix(highres.colors(xx, yy+1), &h000000, 1.0, l))
                        '    end if
                        'else
                        '    highres.setColor(xx, yy, rgbMix(highres.colors(xx, yy), &h000000, 1.0, l))
                        '    highres.setCeilColor(xx, yy, rgbMix(highres.colors(xx, yy), &h000000, 1.0, l))
                        'end if
                    else
                        'highres.setHeight(xx, yy, highres.heights(xx, yy))
                    end if
                end if
            next xx
        next yy
		x += v.x
        y += v.y
        z += v.z
    next j
    
    x -= v.x
    y -= v.y
    
    if x > 75 and v.x > 0 then
        x = 75
        v.x = -v.x
    end if
    
    if rndint(0, 4) = 0 and x < 65 then
        size = iif(rndint(0,1)=0, 1, 2)
        for yy = y-size to y+size
            for xx = x-size to x+size
                cell = highres.getCell(xx, yy)
                if cell <> 0 then
                    cell->setFloorHeight( highres.getCell(x, y)->getFloorHeight() )
                    cell->setCeilHeight( highres.getCell(x, y)->getCeilHeight() )
                    cell->setFloorTile( highres.getCell(x, y)->getFloorTile() )
                    cell->setCeilHeight( highres.getCell(x, y)->getCeilHeight() )
                end if
            next xx
        next yy
        if rndint(0, 5) <> 0 then
            fractalDrill(x, y, z, v, size, l-3, i+1)
        else
            return
        end if
    else
        fractalDrill(x, y, z, v, size, l-3, i+1)
    end if
    if rndint(0, 346) = 0 then
        fractalDrill(x, y, z, vectorRotateZ(v,  90), size, l, i*4+1)
    end if
    if rndint(0, 346) = 0 then
        fractalDrill(x, y, z, vectorRotateZ(v, -90), size, l, i*4+1)
    end if

end sub

function fractalSomething3(v as Vector, i as integer=0) as double

    if i > 10 then return v.x/v.y
    
    return fractalSomething3(v+v*log(v.x*v.y*10), i+1)

end function

sub loadMap(highres as FlatMap, medres as FlatMap, lowres as FlatMap)
    
    dim x as integer, y as integer
    dim v as Vector
    dim cell as FlatMapCell ptr
    
    dim objects(16, 1) as string
    dim i as integer
    for i = 0 to 15
        read objects(i, 0)
    next i
    for i = 0 to 15
        read objects(i, 1)
    next i
    
    print "Generating world...";
    
    'dim r as Vector
    dim r as integer
    dim h as double = 600
    dim rv as Vector = vectorFromAngle(rnd(1)*360)
    v = vectorFromAngle(rnd(1)*360)
    
    dim r0 as double
    dim r1 as double
    dim r2 as double
    dim r3 as double
    r0 = rnd(1)*360
    r1 = rnd(1)*360
    r2 = rnd(1)*360
    r3 = rnd(1)*360
    
    for y = 0 to highres.getHeight()-1
        for x = 0 to highres.getWidth()-1
            cell = highres.getCell(x, y)
            if x > 75 then
                cell->setCeilHeight( 5000-(abs(sin(x*TO_RAD)-cos(y*TO_RAD))*500) )
                r = int(fractalSomething(x*x+y)*1) and 15'((x xor y) and 7)
                cell->setCeilTile( addTileColor(rgb(&hee+r, &hee+r, &hee+r)) )
                if cell->getCeilHeight() > 4700 then
                    cell->setCeilTile( addTileColor(&hff00ff))
                else
                    cell->setCeilHeight( cell->getCeilHeight()-50 )
                    cell->setFlag( CellFlags.clouds )
                end if
                
                cell->setFloorHeight(_
                  ((abs(sin(x*3*TO_RAD)*cos(y*3*TO_RAD))+sin(x*3*TO_RAD))*-h _
                - (abs(sin(y*TO_RAD)))*-h _
                + (abs(cos(y/10*TO_RAD)))*-h) _
                )
                
                'highres.setHeight(x, y, _
                '    cos((x*(360/highres.w)+r0)*TO_RAD)*-h _
                '  + sin((y*(360/highres.h)+r1)*TO_RAD)*-h _
                '  - sin((x*(360/highres.w)+r2)*TO_RAD)*-h _
                '  + cos((y*(360/highres.h)+r3)*TO_RAD)*-h _
                '  + fractalSomething3(Vector(x,y)) _ '*-h _
                ')
                
                if cell->getFloorHeight() < -int(h*0.95) then
                    cell->setFloorHeight( -int(h*0.95) )
                    'highres.setColor(x, y, rgb(&h8d+r, &hb2+r, &h7c+r))
                    'highres.setColor(x, y, &h5c73ab)
                    r = int(16*rnd(1))-32
                    cell->setFloorTile( addTileColor(rgbAdd(colorWater, r)) )
                    cell->setFlag( CellFlags.water )
                else
                    r = int(16*rnd(1))-32
                    cell->setFloorTile( addTileColor(rgbAdd(colorFloor, r)) )
                end if
            
            else
                cell->setCeilHeight( 0 )
                cell->setFloorHeight( 0 )
                r = int(16*rnd(1))-32
                cell->setCeilTile( addTileColor( rgbMix(rgbAdd(colorWall, r), &h000000, 1.0, (75-x)*(75-x)*0.01)) )
                cell->setFloorTile( addTileColor( rgbMix(rgbAdd(colorWall, r), &h000000, 1.0, (75-x)*(75-x)*0.01)) )
            end if
        next x
        if (y and 511) = 0 then print ".";
    next y
    
    dim c as string
    'dim h as integer
    dim low_h as integer
    dim obj_id as integer
    dim colr as integer
    dim g as integer, b as integer
    dim chance as double
    
    print ".";
    
    '// mountains
    dim dx as integer
    dim dy as integer
    if 0 then
    dx = 75+int((highres.getWidth()-75)*rnd(1))
    dy = int(highres.getHeight()*rnd(1))
    for y = dy-500 to dy+500
    for x = dx-500 to dx+500
        cell = highres.getCell(x, y)
        if cell <> 0 then
            'cell->setFloorHeight(_
            '  ((sin((int(y) * int(x))*0.01*TO_RAD))*600_
            '))
            cell->setFloorHeight( cell->getFloorHeight()+((sin((int(y) * int(x))*0.01*TO_RAD))*600 ) )
            r = int(16*rnd(1))-32
            cell->setFloorTile( addTileColor(rgbAdd(colorFloor, r)) )
            cell->clearFlags()
            'if highres.heights(x, y) < -100 then
            '    highres.setHeight(x, y, -100)
            '    'highres.setColor(x, y, rgb(&h8e-50, &h92-20, &hbf-20))
            '    r = int(16*rnd(1))-32
            '    highres.setColor(x, y, rgb(&h8d+r, &hb2+r, &h7c+r))
            '    highres.setData(x, y, 0, 777)
            'else
            '    r = int(16*rnd(1))-32
            '    cell->setFloorTile( addTileColor(rgb(&hd2+r, &hd2+r, &hd2+r)) )
            '    cell->clearFlags()
            'end if
        end if
    next x
    next y
    
    print ".";
    
    end if
    
    '// desert
    'dx = int(highres.w*rnd(1))
    'dy = int(highres.h*rnd(1))
    'for y = dy-300 to dy+300
    'for x = dx-300 to dx+300
    '    if highres.heights(x, y) > 0 then
    '        highres.setWall(x, y, 0)
    '        highres.setHeight(x, y, _
    '          ((sin((int(y) and int(x))*3*TO_RAD))*1000_
    '        ))
    '        if highres.heights(x, y) < -25 then
    '            highres.setHeight(x, y, -25)
    '            r  = (1-sin(y*30))*10
    '            r += (1-cos(x*30))*10
    '            r = 0
    '            r = int(16*rnd(1))-32
    '            highres.setColor(x, y, rgb(&hdd+r, &hb2+r, &h5c+r))
    '            highres.setData(x, y, 0, 777)
    '        else
    '            r = int(16*rnd(1))-32
    '            r += int(x*y) and 7
    '            highres.setColor(x, y, rgb(&hdd+r, &hb2+r, &h5c+r))
    '            highres.setData(x, y, 0, 0)
    '        end if
    '    end if
    'next x
    'next y
    
    print ".";
    
    '// snow caps
    dx = int(highres.getWidth()*rnd(1))
    dy = int(highres.getHeight()*rnd(1))
    for y = dy-200 to dy+200
    for x = dx-200 to dx+200
        cell = highres.getCell(x, y)
        if cell <> 0 then
            if cell->getFloorHeight() > 2500 then
                colr = tileColors(cell->getFloorTile())
                r = (colr shr 16) and &hff: g = (colr shr 8) and &hff: b = (colr and &hff)
                r += cell->getFloorHeight()*0.001+128
                g += cell->getFloorHeight()*0.001+128
                b += cell->getFloorHeight()*0.001+128
                if r > 255 then r = 255
                if g > 255 then g = 255
                if b > 255 then b = 255
                chance = -int(16*rnd(1))
                cell->setFloorTile( addTileColor(rgb(r+chance, g+chance, b+chance)) )
                cell->clearFlags()
            end if
        end if
    next x
    next y
    
    print ".";
    
    '// swamp
    dx = int((highres.getWidth()-400)*rnd(1))+200
    dy = int((highres.getHeight()-400)*rnd(1))+200
    for y = dy-200 to dy+200
        for x = dx-200 to dx+200
            cell = highres.getCell(x, y)
            cell->setFloorHeight( cell->getFloorHeight()/5 )
            r = int(16*rnd(1))-32
            cell->setFloorTile( addTileColor(rgb(&h7d+r, &h92+r, &h6c+r)) )
            cell->clearFlags()
        next x
    next y
    for y = dy-180 to dy+180
        for x = dx-180 to dx+180
            if int(32*rnd(1)) = 1 then
                cell = highres.getCell(x, y)
                cell->setFloorHeight( cell->getFloorHeight()+60+int(rnd(1)*1) )
                cell->setFloorTile( addTileColor(rgb(&h9d+r, &h92+r, &h5c+r)) )
                cell->clearFlags()
            end if
        next x
    next y
    
    print ".";
    
    for i = 0 to 30
        y = MAP_HEIGHT*rnd(1)
        fractalDrill(75, y, highres.getCell(76, y)->getFloorHeight()+100*rnd(1), Vector(-10, 0, 0), 30)
    next i
    
    dim dist as double
    dim lightColor as integer
    for i = 0 to 150
        dx = rndint(5, 55)
        dy = rndint(5, MAP_HEIGHT-5)
        lightColor = rndint(1, 10)
        if lightColor < 5 then
            lightColor = &hffff99
        elseif lightColor < 9 then
            lightColor = &hcc3333
        elseif lightColor = 9 then
            lightColor = &h55ff55
        else
            lightColor = &h5577ff
        end if
        for y = dy-3 to dy+3
            for x = dx-3 to dx+3
                cell = highres.getCell(x, y)
                dist = sqr((x-dx)*(x-dx)+(y-dy)*(y-dy)) 'iif(abs(x-dx) > abs(y-dy), abs(x-dx), abs(y-dy))+1
                if dist <= 3 then
                    dist *= 3
                    if dist < 0.8 then dist = 0.8
                    cell->setFloorTile( addTileColor( rgbMix(tileColors(cell->getFloorTile()), lightColor, dist, 1.0)) )
                    cell->setCeilTile( addTileColor( rgbMix(tileColors(cell->getFloorTile()), lightColor, dist, 1.0)) )
                end if
            next x
        next y
    next i
    
    print ".";
    
    restore objects
    for i = 0 to 0
        obj_id = 1'int(2*rnd(1))
        x = int(highres.getWidth()*rnd(1))
        y = int(highres.getHeight()*rnd(1))
        low_h = 9999
        for dy = 0 to 15
            for dx = 0 to 15
                if dx = 0 or dy = 0 or dx = 15 or dy = 15 then
                    h = highres.getCell(x+dx, y+dy)->getFloorHeight()
                    if h < low_h then
                        low_h = h
                    end if
                end if
            next dx
        next dy
        for dy = 0 to 15
            for dx = 0 to 15
                cell = highres.getCell(x+dx, y+dy)
                c = mid(objects(dy, obj_id), dx+1, 1)
                if c = "#" then
                    h = 2
                    r = -20
                elseif c = " " then
                    h = 0
                elseif c = "0" then
                    h = -1
                elseif c >= "a" and c <= "z" then
                    h = (asc(c)-97+10)*0.2
                    r = h*12+20
                else
                    h = val(c)
                    r = h*12+20
                end if
                h *= iif(obj_id = 0, 40, 150)
                cell->setFloorHeight( low_h+h )
                dim nothing as integer = int(16*rnd(1))-32
                if h = -40 then
                    cell->setFloorTile( addTileColor(rgb(&h6e, &h72, &h9f)) )
                elseif h <> 0 then
                    cell->setFloorTile( addTileColor(rgb(&hff+r, &he4+r, &hd8+r)) )
                else
                    if (y+dy) and 1 then
                        r = iif((x+dx) and 1, &hbe, &h22)
                    else
                        r = iif((x+dx) and 1, &h22, &hbe)
                    end if
                    cell->setFloorTile( addTileColor(rgb(&h00+r, &h00+r, &h00+r)) )
                end if
            next dx
        next dy
    next i
    
    print ".";
    
    dim rx as integer
    dim ry as integer
    rx = int(rnd(1)*500)+400
    ry = int(rnd(1)*500)+400
    highres.getCell(rx, ry)->setFloorHeight(3000)
    rx = int(rnd(1)*500)+400
    ry = int(rnd(1)*500)+400
    highres.getCell(rx, ry)->setFloorHeight(2000)
    rx = int(rnd(1)*500)+400
    ry = int(rnd(1)*500)+400
    highres.getCell(rx, ry)->setFloorHeight(1000)
    for y = -50 to 50
        for x = -50 to 50
            highres.getCell(rx+x, ry+y)->setFloorHeight(1500)
        next x
    next y
    
    '// glow boxes
    'dim rx as integer, ry as integer
    'for i = 0 to 0
    '    rx = int(highres.w*rnd(1))
    '    ry = int(highres.h*rnd(1))
    '    low_h = 9999
    '    for y = ry-10 to ry+10
    '        for x = rx-10 to rx+10
    '            if highres.heights(x, y) < low_h then
    '                low_h = highres.heights(x, y)
    '            end if
    '        next x
    '    next y
    '    for y = ry-10 to ry+10
    '        for x = rx-10 to rx+10
    '            dist = iif(abs(x-rx) > abs(y-ry), abs(x-rx), abs(y-ry))+1
    '            dist = 1000/(dist*dist)
    '            colr = highres.colors(x, y)
    '            r = red(colr): g = grn(colr): b = blu(colr)
    '            r = iif(r+dist > 255, 255, r+dist)
    '            g = iif(g+dist > 255, 255, g+dist)
    '            b = iif(b+dist > 255, 255, b+dist)
    '            highres.setColor(x, y, rgb(r, g, b))
    '            'highres.setHeight(x, y, low_h)
    '        next x
    '    next y
    '    highres.setHeight(rx, ry, highres.heights(rx, ry)+25000)
    'next i
    '
    'print ".";
    '
    '// portals
    'dim dat as integer
    'dim xFrom as integer, yFrom as integer
    'dim xTo as integer, yTo as integer
    'for i = 0 to 9
    '    do
    '        xFrom = int(highres.w*rnd(1)): yFrom = int(highres.h*rnd(1))
    '        xTo = int(highres.w*rnd(1)): yTo = int(highres.h*rnd(1))
    '    loop while (xFrom = xTo) and (yFrom = yTo)
    '    highres.setData(x, y, 0, (xFrom shl 16) or yFrom)
    '    highres.setData(x, y, 1, (xTo shl 16) or yTo)
    '    highres.setCallback(x, y, @rayTeleport)
    'next i
    '
    'print ".";
    '
    '// normals
    dim vNorth as Vector = vectorUnit(Vector(1, -1, 1))
    dim vNormal as Vector
    dim w as Vector
    dim u as Vector
    dim hh as double
    for y = 0 to highres.getHeight()-1
        for x = 0 to highres.getWidth()-1
            cell = highres.getCell(x, y)
            if (x > 150) and (x < highres.getWidth()-150) and (y > 150) and (y < highres.getHeight()-150) then
                u.x = x: u.y = y: u.z = cell->getFloorHeight()
                v.x = -10: v.y = y-10: v.z = highres.getCell(x+10, y+10)->getFloorHeight()
                w = vectorUnit(vectorCross(vectorUnit(u), vectorUnit(v)))
                vNormal = w
                cell->setNormal( int(vectorDot(vNormal, vNorth)*40) )
            end if
        next x
    next y
    
    '// generate low-res maps
    for y = 0 to medres.getHeight()-1
        for x = 0 to medres.getWidth()-1
            cell = medres.getCell(x, y)
            *cell = highres.getCellAvg(x*2, y*2, 2)
        next x
    next y
    print ".";
    for y = 0 to lowres.getHeight()-1
        for x = 0 to lowres.getWidth()-1
            cell = lowres.getCell(x, y)
            *cell = highres.getCellAvg(x*4, y*4, 4)
        next x
    next y
    print ".";
    for y = 0 to subres.getHeight()-1
        for x = 0 to subres.getWidth()-1
            cell = subres.getCell(x, y)
            *cell = highres.getCellAvg(x*8, y*8, 8)
        next x
    next y
    print "ready!"
end sub
objects:
data "eeeeeeeeeeeeeeee"
data "eaaaaaaaaaaaaaae"
data "eaeeeeeeeeeeeeae"
data "eaeeeeeeeeeeeeae"
data "eaee##eeee##eeae"
data "eaee##eeee##eeae"
data "eaeeeeeeeeeeeeae"
data "eaeeeeeeeeeeeeae"
data "eaeeeeeeeeeeeeae"
data "eae####ee####eae"
data "eae####ee####eae"
data "eae##########eae"
data "eae##########eae"
data "eaeeeeeeeeeeeeae"
data "eaaaaaaaaaaaaaae"
data "eeeeeeeeeeeeeeee"

data "2222222222222222"
data "2444444444444442"
data "2466666666666642"
data "2468888888888642"
data "2468aaaaaaaa8642"
data "2468acccccca8642"
data "2468aceeeeca8642"
data "2468aceeeeca8642"
data "2468aceeeeca8642"
data "2468aceeeeca8642"
data "2468acccccca8642"
data "2468aaaaaaaa8642"
data "2468888888888642"
data "2466666666666642"
data "2444444444444442"
data "2222222222222222"
horse:
data "................"
data "................"
data "................"
data "............#..."
data "..........####.."
data "........########"
data "....#######....."
data "############...."
data "...##########..."
data "...##......##..."
data "..##.....##....."
data "..#....##......."
data "................"
data "................"
data "................"
data "................"

'//====================
data "................"
data "................"
data "................"
data "............#..."
data "..........####.."
data "........########"
data "....#######....."
data "############...."
data "...##########..."
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"

runes:
data ".###...###..##.##"
data ".#..#...#...#####"
data ".#..#...#...#.#.#"
data ".#..#...#...#...#"
data ".###...###..#...#"

data ".###..#...#.#####"
data "..#...##..#...#.."
data "..#...#.#.#...#.."
data "..#...#..##...#.."
data ".###..#...#...#.."

data ".#...#...##.####.."
data ".#...#..#.#.#..##."
data ".#...#.#..#.####.."
data "..#.#.#####.#..##."
data "...#..#...#.#...##"

data ".#####......####.."
data ".##....###..#..##."
data ".####.#...#.####.."
data ".##...#...#.#..##."
data ".##....###..#...##"

data ".##.##.......###.."
data ".#####..###..#..#."
data ".#.#.#.#...#.#..#."
data ".#...#.#...#.#..#."
data ".#...#..###..###.."

data "...##.#...#..###.."
data "..#.#.##..#..#..#."
data ".#..#.#.#.#..#..#."
data "#####.#..##..#..#."
data "#...#.#...#..###.."

data "#...#........#####"
data "##..#...###....#.."
data "#.#.#..#...#...#.."
data "#..##..#...#...#.."
data "#...#...###....#.."

data ".#....####..#...#."
data ".#....#.....##..#."
data ".#....###...#.#.#."
data ".#....#.....#..##."
data ".####.####..#...#."

data "..###..####..####."
data ".#.....#..#.##...."
data ".####..####.##...."
data "....#..#....##...."
data ".###...#.....####."

'data ".####.......###."
'data ".#....####.#...."
'data ".#....#..#.###.."
'data ".#....#..#....#."
'data ".####.####.####."

'data ".#..#.###.#...#."
'data ".#..#.#....#.#.."
'data ".####.###...#..."
'data ".#..#.#....#.#.."
'data ".#..#.###.#...#."

'data "................"
'data ".####.#..#.###.."
'data ".#..#.#..#..#..."
'data ".#..#.#..#..#..."
'data ".####.####..#..."

'data "..###......###.."
'data ".#....#..#.#..#."
'data ".###..#..#.###.."
'data "....#.#..#.#..#."
'data ".####.####.###.."

'data "................"
'data "##.##.####.###.."
'data "#.#.#.#..#.#..#."
'data "#...#.#..#.#..#."
'data "#...#.####.###.."

empty:
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"
data "................"

something:
data "................"
data "................"
data "................"
data "#######........."
data "#..####........."
data "#..####.#......."
data "#######.###....."
data "#######.#####..."
data "....###.#######."
data "....###.....####"
data ".######.####.###"
data ".......####.#.##"
data "..##..###.#.####"
data "....###...#####."
data ".....#......####"
data ".........######."

zombie:
data "......###......."
data "......###......."
data "......###......."
data ".......#........"
data "...########....."
data "...#..##..#....."
data "...#..##..#....."
data "....#..##..#...."
data "....#..##..#...."
data "......####......"
data ".....#...#......"
data ".....#...#......"
data "....##..##......"
data ".....#..#......."
data ".....#..#......."
data "....##..##......"

sub gfx_dice(sprites() as SDL_RECT, filename as string, img_w as integer, img_h as integer, sp_w as integer, sp_h as integer, scale_x as double=1.0, scale_y as double=0)

	if scale_y = 0 then
		scale_y = scale_x
	end if
	
	dim gfxSource as SDL_Surface ptr = SDL_LoadBMP(filename)
	
	SDL_SetColorKey( gfxSource, SDL_TRUE, SDL_MapRGB(gfxSource->format, 255, 0, 255) )
	gfxSprites = SDL_CreateTextureFromSurface( gfxRenderer, gfxSource )
	
	dim row_w as integer, row_h as integer
	row_w = int(img_w / sp_w)
	row_h = int(img_h / sp_h)
	
	dim i as integer
	for i = 0 to row_w*row_h-1
		sprites(i).x = (i mod row_w)*sp_w
		sprites(i).y = int(i/row_w)*sp_h
		sprites(i).w = sp_w
		sprites(i).h = sp_h
	next i

end sub

