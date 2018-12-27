#pragma once
#inclib "sound"

#include once "SDL2/SDL.bi"
#include once "SDL2/SDL_mixer.bi"

#define AUDIO_RATE		44100 'MIX_DEFAULT_FREQUENCY
#define AUDIO_FORMAT	MIX_DEFAULT_FORMAT
#define AUDIO_CHANNELS	2
#define AUDIO_BUFFERS	1024

declare sub SOUND_Init ()
declare sub SOUND_Release ()
declare sub SOUND_Update ()

declare function SOUND_GetMusicVolume() as double
declare function SOUND_GetSoundVolume() as double
declare sub SOUND_SetMusicVolume(volume as double)
declare sub SOUND_SetSoundVolume(volume as double)

declare sub SOUND_SetMusic (filename as string)
declare sub SOUND_PlayMusic (loops as integer = -1)
declare sub SOUND_StopMusic ()
declare sub SOUND_PauseMusic ()
declare sub SOUND_ResumeMusic ()

declare sub SOUND_AddSound (id as string, filename as string, maxChannels as integer=4, loops as integer=0, volume as double=1.0)
declare sub SOUND_PlaySound (id as string, volume as double=1.0)
declare sub SOUND_StopSound (id as string)

declare function SOUND_MusicIsPlaying () as integer
declare sub SOUND_ChannelFinished cdecl(channelId as long)
