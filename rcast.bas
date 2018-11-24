#include once "SDL2/SDL.bi"

#define FULLSCREEN 1
#define SCREEN_X   533
#define SCREEN_Y   300
#define HALF_X     SCREEN_X \ 2
#define HALF_Y     SCREEN_Y \ 2
#define TO_RAD     0.0174532925
#define SUPERBIG   &h7fffffff
#define SUPERSML   0.00000001

#define MAP_WIDTH    1024
#define MAP_HEIGHT   1024
#define MAX_DISTANCE 300

type Vector
    x as double
    y as double
end type

type Caster
    intersection as Vector
    ray_initial  as Vector
    ray_continue as Vector    
    ray_offset   as Vector
end type

type FlatMap
private:
    _w as integer
    _h as integer
    redim   _walls(0, 0) as byte
    redim _heights(0, 0) as short
    redim  _colors(0, 0) as integer
public:
    declare constructor(w as integer, h as integer)
    declare function walls(x as integer, y as integer) as byte
    declare function heights(x as integer, y as integer) as short
    declare function colors(x as integer, y as integer) as integer
    declare property w() as integer
    declare property w(new_w as integer)
    declare property h() as integer
    declare property h(new_h as integer)
    declare function setWall(x as integer, y as integer, new_w as integer) as FlatMap ptr
    declare function setHeight(x as integer, y as integer, new_h as integer) as FlatMap ptr
    declare function setColor(x as integer, y as integer, new_c as integer) as FlatMap ptr
end type
constructor FlatMap(map_w as integer, map_h as integer)
    this._w = map_w
    this._h = map_h
    redim this._walls(map_w, map_h)
    redim this._heights(map_w, map_h)
    redim this._colors(map_w, map_h)
end constructor
function FlatMap.walls(x as integer, y as integer) as byte
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._walls(x, this._h-1-y)
    else
        return 0
    end if
end function
function FlatMap.heights(x as integer, y as integer) as short
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._heights(x, this._h-1-y)
    else
        return 0
    end if
end function
function FlatMap.colors(x as integer, y as integer) as integer
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._colors(x, this._h-1-y)
    else
        return 0
    end if
end function
property Flatmap.w() as integer
    return this._w
end property
property Flatmap.w(new_w as integer)
    this._w = new_w
end property
property Flatmap.h() as integer
    return this._h
end property
property Flatmap.h(new_h as integer)
    this._h = new_h
end property
function Flatmap.setWall(x as integer, y as integer, new_w as integer) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._walls(x, this._h-1-y) = new_w
    end if
    return @this
end function
function Flatmap.setHeight(x as integer, y as integer, new_h as integer) as FlatMap ptr
     if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._heights(x, this._h-1-y) = new_h
    end if
    return @this
end function
function Flatmap.setColor(x as integer, y as integer, new_c as integer) as FlatMap ptr
     if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._colors(x, this._h-1-y) = new_c
    end if
    return @this
end function

declare sub drawLine(x0 as integer, y0 as integer, x1 as integer, y1 as integer, c as integer, a as integer = 0)
declare function vectorFromAngle(a as double) as Vector
declare function vectorToRight(u as Vector) as Vector
declare function vectorDot(u as Vector, v as Vector) as double
declare function VectorToUnit(u as Vector) as Vector
declare sub main()
declare sub loadMap(map as FlatMap)

'// SHARED  ============================================================
dim shared map as FlatMap = FlatMap(MAP_WIDTH, MAP_HEIGHT)
'//=====================================================================

'// INIT SDL SYSTEM AND GRAPHICS  ======================================
dim shared gfxWindow as SDL_Window ptr
dim shared gfxRenderer as SDL_Renderer ptr
dim shared gfxSprites as SDL_Texture ptr

'SDL_Init( SDL_INIT_AUDIO or SDL_INIT_JOYSTICK or SDL_INIT_HAPTIC )
SDL_Init( SDL_INIT_VIDEO )

if FULLSCREEN then SDL_ShowCursor( 0 )

gfxWindow = SDL_CreateWindow( "Second World", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 0, 0, SDL_WINDOW_FULLSCREEN_DESKTOP )
gfxRenderer = SDL_CreateRenderer( gfxWindow, -1, SDL_RENDERER_PRESENTVSYNC )
SDL_RenderSetLogicalSize( gfxRenderer, SCREEN_X, SCREEN_Y )
SDL_SetRenderDrawBlendMode( gfxRenderer, SDL_BLENDMODE_BLEND )
'//=====================================================================

loadMap map
main

'// SHUTDOWN SDL  ======================================================
SDL_DestroyTexture( gfxSprites )
SDL_DestroyRenderer( gfxRenderer )
SDL_DestroyWindow( gfxWindow )
    
SDL_Quit
'//=====================================================================

end

sub main()

    dim px as double, py as double
    dim pa as double
    dim ph as double
    dim f as double
    dim a as double
    
    px = 63.5
    py = 63.5
    pa = 0
    ph = 1
    
    dim vf as Vector
    dim vr as Vector
    dim vray as Vector
    
    dim dx as double, dy as double
    dim ax as double, ay as double
    dim ex as integer, ey as integer
    dim x_dx as double, x_dy as double
    dim y_dx as double, y_dy as double
    dim x_ax as double, x_ay as double
    dim y_ax as double, y_ay as double
    dim x_ex as integer, x_ey as integer
    dim y_ex as integer, y_ey as integer
    dim x_di as double, y_di as double
    dim lx as integer, ly as integer
    dim xHit as integer, yHit as integer
    dim xDist as double, yDist as double
    dim dist as double
    dim dc as double
    
    dim event as SDL_Event
	dim keys as const ubyte ptr
    dim mousestate as long
    dim mx as long, my as long
    
    dim top as integer
    dim bottom as integer
    
    dim colorFloor as integer
    dim colorWall as integer
    dim colorSky as integer
    
    dim fov as double: fov = 1
    
    dim midline as double: midline = HALF_Y
    
    colorFloor = &h8db27c
    colorWall  = &hffe4d8
    colorSky   = &hbec2ff
    
    dim nph as double
    midline += (HALF_Y/2)
    do
        SDL_RenderPresent( gfxRenderer )
		
		while( SDL_PollEvent( @event ) )
			select case event.type
			case SDL_QUIT_
				return
			end select
		wend
		keys = SDL_GetKeyboardState(0)
        mousestate = SDL_GetRelativeMouseState(@mx, @my)
        
        pa -= mx*0.20
        midline -= my
        if midline < -HALF_Y then midline = -HALF_Y
        'if midline > HALF_Y*10 then midline = HALF_Y*10
        fov = 1+abs(midline-HALF_Y)*0.00125
        
        static dv as double
        
        if keys[SDL_SCANCODE_ESCAPE] then
            return
        end if
        if keys[SDL_SCANCODE_LEFT] then
            pa += 12
        end if
        if keys[SDL_SCANCODE_RIGHT] then
            pa -= 12
        end if
        if keys[SDL_SCANCODE_A] then
            vf = vectorFromAngle(pa)
            vf = vectorToRight(vf)
            px -= vf.x * 0.1 * iif(keys[SDL_SCANCODE_LCTRL], 2, 1)
            py -= vf.y * 0.1 * iif(keys[SDL_SCANCODE_LCTRL], 2, 1)
            'nph = (map.heights(int(px), int(py))*0.01)+1
            'if nph-ph > 0.5 then
            '    px += vf.x * 0.1
            '    py += vf.y * 0.1
            'elseif (dv = 0) and (nph-ph) < .1 then
            '    ph = nph
            'end if
        end if
        if keys[SDL_SCANCODE_D] then
            vf = vectorFromAngle(pa)
            vf = vectorToRight(vf)
            px += vf.x * 0.5 * iif(keys[SDL_SCANCODE_LCTRL], 2, 1)
            py += vf.y * 0.5 * iif(keys[SDL_SCANCODE_LCTRL], 2, 1)
            'nph = (map.heights(int(px), int(py))*0.01)+2
            'if nph-ph > 0.5 then
            '    px -= vf.x * 0.1
            '    py -= vf.y * 0.1
            'elseif (dv = 0) and (nph-ph) < 0.05 then
            '    ph = nph
            'end if
        end if
        if keys[SDL_SCANCODE_UP] or keys[SDL_SCANCODE_W] then
            vf = vectorFromAngle(pa)
            px += vf.x * 0.5 * iif(keys[SDL_SCANCODE_LCTRL], 2, 1)
            py += vf.y * 0.5 * iif(keys[SDL_SCANCODE_LCTRL], 2, 1)
            'nph = (hmap(int(px), MAP_HEIGHT-1-int(py))*0.01)+2
            'if nph-ph > 0.5 then
            '    px -= vf.x * 0.1
            '    py -= vf.y * 0.1
            'elseif (dv = 0) and (nph-ph) < 0.05 then
            '    ph = nph
            'end if
        end if
        if keys[SDL_SCANCODE_DOWN] or keys[SDL_SCANCODE_S] then
            vf = vectorFromAngle(pa)
            px -= vf.x * 0.5
            py -= vf.y * 0.5
            'nph = (hmap(int(px), MAP_HEIGHT-1-int(py))*0.01)+2
            'if nph-ph > 0.5 then
            '    px += vf.x * 0.1
            '    py += vf.y * 0.1
            'elseif (dv = 0) and (nph-ph) < 0.05 then
            '    ph = nph
            'end if
        end if
        if keys[SDL_SCANCODE_SPACE] and (dv = 0) then
            ph += 1
            'dv = -0.2
        end if
        if keys[SDL_SCANCODE_LSHIFT] then
            ph -= 1
        end if
        
        if pa >= 360 or pa < 0 then pa = pa mod 360
        
        '// RAYCAST BEGIN  =============================================
        
        vf    = vectorFromAngle(pa)
        vr    = vectorToRight(vf)
        vray.x = vf.x-vr.x*abs(fov)
        vray.y = vf.y-vr.y*abs(fov)
        vr.x /= HALF_X: vr.y /= HALF_X
        vr.x *= abs(fov)
        vr.y *= abs(fov)
        
        dim north as Vector
        north.x = 0: north.y = 1
        
        'ph -= dv
        'dv += 0.02
        '
        'nph = (hmap(int(px), MAP_HEIGHT-1-int(py))*0.01)+2
        '
        'if ph < nph then
        '    ph = nph
        '    dv = 0
        'end if
        
        dim distanceCount as integer
        dim colr as integer
        
        for f = 0 to SCREEN_X-1
        
            bottom = SCREEN_Y
            
            xHit = 0
            dx = iif(vray.x > 0, int(px+1)-px, int(px)-px)
            dy = vray.y*abs(dx/vray.x)
            ex = iif(vray.x >= 0, 0, -1)
            ey = 0
            dx += px
            dy += py
            if int(dy)+ey >= 0 and int(dy)+ey < map.h then
                if map.walls(int(dx)+ex, int(dy)+ey) then
                    xHit = 1
                end if
            else
                xHit = 1
            end if
            
            xDist = abs(vray.x/(dx-px))
            
            x_dx = dx: x_dy = dy
            
            yHit = 0
            dy = iif(vray.y > 0, int(py+1)-py, int(py)-py)
            dx = vray.x*abs(dy/vray.y)
            ex = 0
            ey = iif(vray.y >= 0, 0, -1)
            dy += py
            dx += px
            if int(dx)+ex >= 0 and int(dx)+ex < map.w then
                if map.walls(int(dx)+ex, int(dy)+ey) then
                    yHit = 1
                end if
            else
                yHit = 1
            end if
            
            yDist = abs(vray.y/(dy-py))
            
            y_dx = dx: y_dy = dy
            
            dx = iif(xDist > yDist, x_dx, y_dx)
            dy = iif(xDist > yDist, x_dy, y_dy)
            ex = iif(xDist > yDist, iif(vray.x >= 0, 0, -1), 0)
            ey = iif(yDist > xDist, iif(vray.y >= 0, 0, -1), 0)
            lx = int(dx)+ex: ly = int(dy)+ey
            lx = lx and 1023
            ly = ly and 1023
            
            dist = iif(xDist > yDist, xDist, yDist)
            dist *= 127
            dc = 0
            dim h as double
            'h = hmap(int(px), MAP_HEIGHT-1-int(py))*0.01
            h = map.heights(lx, ly)*0.01
            colr = map.colors(lx, ly)
            dc = iif(xDist > yDist, 10, -10)
            top = midline+int(dist*(ph-h))+1
            if top <= bottom then
                drawLine f, top, f, bottom, colr, dc
                bottom = top-1
            end if
            '// CONTINUE  ==============================================
            distanceCount = 1
            
            x_ax = iif(vray.x >= 0, 1, -1)
            x_ay = vray.y / abs(vray.x)
            x_ex = iif(vray.x >= 0, 0, -1)
            x_ey = 0
            x_di = 1
            
            y_ay = iif(vray.y >= 0, 1, -1)
            y_ax = vray.x / abs(vray.y)
            y_ey = iif(vray.y >= 0, 0, -1)
            y_ex = 0
            y_di = 1
            
            do until (xHit and (xDist > yDist)) or (yHit and (yDist > xDist))
                if xDist > yDist then '// if xDist is closer
                    x_dx  += x_ax: x_dy += x_ay
                    if int(x_dy)+x_ey >= 0 and int(x_dy)+x_ey < map.h then
                        if map.walls(int(x_dx)+x_ex, int(x_dy)+x_ey) then
                            xHit = 1
                        end if
                    else
                        xHit = 1
                    end if
                    xDist = abs(vray.x/(px-x_dx))
               else
                    y_dy  += y_ay: y_dx += y_ax
                    if int(y_dx)+y_ex >= 0 and int(y_dx)+y_ex < map.w then
                        if map.walls(int(y_dx)+y_ex, int(y_dy)+y_ey) then
                            yHit = 1
                        end if
                    else
                        yHit = 1
                    end if
                    yDist = abs(vray.y/(py-y_dy))
                end if
                
                
                'dc = iif(xDist > yDist, xDist, yDist)*-84
                dc = (abs(lx-int(px))+abs(ly-int(py)))*0.01
                dc = dc*dc
                'dc += vectorDot(vray, north)*16
                colr = map.colors(lx, ly)
                dx = iif(xDist > yDist, x_dx, y_dx)
                dy = iif(xDist > yDist, x_dy, y_dy)
                ex = iif(xDist > yDist, iif(vray.x >= 0, 0, -1), 0)
                ey = iif(yDist > xDist, iif(vray.y >= 0, 0, -1), 0)
                lx = int(dx)+ex: ly = int(dy)+ey
                lx = lx and 1023
                ly = ly and 1023
                
                
                dim wallR as integer, wallG as integer, wallB as integer
                dim skyR as integer, skyG as integer, skyB as integer
                wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                skyR  = (colorSky  shr 16) and 255: skyG  = (colorSky  shr 8) and 255: skyB  = (colorSky  and 255)
                
                dist = iif(xDist > yDist, xDist, yDist)
                dist *= 127
                colr = rgb((wallR+(skyR*dc))/(dc+1), (wallG+(skyG*dc))/(dc+1), (wallB+(skyB*dc))/(dc+1))
                top = midline+int(dist*(ph-h))+1
                if top <= bottom then
                    drawLine f, top, f, bottom, colr, 0
                    bottom = top-1
                end if
                h = map.heights(lx, ly)*0.01
                colr = map.colors(lx, ly)
                top = midline+int(dist*(ph-h))+1
                if top <= bottom then '- maybe draw this one first? (make sure no lines overlap)
                    dim ic as integer
                    ic += iif(xDist > yDist, 10, -10)
                    wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                    wallR += ic: wallG += ic: wallB += ic
                    if wallR > 255 then wallR = 255
                    if wallG > 255 then wallG = 255
                    if wallB > 255 then wallB = 255
                    colr = rgb((wallR+(skyR*dc))/(dc+1), (wallG+(skyG*dc))/(dc+1), (wallB+(skyB*dc))/(dc+1))
                    drawLine f, top, f, bottom, colr, 0
                    bottom = top-1
                end if
                
                distanceCount += 1
                if distanceCount > MAX_DISTANCE then
                    exit do
                end if
                
            loop
            
            if (xHit and (xDist > yDist)) or (yHit and (yDist > xDist)) then
                dc = iif(xDist > yDist, -16, 0)
                top = midline-int(dist*(h-ph))
                if top <= bottom then
                    drawLine f, top, f, bottom, colorWall, dc
                    bottom = top-1
                end if
            end if
            drawLine f, -1, f, bottom, colorSky
            
            vray.x += vr.x: vray.y += vr.y
            
        next f
        '// RAYCAST END  ===============================================
        
        SDL_RenderPresent gfxRenderer
    
    loop

end sub

sub drawLine(x0 as integer, y0 as integer, x1 as integer, y1 as integer, c as integer, a as integer = 0)

    dim r as integer, g as integer, b as integer
    
    r = (c shr 16) and &hff
    g = (c shr 8 ) and &hff
    b = (c and &hff)
    
    r += a: g += a: b += a
    
    if r < 0 then r = 0
    if b < 0 then b = 0
    if g < 0 then g = 0
    if r > 255 then r = 255
    if g > 255 then g = 255
    if b > 255 then b = 255

    SDL_SetRenderDrawColor gfxRenderer, r, g, b, &hff
    SDL_RenderDrawLine gfxRenderer, x0, y0, x1, y1

end sub

function vectorFromAngle(a as double) as Vector

    dim v as Vector
    v.x = cos(a*TO_RAD)
    v.y = sin(a*TO_RAD)
    
    return v

end function

function vectorToRight(u as Vector) as Vector

    dim v as Vector
    v.y = -u.x
    v.x =  u.y
    
    return v

end function

function VectorToUnit(u as Vector) as Vector
    dim v as Vector
    dim m as double
    m = sqr(u.x*u.x+v.y*v.y)
    if m <> 0 then
        v.x = u.x / m
        v.y = u.y / m
    else
        v.x = 0
		v.y = 0
    end if
    return v
end function

function vectorDot(u as Vector, v as Vector) as double
    return u.x*v.x+u.y*v.y
end function

sub loadMap(map as FlatMap)
    dim x as integer, y as integer
    dim v as Vector
    'dim r as Vector
    dim r as integer
    v = vectorFromAngle(rnd(1)*360)
    for y = 0 to map.h-1
        for x = 0 to map.w-1
            if (x = 0) or (y = 0) or (x = (map.w-1)) or (y = (map.h-1)) then
                map.setWall(x, y, 1)
                map.setHeight(x, y, 0)
                map.setColor(x, y, &hffe4d8)
            else
                map.setWall(x, y, 0)
                map.setHeight(x, y, (abs(sin(x*3*TO_RAD)*cos(y*3*TO_RAD))+sin(x*3*TO_RAD))*-3000)
                r = int(16*rnd(1))-32
                map.setColor(x, y, rgb(&h8d+r, &hb2+r, &h7c+r))
            end if
        next x
    next y
end sub
