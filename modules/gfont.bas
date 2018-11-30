#include once "modules/inc/gfont.bi"

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
