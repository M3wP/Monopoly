base:
zpbase           = 20
SIDBASE          = 54272
SOUNDSUPPORT     = 1
VOLSUPPORT       = 0
BUFFEREDWRITES   = 1
GHOSTREGS        = 0
ZPGHOSTREGS      = 0
FIXEDPARAMS      = 1
SIMPLEPULSE      = 0
PULSEOPTIMIZATION = 1
REALTIMEOPTIMIZATION = 1
NOAUTHORINFO     = 1
NOEFFECTS        = 0
NOGATE           = 0
NOFILTER         = 0
NOFILTERMOD      = 0
NOPULSE          = 0
NOPULSEMOD       = 0
NOWAVEDELAY      = 1
NOWAVECMD        = 1
NOREPEAT         = 1
NOTRANS          = 1
NOPORTAMENTO     = 0
NOTONEPORTA      = 0
NOVIB            = 0
NOINSTRVIB       = 0
NOSETAD          = 1
NOSETSR          = 0
NOSETWAVE        = 1
NOSETWAVEPTR     = 1
NOSETPULSEPTR    = 1
NOSETFILTPTR     = 0
NOSETFILTCTRL    = 0
NOSETFILTCUTOFF  = 0
NOSETMASTERVOL   = 1
NOFUNKTEMPO      = 1
NOGLOBALTEMPO    = 0
NOCHANNELTEMPO   = 1
NOFIRSTWAVECMD   = 1
NOCALCULATEDSPEED = 1
NONORMALSPEED    = 0
NOZEROSPEED      = 0
NUMCHANNELS      = 3
NUMSONGS         = 16
FIRSTNOTE        = 0
FIRSTNOHRINSTR   = 10
FIRSTLEGATOINSTR = 10
NUMHRINSTR       = 9
NUMNOHRINSTR     = 0
NUMLEGATOINSTR   = 0
ADPARAM          = 15
SRPARAM          = 0
DEFAULTTEMPO     = 5
FIRSTWAVEPARAM   = 9
GATETIMERPARAM   = 2
;-------------------------------------------------------------------------------
; GoatTracker V2.73 playroutine
;
; NOTE: This playroutine source code does not fall under the GPL license!
; Use it, or song binaries created from it freely for any purpose, commercial
; or noncommercial.
;
; NOTE 2: This code is in the format of Magnus Lind's assembler from Exomizer.
; Does not directly compile on DASM etc.
;-------------------------------------------------------------------------------

        ;Defines will be inserted by the relocator here

              .IF (ZPGHOSTREGS = 0)
mt_temp1        = zpbase+0
mt_temp2        = zpbase+1
              .ELSE
ghostfreqlo     = zpbase+0
ghostfreqhi     = zpbase+1
ghostpulselo    = zpbase+2
ghostpulsehi    = zpbase+3
ghostwave       = zpbase+4
ghostad         = zpbase+5
ghostsr         = zpbase+6
ghostfiltcutlow = zpbase+21
ghostfiltcutoff = zpbase+22
ghostfiltctrl   = zpbase+23
ghostfilttype   = zpbase+24
mt_temp1        = zpbase+25
mt_temp2        = zpbase+26
              .ENDIF

        ;Defines for the music data
        ;Patterndata notes

ENDPATT         = $00
INS             = $00
FX              = $40
FXONLY          = $50
NOTE            = $60
REST            = $bd
KEYOFF          = $be
KEYON           = $bf
FIRSTPACKEDREST = $c0
PACKEDREST      = $00

        ;Effects

DONOTHING       = $00
PORTAUP         = $01
PORTADOWN       = $02
TONEPORTA       = $03
VIBRATO         = $04
SETAD           = $05
SETSR           = $06
SETWAVE         = $07
SETWAVEPTR      = $08
SETPULSEPTR     = $09
SETFILTPTR      = $0a
SETFILTCTRL     = $0b
SETFILTCUTOFF   = $0c
SETMASTERVOL    = $0d
SETFUNKTEMPO    = $0e
SETTEMPO        = $0f

        ;Orderlist commands

REPEAT          = $d0
TRANSDOWN       = $e0
TRANS           = $f0
TRANSUP         = $f0
LOOPSONG        = $ff

        ;Wave,pulse,filttable comands

LOOPWAVE        = $ff
LOOPPULSE       = $ff
LOOPFILT        = $ff
SETPULSE        = $80
SETFILTER       = $80
SETCUTOFF       = $00

;                .ORG (base)

plractualaddr:

.IF	plractualaddr <> base
	.error alignment incorrect
.endif

        ;Jump table

                jmp mt_init
                jmp mt_play
              .IF (SOUNDSUPPORT <> 0)
                jmp mt_playsfx
              .ENDIF
              .IF (VOLSUPPORT <> 0)
                jmp mt_setmastervol
              .ENDIF

        ;Author info

              .IF (NOAUTHORINFO = 0)

authorinfopos   = base + $20
checkpos1:
              .IF ((authorinfopos - checkpos1) > 15)
mt_tick0jumptbl:
                .BYTE mt_tick0_0 .mod 256
                .BYTE mt_tick0_12 .mod 256
                .BYTE mt_tick0_12 .mod 256
                .BYTE mt_tick0_34 .mod 256
                .BYTE mt_tick0_34 .mod 256
                .BYTE mt_tick0_5 .mod 256
                .BYTE mt_tick0_6 .mod 256
                .BYTE mt_tick0_7 .mod 256
                .BYTE mt_tick0_8 .mod 256
                .BYTE mt_tick0_9 .mod 256
                .BYTE mt_tick0_a .mod 256
                .BYTE mt_tick0_b .mod 256
                .BYTE mt_tick0_c .mod 256
                .BYTE mt_tick0_d .mod 256
                .BYTE mt_tick0_e .mod 256
                .BYTE mt_tick0_f .mod 256
              .ENDIF

checkpos2:
              .IF ((authorinfopos - checkpos2) > 4)
mt_effectjumptbl:
                .BYTE mt_effect_0 .mod 256
                .BYTE mt_effect_12 .mod 256
                .BYTE mt_effect_12 .mod 256
                .BYTE mt_effect_3 .mod 256
                .BYTE mt_effect_4 .mod 256
              .ENDIF

checkpos3:
              .IF ((authorinfopos - checkpos3) > 1)
mt_funktempotbl:
                .BYTE 8,5
              .ENDIF

        ;This is pretty stupid way of filling left-out space, but .ORG
        ;seemed to bug

checkpos4:
              .IF ((authorinfopos - checkpos4) > 0) 
			.BYTE 0 
		.ENDIF
checkpos5:
              .IF ((authorinfopos - checkpos5) > 0) 
		.BYTE 0 
		.ENDIF
checkpos6:
              .IF ((authorinfopos - checkpos6) > 0) 
	      .BYTE 0 
	      .ENDIF

mt_author:

                .BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                .BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              .ENDIF

        ;0 Instrument vibrato

mt_tick0_0:
              .IF (NOEFFECTS = 0)
              .IF (NOINSTRVIB = 0)
                lda mt_insvibparam-1,y
                jmp mt_tick0_34
              .ELSE
              .IF (NOVIB = 0)
                jmp mt_tick0_34
              .ENDIF
              .ENDIF
              .ENDIF

        ;1,2 Portamentos


mt_tick0_12:
              .IF (NOVIB = 0)
                tay
                lda #$00
                sta mt_chnvibtime,x
                tya
              .ENDIF

        ;3,4 Toneportamento, Vibrato

mt_tick0_34:
              .IF (NOEFFECTS = 0)
              .IF ((NOTONEPORTA = 0) || (NOPORTAMENTO = 0) || (NOVIB = 0))
                sta mt_chnparam,x
                lda mt_chnnewfx,x
                sta mt_chnfx,x
              .ENDIF
                rts
              .ENDIF

        ;5 Set AD

mt_tick0_5:
              .IF (NOSETAD = 0)
              .IF (BUFFEREDWRITES = 0)
                sta SIDBASE+$05,x
              .ELSE
              .IF (GHOSTREGS = 0)
                sta mt_chnad,x
              .ELSE
                sta <ghostad,x
              .ENDIF
              .ENDIF
                rts
              .ENDIF

        ;6 Set Sustain/Release

mt_tick0_6:
              .IF (NOSETSR = 0)
              .IF (BUFFEREDWRITES = 0)
                sta SIDBASE+$06,x
              .ELSE
              .IF (GHOSTREGS = 0)
                sta mt_chnsr,x
              .ELSE
                sta <ghostsr,x
              .ENDIF
              .ENDIF
                rts
              .ENDIF

        ;7 Set waveform

mt_tick0_7:
              .IF (NOSETWAVE = 0)
                sta mt_chnwave,x
                rts
              .ENDIF

        ;8 Set wavepointer

mt_tick0_8:
              .IF (NOSETWAVEPTR = 0)
                sta mt_chnwaveptr,x
              .IF (NOWAVEDELAY = 0)
                lda #$00                        ;Make sure possible delayed
                sta mt_chnwavetime,x            ;waveform execution goes
              .ENDIF                            ;correctly
                rts
              .ENDIF

        ;9 Set pulsepointer

mt_tick0_9:
              .IF (NOSETPULSEPTR = 0)
                sta mt_chnpulseptr,x
                lda #$00                        ;Reset pulse step duration
                sta mt_chnpulsetime,x
                rts
              .ENDIF

        ;a Set filtpointer

mt_tick0_a:
              .IF (NOSETFILTPTR = 0)
              .IF (NOFILTERMOD = 0)
                ldy #$00
                sty mt_filttime+1
              .ENDIF
mt_tick0_a_step:
                sta mt_filtstep+1
                rts
              .ENDIF

        ;b Set filtcontrol (channels & resonance)

mt_tick0_b:
              .IF (NOSETFILTCTRL = 0)
                sta mt_filtctrl+1
              .IF (NOSETFILTPTR = 0)
                beq mt_tick0_a_step          ;If 0, stop also step-programming
              .ELSE
                bne mt_tick0_b_noset
                sta mt_filtstep+1
mt_tick0_b_noset:
              .ENDIF
                rts
              .ENDIF

        ;c Set cutoff

mt_tick0_c:
              .IF (NOSETFILTCUTOFF = 0)
                sta mt_filtcutoff+1
                rts
              .ENDIF

        ;d Set mastervolume / timing mark

mt_tick0_d:
              .IF (NOSETMASTERVOL = 0)
              .IF (NOAUTHORINFO = 0)
                cmp #$10
                bcs mt_tick0_d_timing
              .ENDIF
mt_setmastervol:
                sta mt_masterfader+1
                rts
              .IF (NOAUTHORINFO = 0)
mt_tick0_d_timing:
                sta mt_author+31
                rts
              .ENDIF
              .ENDIF

        ;e Funktempo

mt_tick0_e:
              .IF (NOFUNKTEMPO = 0)
                tay
                lda mt_speedlefttbl-1,y
                sta mt_funktempotbl
                lda mt_speedrighttbl-1,y
                sta mt_funktempotbl+1
                lda #$00
              .IF (NOCHANNELTEMPO = 0)
                beq mt_tick0_f_setglobaltempo
              .ENDIF
              .ENDIF

        ;f Set Tempo

mt_tick0_f:
              .IF ((NOCHANNELTEMPO = 0) && (NOGLOBALTEMPO = 0))
                bmi mt_tick0_f_setchantempo     ;Channel or global tempo?
              .ENDIF
mt_tick0_f_setglobaltempo:
              .IF (NOGLOBALTEMPO = 0)
                sta mt_chntempo
              .IF (NUMCHANNELS > 1)
                sta mt_chntempo+7
              .ENDIF
              .IF (NUMCHANNELS > 2)
                sta mt_chntempo+14
              .ENDIF
                rts
              .ENDIF
mt_tick0_f_setchantempo:
              .IF (NOCHANNELTEMPO = 0)
                and #$7f
                sta mt_chntempo,x
                rts
              .ENDIF

        ;Continuous effect code

        ;0 Instrument vibrato

              .IF (NOINSTRVIB = 0)
mt_effect_0_delay:
                dec mt_chnvibdelay,x
mt_effect_0_donothing:
                jmp mt_done
mt_effect_0:    beq mt_effect_0_donothing         ;Speed 0 = no vibrato at all
                lda mt_chnvibdelay,x
                bne mt_effect_0_delay
              .ELSE
mt_effect_0:
mt_effect_0_donothing:
                jmp mt_done
              .ENDIF

        ;4 Vibrato

mt_effect_4:
              .IF (NOVIB = 0)
              .IF (NOCALCULATEDSPEED = 0)
                lda mt_speedlefttbl-1,y
              .IF (NONORMALSPEED = 0)
                bmi mt_effect_4_nohibyteclear
                ldy #$00                        ;Clear speed highbyte
                sty <mt_temp2
              .ENDIF
mt_effect_4_nohibyteclear:
                and #$7f
                sta mt_effect_4_speedcmp+1
              .ELSE
                lda #$00                        ;Clear speed highbyte
                sta <mt_temp2
              .ENDIF
                lda mt_chnvibtime,x
                bmi mt_effect_4_nodir
              .IF (NOCALCULATEDSPEED <> 0)
                cmp mt_speedlefttbl-1,y
              .ELSE
mt_effect_4_speedcmp:
                cmp #$00
              .ENDIF
                bcc mt_effect_4_nodir2
                beq mt_effect_4_nodir
                eor #$ff
mt_effect_4_nodir:
                clc
mt_effect_4_nodir2:
                adc #$02
mt_vibdone:
                sta mt_chnvibtime,x
                lsr
                bcc mt_freqadd
                bcs mt_freqsub
              .ENDIF

        ;1,2,3 Portamentos

mt_effect_3:
              .IF (NOTONEPORTA = 0)
                tya
                beq mt_effect_3_found           ;Speed $00 = tie note
              .ENDIF
mt_effect_12:
              .IF ((NOTONEPORTA = 0) || (NOPORTAMENTO = 0))
              .IF (NOCALCULATEDSPEED <> 0)
                lda mt_speedlefttbl-1,y
                sta <mt_temp2
              .ENDIF
              .ENDIF
              .IF (NOPORTAMENTO = 0)

              .IF (NOWAVECMD <> 0)
                lda mt_chnfx,x
              .ELSE
mt_effectnum:
                lda #$00
              .ENDIF
                cmp #$02
                bcc mt_freqadd
                beq mt_freqsub
              .ELSE
              .IF (NOTONEPORTA = 0)
                sec
              .ENDIF
              .ENDIF
              .IF (NOTONEPORTA = 0)
;dengland
                ldy mt_chnnote,x
;---
		.IF (GHOSTREGS = 0)
                lda mt_chnfreqlo,x              ;Calculate offset to the
                sbc mt_freqtbllo-FIRSTNOTE,y    ;right frequency
                pha
                lda mt_chnfreqhi,x
              .ELSE
                lda <ghostfreqlo,x              ;Calculate offset to the
                sbc mt_freqtbllo-FIRSTNOTE,y    ;right frequency
                pha
                lda <ghostfreqhi,x
              .ENDIF
                sbc mt_freqtblhi-FIRSTNOTE,y
                tay
                pla
                bcs mt_effect_3_down            ;If positive, have to go down

mt_effect_3_up:
                adc <mt_temp1                   ;Add speed to offset
                tya                             ;If changes sign, we're done
                adc <mt_temp2
                bpl mt_effect_3_found
              .ENDIF


              .IF ((NOTONEPORTA = 0) || (NOPORTAMENTO = 0) || (NOVIB = 0))
mt_freqadd:
              .IF (GHOSTREGS = 0)
                lda mt_chnfreqlo,x
                adc <mt_temp1
                sta mt_chnfreqlo,x
                lda mt_chnfreqhi,x
              .ELSE
                lda <ghostfreqlo,x
                adc <mt_temp1
                sta <ghostfreqlo,x
                lda <ghostfreqhi,x
              .ENDIF
                adc <mt_temp2
                jmp mt_storefreqhi
              .ENDIF

              .IF (NOTONEPORTA = 0)
mt_effect_3_down:
                sbc <mt_temp1                   ;Subtract speed from offset
                tya                             ;If changes sign, we're done
                sbc <mt_temp2
                bmi mt_effect_3_found
              .ENDIF

              .IF ((NOTONEPORTA = 0) || (NOPORTAMENTO = 0) || (NOVIB = 0))
mt_freqsub:
              .IF (GHOSTREGS = 0)
                lda mt_chnfreqlo,x
                sbc <mt_temp1
                sta mt_chnfreqlo,x
                lda mt_chnfreqhi,x
              .ELSE
                lda <ghostfreqlo,x
                sbc <mt_temp1
                sta <ghostfreqlo,x
                lda <ghostfreqhi,x
              .ENDIF
                sbc <mt_temp2
                jmp mt_storefreqhi
              .ENDIF

mt_effect_3_found:
              .IF (NOTONEPORTA = 0)
              .IF (NOCALCULATEDSPEED = 0)
                lda mt_chnnote,x
                jmp mt_wavenoteabs
              .ELSE
;dengland
                ldy mt_chnnote,x
;--
		jmp mt_wavenote
              .ENDIF
              .ENDIF

        ;Init routine

mt_init:
              .IF (NUMSONGS > 1)
                sta mt_init+5
                asl
                adc #$00
              .ENDIF
                sta mt_initsongnum+1
                rts

        ;Play soundeffect -routine

              .IF (SOUNDSUPPORT <> 0)
        ;Sound FX init routine

mt_playsfx:     sta mt_playsfxlo+1
                sty mt_playsfxhi+1
                lda mt_chnsfx,x                   ;Need a priority check?
                beq mt_playsfxok
                tya                               ;Check address highbyte
                cmp mt_chnsfxhi,x
                bcc mt_playsfxskip                ;Lower than current -> skip
                bne mt_playsfxok                  ;Higher than current -> OK
                lda mt_playsfxlo+1                ;Check address lowbyte
                cmp mt_chnsfxlo,x
                bcc mt_playsfxskip                ;Lower than current -> skip
mt_playsfxok:   lda #$01
                sta mt_chnsfx,x
mt_playsfxlo:   lda #$00
                sta mt_chnsfxlo,x
mt_playsfxhi:   lda #$00
                sta mt_chnsfxhi,x
mt_playsfxskip: rts
              .ENDIF

        ;Set mastervolume -routine

              .IF ((VOLSUPPORT <> 0) && (NOSETMASTERVOL <> 0))
mt_setmastervol:
                sta mt_masterfader+1
                rts
              .ENDIF

        ;Playroutine

mt_play:        
                .IF ((ZPGHOSTREGS = 0) && (GHOSTREGS <> 0))
                ldx #24                         ;In full ghosting mode copy
mt_copyregs:    lda ghostregs,x                 ;previous frame's SID values in one step
                sta SIDBASE,x
                dex
                bpl mt_copyregs
                .ENDIF

                ldx #$00                        ;Channel index

        ;Song initialization

mt_initsongnum:
                ldy #$00
                bmi mt_filtstep
                txa
                ldx #NUMCHANNELS * 14 - 1
mt_resetloop:
                sta mt_chnsongptr,x             ;Reset sequencer + voice
                dex                             ;variables on all channels
                bpl mt_resetloop
              .IF (GHOSTREGS = 0)
              .IF (NUMCHANNELS = 2)
;dengland
;                sta SIDBASE+$12
;---
              .ENDIF
              .IF (NUMCHANNELS = 1)
                sta SIDBASE+$0b
;dengland
;                sta SIDBASE+$12
;---
              .ENDIF
                sta SIDBASE+$15                       ;Reset filter cutoff lowbyte
              .ELSE
                sta <ghostfiltcutlow
              .ENDIF
                sta mt_filtctrl+1             ;Switch filter off & reset
              .IF (NOFILTER = 0)
                sta mt_filtstep+1             ;step-programming
              .ENDIF
                stx mt_initsongnum+1          ;Reset initflag
                tax
              .IF (NUMCHANNELS = 3)
                jsr mt_initchn
                ldx #$07
;dengland
;               jsr mt_initchn
;               ldx #$0e
;---              
              .ENDIF
              .IF (NUMCHANNELS = 2)
                jsr mt_initchn
                ldx #$07
              .ENDIF
mt_initchn:
              .IF (NUMSONGS > 1)
                tya
                iny
                sta mt_chnsongnum,x             ;Store index to songtable
              .ENDIF
mt_defaulttempo:
                lda #DEFAULTTEMPO               ;Set default tempo
                sta mt_chntempo,x
                lda #$01
                sta mt_chncounter,x             ;Reset counter
                sta mt_chninstr,x               ;Reset instrument
                jmp mt_loadregswaveonly          ;Load waveform

        ;Filter execution

mt_filtstep:
              .IF (NOFILTER = 0)
                ldy #$00                        ;See if filter stopped
                beq mt_filtdone
              .IF (NOFILTERMOD = 0)
mt_filttime:
                lda #$00                        ;See if time left for mod.
                bne mt_filtmod                  ;step
              .ENDIF
mt_newfiltstep:
                lda mt_filttimetbl-1,y          ;$80-> = set filt parameters
                beq mt_setcutoff                ;$00 = set cutoff
              .IF (NOFILTERMOD = 0)
                bpl mt_newfiltmod
              .ENDIF
mt_setfilt:
                asl                             ;Set passband
                sta mt_filttype+1
                lda mt_filtspdtbl-1,y           ;Set resonance/channel
                sta mt_filtctrl+1
                lda mt_filttimetbl,y            ;Check for cutoff setting
                bne mt_nextfiltstep2            ;following immediately
mt_setcutoff2:
                iny
mt_setcutoff:
                lda mt_filtspdtbl-1,y           ;Take cutoff value
                sta mt_filtcutoff+1
              .IF (NOFILTERMOD = 0)
                jmp mt_nextfiltstep
mt_newfiltmod:
                sta mt_filttime+1               ;$01-$7f = new modulation step
mt_filtmod:   
                lda mt_filtspdtbl-1,y           ;Take filt speed
                clc
                adc mt_filtcutoff+1
                sta mt_filtcutoff+1
                dec mt_filttime+1
                bne mt_storecutoff
              .ENDIF
mt_nextfiltstep:
                lda mt_filttimetbl,y           ;Jump in filttable?
mt_nextfiltstep2:
                cmp #LOOPFILT
                iny
                tya
                bcc mt_nofiltjump
                lda mt_filtspdtbl-1,y          ;Take jump point
mt_nofiltjump:
                sta mt_filtstep+1
mt_filtdone:
mt_filtcutoff:
                lda #$00
mt_storecutoff:
              .IF (GHOSTREGS = 0)
                sta SIDBASE+$16
              .ELSE
                sta <ghostfiltcutoff
              .ENDIF
              .ENDIF
mt_filtctrl:
                lda #$00
              .IF (GHOSTREGS = 0)
                sta SIDBASE+$17
              .ELSE
                sta <ghostfiltctrl
              .ENDIF
mt_filttype:
                lda #$00
mt_masterfader:
                ora #$0f                        ;Master volume fader
;dengland
		ora #$80
;---
		.IF (GHOSTREGS = 0)
                sta SIDBASE+$18
              .ELSE
                sta <ghostfilttype
              .ENDIF

              .IF (NUMCHANNELS = 3)
                jsr mt_execchn
                ldx #$07
;dengland	
;		jsr mt_execchn
;               ldx #$0e
;---
              .ENDIF
              .IF (NUMCHANNELS = 2)
                jsr mt_execchn
                ldx #$07
              .ENDIF

        ;Channel execution

mt_execchn:
                dec mt_chncounter,x               ;See if tick 0
                beq mt_tick0

        ;Ticks 1-n

mt_notick0:
                bpl mt_effects
                lda mt_chntempo,x               ;Reload tempo if negative

              .IF (NOFUNKTEMPO = 0)
                cmp #$02
                bcs mt_nofunktempo              ;Funktempo: bounce between
                tay                             ;funktable indexes 0,1
                eor #$01
                sta mt_chntempo,x
                lda mt_funktempotbl,y
                sbc #$00
              .ENDIF

mt_nofunktempo:
                sta mt_chncounter,x
mt_effects:
                jmp mt_waveexec

        ;Sequencer repeat

mt_repeat:
              .IF (NOREPEAT = 0)
                sbc #REPEAT
                inc mt_chnrepeat,x
                cmp mt_chnrepeat,x
                bne mt_nonewpatt
mt_repeatdone:
                lda #$00
                sta mt_chnrepeat,x
                beq mt_repeatdone2
              .ENDIF

        ;Tick 0

mt_tick0:
              .IF (NOEFFECTS = 0)
;dengland
                ldy mt_chnnewfx,x               ;Setup tick 0 FX jumps
;---
		lda mt_tick0jumptbl,y
                sta mt_tick0jump1+1
                sta mt_tick0jump2+1
              .ENDIF

        ;Sequencer advance

mt_checknewpatt:
                lda mt_chnpattptr,x             ;Fetch next pattern?
                bne mt_nonewpatt
mt_sequencer:
;dengland
;		ldy mt_chnsongnum,y
		ldy mt_chnsongnum,x
;--                
                lda mt_songtbllo,y              ;Get address of sequence
                sta <mt_temp1
                lda mt_songtblhi,y
                sta <mt_temp2
;dengland
;		ldy mt_chnsongptr,y
		ldy mt_chnsongptr,x
;---
                lda (mt_temp1),y                ;Get pattern from sequence
                cmp #LOOPSONG                   ;Check for loop
                bcc mt_noloop
                iny
                lda (mt_temp1),y
                tay
                lda (mt_temp1),y
mt_noloop:
              .IF (NOTRANS = 0)
                cmp #TRANSDOWN                  ;Check for transpose
                bcc mt_notrans
                sbc #TRANS
                sta mt_chntrans,x
                iny
                lda (mt_temp1),y
              .ENDIF
mt_notrans:
              .IF (NOREPEAT = 0)
                cmp #REPEAT                     ;Check for repeat
                bcs mt_repeat
              .ENDIF
                sta mt_chnpattnum,x             ;Store pattern number
mt_repeatdone2:
                iny
                tya
                sta mt_chnsongptr,x             ;Store songposition

        ;New note start

mt_nonewpatt:
;dengland
;		ldy mt_chninstr,y
                ldy mt_chninstr,x
;---
		.IF (FIXEDPARAMS = 0)
                lda mt_insgatetimer-1,y
                sta mt_chngatetimer,x
              .ENDIF
                lda mt_chnnewnote,x             ;Test new note init flag
                beq mt_nonewnoteinit
mt_newnoteinit:
                sec
                sbc #NOTE
                sta mt_chnnote,x
                lda #$00
              .IF (NOEFFECTS = 0)
              .IF ((NOTONEPORTA = 0) || (NOPORTAMENTO = 0) || (NOVIB = 0))
                sta mt_chnfx,x                  ;Reset effect
              .ENDIF
              .ENDIF
                sta mt_chnnewnote,x             ;Reset newnote action
              .IF (NOINSTRVIB = 0)
                lda mt_insvibdelay-1,y          ;Load instrument vibrato
                sta mt_chnvibdelay,x
              .IF (NOEFFECTS = 0)
                lda mt_insvibparam-1,y
                sta mt_chnparam,x
              .ENDIF
              .ENDIF
              .IF (NOTONEPORTA = 0)
                lda mt_chnnewfx,x               ;If toneportamento, skip
                cmp #TONEPORTA                  ;most of note init
                beq mt_nonewnoteinit
              .ENDIF

              .IF (FIXEDPARAMS = 0)
                lda mt_insfirstwave-1,y         ;Load first frame waveform
              .IF (NOFIRSTWAVECMD = 0)
                beq mt_skipwave
                cmp #$fe
                bcs mt_skipwave2                ;Skip waveform but load gate
              .ENDIF
              .ELSE
                lda #FIRSTWAVEPARAM
              .ENDIF
                sta mt_chnwave,x
              .IF ((NUMLEGATOINSTR > 0) || (NOFIRSTWAVECMD = 0))
                lda #$ff
mt_skipwave2:
                sta mt_chngate,x                ;Reset gateflag
              .ELSE
                inc mt_chngate,x
              .ENDIF
mt_skipwave:   

              .IF (NOPULSE = 0)
                lda mt_inspulseptr-1,y          ;Load pulseptr (if nonzero)
                beq mt_skippulse
                sta mt_chnpulseptr,x
              .IF (NOPULSEMOD = 0)
                lda #$00                        ;Reset pulse step duration
                sta mt_chnpulsetime,x
              .ENDIF
              .ENDIF
mt_skippulse:
              .IF (NOFILTER = 0)
                lda mt_insfiltptr-1,y           ;Load filtptr (if nonzero)
                beq mt_skipfilt
                sta mt_filtstep+1
              .IF (NOFILTERMOD = 0)
                lda #$00
                sta mt_filttime+1
              .ENDIF
              .ENDIF
mt_skipfilt:

                lda mt_inswaveptr-1,y           ;Load waveptr
                sta mt_chnwaveptr,x

                lda mt_inssr-1,y                ;Load Sustain/Release
              .IF (BUFFEREDWRITES = 0)
                sta SIDBASE+$06,x
              .ELSE
              .IF (GHOSTREGS = 0)
                sta mt_chnsr,x
              .ELSE
                sta <ghostsr,x
              .ENDIF
              .ENDIF
                lda mt_insad-1,y                ;Load Attack/Decay
              .IF (BUFFEREDWRITES = 0)
                sta SIDBASE+$05,x
              .ELSE
              .IF (GHOSTREGS = 0)
                sta mt_chnad,x
              .ELSE
                sta <ghostad,x
              .ENDIF
              .ENDIF

              .IF (NOEFFECTS = 0)
                lda mt_chnnewparam,x            ;Execute tick 0 FX after
mt_tick0jump1:                                  ;newnote init
                jsr mt_tick0_0
              .ENDIF
              .IF (BUFFEREDWRITES = 0)
                jmp mt_loadregswaveonly
              .ELSE
                jmp mt_loadregs
              .ENDIF

              .IF (NOWAVECMD = 0)
mt_wavecmd:
                jmp mt_execwavecmd
              .ENDIF

        ;Tick 0 effect execution

mt_nonewnoteinit:
              .IF (NOEFFECTS = 0)
                lda mt_chnnewparam,x            ;No new note init: exec tick 0
mt_tick0jump2:
                jsr mt_tick0_0                  ;FX, and wavetable afterwards
              .ENDIF

        ;Wavetable execution

mt_waveexec:
;dengland
;		ldy mt_chnwaveptr,y
		ldy mt_chnwaveptr,x
;---
                beq mt_wavedone
                lda mt_wavetbl-1,y
              .IF (NOWAVEDELAY = 0)
                cmp #$10                        ;0-15 used as delay
                bcs mt_nowavedelay              ;+ no wave change
                cmp mt_chnwavetime,x
                beq mt_nowavechange
                inc mt_chnwavetime,x
                bne mt_wavedone
mt_nowavedelay:
                sbc #$10
              .ELSE
                beq mt_nowavechange
              .ENDIF
              .IF (NOWAVECMD = 0)
                cmp #$e0
                bcs mt_nowavechange
              .ENDIF
                sta mt_chnwave,x
mt_nowavechange:
                lda mt_wavetbl,y
                cmp #LOOPWAVE                  ;Check for wavetable jump
                iny
                tya
                bcc mt_nowavejump
              .IF (NOWAVECMD <> 0)
                clc
              .ENDIF
                lda mt_notetbl-1,y
mt_nowavejump:
                sta mt_chnwaveptr,x
              .IF (NOWAVEDELAY = 0)
                lda #$00
                sta mt_chnwavetime,x
              .ENDIF

              .IF (NOWAVECMD = 0)
                lda mt_wavetbl-2,y
                cmp #$e0
                bcs mt_wavecmd
              .ENDIF

                lda mt_notetbl-2,y

              .IF ((NOTONEPORTA = 0) || (NOPORTAMENTO = 0) || (NOVIB = 0))
                bne mt_wavefreq                 ;No frequency-change?

        ;No frequency-change / continuous effect execution

mt_wavedone:
              .IF (REALTIMEOPTIMIZATION <> 0)
                lda mt_chncounter,x             ;No continuous effects on tick0
              .IF (PULSEOPTIMIZATION <> 0)
                beq mt_gatetimer
              .ELSE
                beq mt_done
              .ENDIF
              .ENDIF
              .IF (NOEFFECTS = 0)
;dengland
                ldy mt_chnfx,x
;---		
              .IF (NOWAVECMD = 0)
              .IF (.DEFINED(mt_effectnum))
                sty mt_effectnum+1
              .ENDIF
              .ENDIF
                lda mt_effectjumptbl,y
                sta mt_effectjump+1
;dengland
                ldy mt_chnparam,x
;---		
              .ELSE
;dengland
;		ldy mt_chninstr,y
		ldy mt_chninstr,x
;---
                lda mt_insvibparam-1,y
                tay
              .ENDIF
mt_setspeedparam:
              .IF (NOCALCULATEDSPEED <> 0)
                lda mt_speedrighttbl-1,y
                sta <mt_temp1
              .ELSE
              .IF (NONORMALSPEED = 0)
                lda mt_speedlefttbl-1,y
                bmi mt_calculatedspeed
mt_normalspeed:
                sta <mt_temp2
                lda mt_speedrighttbl-1,y
                sta <mt_temp1
                jmp mt_effectjump
              .ELSE
              .IF (NOZEROSPEED = 0)
                bne mt_calculatedspeed
mt_zerospeed:
                sty <mt_temp1
                sty <mt_temp2
                beq mt_effectjump
              .ENDIF
              .ENDIF
mt_calculatedspeed:
                lda mt_speedrighttbl-1,y
                sta mt_cscount+1
                sty mt_csresty+1
;dengland
                ldy mt_chnlastnote,x
;---		
                lda mt_freqtbllo+1-FIRSTNOTE,y
                sec
                sbc mt_freqtbllo-FIRSTNOTE,y
                sta <mt_temp1
                lda mt_freqtblhi+1-FIRSTNOTE,y
                sbc mt_freqtblhi-FIRSTNOTE,y
mt_cscount:     ldy #$00
                beq mt_csresty
mt_csloop:      lsr
                ror <mt_temp1
                dey
                bne mt_csloop
mt_csresty:     ldy #$00
                sta <mt_temp2
              .ENDIF
mt_effectjump:
                jmp mt_effect_0
              .ELSE
                beq mt_wavedone
              .ENDIF

        ;Setting note frequency

mt_wavefreq:
                bpl mt_wavenoteabs
                adc mt_chnnote,x
                and #$7f
mt_wavenoteabs:
              .IF (NOCALCULATEDSPEED = 0)
                sta mt_chnlastnote,x
              .ENDIF
                tay
mt_wavenote:
              .IF (NOVIB = 0)
                lda #$00                        ;Reset vibrato phase
                sta mt_chnvibtime,x
              .ENDIF
                lda mt_freqtbllo-FIRSTNOTE,y
              .IF (GHOSTREGS = 0)
                sta mt_chnfreqlo,x
                lda mt_freqtblhi-FIRSTNOTE,y
mt_storefreqhi:
                sta mt_chnfreqhi,x
              .ELSE
                sta <ghostfreqlo,x
                lda mt_freqtblhi-FIRSTNOTE,y
mt_storefreqhi:
                sta <ghostfreqhi,x
              .ENDIF

        ;Check for new note fetch

              .IF ((NOTONEPORTA <> 0) && (NOPORTAMENTO <> 0) && (NOVIB <> 0))
mt_wavedone:
              .ENDIF
mt_done:
              .IF (PULSEOPTIMIZATION <> 0)
                lda mt_chncounter,x             ;Check for gateoff timer
mt_gatetimer:
              .IF (FIXEDPARAMS = 0)
                cmp mt_chngatetimer,x
              .ELSE
                cmp #GATETIMERPARAM
              .ENDIF

                beq mt_getnewnote               ;Fetch new notes if equal
              .ENDIF

        ;Pulse execution
              .IF (NOPULSE = 0)
mt_pulseexec:
;dengland
;		ldy mt_chnpulseptr,y            ;See if pulse stopped
		ldy mt_chnpulseptr,x            ;See if pulse stopped
;---
                beq mt_pulseskip
              .IF (PULSEOPTIMIZATION <> 0)
                ora mt_chnpattptr,x             ;Skip when sequencer executed
                beq mt_pulseskip
              .ENDIF
              .IF (NOPULSEMOD = 0)
                lda mt_chnpulsetime,x           ;Pulse step counter time left?
                bne mt_pulsemod
              .ENDIF
mt_newpulsestep:
                lda mt_pulsetimetbl-1,y         ;Set pulse, or new modulation
              .IF (NOPULSEMOD = 0)
                bpl mt_newpulsemod              ;step?
              .ENDIF
mt_setpulse:
              .IF (SIMPLEPULSE = 0)
              .IF (GHOSTREGS = 0)
                sta mt_chnpulsehi,x             ;Highbyte
              .ELSE
                sta <ghostpulsehi,x
              .ENDIF
              .ENDIF
                lda mt_pulsespdtbl-1,y          ;Lowbyte
              .IF (GHOSTREGS = 0)
                sta mt_chnpulselo,x
              .ELSE
                sta <ghostpulselo,x
              .IF (SIMPLEPULSE <> 0)
                sta <ghostpulsehi,x
              .ENDIF
              .ENDIF
              .IF (NOPULSEMOD = 0)
                jmp mt_nextpulsestep
mt_newpulsemod:
                sta mt_chnpulsetime,x
mt_pulsemod:
              .IF (SIMPLEPULSE = 0)
                lda mt_pulsespdtbl-1,y          ;Take pulse speed
                clc
                bpl mt_pulseup
              .IF (GHOSTREGS = 0)
                dec mt_chnpulsehi,x
mt_pulseup:
                adc mt_chnpulselo,x             ;Add pulse lowbyte
                sta mt_chnpulselo,x
                bcc mt_pulsenotover
                inc mt_chnpulsehi,x
              .ELSE
                dec <ghostpulsehi,x
mt_pulseup:
                adc <ghostpulselo,x             ;Add pulse lowbyte
                sta <ghostpulselo,x
                bcc mt_pulsenotover
                inc <ghostpulsehi,x
              .ENDIF
mt_pulsenotover:
              .ELSE
              .IF (GHOSTREGS = 0)
                lda mt_chnpulselo,x
                clc
                adc mt_pulsespdtbl-1,y
                adc #$00
                sta mt_chnpulselo,x
              .ELSE
                lda <ghostpulselo,x
                clc
                adc mt_pulsespdtbl-1,y
                adc #$00
                sta <ghostpulselo,x
                sta <ghostpulsehi,x
              .ENDIF
              .ENDIF
                dec mt_chnpulsetime,x
                bne mt_pulsedone2
              .ENDIF

mt_nextpulsestep:
                lda mt_pulsetimetbl,y           ;Jump in pulsetable?
                cmp #LOOPPULSE
                iny
                tya
                bcc mt_nopulsejump
                lda mt_pulsespdtbl-1,y          ;Take jump point
mt_nopulsejump:
                sta mt_chnpulseptr,x
mt_pulsedone:
              .IF (BUFFEREDWRITES = 0)
                lda mt_chnpulselo,x
              .ENDIF
mt_pulsedone2:
              .IF (BUFFEREDWRITES = 0)
                sta SIDBASE+$02,x
              .IF (SIMPLEPULSE = 0)
                lda mt_chnpulsehi,x
              .ENDIF
                sta SIDBASE+$03,x
              .ENDIF
mt_pulseskip:
              .ENDIF

              .IF (PULSEOPTIMIZATION = 0)
                lda mt_chncounter,x             ;Check for gateoff timer
mt_gatetimer:
              .IF (FIXEDPARAMS = 0)
                cmp mt_chngatetimer,x
              .ELSE
                cmp #GATETIMERPARAM
              .ENDIF

                beq mt_getnewnote               ;Fetch new notes if equal
              .ENDIF

                jmp mt_loadregs

        ;New note fetch

mt_getnewnote:
;dengland                
;		ldy mt_chnpattnum,y
		ldy mt_chnpattnum,x
;---
                lda mt_patttbllo,y
                sta <mt_temp1
                lda mt_patttblhi,y
                sta <mt_temp2
;dengland
;		ldy mt_chnpattptr,y
		ldy mt_chnpattptr,x
;---
                lda (mt_temp1),y
                cmp #FX
                bcc mt_instr                    ;Instr. change
              .IF (NOEFFECTS = 0)
                cmp #NOTE
                bcc mt_fx                       ;FX
              .ENDIF
                cmp #FIRSTPACKEDREST
                bcc mt_note                     ;Note only

        ;Packed rest handling

mt_packedrest:
                lda mt_chnpackedrest,x
                bne mt_packedrestnonew
                lda (mt_temp1),y
mt_packedrestnonew:
                adc #$00
                sta mt_chnpackedrest,x
                beq mt_rest
                bne mt_loadregs

        ;Instrument change

mt_instr:
                sta mt_chninstr,x               ;Instrument change, followed
                iny
                lda (mt_temp1),y                ;by either FX or note

              .IF (NOEFFECTS = 0)
                cmp #NOTE
                bcs mt_note

        ;Effect change

mt_fx:
                cmp #FXONLY                     ;Note follows?
                and #$0f
                sta mt_chnnewfx,x
                beq mt_fx_noparam               ;Effect 0 - no param.
                iny
                lda (mt_temp1),y
                sta mt_chnnewparam,x
mt_fx_noparam:
                bcs mt_rest
mt_fx_getnote:
                iny
                lda (mt_temp1),y
              .ENDIF

        ;Note handling

mt_note:
                cmp #REST                   ;Rest or gateoff/on?
              .IF (NOGATE = 0)
                bcc mt_normalnote
              .ENDIF
                beq mt_rest
mt_gate:
              .IF (NOGATE = 0)
                ora #$f0
                bne mt_setgate
              .ENDIF

        ;Prepare for note start; perform hardrestart

mt_normalnote:
              .IF (NOTRANS = 0)
                adc mt_chntrans,x
              .ENDIF
                sta mt_chnnewnote,x
              .IF (NOTONEPORTA = 0)
                lda mt_chnnewfx,x           ;If toneportamento, no gateoff
                cmp #TONEPORTA
                beq mt_rest
              .ENDIF
              .IF (((NUMHRINSTR > 0) && (NUMNOHRINSTR > 0)) || (NUMLEGATOINSTR > 0))
                lda mt_chninstr,x
                cmp #FIRSTNOHRINSTR         ;Instrument order:
              .IF (NUMLEGATOINSTR > 0)
                bcs mt_nohr_legato          ;With HR - no HR - legato
              .ELSE
                bcs mt_skiphr
              .ENDIF
              .ENDIF
              .IF (NUMHRINSTR > 0)
                lda #SRPARAM                ;Hard restart 
              .IF (BUFFEREDWRITES = 0)
                sta SIDBASE+$06,x
              .ELSE
              .IF (GHOSTREGS = 0)
                sta mt_chnsr,x
              .ELSE
                sta <ghostsr,x
              .ENDIF
              .ENDIF
                lda #ADPARAM
              .IF (BUFFEREDWRITES = 0)
                sta SIDBASE+$05,x
              .ELSE
              .IF (GHOSTREGS = 0)
                sta mt_chnad,x
              .ELSE
                sta <ghostad,x
              .ENDIF
              .ENDIF
            
              .ENDIF
mt_skiphr:
                lda #$fe
mt_setgate:
                sta mt_chngate,x

        ;Check for end of pattern

mt_rest:
                iny
                lda (mt_temp1),y
                beq mt_endpatt
                tya
mt_endpatt:
                sta mt_chnpattptr,x

        ;Load voice registers

mt_loadregs:
              .IF (BUFFEREDWRITES = 0)
                lda mt_chnfreqlo,x
                sta SIDBASE+$00,x
                lda mt_chnfreqhi,x
                sta SIDBASE+$01,x
mt_loadregswaveonly:
                lda mt_chnwave,x
                and mt_chngate,x
                sta SIDBASE+$04,x
              .ELSE
              .IF (SOUNDSUPPORT <> 0)
;dengland
                ldy mt_chnsfx,x
;---		
                bne mt_sfxexec
              .ENDIF
              .IF (GHOSTREGS = 0)
                lda mt_chnad,x
                sta SIDBASE+$05,x
                lda mt_chnsr,x
                sta SIDBASE+$06,x
                lda mt_chnpulselo,x
              .IF (SIMPLEPULSE = 0)
                sta SIDBASE+$02,x
                lda mt_chnpulsehi,x
                sta SIDBASE+$03,x
              .ELSE
                sta SIDBASE+$02,x
                sta SIDBASE+$03,x
              .ENDIF
mt_loadregswavefreq:
                lda mt_chnfreqlo,x
                sta SIDBASE+$00,x
                lda mt_chnfreqhi,x
                sta SIDBASE+$01,x
mt_loadregswaveonly:
                lda mt_chnwave,x
                and mt_chngate,x
                sta SIDBASE+$04,x
              .ELSE
mt_loadregswaveonly:
                lda mt_chnwave,x
                and mt_chngate,x
                sta <ghostwave,x
              .ENDIF
              .ENDIF
                rts

              .IF (NUMLEGATOINSTR > 0)
mt_nohr_legato:
                cmp #FIRSTLEGATOINSTR
                bcc mt_skiphr
                bcs mt_rest
              .ENDIF

        ;Sound FX code

              .IF (SOUNDSUPPORT <> 0)
              .IF (GHOSTREGS = 0)

        ;Sound FX code without ghostregs

mt_sfxexec:     lda mt_chnsfxlo,x
                sta <mt_temp1
                lda mt_chnsfxhi,x
                sta <mt_temp2
                lda #$fe
                sta mt_chngate,x
                lda #$00
                sta mt_chnwaveptr,x
                inc mt_chnsfx,x
                cpy #$02
                beq mt_sfxexec_frame0
                bcs mt_sfxexec_framen
                sta SIDBASE+$06,x                ;Hardrestart before sound FX
                sta SIDBASE+$05,x                ;begins
                bcc mt_loadregswavefreq
mt_sfxexec_frame0:
                tay
                lda (mt_temp1),y           ;Load ADSR
                sta SIDBASE+$05,x
                iny
                lda (mt_temp1),y
                sta SIDBASE+$06,x
                iny
                lda (mt_temp1),y           ;Load pulse
                sta SIDBASE+$02,x
                sta SIDBASE+$03,x
                lda #$09                   ;Testbit
mt_sfxexec_wavechg:
                sta mt_chnwave,x
                sta SIDBASE+$04,x
mt_sfxexec_done:
                rts
mt_sfxexec_framen:
                lda (mt_temp1),y
                bne mt_sfxexec_noend
mt_sfxexec_end:
                sta mt_chnsfx,x
                beq mt_sfxexec_wavechg
mt_sfxexec_noend:
                tay
                lda mt_freqtbllo-$80,y        ;Get frequency
                sta SIDBASE+$00,x
                lda mt_freqtblhi-$80,y
                sta SIDBASE+$01,x
;dengland
                ldy mt_chnsfx,x
;---		
                lda (mt_temp1),y              ;Then take a look at the next
                beq mt_sfxexec_done           ;byte
                cmp #$82                      ;Is it a waveform or a note?
                bcs mt_sfxexec_done
                inc mt_chnsfx,x
                bcc mt_sfxexec_wavechg

              .ELSE

        ;Sound FX code with ghostregs

mt_sfxexec:
                lda mt_chnsfxlo,x
                sta <mt_temp1
                lda mt_chnsfxhi,x
                sta <mt_temp2
                lda #$fe
                sta mt_chngate,x
                lda #$00
                sta mt_chnwaveptr,x
                inc mt_chnsfx,x
                cpy #$02
                bcc mt_sfxexec_fr1                  ;Hardrestart frame?
                beq mt_sfxexec_fr2                  ;First or nth frame?
mt_sfxexec_fr3:
                lda (mt_temp1),y
                bne mt_sfxexec_noend
mt_sfxexec_end:
                sta mt_chnsfx,x
                beq mt_sfxexec_wavechg
mt_sfxexec_noend:
                tay
                lda mt_freqtbllo-$80,y        ;Get frequency
                sta <ghostfreqlo,x
                lda mt_freqtblhi-$80,y
                sta <ghostfreqhi,x
;dengland
                ldy mt_chnsfx,x
;---		
                lda (mt_temp1),y              ;Then take a look at the next
                beq mt_sfxexec_done           ;byte
                cmp #$82                      ;Is it a waveform or a note?
                bcs mt_sfxexec_done
                inc mt_chnsfx,x
mt_sfxexec_wavechg:
                sta mt_chnwave,x
                sta <ghostwave,x
mt_sfxexec_done:
                ldy #$00
                lda (mt_temp1),y             ;Load ADSR
                sta <ghostad,x
                iny
                lda (mt_temp1),y
                sta <ghostsr,x
                iny
                lda (mt_temp1),y             ;Load pulse
                sta <ghostpulselo,x
                sta <ghostpulsehi,x
                rts

mt_sfxexec_fr1:
                sta <ghostad,x               ;Hardrestart before sound FX
                sta <ghostsr,x               ;begins
                bcc mt_loadregswaveonly

mt_sfxexec_fr2:
                lda #$09
                bne mt_sfxexec_wavechg

              .ENDIF
              .ENDIF

        ;Wavetable command exec

              .IF (NOWAVECMD = 0)
mt_execwavecmd:
                and #$0f
                sta <mt_temp1
                lda mt_notetbl-2,y
                sta <mt_temp2
                ldy <mt_temp1
              .IF ((NOTONEPORTA = 0) || (NOPORTAMENTO = 0) || (NOVIB = 0))
                cpy #$05
                bcs mt_execwavetick0
mt_execwavetickn:
              .IF (.DEFINED(mt_effectnum))
                sty mt_effectnum+1
              .ENDIF
                lda mt_effectjumptbl,y
                sta mt_effectjump+1
                ldy <mt_temp2
                jmp mt_setspeedparam
              .ENDIF
mt_execwavetick0:
                lda mt_tick0jumptbl,y
                sta mt_execwavetick0jump+1
                lda <mt_temp2
mt_execwavetick0jump:
                jsr mt_tick0_0
                jmp mt_done
              .ENDIF

              .IF (NOEFFECTS = 0)
              .IF (!.DEFINED(mt_tick0jumptbl))
mt_tick0jumptbl:
                .BYTE mt_tick0_0 .mod 256
                .BYTE mt_tick0_12 .mod 256
                .BYTE mt_tick0_12 .mod 256
                .BYTE mt_tick0_34 .mod 256
                .BYTE mt_tick0_34 .mod 256
                .BYTE mt_tick0_5 .mod 256
                .BYTE mt_tick0_6 .mod 256
                .BYTE mt_tick0_7 .mod 256
                .BYTE mt_tick0_8 .mod 256
                .BYTE mt_tick0_9 .mod 256
                .BYTE mt_tick0_a .mod 256
                .BYTE mt_tick0_b .mod 256
                .BYTE mt_tick0_c .mod 256
                .BYTE mt_tick0_d .mod 256
                .BYTE mt_tick0_e .mod 256
                .BYTE mt_tick0_f .mod 256
              .ENDIF
              .ENDIF

              .IF (NOEFFECTS = 0)
              .IF (!.DEFINED(mt_effectjumptbl))
              .IF ((NOTONEPORTA = 0) || (NOPORTAMENTO = 0) || (NOVIB = 0))
mt_effectjumptbl:
                .BYTE mt_effect_0 .mod 256
                .BYTE mt_effect_12 .mod 256
                .BYTE mt_effect_12 .mod 256
                .BYTE mt_effect_3 .mod 256
                .BYTE mt_effect_4 .mod 256
              .ENDIF
              .ENDIF
              .ENDIF

              .IF (!.DEFINED(mt_funktempotbl))
              .IF (NOFUNKTEMPO = 0)
mt_funktempotbl:
                .BYTE 8,5
              .ENDIF
              .ENDIF

              .IF ((NOEFFECTS = 0) || (NOWAVEDELAY = 0) || (NOTRANS = 0) || (NOREPEAT = 0) || (FIXEDPARAMS = 0) || (GHOSTREGS <> 0) || (BUFFEREDWRITES <> 0) || (NOCALCULATEDSPEED = 0))

              ;Normal channel variables

mt_chnsongptr:
                .BYTE 0
mt_chntrans:
                .BYTE 0
mt_chnrepeat:
                .BYTE 0
mt_chnpattptr:
                .BYTE 0
mt_chnpackedrest:
                .BYTE 0
mt_chnnewfx:
                .BYTE 0
mt_chnnewparam:
                .BYTE 0

              .IF (NUMCHANNELS > 1)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF
              .IF (NUMCHANNELS > 2)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF

mt_chnfx:
                .BYTE 0
mt_chnparam:
                .BYTE 0
mt_chnnewnote:
                .BYTE 0
mt_chnwaveptr:
                .BYTE 0
mt_chnwave:
                .BYTE 0
mt_chnpulseptr:
                .BYTE 0
mt_chnpulsetime:
                .BYTE 0

              .IF (NUMCHANNELS > 1)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF
              .IF (NUMCHANNELS > 2)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF

mt_chnsongnum:
                .BYTE 0
mt_chnpattnum:
                .BYTE 0
mt_chntempo:
                .BYTE 0
mt_chncounter:
                .BYTE 0
mt_chnnote:
                .BYTE 0
mt_chninstr:
                .BYTE 1
mt_chngate:
                .BYTE $fe

              .IF (NUMCHANNELS > 1)
                .BYTE 1,0,0,0,0,1,$fe
              .ENDIF
              .IF (NUMCHANNELS > 2)
                .BYTE 2,0,0,0,0,1,$fe
              .ENDIF

              .IF ((GHOSTREGS = 0) || (NOCALCULATEDSPEED = 0))

mt_chnvibtime:
                .BYTE 0
mt_chnvibdelay:
                .BYTE 0
mt_chnwavetime:
                .BYTE 0
mt_chnfreqlo:
                .BYTE 0
mt_chnfreqhi:
                .BYTE 0
mt_chnpulselo:
                .BYTE 0
mt_chnpulsehi:
                .BYTE 0

              .IF (NUMCHANNELS > 1)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF
              .IF (NUMCHANNELS > 2)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF

              .IF ((BUFFEREDWRITES <> 0) || (FIXEDPARAMS = 0) || (NOCALCULATEDSPEED = 0))
mt_chnad:
                .BYTE 0
mt_chnsr:
                .BYTE 0
mt_chnsfx:
                .BYTE 0
mt_chnsfxlo:
                .BYTE 0
mt_chnsfxhi:
                .BYTE 0
mt_chngatetimer:
                .BYTE 0
mt_chnlastnote:
                .BYTE 0

              .IF (NUMCHANNELS > 1)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF
              .IF (NUMCHANNELS > 2)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF

              .ENDIF

              .ELSE

mt_chnvibtime:
                .BYTE 0
mt_chnvibdelay:
                .BYTE 0
mt_chnwavetime:
                .BYTE 0
mt_chnsfx:
                .BYTE 0
mt_chnsfxlo:
                .BYTE 0
mt_chnsfxhi:
                .BYTE 0
mt_chngatetimer:
                .BYTE 0

              .IF (NUMCHANNELS > 1)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF
              .IF (NUMCHANNELS > 2)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF

              .ENDIF

              .ELSE

              ;Optimized channel variables

mt_chnsongptr:
                .BYTE 0
mt_chnpattptr:
                .BYTE 0
mt_chnpackedrest:
                .BYTE 0
mt_chnnewnote:
                .BYTE 0
mt_chnwaveptr:
                .BYTE 0
mt_chnwave:
                .BYTE 0
mt_chnpulseptr:
                .BYTE 0

              .IF (NUMCHANNELS > 1)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF
              .IF (NUMCHANNELS > 2)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF

mt_chnpulsetime:
                .BYTE 0
mt_chnpulselo:
                .BYTE 0
mt_chnpulsehi:
                .BYTE 0
mt_chnvibtime:
                .BYTE 0
mt_chnvibdelay:
                .BYTE 0
mt_chnfreqlo:
                .BYTE 0
mt_chnfreqhi:
                .BYTE 0

              .IF (NUMCHANNELS > 1)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF
              .IF (NUMCHANNELS > 2)
                .BYTE 0,0,0,0,0,0,0
              .ENDIF

mt_chnsongnum:
                .BYTE 0
mt_chnpattnum:
                .BYTE 0
mt_chntempo:
                .BYTE 0
mt_chncounter:
                .BYTE 0
mt_chnnote:
                .BYTE 0
mt_chninstr:
                .BYTE 1
mt_chngate:
                .BYTE $fe

              .IF (NUMCHANNELS > 1)
                .BYTE 1,0,0,0,0,1,$fe
              .ENDIF
              .IF (NUMCHANNELS > 2)
                .BYTE 2,0,0,0,0,1,$fe
              .ENDIF

              .ENDIF

              .IF ((GHOSTREGS <> 0) && (ZPGHOSTREGS = 0))
ghostregs:    .BYTE 0,0,0,0,0,0,0, 0,0,0,0,0,0,0, 0,0,0,0,0,0,0, 0,0,0,0
ghostfreqlo     = ghostregs+0
ghostfreqhi     = ghostregs+1
ghostpulselo    = ghostregs+2
ghostpulsehi    = ghostregs+3
ghostwave       = ghostregs+4
ghostad         = ghostregs+5
ghostsr         = ghostregs+6
ghostfiltcutlow = ghostregs+21
ghostfiltcutoff = ghostregs+22
ghostfiltctrl   = ghostregs+23
ghostfilttype   = ghostregs+24
              .ENDIF

        ;Songdata & frequencytable will be inserted by the relocator here

mt_freqtbllo:
                .BYTE $17,$27,$39,$4B,$5F,$74,$8A,$A1,$BA,$D4,$F0,$0E,$2D,$4E,$71,$96
                .BYTE $BE,$E8,$14,$43,$74,$A9,$E1,$1C,$5A,$9C,$E2,$2D,$7C,$CF,$28,$85
                .BYTE $E8,$52,$C1,$37,$B4,$39,$C5,$5A,$F7,$9E,$4F,$0A,$D1,$A3,$82,$6E
                .BYTE $68,$71,$8A,$B3,$EE,$3C,$9E,$15,$A2,$46,$04,$DC,$D0,$E2,$14,$67
                .BYTE $DD,$79,$3C,$29,$44,$8D,$08,$B8,$A1,$C5,$28,$CD,$BA,$F1,$78,$53
                .BYTE $87,$1A,$10,$71,$42,$89,$4F,$9B,$74,$E2,$F0,$A6,$0E,$33,$20,$FF
mt_freqtblhi:
                .BYTE $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02
                .BYTE $02,$02,$03,$03,$03,$03,$03,$04,$04,$04,$04,$05,$05,$05,$06,$06
                .BYTE $06,$07,$07,$08,$08,$09,$09,$0A,$0A,$0B,$0C,$0D,$0D,$0E,$0F,$10
                .BYTE $11,$12,$13,$14,$15,$17,$18,$1A,$1B,$1D,$1F,$20,$22,$24,$27,$29
                .BYTE $2B,$2E,$31,$34,$37,$3A,$3E,$41,$45,$49,$4E,$52,$57,$5C,$62,$68
                .BYTE $6E,$75,$7C,$83,$8B,$93,$9C,$A5,$AF,$B9,$C4,$D0,$DD,$EA,$F8,$FF
mt_songtbllo:
                .BYTE mt_song0 .mod 256
                .BYTE mt_song1 .mod 256
                .BYTE mt_song2 .mod 256
                .BYTE mt_song3 .mod 256
                .BYTE mt_song4 .mod 256
                .BYTE mt_song5 .mod 256
                .BYTE mt_song6 .mod 256
                .BYTE mt_song7 .mod 256
                .BYTE mt_song8 .mod 256
                .BYTE mt_song9 .mod 256
                .BYTE mt_song10 .mod 256
                .BYTE mt_song11 .mod 256
                .BYTE mt_song12 .mod 256
                .BYTE mt_song13 .mod 256
                .BYTE mt_song14 .mod 256
                .BYTE mt_song15 .mod 256
                .BYTE mt_song16 .mod 256
                .BYTE mt_song17 .mod 256
                .BYTE mt_song18 .mod 256
                .BYTE mt_song19 .mod 256
                .BYTE mt_song20 .mod 256
                .BYTE mt_song21 .mod 256
                .BYTE mt_song22 .mod 256
                .BYTE mt_song23 .mod 256
                .BYTE mt_song24 .mod 256
                .BYTE mt_song25 .mod 256
                .BYTE mt_song26 .mod 256
                .BYTE mt_song27 .mod 256
                .BYTE mt_song28 .mod 256
                .BYTE mt_song29 .mod 256
                .BYTE mt_song30 .mod 256
                .BYTE mt_song31 .mod 256
                .BYTE mt_song32 .mod 256
                .BYTE mt_song33 .mod 256
                .BYTE mt_song34 .mod 256
                .BYTE mt_song35 .mod 256
                .BYTE mt_song36 .mod 256
                .BYTE mt_song37 .mod 256
                .BYTE mt_song38 .mod 256
                .BYTE mt_song39 .mod 256
                .BYTE mt_song40 .mod 256
                .BYTE mt_song41 .mod 256
                .BYTE mt_song42 .mod 256
                .BYTE mt_song43 .mod 256
                .BYTE mt_song44 .mod 256
                .BYTE mt_song45 .mod 256
                .BYTE mt_song46 .mod 256
                .BYTE mt_song47 .mod 256
mt_songtblhi:
                .BYTE mt_song0 / 256
                .BYTE mt_song1 / 256
                .BYTE mt_song2 / 256
                .BYTE mt_song3 / 256
                .BYTE mt_song4 / 256
                .BYTE mt_song5 / 256
                .BYTE mt_song6 / 256
                .BYTE mt_song7 / 256
                .BYTE mt_song8 / 256
                .BYTE mt_song9 / 256
                .BYTE mt_song10 / 256
                .BYTE mt_song11 / 256
                .BYTE mt_song12 / 256
                .BYTE mt_song13 / 256
                .BYTE mt_song14 / 256
                .BYTE mt_song15 / 256
                .BYTE mt_song16 / 256
                .BYTE mt_song17 / 256
                .BYTE mt_song18 / 256
                .BYTE mt_song19 / 256
                .BYTE mt_song20 / 256
                .BYTE mt_song21 / 256
                .BYTE mt_song22 / 256
                .BYTE mt_song23 / 256
                .BYTE mt_song24 / 256
                .BYTE mt_song25 / 256
                .BYTE mt_song26 / 256
                .BYTE mt_song27 / 256
                .BYTE mt_song28 / 256
                .BYTE mt_song29 / 256
                .BYTE mt_song30 / 256
                .BYTE mt_song31 / 256
                .BYTE mt_song32 / 256
                .BYTE mt_song33 / 256
                .BYTE mt_song34 / 256
                .BYTE mt_song35 / 256
                .BYTE mt_song36 / 256
                .BYTE mt_song37 / 256
                .BYTE mt_song38 / 256
                .BYTE mt_song39 / 256
                .BYTE mt_song40 / 256
                .BYTE mt_song41 / 256
                .BYTE mt_song42 / 256
                .BYTE mt_song43 / 256
                .BYTE mt_song44 / 256
                .BYTE mt_song45 / 256
                .BYTE mt_song46 / 256
                .BYTE mt_song47 / 256
mt_patttbllo:
                .BYTE mt_patt0 .mod 256
                .BYTE mt_patt1 .mod 256
                .BYTE mt_patt2 .mod 256
                .BYTE mt_patt3 .mod 256
                .BYTE mt_patt4 .mod 256
                .BYTE mt_patt5 .mod 256
                .BYTE mt_patt6 .mod 256
                .BYTE mt_patt7 .mod 256
                .BYTE mt_patt8 .mod 256
                .BYTE mt_patt9 .mod 256
                .BYTE mt_patt10 .mod 256
                .BYTE mt_patt11 .mod 256
                .BYTE mt_patt12 .mod 256
                .BYTE mt_patt13 .mod 256
                .BYTE mt_patt14 .mod 256
                .BYTE mt_patt15 .mod 256
                .BYTE mt_patt16 .mod 256
                .BYTE mt_patt17 .mod 256
                .BYTE mt_patt18 .mod 256
                .BYTE mt_patt19 .mod 256
                .BYTE mt_patt20 .mod 256
                .BYTE mt_patt21 .mod 256
                .BYTE mt_patt22 .mod 256
                .BYTE mt_patt23 .mod 256
                .BYTE mt_patt24 .mod 256
                .BYTE mt_patt25 .mod 256
                .BYTE mt_patt26 .mod 256
                .BYTE mt_patt27 .mod 256
                .BYTE mt_patt28 .mod 256
                .BYTE mt_patt29 .mod 256
                .BYTE mt_patt30 .mod 256
                .BYTE mt_patt31 .mod 256
                .BYTE mt_patt32 .mod 256
                .BYTE mt_patt33 .mod 256
                .BYTE mt_patt34 .mod 256
                .BYTE mt_patt35 .mod 256
                .BYTE mt_patt36 .mod 256
                .BYTE mt_patt37 .mod 256
                .BYTE mt_patt38 .mod 256
                .BYTE mt_patt39 .mod 256
                .BYTE mt_patt40 .mod 256
                .BYTE mt_patt41 .mod 256
                .BYTE mt_patt42 .mod 256
                .BYTE mt_patt43 .mod 256
                .BYTE mt_patt44 .mod 256
                .BYTE mt_patt45 .mod 256
mt_patttblhi:
                .BYTE mt_patt0 / 256
                .BYTE mt_patt1 / 256
                .BYTE mt_patt2 / 256
                .BYTE mt_patt3 / 256
                .BYTE mt_patt4 / 256
                .BYTE mt_patt5 / 256
                .BYTE mt_patt6 / 256
                .BYTE mt_patt7 / 256
                .BYTE mt_patt8 / 256
                .BYTE mt_patt9 / 256
                .BYTE mt_patt10 / 256
                .BYTE mt_patt11 / 256
                .BYTE mt_patt12 / 256
                .BYTE mt_patt13 / 256
                .BYTE mt_patt14 / 256
                .BYTE mt_patt15 / 256
                .BYTE mt_patt16 / 256
                .BYTE mt_patt17 / 256
                .BYTE mt_patt18 / 256
                .BYTE mt_patt19 / 256
                .BYTE mt_patt20 / 256
                .BYTE mt_patt21 / 256
                .BYTE mt_patt22 / 256
                .BYTE mt_patt23 / 256
                .BYTE mt_patt24 / 256
                .BYTE mt_patt25 / 256
                .BYTE mt_patt26 / 256
                .BYTE mt_patt27 / 256
                .BYTE mt_patt28 / 256
                .BYTE mt_patt29 / 256
                .BYTE mt_patt30 / 256
                .BYTE mt_patt31 / 256
                .BYTE mt_patt32 / 256
                .BYTE mt_patt33 / 256
                .BYTE mt_patt34 / 256
                .BYTE mt_patt35 / 256
                .BYTE mt_patt36 / 256
                .BYTE mt_patt37 / 256
                .BYTE mt_patt38 / 256
                .BYTE mt_patt39 / 256
                .BYTE mt_patt40 / 256
                .BYTE mt_patt41 / 256
                .BYTE mt_patt42 / 256
                .BYTE mt_patt43 / 256
                .BYTE mt_patt44 / 256
                .BYTE mt_patt45 / 256
mt_insad:
                .BYTE $2A,$04,$11,$0F,$00,$24,$0F,$01,$2F
mt_inssr:
                .BYTE $E3,$F6,$F3,$F7,$E4,$E3,$D0,$F1,$F4
mt_inswaveptr:
                .BYTE $01,$07,$0D,$11,$18,$1E,$24,$29,$2E
mt_inspulseptr:
                .BYTE $01,$03,$05,$00,$00,$05,$00,$00,$00
mt_insfiltptr:
                .BYTE $00,$00,$00,$00,$00,$01,$00,$00,$00
mt_insvibparam:
                .BYTE $01,$01,$05,$03,$00,$04,$00,$00,$00
mt_insvibdelay:
                .BYTE $00,$01,$00,$00,$00,$01,$00,$00,$00
mt_wavetbl:
                .BYTE $41
                .BYTE $41
                .BYTE $11
                .BYTE $11
                .BYTE $11
                .BYTE $FF
                .BYTE $41
                .BYTE $81
                .BYTE $90
                .BYTE $81
                .BYTE $10
                .BYTE $FF
                .BYTE $41
                .BYTE $11
                .BYTE $41
                .BYTE $FF
                .BYTE $41
                .BYTE $81
                .BYTE $11
                .BYTE $81
                .BYTE $91
                .BYTE $81
                .BYTE $FF
                .BYTE $21
                .BYTE $81
                .BYTE $81
                .BYTE $21
                .BYTE $80
                .BYTE $FF
                .BYTE $21
                .BYTE $41
                .BYTE $21
                .BYTE $41
                .BYTE $21
                .BYTE $FF
                .BYTE $81
                .BYTE $81
                .BYTE $80
                .BYTE $80
                .BYTE $FF
                .BYTE $41
                .BYTE $81
                .BYTE $81
                .BYTE $21
                .BYTE $FF
                .BYTE $41
                .BYTE $21
                .BYTE $11
                .BYTE $FF
mt_notetbl:
                .BYTE $80
                .BYTE $80
                .BYTE $E2
                .BYTE $E2
                .BYTE $80
                .BYTE $00
                .BYTE $EB
                .BYTE $98
                .BYTE $EB
                .BYTE $98
                .BYTE $80
                .BYTE $00
                .BYTE $80
                .BYTE $EB
                .BYTE $80
                .BYTE $0F
                .BYTE $A4
                .BYTE $EB
                .BYTE $80
                .BYTE $98
                .BYTE $98
                .BYTE $98
                .BYTE $00
                .BYTE $80
                .BYTE $80
                .BYTE $80
                .BYTE $80
                .BYTE $80
                .BYTE $00
                .BYTE $80
                .BYTE $85
                .BYTE $E6
                .BYTE $80
                .BYTE $80
                .BYTE $1F
                .BYTE $E2
                .BYTE $80
                .BYTE $84
                .BYTE $87
                .BYTE $00
                .BYTE $83
                .BYTE $80
                .BYTE $87
                .BYTE $80
                .BYTE $2A
                .BYTE $8C
                .BYTE $80
                .BYTE $8C
                .BYTE $2F
mt_pulsetimetbl:
                .BYTE $05
                .BYTE $FF
                .BYTE $0A
                .BYTE $FF
                .BYTE $50
                .BYTE $FF
mt_pulsespdtbl:
                .BYTE $0A
                .BYTE $01
                .BYTE $32
                .BYTE $03
                .BYTE $50
                .BYTE $05
mt_filttimetbl:
                .BYTE $90
                .BYTE $00
                .BYTE $20
                .BYTE $00
                .BYTE $20
                .BYTE $FF
                .BYTE $88
                .BYTE $FF
                .BYTE $A0
                .BYTE $03
                .BYTE $FF
mt_filtspdtbl:
                .BYTE $C1
                .BYTE $40
                .BYTE $10
                .BYTE $30
                .BYTE $10
                .BYTE $02
                .BYTE $C1
                .BYTE $02
                .BYTE $F1
                .BYTE $32
                .BYTE $0A
                .BYTE $00
mt_speedlefttbl:
                .BYTE $03
                .BYTE $04
                .BYTE $02
                .BYTE $20
                .BYTE $40
                .BYTE $00
                .BYTE $03
                .BYTE $00
mt_speedrighttbl:
                .BYTE $1F
                .BYTE $40
                .BYTE $20
                .BYTE $7F
                .BYTE $00
                .BYTE $50
                .BYTE $1B
mt_song0:
                .BYTE $00,$04,$05,$07,$09,$0D,$0B,$04,$04,$0F,$0F,$11,$11,$13,$04,$05
                .BYTE $07,$09,$15,$17,$04,$04,$0F,$0F,$11,$11,$FF,$00
mt_song1:
                .BYTE $01,$03,$06,$08,$0A,$0E,$0C,$03,$03,$10,$10,$12,$12,$14,$03,$06
                .BYTE $08,$0A,$16,$18,$03,$03,$10,$10,$12,$12,$FF,$00
mt_song2:
                .BYTE $02,$FF,$00
mt_song3:
                .BYTE $02,$FF,$00
mt_song4:
                .BYTE $02,$FF,$00
mt_song5:
                .BYTE $02,$FF,$00
mt_song6:
                .BYTE $19,$02,$FF,$01
mt_song7:
                .BYTE $02,$FF,$00
mt_song8:
                .BYTE $02,$FF,$00
mt_song9:
                .BYTE $1A,$02,$FF,$01
mt_song10:
                .BYTE $02,$FF,$00
mt_song11:
                .BYTE $02,$FF,$00
mt_song12:
                .BYTE $1B,$02,$FF,$01
mt_song13:
                .BYTE $02,$FF,$00
mt_song14:
                .BYTE $02,$FF,$00
mt_song15:
                .BYTE $1C,$02,$FF,$01
mt_song16:
                .BYTE $02,$FF,$00
mt_song17:
                .BYTE $02,$FF,$00
mt_song18:
                .BYTE $19,$02,$FF,$01
mt_song19:
                .BYTE $02,$FF,$00
mt_song20:
                .BYTE $02,$FF,$00
mt_song21:
                .BYTE $1D,$02,$FF,$01
mt_song22:
                .BYTE $02,$FF,$00
mt_song23:
                .BYTE $02,$FF,$00
mt_song24:
                .BYTE $1E,$02,$FF,$01
mt_song25:
                .BYTE $1F,$02,$FF,$01
mt_song26:
                .BYTE $02,$FF,$00
mt_song27:
                .BYTE $20,$02,$FF,$01
mt_song28:
                .BYTE $02,$FF,$00
mt_song29:
                .BYTE $02,$FF,$00
mt_song30:
                .BYTE $20,$02,$FF,$01
mt_song31:
                .BYTE $21,$02,$FF,$01
mt_song32:
                .BYTE $02,$FF,$00
mt_song33:
                .BYTE $22,$02,$FF,$01
mt_song34:
                .BYTE $02,$FF,$00
mt_song35:
                .BYTE $02,$FF,$00
mt_song36:
                .BYTE $22,$02,$FF,$01
mt_song37:
                .BYTE $23,$02,$FF,$01
mt_song38:
                .BYTE $02,$FF,$00
mt_song39:
                .BYTE $25,$27,$28,$2A,$FF,$00
mt_song40:
                .BYTE $24,$26,$29,$2B,$FF,$00
mt_song41:
                .BYTE $02,$FF,$00
mt_song42:
                .BYTE $25,$02,$FF,$01
mt_song43:
                .BYTE $24,$02,$FF,$01
mt_song44:
                .BYTE $02,$FF,$00
mt_song45:
                .BYTE $2C,$02,$FF,$01
mt_song46:
                .BYTE $2D,$02,$FF,$01
mt_song47:
                .BYTE $02,$FF,$00
mt_patt0:
                .BYTE $01,$4F,$06,$92,$50,$FE,$02,$90,$FD,$01,$95,$FB,$BE,$FB,$04,$A3
                .BYTE $FD,$BE,$FB,$5A,$09,$5B,$F1,$06,$4F,$05,$88,$56,$73,$51,$04,$FD
                .BYTE $5F,$04,$51,$04,$FD,$4B,$00,$BE,$02,$4F,$07,$90,$5A,$00,$50,$BD
                .BYTE $90,$FD,$04,$A3,$FD,$01,$4A,$01,$99,$56,$94,$5B,$53,$5B,$C3,$5B
                .BYTE $83,$5A,$00,$5B,$00,$4F,$05,$BE,$00
mt_patt1:
                .BYTE $50,$F9,$03,$7A,$F9,$BE,$F1,$7F,$BE,$7F,$BE,$7F,$BE,$7F,$BE,$7F
                .BYTE $BE,$FE,$7A,$FD,$BE,$FB,$52,$01,$BD,$44,$07,$7D,$F9,$00
mt_patt2:
                .BYTE $50,$C1,$00
mt_patt3:
                .BYTE $03,$44,$03,$7C,$FE,$54,$07,$43,$00,$7F,$54,$03,$50,$54,$03,$43
                .BYTE $00,$7A,$54,$03,$BD,$51,$01,$54,$03,$BD,$43,$00,$7D,$51,$01,$43
                .BYTE $00,$89,$50,$7A,$51,$01,$42,$01,$8B,$51,$01,$BD,$50,$43,$00,$86
                .BYTE $50,$FD,$54,$01,$43,$01,$88,$51,$01,$52,$01,$51,$01,$50,$BD,$81
                .BYTE $52,$01,$50,$54,$01,$43,$00,$86,$50,$BD,$54,$01,$43,$00,$8B,$51
                .BYTE $01,$BD,$40,$BE,$02,$90,$FD,$03,$7F,$FA,$BE,$05,$AF,$FD,$00
mt_patt4:
                .BYTE $01,$44,$07,$90,$5A,$01,$56,$64,$54,$01,$56,$44,$54,$01,$BD,$40
                .BYTE $BE,$42,$01,$95,$51,$01,$56,$34,$50,$02,$46,$34,$90,$50,$56,$24
                .BYTE $50,$01,$44,$01,$97,$FD,$02,$40,$90,$BD,$51,$01,$40,$BE,$04,$41
                .BYTE $07,$A3,$BD,$54,$01,$BD,$06,$4B,$F1,$97,$56,$84,$50,$BD,$4A,$07
                .BYTE $99,$56,$55,$5B,$00,$5A,$00,$02,$40,$94,$54,$01,$FE,$04,$41,$07
                .BYTE $94,$BD,$50,$BD,$05,$AF,$FE,$5B,$D1,$01,$4A,$01,$9B,$54,$01,$FE
                .BYTE $06,$A0,$FE,$4A,$00,$BE,$04,$44,$01,$A3,$BD,$06,$97,$4B,$00,$BE
                .BYTE $01,$40,$81,$BE,$6E,$BE,$00
mt_patt5:
                .BYTE $01,$4F,$05,$8F,$51,$06,$52,$06,$51,$06,$43,$00,$9B,$5B,$D1,$51
                .BYTE $06,$41,$04,$92,$42,$06,$97,$BD,$51,$06,$5A,$07,$4B,$41,$94,$50
                .BYTE $43,$00,$92,$5B,$F1,$5A,$07,$51,$06,$BD,$5A,$00,$44,$07,$95,$BD
                .BYTE $5A,$00,$5B,$00,$02,$41,$06,$90,$52,$06,$51,$06,$52,$06,$04,$4F
                .BYTE $05,$A3,$5B,$00,$50,$5A,$01,$06,$40,$94,$5B,$C1,$56,$54,$5A,$00
                .BYTE $02,$4F,$04,$90,$5B,$00,$52,$06,$51,$06,$01,$44,$07,$A0,$FE,$56
                .BYTE $63,$51,$03,$56,$43,$52,$01,$4B,$00,$BE,$4F,$05,$81,$40,$BE,$6E
                .BYTE $BE,$04,$94,$FE,$5A,$09,$06,$4B,$A2,$9B,$56,$84,$54,$01,$5B,$00
                .BYTE $04,$4F,$07,$9C,$56,$55,$54,$07,$5A,$00,$00
mt_patt6:
                .BYTE $03,$40,$88,$F9,$7F,$FB,$54,$01,$BD,$43,$00,$8D,$50,$FB,$51,$01
                .BYTE $40,$7D,$FB,$51,$01,$40,$BE,$05,$A3,$FD,$A3,$FD,$03,$8B,$FA,$BE
                .BYTE $7D,$FA,$BE,$44,$07,$88,$FC,$05,$40,$A3,$BD,$BE,$00
mt_patt7:
                .BYTE $01,$4F,$04,$90,$5A,$01,$51,$03,$52,$03,$51,$03,$5B,$21,$5F,$05
                .BYTE $51,$06,$4A,$00,$90,$5B,$00,$50,$FC,$BE,$02,$90,$FD,$01,$8B,$FE
                .BYTE $BE,$02,$90,$FD,$01,$81,$BE,$6E,$BE,$41,$07,$9C,$FE,$4A,$07,$BE
                .BYTE $4B,$91,$89,$50,$02,$4B,$00,$90,$5A,$00,$40,$90,$FE,$4A,$09,$BE
                .BYTE $06,$4B,$C1,$92,$52,$03,$BD,$54,$01,$01,$92,$5B,$00,$54,$01,$4A
                .BYTE $01,$BE,$02,$4B,$C2,$94,$54,$07,$FE,$04,$4A,$00,$A3,$5B,$00,$50
                .BYTE $5A,$01,$06,$4B,$F2,$97,$50,$5A,$00,$4B,$00,$BE,$00
mt_patt8:
                .BYTE $03,$40,$7F,$BD,$7F,$51,$01,$40,$7F,$FD,$88,$52,$01,$40,$8B,$FC
                .BYTE $BE,$7D,$FA,$BE,$05,$AF,$BE,$AF,$BE,$03,$88,$FA,$BE,$7D,$FD,$41
                .BYTE $01,$7D,$50,$BD,$52,$01,$BD,$50,$BD,$BE,$89,$FE,$52,$01,$41,$01
                .BYTE $89,$54,$01,$BD,$40,$BE,$05,$AF,$FD,$03,$8D,$52,$01,$50,$BE,$00
mt_patt9:
                .BYTE $01,$40,$A1,$BD,$43,$00,$97,$52,$01,$43,$00,$A1,$5A,$01,$03,$43
                .BYTE $00,$A0,$5B,$D1,$01,$44,$01,$97,$5A,$07,$44,$07,$9C,$FD,$5B,$00
                .BYTE $4A,$00,$BE,$04,$40,$A0,$FE,$BE,$01,$81,$BE,$7A,$BE,$A8,$FA,$4A
                .BYTE $07,$BE,$06,$4F,$05,$90,$5B,$71,$54,$01,$54,$07,$54,$01,$54,$07
                .BYTE $56,$34,$46,$24,$BE,$02,$42,$01,$94,$5B,$00,$54,$04,$4A,$00,$BE
                .BYTE $01,$41,$03,$97,$52,$03,$51,$01,$BD,$02,$40,$90,$FE,$4A,$07,$BE
                .BYTE $06,$4B,$F1,$89,$50,$BD,$5B,$00,$01,$4A,$09,$81,$40,$BE,$06,$6E
                .BYTE $4B,$00,$BE,$02,$4A,$00,$94,$5B,$00,$42,$07,$97,$BD,$00
mt_patt10:
                .BYTE $03,$40,$89,$FD,$78,$FD,$84,$BD,$51,$01,$BD,$40,$8B,$51,$01,$52
                .BYTE $01,$40,$BE,$05,$AF,$FD,$AF,$FD,$03,$94,$51,$01,$52,$01,$54,$01
                .BYTE $50,$FD,$43,$00,$89,$50,$FB,$BE,$7D,$FB,$43,$00,$7F,$52,$01,$50
                .BYTE $FE,$BE,$89,$F6,$BE,$00
mt_patt11:
                .BYTE $05,$4F,$04,$AC,$50,$FE,$02,$4F,$03,$90,$50,$BD,$94,$BD,$5F,$04
                .BYTE $01,$40,$9B,$FC,$06,$41,$04,$97,$56,$64,$51,$04,$01,$4F,$04,$94
                .BYTE $52,$07,$94,$54,$04,$BD,$51,$04,$06,$40,$97,$56,$74,$01,$42,$07
                .BYTE $94,$5F,$05,$06,$46,$64,$9C,$51,$07,$02,$94,$5F,$02,$06,$41,$04
                .BYTE $97,$56,$44,$44,$04,$94,$52,$07,$04,$4F,$05,$97,$51,$07,$BD,$50
                .BYTE $01,$9B,$52,$01,$BD,$54,$01,$06,$94,$50,$51,$01,$40,$BE,$02,$90
                .BYTE $BD,$06,$95,$56,$74,$02,$40,$90,$BD,$06,$94,$56,$44,$04,$41,$05
                .BYTE $A3,$BD,$52,$05,$51,$05,$52,$05,$51,$05,$51,$07,$5F,$05,$00
mt_patt12:
                .BYTE $03,$40,$89,$BD,$43,$00,$88,$56,$C4,$50,$89,$FC,$7C,$FC,$86,$FC
                .BYTE $88,$FD,$43,$01,$8B,$56,$D3,$54,$01,$51,$01,$40,$8B,$FC,$43,$00
                .BYTE $8B,$50,$FC,$BE,$7D,$54,$01,$BD,$50,$FC,$43,$00,$7A,$50,$FC,$54
                .BYTE $01,$BD,$40,$78,$F9,$00
mt_patt13:
                .BYTE $05,$4F,$05,$AA,$50,$AA,$BD,$AA,$BD,$AA,$BD,$01,$4B,$31,$97,$56
                .BYTE $64,$50,$5B,$00,$04,$40,$A3,$FA,$4F,$07,$BE,$01,$40,$9B,$BD,$5F
                .BYTE $05,$50,$BD,$4F,$03,$BE,$02,$46,$60,$88,$56,$34,$50,$56,$24,$50
                .BYTE $5F,$04,$50,$BD,$90,$BD,$90,$5F,$03,$51,$01,$90,$01,$4F,$05,$9B
                .BYTE $50,$5A,$07,$5B,$31,$4F,$03,$A5,$50,$BD,$5B,$01,$04,$4F,$07,$A3
                .BYTE $50,$5A,$00,$5F,$06,$40,$A3,$5B,$F1,$4B,$41,$A3,$5F,$07,$06,$46
                .BYTE $23,$97,$5A,$00,$05,$4F,$03,$AF,$5B,$00,$46,$84,$AF,$5A,$00,$5F
                .BYTE $05,$50,$00
mt_patt14:
                .BYTE $03,$40,$94,$FD,$88,$FD,$94,$F9,$41,$01,$88,$BD,$50,$BD,$54,$01
                .BYTE $50,$BD,$54,$01,$52,$01,$50,$FE,$8F,$F9,$54,$01,$51,$01,$54,$01
                .BYTE $BD,$43,$02,$7D,$51,$01,$43,$01,$7C,$56,$93,$43,$00,$7F,$56,$83
                .BYTE $52,$01,$50,$43,$00,$78,$51,$06,$BD,$54,$05,$BD,$52,$01,$05,$40
                .BYTE $AF,$FE,$52,$01,$03,$44,$02,$8B,$BD,$05,$AF,$BD,$03,$43,$02,$8B
                .BYTE $46,$42,$BE,$00
mt_patt15:
                .BYTE $06,$4F,$03,$A0,$50,$FD,$56,$C3,$50,$FE,$54,$01,$56,$B3,$54,$01
                .BYTE $50,$54,$01,$56,$A3,$54,$01,$50,$54,$01,$56,$93,$54,$01,$54,$07
                .BYTE $54,$01,$54,$07,$5B,$A1,$54,$07,$FE,$52,$01,$40,$A0,$52,$02,$FE
                .BYTE $5B,$71,$54,$02,$BD,$54,$04,$F9,$4B,$70,$BE,$04,$40,$A3,$FD,$51
                .BYTE $01,$FE,$40,$BE,$01,$4A,$04,$8F,$5B,$C1,$56,$31,$5B,$A1,$51,$07
                .BYTE $BD,$5A,$00,$5B,$00,$40,$81,$4A,$01,$BE,$06,$4B,$00,$9B,$46,$14
                .BYTE $BE,$00
mt_patt16:
                .BYTE $01,$40,$7D,$FD,$84,$BD,$7F,$FD,$44,$07,$83,$EB,$40,$7D,$BD,$7D
                .BYTE $BD,$7D,$BD,$7D,$BD,$7D,$FE,$BE,$05,$AF,$F9,$01,$7D,$FD,$03,$43
                .BYTE $00,$88,$56,$64,$52,$07,$BD,$05,$40,$AF,$BD,$56,$24,$50,$00
mt_patt17:
                .BYTE $06,$40,$99,$ED,$5B,$A1,$50,$FB,$5B,$31,$54,$04,$F9,$01,$40,$A5
                .BYTE $FC,$5B,$31,$50,$51,$06,$50,$51,$06,$50,$52,$06,$51,$07,$BE,$04
                .BYTE $A3,$51,$06,$52,$07,$51,$06,$52,$07,$51,$06,$52,$07,$40,$BE,$01
                .BYTE $44,$04,$81,$40,$BE,$90,$56,$24,$02,$4B,$00,$90,$50,$00
mt_patt18:
                .BYTE $03,$40,$86,$DD,$01,$43,$00,$7D,$50,$F4,$43,$00,$83,$50,$51,$04
                .BYTE $54,$01,$50,$FD,$43,$00,$78,$50,$FD,$BE,$00
mt_patt19:
                .BYTE $01,$4F,$03,$89,$5B,$A1,$50,$F9,$92,$F9,$8F,$FB,$52,$07,$50,$51
                .BYTE $01,$52,$01,$54,$01,$FE,$5B,$21,$50,$BD,$54,$04,$51,$07,$52,$07
                .BYTE $54,$04,$54,$01,$54,$04,$54,$01,$5B,$00,$02,$40,$90,$FB,$06,$4F
                .BYTE $0E,$9B,$52,$04,$51,$04,$52,$04,$51,$04,$52,$04,$5B,$C1,$50,$BD
                .BYTE $5B,$00,$5B,$31,$5B,$00,$5F,$0C,$5B,$F1,$5B,$00,$4F,$05,$BE,$00
mt_patt20:
                .BYTE $03,$40,$7F,$C9,$05,$9C,$FD,$9C,$BD,$9C,$BD,$00
mt_patt21:
                .BYTE $01,$4F,$03,$9E,$5B,$C3,$5A,$02,$50,$FC,$9E,$F9,$4B,$C3,$99,$50
                .BYTE $FA,$9C,$F9,$4B,$63,$95,$50,$FA,$9B,$FD,$5B,$00,$56,$54,$50,$FB
                .BYTE $5B,$F3,$50,$F7,$4B,$00,$BE,$00
mt_patt22:
                .BYTE $03,$40,$97,$E9,$43,$00,$8B,$50,$FA,$43,$00,$95,$50,$E3,$BE,$00
mt_patt23:
                .BYTE $01,$4F,$03,$9E,$5B,$C3,$5A,$02,$50,$FC,$9E,$F9,$4B,$C3,$99,$50
                .BYTE $FA,$9C,$F9,$4B,$63,$95,$50,$FA,$9B,$FD,$5B,$00,$56,$54,$54,$07
                .BYTE $FB,$06,$4B,$F1,$99,$54,$07,$F8,$5F,$05,$4B,$00,$BE,$00
mt_patt24:
                .BYTE $03,$40,$97,$E9,$97,$F9,$43,$00,$95,$50,$EE,$05,$AF,$FD,$04,$A3
                .BYTE $FA,$BE,$00
mt_patt25:
                .BYTE $07,$4A,$01,$84,$4B,$C1,$BE,$40,$90,$BE,$FE,$84,$BE,$C8,$00
mt_patt26:
                .BYTE $07,$4A,$01,$84,$4B,$C1,$BE,$50,$4B,$D1,$90,$40,$BE,$BD,$84,$BE
                .BYTE $C8,$00
mt_patt27:
                .BYTE $07,$4A,$07,$6C,$4B,$C0,$7C,$40,$90,$BE,$5B,$C1,$5A,$01,$40,$78
                .BYTE $BE,$C8,$00
mt_patt28:
                .BYTE $07,$4A,$01,$84,$4B,$C1,$BE,$50,$90,$BE,$4B,$00,$88,$4B,$C1,$84
                .BYTE $40,$BE,$C8,$00
mt_patt29:
                .BYTE $08,$4A,$07,$84,$4A,$01,$9C,$4A,$07,$84,$4B,$51,$9C,$4B,$F1,$A0
                .BYTE $46,$64,$9C,$46,$81,$94,$4B,$00,$84,$42,$02,$BE,$50,$CA,$00
mt_patt30:
                .BYTE $09,$4A,$09,$A1,$50,$FA,$5C,$F0,$50,$5B,$F3,$5C,$20,$50,$BD,$5C
                .BYTE $20,$4B,$00,$BE,$50,$D1,$00
mt_patt31:
                .BYTE $03,$40,$83,$FE,$81,$FD,$86,$FD,$7F,$BD,$51,$05,$BD,$40,$BE,$D0
                .BYTE $00
mt_patt32:
                .BYTE $05,$4A,$07,$A5,$5B,$C3,$50,$BD,$4A,$09,$A5,$5B,$E3,$50,$BD,$4A
                .BYTE $07,$B1,$5B,$B3,$50,$BD,$4A,$09,$A5,$5B,$E3,$50,$4A,$00,$BE,$5B
                .BYTE $00,$50,$D2,$00
mt_patt33:
                .BYTE $06,$40,$A1,$FE,$56,$C5,$43,$00,$B1,$50,$BD,$56,$B5,$43,$00,$A0
                .BYTE $50,$BD,$56,$A5,$43,$00,$A3,$50,$BD,$BE,$D0,$00
mt_patt34:
                .BYTE $06,$4A,$09,$9C,$56,$83,$50,$BD,$5B,$F3,$52,$01,$FE,$43,$00,$97
                .BYTE $56,$53,$5A,$07,$4B,$00,$BE,$5A,$00,$50,$CE,$00
mt_patt35:
                .BYTE $03,$40,$88,$BD,$8D,$BD,$88,$BD,$8F,$FC,$BE,$CC,$00
mt_patt36:
                .BYTE $06,$40,$8D,$F9,$8B,$F9,$8F,$F5,$43,$01,$90,$50,$DF,$BE,$00
mt_patt37:
                .BYTE $03,$40,$89,$F9,$88,$F9,$8F,$F5,$90,$DE,$BE,$00
mt_patt38:
                .BYTE $04,$40,$A0,$FD,$03,$7C,$F9,$81,$DD,$88,$F1,$00
mt_patt39:
                .BYTE $02,$4B,$00,$8B,$50,$FE,$01,$97,$51,$01,$52,$01,$50,$43,$01,$94
                .BYTE $50,$FE,$90,$FD,$8D,$FD,$88,$F5,$9C,$F1,$02,$8B,$FD,$01,$97,$F5
                .BYTE $00
mt_patt40:
                .BYTE $02,$40,$8B,$FD,$06,$90,$FD,$97,$F9,$01,$9C,$F5,$06,$97,$F5,$01
                .BYTE $94,$F5,$06,$94,$F5,$00
mt_patt41:
                .BYTE $04,$40,$A0,$FD,$05,$8D,$FD,$03,$7C,$E1,$02,$8B,$FD,$04,$A0,$FD
                .BYTE $03,$7F,$F1,$00
mt_patt42:
                .BYTE $50,$ED,$01,$4B,$00,$94,$50,$EE,$06,$94,$F1,$01,$9C,$F9,$00
mt_patt43:
                .BYTE $50,$C5,$01,$43,$02,$7C,$56,$B3,$56,$73,$56,$33,$00
mt_patt44:
                .BYTE $05,$40,$99,$FD,$02,$94,$FD,$01,$9C,$BD,$9C,$FE,$54,$04,$FE,$40
                .BYTE $97,$F8,$52,$01,$FE,$40,$94,$F9,$99,$BD,$99,$FA,$51,$01,$FE,$40
                .BYTE $9B,$F9,$9C,$FA,$BE,$00
mt_patt45:
                .BYTE $04,$40,$95,$F9,$03,$7C,$FD,$81,$F9,$7D,$F9,$84,$F9,$78,$E6,$BE
                .BYTE $00
