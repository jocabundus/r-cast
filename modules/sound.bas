#include "modules/inc/sound.bi"

type tSFX

	id as string
	loops as integer
	
	sfxId as Mix_Chunk ptr
	volume as integer
	channels(3) as integer
	maxChannels as integer
	numChannels as integer

end type

declare function SOUND_FindSound (id as string) as integer

dim shared GLOBAL_MaxChannels as integer = 16

redim shared GLOBAL_Sounds(0) as tSFX
dim shared GLOBAL_SoundChannels(GLOBAL_MaxChannels-1) as integer
dim shared GLOBAL_NumSounds as integer
dim shared GLOBAL_BackgroundMusic as Mix_Music ptr
dim shared GLOBAL_SoundVolume as double = 0.5
dim shared GLOBAL_MusicVolume as double = 0.5
dim shared GLOBAL_MusicIsPlaying as integer = 0
dim shared GLOBAL_SoundInitialized as integer = 0

sub SOUND_Init ()

	GLOBAL_NumSounds = 0
	
	if Mix_OpenAudio( AUDIO_RATE, AUDIO_FORMAT, AUDIO_CHANNELS, AUDIO_BUFFERS ) then
		return
	end if
	
	if (Mix_Init( MIX_INIT_OGG ) and MIX_INIT_OGG) <> MIX_INIT_OGG then
		return
	end if
	
	Mix_AllocateChannels(GLOBAL_MaxChannels)
	dim n as integer
	for n = 0 to GLOBAL_MaxChannels-1
		GLOBAL_SoundChannels(n) = -1
	next n
	Mix_ChannelFinished(@SOUND_ChannelFinished)
	
	GLOBAL_SoundInitialized = 1

end sub

sub SOUND_Release ()

	if GLOBAL_SoundInitialized then
		Mix_FreeMusic( GLOBAL_BackgroundMusic )
		GLOBAL_BackgroundMusic = 0
		
		Mix_CloseAudio
	end if

end sub

sub SOUND_Update ()


end sub

sub SOUND_SetMusicVolume(volume as double)

	if GLOBAL_SoundInitialized then
		Mix_VolumeMusic(volume*MIX_MAX_VOLUME)
		GLOBAL_MusicVolume = volume
	end if

end sub

sub SOUND_SetSoundVolume(volume as double)

	if GLOBAL_SoundInitialized then
		dim n as integer
		for n = 0 to GLOBAL_NumSounds-1
			Mix_VolumeChunk(GLOBAL_Sounds(n).sfxId, volume*GLOBAL_Sounds(n).volume)
		next n
		GLOBAL_SoundVolume = volume
	end if

end sub

function SOUND_GetMusicVolume() as double
	return GLOBAL_MusicVolume
end function

function SOUND_GetSoundVolume() as double
	return GLOBAL_SoundVolume
end function

function SOUND_FindSound (id as string) as integer

	dim n as integer
	for n = 0 to GLOBAL_NumSounds-1
		if GLOBAL_Sounds(n).id = id then
			return n
		end if
	next n
	
	return -1
	
end function

sub SOUND_SetMusic (filename as string)

	GLOBAL_BackgroundMusic = Mix_LoadMUS(filename)

end sub

sub SOUND_PlayMusic (loops as integer = -1)

	if GLOBAL_SoundInitialized and (GLOBAL_BackgroundMusic <> 0) then
		Mix_VolumeMusic(GLOBAL_MusicVolume*MIX_MAX_VOLUME)
		Mix_PlayMusic( GLOBAL_BackgroundMusic, loops )
		
		GLOBAL_MusicIsPlaying = 1
	end if

end sub

sub SOUND_StopMusic ()

	if GLOBAL_SoundInitialized then
		Mix_HaltMusic
	end if
	
	GLOBAL_MusicIsPlaying = 0

end sub

sub SOUND_PauseMusic ()

	if GLOBAL_SoundInitialized and (GLOBAL_BackgroundMusic <> 0) then
		if Mix_PlayingMusic then
			Mix_PauseMusic
			GLOBAL_MusicIsPlaying = 0
		end if
	end if

end sub

sub SOUND_ResumeMusic ()

	if GLOBAL_SoundInitialized and (GLOBAL_BackgroundMusic <> 0) then
		if Mix_PausedMusic() then
			Mix_ResumeMusic()
			GLOBAL_MusicIsPlaying = 1
		end if
	end if
	
	Mix_ResumeMusic()

end sub

sub SOUND_AddSound (id as string, filename as string, maxChannels as integer=4, loops as integer=0, volume as double=1.0)

	if GLOBAL_SoundInitialized = 0 then return

	dim n as integer

	n = GLOBAL_NumSounds
	GLOBAL_NumSounds += 1
	
	if maxChannels > 4 then maxChannels = 4
	
	redim preserve GLOBAL_Sounds(GLOBAL_NumSounds)
	
	GLOBAL_Sounds(n).id = id
	GLOBAL_Sounds(n).loops = loops
	GLOBAL_Sounds(n).sfxId = Mix_LoadWAV(filename)
	GLOBAL_Sounds(n).channels(0) = -1
	GLOBAL_Sounds(n).channels(1) = -1
	GLOBAL_Sounds(n).channels(2) = -1
	GLOBAL_Sounds(n).channels(3) = -1
	GLOBAL_Sounds(n).maxChannels = maxChannels
	GLOBAL_Sounds(n).numChannels = 0
	GLOBAL_Sounds(n).volume = int(volume*MIX_MAX_VOLUME)
	
	Mix_VolumeChunk(GLOBAL_Sounds(n).sfxId, int(GLOBAL_SoundVolume*GLOBAL_Sounds(n).volume))

end sub

sub SOUND_PlaySound (id as string, volume as double=1.0)

	if GLOBAL_SoundInitialized = 0 then return

	dim n as integer, i as integer
	dim channelSlot as integer
	dim cid as integer
    
    n = SOUND_FindSound(id)
	if n >= 0 then
		if GLOBAL_Sounds(n).numChannels < GLOBAL_Sounds(n).maxChannels then
			
			channelSlot = -1
			for i = 0 to GLOBAL_Sounds(n).maxChannels-1
				if GLOBAL_Sounds(n).channels(i) = -1 then
					channelSlot = i
					exit for
				end if
			next i
			
			if channelSlot >= 0 then
                if volume < 0.0 then volume = 0.0
                if volume > 1.0 then volume = 1.0
                Mix_VolumeChunk(GLOBAL_Sounds(n).sfxId, MIX_MAX_VOLUME*volume)
				cid = Mix_PlayChannel(-1, GLOBAL_Sounds(n).sfxId, GLOBAL_Sounds(n).loops)
				if cid >= 0 then
					GLOBAL_Sounds(n).channels(channelSlot) = cid
					GLOBAL_Sounds(n).numChannels += 1
					GLOBAL_SoundChannels(cid) = n
				end if
			end if
			
		end if
	end if
	
end sub

sub SOUND_StopSound (id as string)

	if GLOBAL_SoundInitialized = 0 then return

	dim n as integer, i as integer
	n = SOUND_FindSound(id)
	if n >= 0 and GLOBAL_Sounds(n).numChannels > 0 then
		for i = 0 to GLOBAL_Sounds(n).maxChannels-1
			if GLOBAL_Sounds(n).channels(i) >= 0 then
				Mix_HaltChannel(GLOBAL_Sounds(n).channels(i))
				GLOBAL_Sounds(n).channels(i) = -1
			end if
		next i
		GLOBAL_Sounds(n).numChannels = 0
	end if
	
end sub

function SOUND_MusicIsPlaying () as integer

	return GLOBAL_MusicIsPlaying

end function

sub SOUND_ChannelFinished cdecl(channelId as long)
	
	if GLOBAL_SoundInitialized = 0 then return
	
	dim n as integer, i as integer
	
	n = GLOBAL_SoundChannels(channelId)
	if n >= 0 then
		for i = 0 to GLOBAL_Sounds(n).maxChannels-1
			if GLOBAL_Sounds(n).channels(i) = channelId then
				GLOBAL_Sounds(n).channels(i) = -1
				GLOBAL_Sounds(n).numChannels -= 1
			end if
		next i
	end if
	
	GLOBAL_SoundChannels(channelId) = -1
	
end sub
