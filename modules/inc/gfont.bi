#pragma once
#inclib "gfont"

#include once "SDL2/SDL.bi"

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
