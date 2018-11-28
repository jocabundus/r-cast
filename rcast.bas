#include once "SDL2/SDL.bi"

#define FULLSCREEN 1
#define SCREEN_X   352
#define SCREEN_Y   198
#define HALF_X     SCREEN_X \ 2
#define HALF_Y     SCREEN_Y \ 2
#define TO_RAD     0.0174532925
#define SUPERBIG   &h7fffffff
#define SUPERSML   0.00000001

#define MAP_WIDTH    1024
#define MAP_HEIGHT   1024
#define HEIGHT_RATIO 127*(SCREEN_Y/300)
#define MAX_DISTANCE 3000' 300

'// TIMER FUNCTIONS  ===================================================
declare function UpdateSpeed (save_time as integer=1) as double
declare function GetDelay () as double

dim shared TimerSeconds as double
dim shared TimerMaxDiff as double = 1.0
dim shared TimerLastTime as double

'- Calculate the global delay factor
function UpdateSpeed (save_time as integer=1) as double
	
	dim seconds as double
	
	seconds       = TIMER-TimerLastTime
	TimerLastTime = TIMER
	
	if seconds > TimerMaxDiff then
		seconds = TimerMaxDiff
	end if
	
	if save_time then
		TimerSeconds = seconds
	end if
	
	return seconds
	
end function

'- Return the delay factor
function GetDelay () as double

	return TimerSeconds
	
end function

function GetLastTime () as double

	return TimerLastTime

end function
'// END TIMER FUNCTIONS  ===============================================

'// GRAPHICS FUNCTIONS  ================================================
declare sub gfx_dice(sprites() as SDL_RECT, filename as string, img_w as integer, img_h as integer, sp_w as integer, sp_h as integer, scale_x as double=1.0, scale_y as double=0)
declare function SDL_CreateTargetTextureFromSurface( renderer as SDL_RENDERER ptr, surface as SDL_Surface ptr, pixel_format as integer = SDL_PIXELFORMAT_ARGB8888 ) as SDL_Texture ptr
declare function red(argb32 as integer) as integer
declare function grn(argb32 as integer) as integer
declare function blu(argb32 as integer) as integer
'// END GRAPHICS FUNCTIONS  ============================================

'// FONT HANDLER  ======================================================
#define GFONT_W 8
#define GFONT_H	8

type GFont
private:
    _sprites(1024) as SDL_RECT
    _sprites_w as integer = GFONT_W
    _sprites_h as integer = GFONT_H
    _sprite_offset as integer = 0
    _gfx_sprites as SDL_Texture ptr
    _gfx_renderer as SDL_Renderer ptr ptr
    _screen_w as integer = 0
public:
    declare constructor(renderer as SDL_Renderer ptr ptr)
    declare function load(filename as string, img_w as integer, img_h as integer, sp_w as integer, sp_h as integer, scale_x as double=1.0, scale_y as double=0) as GFont ptr
    declare function writeText(text as string, x as integer, y as integer) as GFont ptr
    declare function centerText(text as string, y as integer) as GFont ptr
    declare function setOffset(offset as integer) as GFont ptr
    declare sub release()
end type

constructor GFont(renderer as SDL_Renderer ptr ptr)
    this._gfx_renderer = renderer
end constructor

sub GFont.release()
    SDL_DestroyTexture( this._gfx_sprites )
end sub

function GFont.load(filename as string, img_w as integer, img_h as integer, sp_w as integer, sp_h as integer, scale_x as double=1.0, scale_y as double=0) as GFont ptr

    if scale_y = 0 then
	scale_y = scale_x
    end if
    
    dim gfxSource as SDL_Surface ptr = SDL_LoadBMP(filename)
    
    SDL_SetColorKey( gfxSource, SDL_TRUE, SDL_MapRGB(gfxSource->format, 255, 0, 255) )
    this._gfx_sprites = SDL_CreateTextureFromSurface( *this._gfx_renderer, gfxSource )
    
    dim row_w as integer, row_h as integer
    row_w = int(img_w / sp_w)
    row_h = int(img_h / sp_h)
    
    dim i as integer
    for i = 0 to row_w*row_h-1
        this._sprites(i).x = (i mod row_w)*sp_w
        this._sprites(i).y = int(i/row_w)*sp_h
        this._sprites(i).w = sp_w
        this._sprites(i).h = sp_h
    next i
    
    this._sprites_w = sp_w
    this._sprites_h = sp_h

    return @this

end function

function GFont.writeText(text as string, x as integer, y as integer) as GFont ptr
    
    dim n as integer
    dim v as integer
    
    dim dstRect as SDL_Rect
    dstRect.x = x: dstRect.y = y
    dstRect.w = this._sprites_w: dstRect.h = this._sprites_h
    
    for n = 1 to len(text)
        v = asc(mid$(text, n, 1))-32+this._sprite_offset
        SDL_RenderCopy( *this._gfx_renderer, this._gfx_sprites, @this._sprites(v), @dstRect)
        dstRect.x += this._sprites_w
    next n
    
    return @this
    
end function

function GFont.centerText(text as string, y as integer) as GFont ptr

    if this._screen_w = 0 then
        SDL_RenderGetLogicalSize(*this._gfx_renderer, @this._screen_w, null)
    end if
    
    return this.writeText(text, int((this._screen_w-len(text)*this._sprites_w)/2), y)
    
end function

function GFont.setOffset(offset as integer) as GFont ptr
	
    this._sprite_offset = offset
    
    return @this
	
end function
'// END FONT HANDLER  ==================================================

type Vector
    x as double
    y as double
    z as double
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
    dim   _walls(1024*1024) as byte
    dim _heights(1024*1024) as short
    dim  _colors(1024*1024) as integer
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
    declare function getWallAvg(x as integer, y as integer, size as integer) as integer
    declare function getHeightAvg(x as integer, y as integer, size as integer) as integer
    declare function getColorAvg(x as integer, y as integer, size as integer) as integer
end type
constructor FlatMap(map_w as integer, map_h as integer)
    this._w = map_w
    this._h = map_h
    'redim this._walls(map_w, map_h)
    'redim this._heights(map_w, map_h)
    'redim this._colors(map_w, map_h)
end constructor
function FlatMap.walls(x as integer, y as integer) as byte
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._walls(x+((this._h-1-y) shl 10))
    else
        return 0
    end if
end function
function FlatMap.heights(x as integer, y as integer) as short
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._heights(x+((this._h-1-y) shl 10))
    else
        return 0
    end if
end function
function FlatMap.colors(x as integer, y as integer) as integer
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._colors(x+((this._h-1-y) shl 10))
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
        this._walls(x+((this._h-1-y) shl 10)) = new_w
    end if
    return @this
end function
function Flatmap.setHeight(x as integer, y as integer, new_h as integer) as FlatMap ptr
     if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._heights(x+((this._h-1-y) shl 10)) = new_h
    end if
    return @this
end function
function Flatmap.setColor(x as integer, y as integer, new_c as integer) as FlatMap ptr
     if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._colors(x+((this._h-1-y) shl 10)) = new_c
    end if
    return @this
end function
function FlatMap.getWallAvg(x as integer, y as integer, size as integer) as integer
    dim mx as integer, my as integer
    dim sum as double
    for my = y to y+size-1
        for mx = x to x+size-1
            sum += this.walls(mx, my)
        next mx
    next my
    size *= size
    return sum / size
end function
function FlatMap.getHeightAvg(x as integer, y as integer, size as integer) as integer
    dim mx as integer, my as integer
    dim sum as double
    for my = y to y+size-1
        for mx = x to x+size-1
            sum += this.heights(mx, my)
        next mx
    next my
    size *= size
    return sum / size
end function
function FlatMap.getColorAvg(x as integer, y as integer, size as integer) as integer
    dim mx as integer, my as integer
    dim r as integer, g as integer, b as integer
    for my = y to y+size-1
        for mx = x to x+size-1
            r += ((this.colors(mx, my) shr 16) and &hff)
            g += ((this.colors(mx, my) shr  8) and &hff)
            b += (this.colors(mx, my) and &hff)
        next mx
    next my
    size *= size
    return rgb(r / size, g / size, b / size)
end function

declare sub drawLine(x0 as integer, y0 as integer, x1 as integer, y1 as integer, c as integer, a as integer = 0)
declare function vectorFromAngle(a as double) as Vector
declare function vectorToRight(u as Vector) as Vector
declare function vectorDot(u as Vector, v as Vector) as double
declare function VectorToUnit(u as Vector) as Vector
declare function vectorCross(u as Vector, v as Vector) as Vector
declare sub main()
declare sub loadMap(highres as FlatMap, medres as FlatMap, lowres as FlatMap)

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
SDL_Init( SDL_INIT_VIDEO )

if FULLSCREEN then SDL_ShowCursor( 0 )

gfxWindow = SDL_CreateWindow( "Ashes of Eternity", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_X, SCREEN_Y, SDL_WINDOW_FULLSCREEN_DESKTOP )
gfxRenderer = SDL_CreateRenderer( gfxWindow, -1, null )
SDL_RenderSetLogicalSize( gfxRenderer, SCREEN_X, SCREEN_Y )
SDL_SetRenderDrawBlendMode( gfxRenderer, SDL_BLENDMODE_NONE )

dim shared game_font as GFONT = GFONT(@gfxRenderer)
game_font.load("font.bmp", 256, 256, 8, 8, GFONT_W/8)

'//=====================================================================

loadMap highres, medres, lowres
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
    dim lx as integer, ly as integer
    dim xHit as integer, yHit as integer
    dim xDist as double, yDist as double
    dim dist as double
    dim dc as double
    dim sliceSize as double
    
    dim event as SDL_Event
	dim keys as const ubyte ptr
    dim mousestate as long
    dim mx as long, my as long
    
    dim fps as integer
    dim fps_count as integer
    dim fps_timer as double
    
    dim top as integer
    dim bottom as integer
    
    dim colorFloor as integer
    dim colorWall as integer
    dim colorSky as integer
    
    dim fov as double: fov = 1
    
    dim midline as double: midline = HALF_Y
    
    dim map as FlatMap ptr
    dim delta as double
    
    colorFloor = &h8db27c
    colorWall  = &hffe4d8
    colorSky   = &hbec2ff
    
    dim nph as double
    midline += (HALF_Y/2)
    
    dim walkingSpeed as double = 4.0
    dim flyingSpeed as double = 30
    'dim pitch as double
    dim mode as integer = 1
    
    UpdateSpeed()
    do
        delta = UpdateSpeed()
        
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
        
        pa -= mx*0.20
        
        dim ha as double
        ha = midline-HALF_Y
        
        midline -= my
        if midline < -HALF_Y then midline = -HALF_Y
        'if midline > HALF_Y*10 then midline = HALF_Y*10
        fov = 1+abs(midline-HALF_Y)*0.00125
        
        map = @highres
        
        ha = midline-HALF_Y
        
        static dv as double
        dim speed as double
        
        speed = iif(mode = 1, flyingSpeed, walkingSpeed)
        
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
            vf.x = vf.x * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
            vf.y = vf.y * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
            px -= vf.x
            py -= vf.y
            
            if mode = 2 then
                nph = map->heights(int(px), int(py))*0.01+1.5
                if nph-ph > 0.625 then
                    px += vf.x
                    py += vf.y
                'elseif (dv = 0) and ((nph-ph) < 0) and ((nph-ph) > -0.325) then
                '    ph = nph
                end if
            end if
        end if
        if keys[SDL_SCANCODE_D] then
        
            vf = vectorFromAngle(pa)
            vf = vectorToRight(vf)
            vf.x = vf.x * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
            vf.y = vf.y * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
            px += vf.x
            py += vf.y
            
            if mode = 2 then
                nph = map->heights(int(px), int(py))*0.01+1.5
                if nph-ph > 0.625 then
                    px -= vf.x
                    py -= vf.y
                'elseif (dv = 0) and ((nph-ph) < 0) and ((nph-ph) > -0.325) then
                '    ph = nph
                end if
            end if
        end if
        if keys[SDL_SCANCODE_UP] or keys[SDL_SCANCODE_W] then
            select case mode
            case 1
                vf   = vectorFromAngle(pa)
                vf.z = ha*0.3*.02625
                vf   = vectorToUnit(vf)
                
                px += vf.x * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
                py += vf.y * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
                ph += vf.z * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
            case 2
                vf   = vectorFromAngle(pa)
                vf   = vectorToUnit(vf)
                vf.x = vf.x * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
                vf.y = vf.y * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta 
                px += vf.x
                py += vf.y
                
                nph = map->heights(int(px), int(py))*0.01+1.5
                if nph-ph > 0.625 then
                    px -= vf.x
                    py -= vf.y
                'elseif (dv = 0) and ((nph-ph) < 0) and ((nph-ph) > -0.325) then
                '    ph = nph
                end if
            end select
        end if
        if keys[SDL_SCANCODE_DOWN] or keys[SDL_SCANCODE_S] then
            select case mode
            case 1
                vf = vectorFromAngle(pa)
                px -= vf.x * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
                py -= vf.y * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
            case 2
                vf   = vectorFromAngle(pa)
                vf   = vectorToUnit(vf)
                vf.x = vf.x * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta
                vf.y = vf.y * speed * iif(keys[SDL_SCANCODE_LCTRL], 1.75, 1) * delta 
                px -= vf.x
                py -= vf.y
                
                nph = map->heights(int(px), int(py))*0.01+1.5
                if nph-ph > 0.625 then
                    px -= vf.x
                    py -= vf.y
                'elseif (dv = 0) and ((nph-ph) < 0) and ((nph-ph) > -0.325) then
                '    ph = nph
                end if
            end select
        end if
        if keys[SDL_SCANCODE_SPACE] and (dv = 0) then
            if mode = 1 then
                ph += flyingSpeed * delta
            else
                'dv = -0.3333
                dv = -0.5
            end if
        end if
        if keys[SDL_SCANCODE_LSHIFT] then
            ph -= flyingSpeed * delta
        end if
        if keys[SDL_SCANCODE_1] then
            mode = 1
        end if
        if keys[SDL_SCANCODE_2] then
            mode = 2
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
        
        if mode = 2 then
            dv += delta
            ph -= dv
        
            nph = map->heights(int(px), int(py))*0.01+1.5
        
            if ph < nph then
               ph = nph
               dv = 0
            end if
        end if
        
        dim colr as integer
        dim resAdjust as double
        dim xDistMax as double, yDistMax as double
        dim distMax as double
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
        SDL_SetRenderDrawColor(gfxRenderer, r, g, b, &hff)
        SDL_RenderClear(gfxRenderer)
        
        for f = 0 to SCREEN_X-1
        
            map = @highres
        
            bottom = SCREEN_Y
            
            '// EDGE-OF-MAP INTERSECTION ===============================
            dx = iif(vray.x > 0, map->w-1-px, -px)
            xDistMax = abs(dx/vray.x)
            
            dy = iif(vray.y > 0, map->h-1-py, -py)
            yDistMax = abs(dy/vray.y)
            
            distMax = iif(xDistMax < yDistMax, xDistMax, yDistMax)
            if distMax > MAX_DISTANCE then distMax = MAX_DISTANCE
            
            
            '// CLOSEST INTERSECTION  ==================================
            xHit = 0
            dx = iif(vray.x > 0, int(px+1)-px, int(px)-px)
            dy = vray.y*abs(dx/vray.x)
            ex = iif(vray.x >= 0, 0, -1)
            ey = 0
            dx += px
            dy += py
            
            xDist = abs((dx-px)/vray.x)
            
            x_dx = dx: x_dy = dy
            
            yHit = 0
            dy = iif(vray.y > 0, int(py+1)-py, int(py)-py)
            dx = vray.x*abs(dy/vray.y)
            ex = 0
            ey = iif(vray.y >= 0, 0, -1)
            dy += py
            dx += px
            
            yDist = abs((dy-py)/vray.y)
            
            y_dx = dx: y_dy = dy
            
            if xDist < yDist then
                dx = x_dx: dy = x_dy
                ex = x_ex: ey = x_ey
                dist = xDist
            else
                dy = y_dy: dx = y_dx
                ey = y_ey: ex = y_ex
                dist = yDist
            end if
            lx = int(dx)+ex: ly = int(dy)+ey
            
            sliceSize = HEIGHT_RATIO / dist
            dim h as double
            h = map->heights(int(px), int(py))*0.01
            top = midline+int(sliceSize*(ph-h))+1
            if top <= bottom then
                colr = map->colors(int(px), int(py))
                drawLine f, top, f, bottom, colr, 0
                bottom = top-1
            end if
            h = map->heights(lx, ly)*0.01
            top = midline+int(sliceSize*(ph-h))+1
            if top <= bottom then
                colr = map->colors(lx, ly)
                dc = iif(xDist > yDist, 10, -10)
                drawLine f, top, f, bottom, colr, dc
                bottom = top-1
            end if
            '// INTERSECTIONS UNTIL EDGE-OF-MAP/MAX-DISTANCE  ==========
            dim x_di as double
            dim y_di as double
            
            x_ax = iif(vray.x >= 0, 1, -1)
            x_ay = vray.y / abs(vray.x)
            x_ex = iif(vray.x >= 0, 0, -1)
            x_ey = 0
            x_di = abs(1/vray.x)
            
            y_ay = iif(vray.y >= 0, 1, -1)
            y_ax = vray.x / abs(vray.y)
            y_ey = iif(vray.y >= 0, 0, -1)
            y_ex = 0
            y_di = abs(1/vray.y)
            
            
            dim wallR as integer, wallG as integer, wallB as integer
            dim skyR as integer, skyG as integer, skyB as integer
            dim ic as integer
            dim atmosphereFactor as double
            dim dc1 as double
            
            dim map_w as integer = map->w
            dim map_h as integer = map->h
            dim map_x as integer
            dim map_y as integer
            
            atmosphereFactor = 0.0033'/resAdjust
            
            dim resAdjust as double
            resAdjust = 1
            
            dim xAlign as integer, yAlign as integer
            dim switchedToMed as integer, switchedToLow as integer
            dim switchedToSub as integer
            
            switchedToMed = 0: switchedToLow = 0: switchedToSub = 0
            
            do while dist < distMax
                if (dist > 160) and (switchedToMed = 0) then
                    map = @medres
                    xAlign = 1: yAlign = 1
                    x_dx *= 0.5: x_dy *= 0.5
                    y_dx *= 0.5: y_dy *= 0.5
                    x_di *= 2.0: y_di *= 2.0
                    lx   *= 0.5: ly   *= 0.5
                    switchedToMed = 1
                end if
                if (dist > 320) and (switchedToLow = 0) then
                    map = @lowres
                    xAlign = 1: yAlign = 1
                    x_dx *= 0.5: x_dy *= 0.5
                    y_dx *= 0.5: y_dy *= 0.5
                    x_di *= 2.0: y_di *= 2.0
                    lx   *= 0.5: ly   *= 0.5
                    switchedToLow = 1
                end if
                if (dist > 480) and (switchedToSub = 0) then
                    map = @subres
                    xAlign = 1: yAlign = 1
                    x_dx *= 0.5: x_dy *= 0.5
                    y_dx *= 0.5: y_dy *= 0.5
                    x_di *= 2.0: y_di *= 2.0
                    lx   *= 0.5: ly   *= 0.5
                    switchedToSub = 1
                end if
                
                if xDist < yDist then
                    if xAlign then
                    
                        xAlign = 0
                        
                        if int(x_dx)-x_dx <> 0 then
                            x_dx  += x_ax*0.5: x_dy += x_ay*0.5
                            xDist += x_di*0.5
                        else
                            x_dx  += x_ax: x_dy += x_ay
                            xDist += x_di
                        end if
                    else
                        x_dx  += x_ax: x_dy += x_ay
                        xDist += x_di
                    end if
                else
                    if yAlign then
                        
                        yAlign = 0
                        
                        if int(y_dy)-y_dy <> 0 then
                            y_dy  += y_ay*0.5: y_dx += y_ax*0.5
                            yDist += y_di*0.5
                        else
                            y_dy  += y_ay: y_dx += y_ax
                            yDist += y_di
                        end if
                    else
                        y_dy  += y_ay: y_dx += y_ax
                        yDist += y_di
                    end if
                end if
                
                if xDist < yDist then
                    dx = x_dx: dy = x_dy
                    ex = x_ex: ey = x_ey
                    dist = xDist
                else
                    dy = y_dy: dx = y_dx
                    ey = y_ey: ex = y_ex
                    dist = yDist
                end if
                
                if dist > distMax then dist = distMax
                
                sliceSize = HEIGHT_RATIO / dist
                
                top = midline+int(sliceSize*(ph-h))+1
                dc = 0
                if top <= bottom then
                
                    colr = map->colors(lx, ly)
                
                    dc = dist*atmosphereFactor
                    dc = dc*dc*dc*dc*dc
                    dc1 = 1/(dc+1)
                    wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                    skyR  = (colorSky  shr 16) and 255: skyG  = (colorSky  shr 8) and 255: skyB  = (colorSky  and 255)
                    colr = rgb((wallR+(skyR*dc))*dc1, (wallG+(skyG*dc))*dc1, (wallB+(skyB*dc))*dc1)
                
                    drawLine f, top, f, bottom, colr, 0
                    bottom = top-1
                end if
                
                lx = int(dx)+ex: ly = int(dy)+ey
                h = map->heights(lx, ly)*0.01
                top = midline+int(sliceSize*(ph-h))+1
                if top <= bottom then
                    colr = map->colors(lx, ly)
                    if dc = 0 then
                        dc = dist*atmosphereFactor
                        dc = dc*dc*dc*dc*dc
                        dc1 = 1/(dc+1)
                    end if
                    ic = iif(xDist > yDist, 10, -10)
                    wallR = (colr shr 16) and 255: wallG = (colr shr 8) and 255: wallB = (colr and 255)
                    skyR  = (colorSky  shr 16) and 255: skyG  = (colorSky  shr 8) and 255: skyB  = (colorSky  and 255)
                    wallR += ic: wallG += ic: wallB += ic
                    if wallR > 255 then wallR = 255
                    if wallG > 255 then wallG = 255
                    if wallB > 255 then wallB = 255
                    if wallR < 0 then wallR = 0
                    if wallG < 0 then wallG = 0
                    if wallB < 0 then wallB = 0
                    colr = rgb((wallR+(skyR*dc))*dc1, (wallG+(skyG*dc))*dc1, (wallB+(skyB*dc))*dc1)
                    drawLine f, top, f, bottom, colr, 0
                    bottom = top-1
                end if
                
                if bottom < 0 then exit do
                
            loop
            
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
            
            vray.x += vr.x: vray.y += vr.y
            'if f = HALF_X then
            '    game_font.writeText( "MAX: "+str(int(dist)), 3, 12 )
            'end if
            
        next f
        '// RAYCAST END  ===============================================
        game_font.writeText( "FPS: "+str(fps), 3, 3 )
        game_font.writeText( "X: "+str(int(px)), 3, 15 )
        game_font.writeText( "Y: "+str(int(py)), 3, 27 )
        'game_font.writeText( "PITCH: "+str(ha), 3, 3 )
        'game_font.writeText( "MLINE: "+str(midline), 3, 15 )
        game_font.writeText( "+", HALF_X-4, HALF_Y-4 )
        
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
    v.z = 0
    
    return v

end function

function vectorToRight(u as Vector) as Vector

    dim v as Vector
    v.y = -u.x
    v.x =  u.y
    
    return v

end function

function vectorToUnit(u as Vector) as Vector
    dim v as Vector
    dim m as double
    m = sqr(u.x*u.x+u.y*u.y+u.z*u.z)
    if m <> 0 then
        v.x = u.x / m
        v.y = u.y / m
        v.z = u.z / m
    else
        v.x = 0
		v.y = 0
        v.z = 0
    end if
    return v
end function

function vectorDot(u as Vector, v as Vector) as double
    return u.x*v.x+u.y*v.y+u.z*v.z
end function

function vectorCross(u as Vector, v as Vector) as Vector
    dim w as Vector
    w.x = u.y*v.z - u.z*v.y
    w.y = u.z*v.x - u.x*v.z    
    w.z = u.x*v.y - u.y*v.x
    return w
end function

sub loadMap(highres as FlatMap, medres as FlatMap, lowres as FlatMap)
    randomize timer
    dim x as integer, y as integer
    dim v as Vector
    
    dim objects(16, 1) as string
    dim i as integer
    for i = 0 to 15
        read objects(i, 0)
    next i
    for i = 0 to 15
        read objects(i, 1)
    next i
    
    'dim r as Vector
    dim r as integer
    v = vectorFromAngle(rnd(1)*360)
    for y = 0 to highres.h-1
        for x = 0 to highres.w-1
            if (x = 0) or (y = 0) or (x = (highres.w-1)) or (y = (highres.h-1)) then
                highres.setWall(x, y, 1)
                highres.setHeight(x, y, 0)
                highres.setColor(x, y, &hffe4d8)
            else
                highres.setWall(x, y, 0)
                highres.setHeight(x, y, _
                  (abs(sin(x*3*TO_RAD)*cos(y*3*TO_RAD))+sin(x*3*TO_RAD))*-3000 _
                - (abs(sin(y*TO_RAD)))*-3000 _
                + (abs(cos(y/10*TO_RAD)))*-3000 _
                )
                if highres.heights(x, y) < -4000 then
                    highres.setHeight(x, y, -4000)
                    highres.setColor(x, y, rgb(&h8e-50, &h92-20, &hbf-20))
                else
                    r = int(16*rnd(1))-32
                    highres.setColor(x, y, rgb(&h8d+r, &hb2+r, &h7c+r))
                end if
            end if
        next x
    next y
    dim dx as integer
    dim dy as integer
    dim c as string
    dim h as integer
    dim low_h as integer
    dim obj_id as integer
    dim colr as integer
    dim g as integer, b as integer
    dim chance as double
    
    '// snow caps
    dx = int(highres.w*rnd(1))
    dy = int(highres.h*rnd(1))
    for y = dy-200 to dy+200
    for x = dx-200 to dx+200
        if highres.heights(x, y) > 0 then
            colr = highres.colors(x, y)
            r = (colr shr 16) and &hff: g = (colr shr 8) and &hff: b = (colr and &hff)
            r += highres.heights(x, y)*0.001+128
            g += highres.heights(x, y)*0.001+128
            b += highres.heights(x, y)*0.001+128
            if r > 255 then r = 255
            if g > 255 then g = 255
            if b > 255 then b = 255
            chance = -int(16*rnd(1))
            highres.setColor(x, y, rgb(r+chance, g+chance, b+chance))
        end if
    next x
    next y
    
    '// swamp
    dx = int(highres.w*rnd(1))
    dy = int(highres.h*rnd(1))
    for y = dy-200 to dy+200
        for x = dx-200 to dx+200
            highres.setHeight(x, y, highres.heights(x, y)/5)
            r = int(16*rnd(1))-32
            highres.setColor(x, y, rgb(&h7d+r, &h92+r, &h6c+r))
        next x
    next y
    for y = dy-180 to dy+180
        for x = dx-180 to dx+180
            if int(32*rnd(1)) = 1 then
                highres.setHeight(x, y, highres.heights(x, y)+300+int(rnd(1)*1))
                highres.setColor(x, y, rgb(&h9d+r, &h92+r, &h5c+r))
            end if
        next x
    next y
    
    '// desert
    dx = int(highres.w*rnd(1))
    dy = int(highres.h*rnd(1))
    for y = dy-200 to dy+200
    for x = dx-200 to dx+200
        'highres.setColor(x, y, rgb(&hff, &he5, &h00))
    next x
    next y
    
    
    for i = 0 to 0
        obj_id = 1'int(2*rnd(1))
        x = int(highres.w*rnd(1))
        y = int(highres.h*rnd(1))
        low_h = 9999
        for dy = 0 to 15
            for dx = 0 to 15
                if dx = 0 or dy = 0 or dx = 15 or dy = 15 then
                    h = highres.heights(x+dx, y+dy)
                    if h < low_h then
                        low_h = h
                    end if
                end if
            next dx
        next dy
        for dy = 0 to 15
            for dx = 0 to 15
                c = mid(objects(dy, obj_id), dx+1, 1)
                if c = "#" then
                    h = 30
                    r = -20
                elseif c = " " then
                    h = 0
                elseif c = "0" then
                    h = -1
                elseif c >= "a" and c <= "z" then
                    h = asc(c)-97+10
                    r = h*12+80
                else
                    h = val(c)
                    r = h*12+80
                end if
                h *= iif(obj_id = 0, 40, 150)
                highres.setHeight(x+dx, y+dy, low_h+h)
                dim nothing as integer = int(16*rnd(1))-32
                if h = -40 then
                    highres.setColor(x+dx, y+dy, rgb(&h6e, &h72, &h9f))
                elseif h <> 0 then
                    highres.setColor(x+dx, y+dy, rgb(&hff+r, &he4+r, &hd8+r))
                else
                    if (y+dy) and 1 then
                        r = iif((x+dx) and 1, &hbe, &h22)
                    else
                        r = iif((x+dx) and 1, &h22, &hbe)
                    end if
                    highres.setColor(x+dx, y+dy, rgb(&h00+r, &h00+r, &h00+r))
                end if
            next dx
        next dy
    next i
    
    '// glow boxes
    dim rx as integer, ry as integer
    dim dist as integer
    for i = 0 to 0
        rx = int(highres.w*rnd(1))
        ry = int(highres.h*rnd(1))
        low_h = 9999
        for y = ry-10 to ry+10
            for x = rx-10 to rx+10
                if highres.heights(x, y) < low_h then
                    low_h = highres.heights(x, y)
                end if
            next x
        next y
        for y = ry-10 to ry+10
            for x = rx-10 to rx+10
                dist = iif(abs(x-rx) > abs(y-ry), abs(x-rx), abs(y-ry))+1
                dist = 1000/(dist*dist)
                colr = highres.colors(x, y)
                r = red(colr): g = grn(colr): b = blu(colr)
                r = iif(r+dist > 255, 255, r+dist)
                g = iif(g+dist > 255, 255, g+dist)
                b = iif(b+dist > 255, 255, b+dist)
                highres.setColor(x, y, rgb(r, g, b))
                'highres.setHeight(x, y, low_h)
            next x
        next y
        highres.setHeight(rx, ry, highres.heights(rx, ry)+25000)
    next i
    
    '// generate low-res maps
    for y = 0 to medres.h-1
        for x = 0 to medres.w-1
            medres.setWall(x, y, highres.getWallAvg(x*2, y*2, 2))
            medres.setHeight(x, y, highres.getHeightAvg(x*2, y*2, 2))
            medres.setColor(x, y, highres.getColorAvg(x*2, y*2, 2))
        next x
    next y
    for y = 0 to lowres.h-1
        for x = 0 to lowres.w-1
            lowres.setWall(x, y, highres.getWallAvg(x*4, y*4, 4))
            lowres.setHeight(x, y, highres.getHeightAvg(x*4, y*4, 4))
            lowres.setColor(x, y, highres.getColorAvg(x*4, y*4, 4))
        next x
    next y
    for y = 0 to subres.h-1
        for x = 0 to subres.w-1
            subres.setWall(x, y, highres.getWallAvg(x*8, y*8, 8))
            subres.setHeight(x, y, highres.getHeightAvg(x*8, y*8, 8))
            subres.setColor(x, y, highres.getColorAvg(x*8, y*8, 8))
        next x
    next y
end sub

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

function red(argb32 as integer) as integer
    return (argb32 shr 16) and &hff
end function
function grn(argb32 as integer) as integer
    return (argb32 shr 8) and &hff
end function
function blu(argb32 as integer) as integer
    return argb32 and &hff
end function