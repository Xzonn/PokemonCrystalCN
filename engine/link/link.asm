LinkCommunications:
	call ClearBGPalettes
	ld c, 80
	call DelayFrames
	call ClearScreen
	call ClearSprites
	call UpdateSprites
	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	ld c, 80
	call DelayFrames
	call ClearScreen
	call UpdateSprites
	call LoadStandardFont
	call LoadFontsBattleExtra
	farcall LinkComms_LoadPleaseWaitTextboxBorderGFX
	call WaitBGMap2
	hlcoord 6, 8
	ld b, 2
	ld c, 6
	ld d, h
	ld e, l
	farcall LinkTextbox2
	hlcoord 7, 10
	ld de, String_PleaseWait
	call PlaceString
	call SetTradeRoomBGPals
	call WaitBGMap2
	ld hl, wcf5d
	xor a ; LOW($5000)
	ld [hli], a
	ld [hl], HIGH($5000)
	ld a, [wLinkMode]
	cp LINK_TIMECAPSULE
	jp nz, Gen2ToGen2LinkComms

Gen2ToGen1LinkComms:
	call ClearLinkData
	call Link_PrepPartyData_Gen1
	call FixDataForLinkTransfer
	xor a
	ld [wPlayerLinkAction], a
	call WaitLinkTransfer
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	jr nz, .player_1

	ld c, 3
	call DelayFrames
	xor a
	ldh [hSerialSend], a
	ld a, (0 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a

	call DelayFrame
	xor a
	ldh [hSerialSend], a
	ld a, (0 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a

.player_1
	ld de, MUSIC_NONE
	call PlayMusic
	vc_patch Wireless_net_delay_5
if DEF(_CRYSTAL11_VC)
	ld c, 26
else
	ld c, 3
endc
	vc_patch_end Wireless_net_delay_5
	call DelayFrames
	xor a
	ldh [rIF], a
	ld a, 1 << SERIAL
	ldh [rIE], a
	ld hl, wd1f3
	ld de, wEnemyMonSpecies
	ld bc, $11
	vc_hook Wireless_ExchangeBytes_Gen2toGen1_RNG_state
	call Serial_ExchangeBytes
	ld a, SERIAL_NO_DATA_BYTE
	ld [de], a
	ld hl, wLinkData
	ld de, wOTPlayerName
	ld bc, $1a8
	vc_hook Wireless_ExchangeBytes_Gen2toGen1_party_structs
	call Serial_ExchangeBytes
	ld a, SERIAL_NO_DATA_BYTE
	ld [de], a
	ld hl, wLink_c608
	ld de, wTrademons
	ld bc, wTrademons - wLink_c608
	vc_hook Wireless_ExchangeBytes_Gen2toGen1_patch_lists
	call Serial_ExchangeBytes
	xor a
	ldh [rIF], a
	ld a, (1 << JOYPAD) | (1 << SERIAL) | (1 << TIMER) | (1 << VBLANK)
	ldh [rIE], a
	call Link_CopyRandomNumbers
	ld hl, wOTPlayerName
	call Link_FindFirstNonControlCharacter_SkipZero
	push hl
	ld bc, NAME_LENGTH
	add hl, bc
	ld a, [hl]
	pop hl
	and a
	jp z, Function28b22
	cp $7
	jp nc, Function28b22
	ld de, wLinkData
	ld bc, $1a2
	call Link_CopyOTData
	ld de, wPlayerTrademonSpecies
	ld hl, wTimeCapsulePartyMon1Species
	ld c, 2
.loop
	ld a, [de]
	inc de
	and a
	jr z, .loop
	cp SERIAL_PREAMBLE_BYTE
	jr z, .loop
	cp SERIAL_NO_DATA_BYTE
	jr z, .loop
	cp SERIAL_PATCH_LIST_PART_TERMINATOR
	jr z, .next
	push hl
	push bc
	ld b, 0
	dec a
	ld c, a
	add hl, bc
	ld a, SERIAL_NO_DATA_BYTE
	ld [hl], a
	pop bc
	pop hl
	jr .loop

.next
	ld hl, wc90f
	dec c
	jr nz, .loop
	ld hl, wLinkPlayerName
	ld de, wOTPlayerName
	ld bc, NAME_LENGTH
	call CopyBytes ; call CopyOrConvertBytes_G2I
	ld de, wOTPartyCount
	ld a, [hli]
	ld [de], a
	inc de
.party_loop
	ld a, [hli]
	cp -1
	jr z, .done_party
	ld [wTempSpecies], a
	push hl
	push de
	callfar ConvertMon_1to2
	pop de
	pop hl
	ld a, [wTempSpecies]
	ld [de], a
	inc de
	jr .party_loop

.done_party
	ld [de], a
	ld hl, wTimeCapsulePartyMon1Species
	call Function2868a
	ld a, LOW(wOTPartyMonOT)
	ld [wUnusedD102], a
	ld a, HIGH(wOTPartyMonOT)
	ld [wUnusedD102 + 1], a
	ld de, MUSIC_NONE
	call PlayMusic
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	ld c, 66
	call z, DelayFrames
	ld de, MUSIC_ROUTE_30
	call PlayMusic
	jp InitTradeMenuDisplay

Gen2ToGen2LinkComms:
	call ClearLinkData
	call Link_PrepPartyData_Gen2
	call FixDataForLinkTransfer
	call CheckLinkTimeout_Gen2
	ld a, [wScriptVar]
	and a
	jp z, LinkTimeout
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	jr nz, .Player1

	ld c, 3
	call DelayFrames
	xor a
	ldh [hSerialSend], a
	ld a, (0 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a

	call DelayFrame
	xor a
	ldh [hSerialSend], a
	ld a, (0 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a

.Player1:
	ld de, MUSIC_NONE
	call PlayMusic
	vc_patch Wireless_net_delay_8
if DEF(_CRYSTAL11_VC)
	ld c, 26
else
	ld c, 3
endc
	vc_patch_end Wireless_net_delay_8
	call DelayFrames
	xor a
	ldh [rIF], a
	ld a, 1 << SERIAL
	ldh [rIE], a
	ld hl, wd1f3
	ld de, wEnemyMonSpecies
	ld bc, $11
	vc_hook Wireless_ExchangeBytes_RNG_state
	call Serial_ExchangeBytes
	ld a, SERIAL_NO_DATA_BYTE
	ld [de], a
	ld hl, wLinkData
	ld de, wOTPlayerName
	ld bc, $1c2
	vc_hook Wireless_ExchangeBytes_party_structs
	call Serial_ExchangeBytes
	ld a, SERIAL_NO_DATA_BYTE
	ld [de], a
	ld hl, wLink_c608
	ld de, wTrademons
	ld bc, wTrademons - wLink_c608
	vc_hook Wireless_ExchangeBytes_patch_lists
	call Serial_ExchangeBytes
	ld a, [wLinkMode]
	cp LINK_TRADECENTER
	jr nz, .not_trading
	ld hl, wc9f4
	ld de, wcb84
	ld bc, $186
	vc_hook Wireless_ExchangeBytes_mail
	call ExchangeBytes

.not_trading
	xor a
	ldh [rIF], a
	ld a, (1 << JOYPAD) | (1 << SERIAL) | (1 << TIMER) | (1 << VBLANK)
	ldh [rIE], a
	ld de, MUSIC_NONE
	call PlayMusic
	call Link_CopyRandomNumbers
	ld hl, wOTPlayerName
	call Link_FindFirstNonControlCharacter_SkipZero
	ld de, wLinkData
	ld bc, $1b9
	call Link_CopyOTData
	ld de, wPlayerTrademonSpecies
	ld hl, wLinkPlayerPartyMon1Species
	ld c, 2
.loop1
	ld a, [de]
	inc de
	and a
	jr z, .loop1
	cp SERIAL_PREAMBLE_BYTE
	jr z, .loop1
	cp SERIAL_NO_DATA_BYTE
	jr z, .loop1
	cp SERIAL_PATCH_LIST_PART_TERMINATOR
	jr z, .next1
	push hl
	push bc
	ld b, 0
	dec a
	ld c, a
	add hl, bc
	ld a, SERIAL_NO_DATA_BYTE
	ld [hl], a
	pop bc
	pop hl
	jr .loop1

.next1
	ld hl, wc90f
	dec c
	jr nz, .loop1
	ld a, [wLinkMode]
	cp LINK_TRADECENTER
	jp nz, .skip_mail
	ld hl, wcb84
.loop2
	ld a, [hli]
	cp MAIL_MSG_LENGTH
	jr nz, .loop2
.loop3
	ld a, [hli]
	cp SERIAL_NO_DATA_BYTE
	jr z, .loop3
	cp MAIL_MSG_LENGTH
	jr z, .loop3
	dec hl
	ld de, wcb84
	ld bc, $190 ; 400
	call CopyBytes
	ld hl, wcb84
	ld bc, $c6 ; 198
.loop4
	ld a, [hl]
	cp MAIL_MSG_LENGTH + 1
	jr nz, .okay1
	ld [hl], SERIAL_NO_DATA_BYTE
.okay1
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .loop4
	ld de, wcc9e
.loop5
	ld a, [de]
	inc de
	cp SERIAL_PATCH_LIST_PART_TERMINATOR
	jr z, .start_copying_mail
	ld hl, wcc4a
	dec a
	ld b, $0
	ld c, a
	add hl, bc
	ld [hl], SERIAL_NO_DATA_BYTE
	jr .loop5

.start_copying_mail
	ld hl, wcb84
	ld de, wc9f4
	ld b, PARTY_LENGTH
.copy_mail_loop
	push bc
	ld bc, MAIL_MSG_LENGTH + 1
	call CopyBytes
	ld a, LOW(MAIL_STRUCT_LENGTH - (MAIL_MSG_LENGTH + 1))
	add e
	ld e, a
	ld a, HIGH(MAIL_STRUCT_LENGTH - (MAIL_MSG_LENGTH + 1))
	adc d
	ld d, a
	pop bc
	dec b
	jr nz, .copy_mail_loop
	ld de, wc9f4
	ld b, PARTY_LENGTH
.copy_author_loop
	push bc
	ld a, LOW(MAIL_MSG_LENGTH + 1)
	add e
	ld e, a
	ld a, HIGH(MAIL_MSG_LENGTH + 1)
	adc d
	ld d, a
	ld bc, MAIL_STRUCT_LENGTH - (MAIL_MSG_LENGTH + 1)
	call CopyBytes
	pop bc
	dec b
	jr nz, .copy_author_loop
	ld b, PARTY_LENGTH
	ld de, wc9f4
.fix_mail_loop
	push bc
	push de
	farcall IsMailEuropean
	ld a, c
	or a
	jr z, .next
	cp a, $5
	jr z, .next
	sub $3
	jr nc, .skip
	farcall ConvertEnglishMailToFrenchGerman
	jr .next

.skip
	cp $2
	jr nc, .next
	farcall ConvertEnglishMailToSpanishItalian

.next
	pop de
	ld hl, MAIL_STRUCT_LENGTH
	add hl, de
	ld d, h
	ld e, l
	pop bc
	dec b
	jr nz, .fix_mail_loop
	ld de, wcb0e
	xor a
	ld [de], a

.skip_mail
	ld hl, wLinkPlayerName
	ld de, wOTPlayerName
	ld bc, NAME_LENGTH
	call CopyBytes
	ld de, wOTPartyCount
	ld bc, 1 + PARTY_LENGTH + 1
	call CopyBytes
	ld de, wOTPlayerID
	ld bc, 2
	call CopyBytes
	ld de, wOTPartyMons
	ld bc, wOTPartyDataEnd - wOTPartyMons
	call CopyBytes
	ld a, LOW(wOTPartyMonOT)
	ld [wUnusedD102], a
	ld a, HIGH(wOTPartyMonOT)
	ld [wUnusedD102 + 1], a
	ld de, MUSIC_NONE
	call PlayMusic
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	ld c, 66
	call z, DelayFrames
	ld a, [wLinkMode]
	cp LINK_COLOSSEUM
	jr nz, .ready_to_trade
	ld a, CAL
	ld [wOtherTrainerClass], a
	call ClearScreen
	farcall Link_WaitBGMap
	ld hl, wOptions
	ld a, [hl]
	push af
	and 1 << STEREO
	or TEXT_DELAY_MED
	ld [hl], a
	ld hl, wOTPlayerName
	ld de, wOTClassName
	ld bc, NAME_LENGTH
	call CopyBytes
	call ReturnToMapFromSubmenu

	; LET'S DO THIS
	ld a, [wDisableTextAcceleration]
	push af
	ld a, 1
	ld [wDisableTextAcceleration], a
	ldh a, [rIE]
	push af
	ldh a, [rIF]
	push af
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	set LCD_STAT, a
	ldh [rIE], a
	pop af
	ldh [rIF], a

	predef StartBattle

	ldh a, [rIF]
	ld h, a
	xor a
	ldh [rIF], a
	pop af
	ldh [rIE], a
	ld a, h
	ldh [rIF], a
	pop af
	ld [wDisableTextAcceleration], a
	pop af
	ld [wOptions], a
	farcall LoadPokemonData
	jp Function28b22

.ready_to_trade
	ld de, MUSIC_ROUTE_30
	call PlayMusic
	jp InitTradeMenuDisplay

LinkTimeout:
	ld de, .LinkTimeoutText
	ld b, 10
.loop
	call DelayFrame
	call LinkDataReceived
	dec b
	jr nz, .loop
	xor a
	ld [hld], a
	ld [hl], a
	ldh [hVBlank], a
	push de
	hlcoord 0, 12
	ld b, 4
	ld c, 18
	push de
	ld d, h
	ld e, l
	farcall LinkTextbox2
	pop de
	pop hl
	bccoord 1, 14
	call PlaceHLTextAtBC
	call RotateThreePalettesRight
	call ClearScreen
	ld b, SCGB_DIPLOMA
	call GetSGBLayout
	call WaitBGMap2
	ret

.LinkTimeoutText:
	text_far _LinkTimeoutText
	text_end

ExchangeBytes:
	ld a, TRUE
	ldh [hSerialIgnoringInitialData], a
.loop
	ld a, [hl]
	ldh [hSerialSend], a
	call Serial_ExchangeByte
	push bc
	ld b, a
	inc hl
	ld a, 48
.delay_cycles
	dec a
	jr nz, .delay_cycles
	ldh a, [hSerialIgnoringInitialData]
	and a
	ld a, b
	pop bc
	jr z, .load
	dec hl
	xor a
	ldh [hSerialIgnoringInitialData], a
	jr .loop

.load
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

String_PleaseWait:
	db "请稍等！@"

ClearLinkData:
	ld hl, wLinkData
	ld bc, wLinkDataEnd - wLinkData
.loop
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

FixDataForLinkTransfer:
	ld hl, wd1f3
	ld a, SERIAL_PREAMBLE_BYTE
	ld b, wLinkBattleRNs - wd1f3
.loop1
	ld [hli], a
	dec b
	jr nz, .loop1
	ld b, wTempEnemyMonSpecies - wLinkBattleRNs
.loop2
	call Random
	cp SERIAL_PREAMBLE_BYTE
	jr nc, .loop2
	ld [hli], a
	dec b
	jr nz, .loop2
	ld hl, wLink_c608
	ld a, SERIAL_PREAMBLE_BYTE
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld b, $c8
	xor a
.loop3
	ld [hli], a
	dec b
	jr nz, .loop3
	ld hl, wTimeCapsulePartyMon1 - 1 + PARTY_LENGTH
	ld de, wc612
	lb bc, 0, 0
.loop4
	inc c
	ld a, c
	cp SERIAL_PREAMBLE_BYTE
	jr z, .next1
	ld a, b
	dec a
	jr nz, .next2
	push bc
	ld a, [wLinkMode]
	cp LINK_TIMECAPSULE
	ld b, $d
	jr z, .got_value
	ld b, $27
.got_value
	ld a, c
	cp b
	pop bc
	jr z, .done
.next2
	inc hl
	ld a, [hl]
	cp SERIAL_NO_DATA_BYTE
	jr nz, .loop4
	ld a, c
	ld [de], a
	inc de
	ld [hl], SERIAL_PATCH_LIST_PART_TERMINATOR
	jr .loop4

.next1
	ld a, SERIAL_PATCH_LIST_PART_TERMINATOR
	ld [de], a
	inc de
	lb bc, 1, 0
	jr .loop4

.done
	ld a, SERIAL_PATCH_LIST_PART_TERMINATOR
	ld [de], a
	ret

Link_PrepPartyData_Gen1:
	ld de, wLinkData
	ld a, SERIAL_PREAMBLE_BYTE
	ld b, SERIAL_PREAMBLE_LENGTH
.loop1
	ld [de], a
	inc de
	dec b
	jr nz, .loop1
	ld hl, wPlayerName
	ld bc, NAME_LENGTH
	call CopyBytes ; call CopyOrConvertBytes_I2G
	push de
	ld hl, wPartyCount
	ld a, [hli]
	ld [de], a
	inc de
.loop2
	ld a, [hli]
	cp -1
	jr z, .done_party
	ld [wTempSpecies], a
	push hl
	push de
	callfar ConvertMon_2to1
	pop de
	pop hl
	ld a, [wTempSpecies]
	ld [de], a
	inc de
	jr .loop2

.done_party
	ld [de], a
	pop de
	ld hl, 1 + PARTY_LENGTH + 1
	add hl, de
	ld d, h
	ld e, l
	ld hl, wPartyMon1Species
	ld c, PARTY_LENGTH
.mon_loop
	push bc
	call .ConvertPartyStruct2to1
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	dec c
	jr nz, .mon_loop
	ld hl, wPartyMonOT
	call .copy_ot_nicks
	ld hl, wPartyMonNicknames
.copy_ot_nicks
	ld bc, PARTY_LENGTH * NAME_LENGTH
	jp CopyBytes
; 	ld b, PARTY_LENGTH
; .loop_copy_ot_nicks
; 	push bc
; 	ld bc, NAME_LENGTH
; 	call CopyOrConvertBytes_I2G
; 	pop bc
; 	dec b
; 	jr nz, .loop_copy_ot_nicks
; 	ret

.ConvertPartyStruct2to1:
	ld b, h
	ld c, l
	push de
	push bc
	ld a, [hl]
	ld [wTempSpecies], a
	callfar ConvertMon_2to1
	pop bc
	pop de
	ld a, [wTempSpecies]
	ld [de], a
	inc de
	ld hl, MON_HP
	add hl, bc
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	inc de
	xor a
	ld [de], a
	inc de
	ld hl, MON_STATUS
	add hl, bc
	ld a, [hl]
	ld [de], a
	inc de
	ld a, [bc]
	cp MAGNEMITE
	jr z, .steel_type
	cp MAGNETON
	jr nz, .skip_steel

.steel_type
	ld a, ELECTRIC
	ld [de], a
	inc de
	ld [de], a
	inc de
	jr .done_steel

.skip_steel
	push bc
	dec a
	ld hl, BaseData + BASE_TYPES
	ld bc, BASE_DATA_SIZE
	call AddNTimes
	ld bc, BASE_CATCH_RATE - BASE_TYPES
	ld a, BANK(BaseData)
	call FarCopyBytes
	pop bc

.done_steel
	push bc
	ld hl, MON_ITEM
	add hl, bc
	ld bc, MON_HAPPINESS - MON_ITEM
	call CopyBytes
	pop bc

	ld hl, MON_LEVEL
	add hl, bc
	ld a, [hl]
	ld [de], a
	ld [wCurPartyLevel], a
	inc de

	push bc
	ld hl, MON_MAXHP
	add hl, bc
	ld bc, MON_SAT - MON_MAXHP
	call CopyBytes
	pop bc

	push de
	push bc

	ld a, [bc]
	dec a
	push bc
	ld b, 0
	ld c, a
	ld hl, KantoMonSpecials
	add hl, bc
	ld a, BANK(KantoMonSpecials)
	call GetFarByte
	ld [wBaseSpecialAttack], a
	pop bc

	ld hl, MON_STAT_EXP - 1
	add hl, bc
	ld c, STAT_SATK
	ld b, TRUE
	predef CalcMonStatC

	pop bc
	pop de

	ldh a, [hQuotient + 2]
	ld [de], a
	inc de
	ldh a, [hQuotient + 3]
	ld [de], a
	inc de
	ld h, b
	ld l, c
	ret

Link_PrepPartyData_Gen2:
	ld de, wLinkData
	ld a, SERIAL_PREAMBLE_BYTE
	ld b, SERIAL_PREAMBLE_LENGTH
.loop1
	ld [de], a
	inc de
	dec b
	jr nz, .loop1
	ld hl, wPlayerName
	ld bc, NAME_LENGTH
	call CopyBytes
	ld hl, wPartyCount
	ld bc, 1 + PARTY_LENGTH + 1
	call CopyBytes
	ld hl, wPlayerID
	ld bc, 2
	call CopyBytes
	ld hl, wPartyMon1Species
	ld bc, PARTY_LENGTH * PARTYMON_STRUCT_LENGTH
	call CopyBytes
	ld hl, wPartyMonOT
	ld bc, PARTY_LENGTH * NAME_LENGTH
	call CopyBytes
	ld hl, wPartyMonNicknames
	ld bc, PARTY_LENGTH * MON_NAME_LENGTH
	call CopyBytes

; Okay, we did all that.  Now, are we in the trade center?
	ld a, [wLinkMode]
	cp LINK_TRADECENTER
	ret nz

; Fill 5 bytes at wc9f4 with $20
	ld de, wc9f4
	ld a, $20
	call Function28682

; Copy all the mail messages to wc9f9
	ld a, BANK(sPartyMail)
	call OpenSRAM
	ld hl, sPartyMail
	ld b, PARTY_LENGTH
.loop2
	push bc
	ld bc, MAIL_MSG_LENGTH + 1
	call CopyBytes
	ld bc, sPartyMon1MailEnd - sPartyMon1MailAuthor
	add hl, bc
	pop bc
	dec b
	jr nz, .loop2
; Copy the mail data to wcabf
	ld hl, sPartyMail
	ld b, PARTY_LENGTH
.loop3
	push bc
	ld bc, MAIL_MSG_LENGTH + 1
	add hl, bc
	ld bc, sPartyMon1MailEnd - sPartyMon1MailAuthor
	call CopyBytes
	pop bc
	dec b
	jr nz, .loop3

	ld b, PARTY_LENGTH
	ld de, sPartyMail
	ld hl, wc9f9
.loop4
	push bc
	push hl
	push de
	push hl
	farcall IsMailEuropean
	pop de
	ld a, c
	or a
	jr z, .next
	cp a, $5
	jr z, .next
	sub $3
	jr nc, .italian_spanish
	farcall ConvertFrenchGermanMailToEnglish
	jr .next

.italian_spanish
	cp $2
	jr nc, .next
	farcall ConvertSpanishItalianMailToEnglish

.next
	pop de
	ld hl, MAIL_STRUCT_LENGTH
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld bc, sPartyMon1MailAuthor - sPartyMon1Mail
	add hl, bc
	pop bc
	dec b
	jr nz, .loop4
	call CloseSRAM
	ld hl, wc9f9
	ld bc, PARTY_LENGTH * (sPartyMon1MailAuthor - sPartyMon1Mail)
.loop5
	ld a, [hl]
	cp SERIAL_NO_DATA_BYTE
	jr nz, .skip2
	ld [hl], sPartyMon1MailAuthor - sPartyMon1Mail

.skip2
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .loop5
	ld hl, wcabf
	ld de, wcb13
	ld b, PARTY_LENGTH * (sPartyMon1MailEnd - sPartyMon1MailAuthor)
	ld c, $0
.loop6
	inc c
	ld a, [hl]
	cp SERIAL_NO_DATA_BYTE
	jr nz, .skip3
	ld [hl], SERIAL_PATCH_LIST_PART_TERMINATOR
	ld a, c
	ld [de], a
	inc de

.skip3
	inc hl
	dec b
	jr nz, .loop6
	ld a, SERIAL_PATCH_LIST_PART_TERMINATOR
	ld [de], a
	ret

Function28682:
	ld c, 5
.loop
	ld [de], a
	inc de
	dec c
	jr nz, .loop
	ret

Function2868a:
	push hl
	ld d, h
	ld e, l
	ld bc, wLinkOTPartyMonTypes
	ld hl, wcbe8
	ld a, c
	ld [hli], a
	ld [hl], b
	ld hl, wOTPartyMon1Species
	ld c, PARTY_LENGTH
.loop
	push bc
	call .ConvertToGen2
	pop bc
	dec c
	jr nz, .loop
	pop hl
	ld bc, PARTY_LENGTH * REDMON_STRUCT_LENGTH
	add hl, bc
	ld de, wOTPartyMonOT
	ld bc, PARTY_LENGTH * NAME_LENGTH
	call CopyBytes
; 	ld b, PARTY_LENGTH
; .loop2
; 	push bc
; 	ld bc, NAME_LENGTH
; 	call CopyOrConvertBytes_G2I
; 	pop bc
; 	dec b
; 	jr nz, .loop2
	ld de, wOTPartyMonNicknames
	ld bc, PARTY_LENGTH * MON_NAME_LENGTH
	jp CopyBytes
; 	ld b, PARTY_LENGTH
; .loop3
; 	push bc
; 	ld bc, MON_NAME_LENGTH
; 	call CopyOrConvertBytes_G2I
; 	pop bc
; 	dec b
; 	jr nz, .loop3
; 	ret

.ConvertToGen2:
	ld b, h
	ld c, l
	ld a, [de]
	inc de
	push bc
	push de
	ld [wTempSpecies], a
	callfar ConvertMon_1to2
	pop de
	pop bc
	ld a, [wTempSpecies]
	ld [bc], a
	ld [wCurSpecies], a
	ld hl, MON_HP
	add hl, bc
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hl], a
	inc de
	ld hl, MON_STATUS
	add hl, bc
	ld a, [de]
	inc de
	ld [hl], a
	ld hl, wcbe8
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, l
	ld [wcbe8], a
	ld a, h
	ld [wcbe8 + 1], a
	push bc
	ld hl, MON_ITEM
	add hl, bc
	push hl
	ld h, d
	ld l, e
	pop de
	push bc
	ld a, [hli]
	ld b, a
	call TimeCapsule_ReplaceTeruSama
	ld a, b
	ld [de], a
	inc de
	pop bc
	ld bc, $19
	call CopyBytes
	pop bc
	ld d, h
	ld e, l
	ld hl, $1f
	add hl, bc
	ld a, [de]
	inc de
	ld [hl], a
	ld [wCurPartyLevel], a
	push bc
	ld hl, $24
	add hl, bc
	push hl
	ld h, d
	ld l, e
	pop de
	ld bc, 8
	call CopyBytes
	pop bc
	call GetBaseData
	push de
	push bc
	ld d, h
	ld e, l
	ld hl, MON_STAT_EXP - 1
	add hl, bc
	ld c, STAT_SATK
	ld b, TRUE
	predef CalcMonStatC
	pop bc
	pop hl
	ldh a, [hQuotient + 2]
	ld [hli], a
	ldh a, [hQuotient + 3]
	ld [hli], a
	push hl
	push bc
	ld hl, MON_STAT_EXP - 1
	add hl, bc
	ld c, STAT_SDEF
	ld b, TRUE
	predef CalcMonStatC
	pop bc
	pop hl
	ldh a, [hQuotient + 2]
	ld [hli], a
	ldh a, [hQuotient + 3]
	ld [hli], a
	push hl
	ld hl, $1b
	add hl, bc
	ld a, $46
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	pop hl
	inc de
	inc de
	ret

TimeCapsule_ReplaceTeruSama:
	ld a, b
	and a
	ret z
	push hl
	ld hl, TimeCapsule_CatchRateItems
.loop
	ld a, [hli]
	and a
	jr z, .end
	cp b
	jr z, .found
	inc hl
	jr .loop

.found
	ld b, [hl]

.end
	pop hl
	ret

INCLUDE "data/items/catch_rate_items.asm"

; 与皮卡丘汉化版通信使用的转码程序
; 程序中的内码是旧定义，已不适用当前版本
; 皮卡丘汉化版，另寻方法处理。

; CopyOrConvertBytes_G2I:
; 	call CheckConvertGB2312ToInternal
; 	call c, ConvertGB2312ToInternal
; 	jp CopyBytes

; CopyOrConvertBytes_I2G:
; 	call CheckConvertInternalToGB2312
; 	call c, ConvertInternalToGB2312
; 	jp CopyBytes

; CheckConvertGB2312ToInternal:
; 	push hl
; 	push bc
; .loop
; 	ld a, [hli]
; 	cp a, "@"
; 	jr z, .match
; 	cp a, $A1
; 	jr c, .notmatch
; 	cp a, $A9
; 	jr c, .next
; 	cp a, $B0
; 	jr c, .notmatch
; 	cp a, $F7 + 1
; 	jr nc, .notmatch
; .next
; 	dec bc
; 	ld a, b
; 	or c
; 	jr z, .notmatch
; 	ld a, [hli]
; 	cp a, $A0
; 	jr c, .notmatch
; 	cp a, $FD + 1
; 	jr nc, .notmatch
; 	dec bc
; 	ld a, b
; 	or c
; 	jr nz, .loop
; .notmatch
; 	pop bc
; 	pop hl
; 	and a
; 	ret
; .match
; 	pop bc
; 	pop hl
; 	scf
; 	ret

; CheckConvertInternalToGB2312:
; ;hl to de
; 	push hl
; 	push bc
; .loop
; 	ld a, [hli]
; 	cp a, "@"
; 	jr z, .match
; 	and a
; 	jr z, .notmatch
; 	cp $10
; 	jr c, .next
; 	cp $2F
; 	jr nc, .notmatch
; 	bit 3, a
; 	jr z, .notmatch
; .next
; 	dec bc
; 	ld a, b
; 	or c
; 	jr z, .notmatch
; 	ld a, [hli]
; 	cp a, "@"
; 	jr z, .notmatch
; 	cp a, $FE
; 	jr z, .notmatch
; 	dec bc
; 	ld a, b
; 	or c
; 	jr nz, .loop
; .notmatch
; 	pop bc
; 	pop hl
; 	and a
; 	ret
; .match
; 	pop bc
; 	pop hl
; 	scf
; 	ret

; Convert_I2G2I_debug:
; 	ld a, $01
; .loop
; 	cp a, $10
; 	jr nz, .not10
; 	add a, 8
; .not10
; 	cp a, $20
; 	jr nz, .not20
; 	add a, 8
; .not20
; 	push af
; 	ld d, a
; 	ld bc, $0000
; 	ld hl, $D000
; 	ld a, 0
; .loop2
; 	cp a, "@"
; 	jr nz, .not50
; 	inc a
; .not50
; 	cp a, $FE
; 	jr nz, .notFE
; 	inc a
; .notFE
; 	ld [hl], d
; 	inc hl
; 	inc bc
; 	ld [hli], a
; 	inc bc
; 	inc a
; 	jr nz, .loop2
; 	ld [hl], "@"
; 	inc bc
; 	push bc
; 	ld hl, $D000
; 	ld de, $D200
; 	call ConvertInternalToGB2312
; 	pop bc
; 	push bc
; 	ld hl, $D200
; 	ld de, $D400
; 	call ConvertGB2312ToInternal
; 	pop bc
; 	ld de, $D400
; 	ld hl, $D000
; .checkloop
; 	ld a, [de]
; 	inc de
; 	cp [hl]
; 	inc hl
; 	jr z, .notbreak
; .errloop
; 	jr .errloop
; .notbreak
; 	dec bc
; 	ld a, b
; 	or c
; 	jr nz, .checkloop
; 	pop af
; 	inc a
; 	cp a, $2F
; 	jr nz, .loop
; .finishloop
; 	jr .finishloop

; ConvertGB2312ToInternal:
; 	push bc
; 	ld b, h
; 	ld c, l
; .loop
; 	ld a, [bc]
; 	inc bc
; 	cp a, "@"
; 	jr z, .end
; 	cp a, $B0
; 	jr c, .skip
; 	sub a, $06
; .skip
; 	sub a, $A0
; 	push de
; 	ld de, $0060 - 2
; 	ld hl, -$0060 + 2
; .loop2
; 	add hl, de
; 	dec a
; 	jr nz, .loop2
; 	ld a, [bc]
; 	inc bc
; 	sub a, $A0
; 	jr nz, .skipGB2312FE
; 	ld a, $FE - $A0 ; not standard GB2312, replace $FE to $A0
; .skipGB2312FE
; 	dec a ; A1A1 <-> 0000, A1 - A0 - 1
; 	ld e, a
; 	add hl, de
; 	call .expend50FE
; 	inc h
; 	ld a, h
; 	cp a, $10
; 	jr c, .notalign
; 	and $08
; 	add $08
; 	add h
; .notalign
; 	; ld h, a
; 	pop de
; 	; ld a, h
; 	ld [de], a
; 	inc de
; 	ld a, l
; 	ld [de], a
; 	inc de
; 	pop hl ; bc(LENGTH) in start
; 	dec hl
; 	dec hl
; 	push hl
; 	jr .loop
; .end
; 	ld [de], a
; 	inc de
; 	ld h, b
; 	ld l, c
; 	pop bc
; 	dec bc
; 	ret
; .expend50FE:
; 	xor a
; 	ld d, a
; 	jr .e50feloop_entry
; .e50feloop
; 	cpl
; 	inc a
; 	add a, a
; 	ld e, a
; 	ld a, h
; 	add hl, de
; .e50feloop_entry
; 	sub h
; 	jr nz, .e50feloop
; 	ld a, l
; 	cp a, "@"
; 	ret c
; 	inc hl
; 	cp a, $FF - 2
; 	ret c
; 	inc hl
; 	ret

; ConvertInternalToGB2312:
; 	push bc
; 	ld b, h
; 	ld c, l
; .loop
; 	ld a, [bc]
; 	inc bc
; 	cp a, "@"
; 	jr z, .end
; 	push de
; 	ld d, a
; 	and a, $30 ; $1X - 8 , $2X - 16
; 	rrca
; 	ld h, a
; 	ld a, d
; 	sub h
; 	dec a
; 	ld h, a
; 	ld a, [bc]
; 	inc bc
; 	ld l, a
; 	call .sqeeze50FE
; 	ld de, $FFFF - $60 + 2 + 1
; 	ld a, $A0
; .loop2
; 	inc a
; 	add hl, de
; 	jr c, .loop2
; 	cp a, $AA
; 	jr c, .skip3
; 	add a, $06
; .skip3
; 	pop de
; 	ld [de], a
; 	inc de
; 	ld a, l
; 	dec a ; SqueezeFF, so sub loop end at $A2, fit to $A1
; 	cp a, $FE
; 	jr nz, .skipGB2312FE
; 	ld a, $A0 ; not standard GB2312, replace $FE to $A0
; .skipGB2312FE
; 	ld [de], a
; 	inc de
; 	pop hl ; bc(LENGTH) in start
; 	dec hl
; 	dec hl
; 	push hl
; 	jr .loop
; .end
; 	ld [de], a
; 	inc de
; 	ld h, b
; 	ld l, c
; 	pop bc
; 	dec bc
; 	ret
; .sqeeze50FE:
; 	ld a, $FF
; 	ld d, a
; 	inc hl ; move FF to next h, hl + 1
; 	sub h
; 	sub h
; 	ld e, a
; 	ld a, l
; 	add hl, de ; above: hl + 1 - h * 2 - 1
; 	cp a, "@" + 1
; 	ret c
; 	dec hl
; 	ret

Link_CopyOTData:
.loop
	ld a, [hli]
	cp SERIAL_NO_DATA_BYTE
	jr z, .loop
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

Link_CopyRandomNumbers:
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	ret z
	ld hl, wEnemyMonSpecies
	call Link_FindFirstNonControlCharacter_AllowZero
	ld de, wLinkBattleRNs
	ld c, 10
.loop
	ld a, [hli]
	cp SERIAL_NO_DATA_BYTE
	jr z, .loop
	cp SERIAL_PREAMBLE_BYTE
	jr z, .loop
	ld [de], a
	inc de
	dec c
	jr nz, .loop
	ret

Link_FindFirstNonControlCharacter_SkipZero:
.loop
	ld a, [hli]
	and a
	jr z, .loop
	cp SERIAL_PREAMBLE_BYTE
	jr z, .loop
	cp SERIAL_NO_DATA_BYTE
	jr z, .loop
	dec hl
	ret

Link_FindFirstNonControlCharacter_AllowZero:
.loop
	ld a, [hli]
	cp SERIAL_PREAMBLE_BYTE
	jr z, .loop
	cp SERIAL_NO_DATA_BYTE
	jr z, .loop
	dec hl
	ret

InitTradeMenuDisplay:
	call ClearScreen
	call LoadTradeScreenBorderGFX
	farcall InitTradeSpeciesList
	xor a
	ld hl, wOtherPlayerLinkMode
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, 1
	ld [wMenuCursorY], a
	inc a
	ld [wPlayerLinkAction], a
	jp LinkTrade_PlayerPartyMenu

LinkTrade_OTPartyMenu:
	ld a, OTPARTYMON
	ld [wMonType], a
	ld a, A_BUTTON | D_UP | D_DOWN | D_LEFT
	ld [wMenuJoypadFilter], a
	ld a, [wOTPartyCount]
	ld [w2DMenuNumRows], a
	ld a, 1
	ld [w2DMenuNumCols], a
	ld a, 3
	ld [w2DMenuCursorInitY], a
	ld a, 11
	ld [w2DMenuCursorInitX], a
	ld a, 1
	ld [wMenuCursorX], a
	ln a, 2, 0
	ld [w2DMenuCursorOffsets], a
	ld a, MENU_UNUSED_3
	ld [w2DMenuFlags1], a
	xor a
	ld [w2DMenuFlags2], a

LinkTradeOTPartymonMenuLoop:
	farcall LinkTradeMenu
	ld a, d
	and a
	jp z, LinkTradePartiesMenuMasterLoop
	bit A_BUTTON_F, a
	jr z, .not_a_button
	ld a, INIT_ENEMYOT_LIST
	ld [wInitListType], a
	callfar InitList
	ld hl, wOTPartyMon1Species
	farcall LinkMonStatsScreen
	jp LinkTradePartiesMenuMasterLoop

.not_a_button
	bit D_LEFT_F, a
	jr z, .not_d_left
	xor a
	ld [wMonType], a
	call HideCursor
	ld a, [wMenuCursorY]
	ld b, a
	ld a, [wPartyCount]
	cp b
	jr nc, LinkTrade_PlayerPartyMenu
	ld [wMenuCursorY], a
.skip
	jr LinkTrade_PlayerPartyMenu

.not_d_left
	bit D_UP_F, a
	jr z, .not_d_up
	ld a, [wMenuCursorY]
	ld b, a
	ld a, [wOTPartyCount]
	cp b
	jp nz, LinkTradePartiesMenuMasterLoop
	; xor a
	; ld [wMonType], a
	call HideCursor
	; push hl
	; push bc
	; ld bc, NAME_LENGTH
	; add hl, bc
	; ld [hl], " "
	; pop bc
	; pop hl
	; ld a, [wPartyCount]
	; ld [wMenuCursorY], a
	; jr LinkTrade_PlayerPartyMenu
	jp Function28ade

.not_d_up
	bit D_DOWN_F, a
	jp z, LinkTradePartiesMenuMasterLoop
	; jp Function28ac9
	ld a, [wMenuCursorY]
	dec a
	jp nz, LinkTradePartiesMenuMasterLoop
	call HideCursor
	jp Function28ade

LinkTrade_PlayerPartyMenu:
	farcall InitMG_Mobile_LinkTradePalMap
	xor a
	ld [wMonType], a
	ld a, A_BUTTON | D_UP | D_DOWN | D_RIGHT
	ld [wMenuJoypadFilter], a
	ld a, [wPartyCount]
	ld [w2DMenuNumRows], a
	ld a, 1
	ld [w2DMenuNumCols], a
	ld a, 3
	ld [w2DMenuCursorInitY], a
	ld a, 8
	ld [w2DMenuCursorInitX], a
	ld a, 1
	ld [wMenuCursorX], a
	ln a, 2, 0
	ld [w2DMenuCursorOffsets], a
	ld a, MENU_UNUSED_3
	ld [w2DMenuFlags1], a
	xor a
	ld [w2DMenuFlags2], a
	call WaitBGMap2

LinkTradePartymonMenuLoop:
	farcall LinkTradeMenu
	ld a, d
	and a
	jr nz, .check_joypad
	jp LinkTradePartiesMenuMasterLoop

.check_joypad
	bit A_BUTTON_F, a
	jr z, .not_a_button
	jp Function28926

.not_a_button
	bit D_RIGHT_F, a
	jr z, .not_d_right
	ld a,OTPARTYMON
	ld [wMonType], a
	call HideCursor
	ld a, [wMenuCursorY]
	ld b, a
	ld a, [wOTPartyCount]
	cp b
	jp nc, LinkTrade_OTPartyMenu
	ld [wMenuCursorY], a
.skip
	jp LinkTrade_OTPartyMenu

.not_d_right
	bit D_DOWN_F, a
	jr z, .not_d_down
	ld a, [wMenuCursorY]
	dec a
	jp nz, LinkTradePartiesMenuMasterLoop
	; ld a, OTPARTYMON
	; ld [wMonType], a
	call HideCursor
	; push hl
	; push bc
	; ld bc, NAME_LENGTH
	; add hl, bc
	; ld [hl], " "
	; pop bc
	; pop hl
	; ld a, 1
	; ld [wMenuCursorY], a
	; jp LinkTrade_OTPartyMenu
	jp Function28ade

.not_d_down
	bit D_UP_F, a
	jr z, LinkTradePartiesMenuMasterLoop
	ld a, [wMenuCursorY]
	ld b, a
	ld a, [wPartyCount]
	cp b
	jr nz, LinkTradePartiesMenuMasterLoop
	call HideCursor
	; push hl
	; push bc
	; ld bc, NAME_LENGTH
	; add hl, bc
	; ld [hl], " "
	; pop bc
	; pop hl
	jp Function28ade

LinkTradePartiesMenuMasterLoop:
	ld a, [wMonType]
	and a
	jp z, LinkTradePartymonMenuLoop ; PARTYMON
	jp LinkTradeOTPartymonMenuLoop  ; OTPARTYMON

Function28926:
	call LoadTilemapToTempTilemap
	ld a, [wMenuCursorY]
	push af
	hlcoord 0, 14
	ld b, 2
	ld c, 18
	call LinkTextboxAtHL
	hlcoord 2, 16
	ld de, .String_Stats_Trade
	call PlaceString
	farcall Link_WaitBGMap

.joy_loop
	ld a, " "
	ldcoord_a 11, 16
	ld a, A_BUTTON | B_BUTTON | D_RIGHT
	ld [wMenuJoypadFilter], a
	ld a, 1
	ld [w2DMenuNumRows], a
	ld a, 1
	ld [w2DMenuNumCols], a
	ld a, 16
	ld [w2DMenuCursorInitY], a
	ld a, 1
	ld [w2DMenuCursorInitX], a
	ld a, 1
	ld [wMenuCursorY], a
	ld [wMenuCursorX], a
	ln a, 2, 0
	ld [w2DMenuCursorOffsets], a
	xor a
	ld [w2DMenuFlags1], a
	ld [w2DMenuFlags2], a
	call ScrollingMenuJoypad
	bit D_RIGHT_F, a
	jr nz, .d_right
	bit B_BUTTON_F, a
	jr z, .show_stats
.b_button
	pop af
	ld [wMenuCursorY], a
	call SafeLoadTempTilemapToTilemap
	jp LinkTrade_PlayerPartyMenu

.d_right
	ld a, " "
	ldcoord_a 1, 16
	ld a, A_BUTTON | B_BUTTON | D_LEFT
	ld [wMenuJoypadFilter], a
	ld a, 1
	ld [w2DMenuNumRows], a
	ld a, 1
	ld [w2DMenuNumCols], a
	ld a, 16
	ld [w2DMenuCursorInitY], a
	ld a, 11
	ld [w2DMenuCursorInitX], a
	ld a, 1
	ld [wMenuCursorY], a
	ld [wMenuCursorX], a
	ln a, 2, 0
	ld [w2DMenuCursorOffsets], a
	xor a
	ld [w2DMenuFlags1], a
	ld [w2DMenuFlags2], a
	call ScrollingMenuJoypad
	bit D_LEFT_F, a
	jp nz, .joy_loop
	bit B_BUTTON_F, a
	jr nz, .b_button
	jr .try_trade

.show_stats
	pop af
	ld [wMenuCursorY], a
	ld a, INIT_PLAYEROT_LIST
	ld [wInitListType], a
	callfar InitList
	farcall LinkMonStatsScreen
	call SafeLoadTempTilemapToTilemap
	hlcoord 8, 3
	lb bc, 11, 1
	; ld a, " "
	; call LinkEngine_FillBox
	; hlcoord 17, 1
	; lb bc, 6, 1
	ld a, " "
	call LinkEngine_FillBox
	jp LinkTrade_PlayerPartyMenu

.try_trade
	call PlaceHollowCursor
	pop af
	ld [wMenuCursorY], a
	dec a
	ld [wd002], a
	ld [wPlayerLinkAction], a
	farcall Function16d6ce
	ld a, [wOtherPlayerLinkMode]
	cp $f
	jp z, InitTradeMenuDisplay
	ld [wd003], a
	call Function28b68
	ld c, 100
	call DelayFrames
	farcall ValidateOTTrademon
	jr c, .abnormal
	farcall CheckAnyOtherAliveMonsForTrade
	jp nc, LinkTrade
	xor a
	ld [wcf57], a
	ld [wOtherPlayerLinkAction], a
	hlcoord 0, 12
	ld b, 4
	ld c, 18
	call LinkTextboxAtHL
	farcall Link_WaitBGMap
	ld hl, .LinkTradeCantBattleText
	bccoord 1, 14
	call PlaceHLTextAtBC
	jr .cancel_trade

.abnormal
	xor a
	ld [wcf57], a
	ld [wOtherPlayerLinkAction], a
	ld a, [wd003]
	ld hl, wOTPartySpecies
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	hlcoord 0, 12
	ld b, 4
	ld c, 18
	call LinkTextboxAtHL
	farcall Link_WaitBGMap
	ld hl, .LinkAbnormalMonText
	bccoord 1, 14
	call PlaceHLTextAtBC

.cancel_trade
	hlcoord 0, 12
	ld b, 4
	ld c, 18
	call LinkTextboxAtHL
	hlcoord 1, 14
	ld de, String_TooBadTheTradeWasCanceled
	call PlaceString
	ld a, $1
	ld [wPlayerLinkAction], a
	farcall Function16d6ce
	ld c, 100
	call DelayFrames
	jp InitTradeMenuDisplay

.LinkTradeCantBattleText:
	text_far _LinkTradeCantBattleText
	text_end

.String_Stats_Trade:
	db "状态       交换@"

.LinkAbnormalMonText:
	text_far _LinkAbnormalMonText
	text_end

Function28ac9:
	ld a, [wMenuCursorY]
	cp 1
	jp nz, LinkTradePartiesMenuMasterLoop
	call HideCursor
	; push hl
	; push bc
	; ld bc, NAME_LENGTH
	; add hl, bc
	; ld [hl], " "
	; pop bc
	; pop hl
Function28ade:
.loop1
	ld a, "▶"
	ldcoord_a 2, 17
.loop2
	call JoyTextDelay
	ldh a, [hJoyLast]
	and a
	jr z, .loop2
	bit A_BUTTON_F, a
	jr nz, .a_button
	push af
	ld a, " "
	ldcoord_a 2, 17
	pop af
	bit D_UP_F, a
	jr z, .d_up
	ld a, [wPartyCount]
	ld [wMenuCursorY], a
	jp LinkTrade_PlayerPartyMenu

.d_up
	ld a, $1
	ld [wMenuCursorY], a
	jp LinkTrade_PlayerPartyMenu

.a_button
	ld a, "▷"
	ldcoord_a 2, 17
	ld a, $f
	ld [wPlayerLinkAction], a
	farcall Function16d6ce
	ld a, [wOtherPlayerLinkMode]
	cp $f
	jr nz, .loop1
Function28b22:
	call RotateThreePalettesRight
	call ClearScreen
	ld b, SCGB_DIPLOMA
	call GetSGBLayout
	call WaitBGMap2
	xor a
	ld [wcfbb], a
	xor a
	ldh [rSB], a
	ldh [hSerialSend], a
	ld a, (0 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	vc_hook ExitLinkCommunications_ret
	ret

Function28b42: ; unreferenced
	hlcoord 0, 16
	ld a, "┘"
	ld bc, 2 * SCREEN_WIDTH
	call ByteFill
	hlcoord 1, 16
	ld a, " "
	ld bc, SCREEN_WIDTH - 2
	call ByteFill
	hlcoord 2, 16
	ld de, .CancelString
	jp PlaceString

.CancelString:
	db "CANCEL@"

Function28b68:
	ld a, [wOtherPlayerLinkMode]
	hlcoord 11, 3
	ld bc, SCREEN_WIDTH * 2
	call AddNTimes
	ld [hl], "▷"
	ret

LinkEngine_FillBox:
.row
	push bc
	push hl
.col
	ld [hli], a
	dec c
	jr nz, .col
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	dec b
	jr nz, .row
	ret

LinkTrade:
	xor a
	ld [wcf57], a
	ld [wOtherPlayerLinkAction], a
	hlcoord 0, 12
	ld b, 4
	ld c, 18
	call LinkTextboxAtHL
	farcall Link_WaitBGMap
	ld a, [wd002]
	ld hl, wPartySpecies
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	ld hl, wStringBuffer1
	ld de, wd004
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	ld a, [wd003]
	ld hl, wOTPartySpecies
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	ld hl, LinkAskTradeForText
	bccoord 1, 14
	call PlaceHLTextAtBC
	call LoadStandardMenuHeader
	hlcoord 13, 6
	ld b, 4
	ld c, 4
	call LinkTextboxAtHL
	ld de, String28eab
	hlcoord 15, 8
	call PlaceString
	ld a, 8
	ld [w2DMenuCursorInitY], a
	ld a, 14
	ld [w2DMenuCursorInitX], a
	ld a, 1
	ld [w2DMenuNumCols], a
	ld a, 2
	ld [w2DMenuNumRows], a
	xor a
	ld [w2DMenuFlags1], a
	ld [w2DMenuFlags2], a
	ld a, $20
	ld [w2DMenuCursorOffsets], a
	ld a, A_BUTTON | B_BUTTON
	ld [wMenuJoypadFilter], a
	ld a, 1
	ld [wMenuCursorY], a
	ld [wMenuCursorX], a
	farcall Link_WaitBGMap
	call ScrollingMenuJoypad
	push af
	call Call_ExitMenu
	call WaitBGMap2
	pop af
	bit 1, a
	jr nz, .asm_28c33
	ld a, [wMenuCursorY]
	dec a
	jr z, .asm_28c54

.asm_28c33
	ld a, $1
	ld [wPlayerLinkAction], a
	hlcoord 0, 12
	ld b, 4
	ld c, 18
	call LinkTextboxAtHL
	hlcoord 1, 14
	ld de, String_TooBadTheTradeWasCanceled
	call PlaceString
	farcall Function16d6ce
	jp Function28ea3

.asm_28c54
	ld a, $2
	ld [wPlayerLinkAction], a
	farcall Function16d6ce
	ld a, [wOtherPlayerLinkMode]
	dec a
	jr nz, .asm_28c7b
	hlcoord 0, 12
	ld b, 4
	ld c, 18
	call LinkTextboxAtHL
	hlcoord 1, 14
	ld de, String_TooBadTheTradeWasCanceled
	call PlaceString
	jp Function28ea3

.asm_28c7b
	ld hl, sPartyMail
	ld a, [wd002]
	ld bc, MAIL_STRUCT_LENGTH
	call AddNTimes
	ld a, BANK(sPartyMail)
	call OpenSRAM
	ld d, h
	ld e, l
	ld bc, MAIL_STRUCT_LENGTH
	add hl, bc
	ld a, [wd002]
	ld c, a
.asm_28c96
	inc c
	ld a, c
	cp PARTY_LENGTH
	jr z, .asm_28ca6
	push bc
	ld bc, MAIL_STRUCT_LENGTH
	call CopyBytes
	pop bc
	jr .asm_28c96

.asm_28ca6
	ld hl, sPartyMail
	ld a, [wPartyCount]
	dec a
	ld bc, MAIL_STRUCT_LENGTH
	call AddNTimes
	push hl
	ld hl, wc9f4
	ld a, [wd003]
	ld bc, MAIL_STRUCT_LENGTH
	call AddNTimes
	pop de
	ld bc, MAIL_STRUCT_LENGTH
	call CopyBytes
	call CloseSRAM
	ld hl, wPlayerName
	ld de, wPlayerTrademonSenderName
	ld bc, NAME_LENGTH
	call CopyBytes
	ld a, [wd002]
	ld hl, wPartySpecies
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	ld [wPlayerTrademonSpecies], a
	push af
	ld a, [wd002]
	ld hl, wPartyMonOT
	call SkipNames
	ld de, wPlayerTrademonOTName
	ld bc, NAME_LENGTH
	call CopyBytes
	ld hl, wPartyMon1ID
	ld a, [wd002]
	call GetPartyLocation
	ld a, [hli]
	ld [wPlayerTrademonID], a
	ld a, [hl]
	ld [wPlayerTrademonID + 1], a
	ld hl, wPartyMon1DVs
	ld a, [wd002]
	call GetPartyLocation
	ld a, [hli]
	ld [wPlayerTrademonDVs], a
	ld a, [hl]
	ld [wPlayerTrademonDVs + 1], a
	ld a, [wd002]
	ld hl, wPartyMon1Species
	call GetPartyLocation
	ld b, h
	ld c, l
	farcall GetCaughtGender
	ld a, c
	ld [wPlayerTrademonCaughtData], a
	ld hl, wOTPlayerName
	ld de, wOTTrademonSenderName
	ld bc, NAME_LENGTH
	call CopyBytes
	ld a, [wd003]
	ld hl, wOTPartySpecies
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	ld [wOTTrademonSpecies], a
	ld a, [wd003]
	ld hl, wOTPartyMonOT
	call SkipNames
	ld de, wOTTrademonOTName
	ld bc, NAME_LENGTH
	call CopyBytes
	ld hl, wOTPartyMon1ID
	ld a, [wd003]
	call GetPartyLocation
	ld a, [hli]
	ld [wOTTrademonID], a
	ld a, [hl]
	ld [wOTTrademonID + 1], a
	ld hl, wOTPartyMon1DVs
	ld a, [wd003]
	call GetPartyLocation
	ld a, [hli]
	ld [wOTTrademonDVs], a
	ld a, [hl]
	ld [wOTTrademonDVs + 1], a
	ld a, [wd003]
	ld hl, wOTPartyMon1Species
	call GetPartyLocation
	ld b, h
	ld c, l
	farcall GetCaughtGender
	ld a, c
	ld [wOTTrademonCaughtData], a
	ld a, [wd002]
	ld [wCurPartyMon], a
	ld hl, wPartySpecies
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	ld [wd002], a
	xor a ; REMOVE_PARTY
	ld [wPokemonWithdrawDepositParameter], a
	callfar RemoveMonFromPartyOrBox
	ld a, [wPartyCount]
	dec a
	ld [wCurPartyMon], a
	ld a, TRUE
	ld [wForceEvolution], a
	ld a, [wd003]
	push af
	ld hl, wOTPartySpecies
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	ld [wd003], a
	ld c, 100
	call DelayFrames
	call ClearTilemap
	call LoadFontsBattleExtra
	ld b, SCGB_DIPLOMA
	call GetSGBLayout
	ldh a, [hSerialConnectionStatus]
	cp USING_EXTERNAL_CLOCK
	jr z, .player_2
	predef TradeAnimation
	jr .done_animation

.player_2
	predef TradeAnimationPlayer2

.done_animation
	pop af
	ld c, a
	ld [wCurPartyMon], a
	ld hl, wOTPartySpecies
	ld d, 0
	ld e, a
	add hl, de
	ld a, [hl]
	ld [wCurPartySpecies], a
	ld hl, wOTPartyMon1Species
	ld a, c
	call GetPartyLocation
	ld de, wTempMonSpecies
	ld bc, PARTYMON_STRUCT_LENGTH
	call CopyBytes
	predef AddTempmonToParty
	ld a, [wPartyCount]
	dec a
	ld [wCurPartyMon], a
	callfar EvolvePokemon
	call ClearScreen
	call LoadTradeScreenBorderGFX
	call SetTradeRoomBGPals
	farcall Link_WaitBGMap

; Check if either of the Pokémon sent was a Mew or Celebi, and send a different
; byte depending on that. Presumably this would've been some prevention against
; illicit trade machines, but it doesn't seem like a very effective one.
; Removing this code breaks link compatibility with the vanilla gen2 games, but
; has otherwise no consequence.
	ld b, 1
	pop af
	ld c, a
	cp MEW
	jr z, .send_checkbyte
	ld a, [wCurPartySpecies]
	cp MEW
	jr z, .send_checkbyte
	ld b, 2
	ld a, c
	cp CELEBI
	jr z, .send_checkbyte
	ld a, [wCurPartySpecies]
	cp CELEBI
	jr z, .send_checkbyte

; Send the byte in a loop until the desired byte has been received.
	ld b, 0
.send_checkbyte
	ld a, b
	ld [wPlayerLinkAction], a
	push bc
	call Serial_PrintWaitingTextAndSyncAndExchangeNybble
	pop bc
	ld a, [wLinkMode]
	cp LINK_TIMECAPSULE
	jr z, .save
	ld a, b
	and a
	jr z, .save
	ld a, [wOtherPlayerLinkAction]
	cp b
	jr nz, .send_checkbyte

.save
	farcall SaveAfterLinkTrade
	farcall StubbedTrainerRankings_Trades
	farcall BackupMobileEventIndex
	ld c, 40
	call DelayFrames
	hlcoord 0, 12
	ld b, 4
	ld c, 18
	call LinkTextboxAtHL
	hlcoord 1, 14
	ld de, String28ebd
	call PlaceString
	farcall Link_WaitBGMap
	vc_hook Trade_save_game_end
	ld c, 50
	call DelayFrames
	ld a, [wLinkMode]
	cp LINK_TIMECAPSULE
	jp z, Gen2ToGen1LinkComms
	jp Gen2ToGen2LinkComms

Function28ea3:
	ld c, 100
	call DelayFrames
	jp InitTradeMenuDisplay

String28eab:
	db   "交换"
	next "取消@"

LinkAskTradeForText:
	text_far _LinkAskTradeForText
	text_end

String28ebd:
	db   "交换结束！@"

String_TooBadTheTradeWasCanceled:
	db   "真遗憾！"
	next "交换被切断了！@"

LinkTextboxAtHL:
	ld d, h
	ld e, l
	farcall LinkTextbox
	ret

LoadTradeScreenBorderGFX:
	farcall _LoadTradeScreenBorderGFX
	ret

SetTradeRoomBGPals:
	farcall LoadTradeRoomBGPals ; just a nested farcall; so wasteful
	call SetPalettes
	ret

PlaceTradeScreenTextbox: ; unreferenced
	hlcoord 0, 0
	ld b, 6
	ld c, 18
	call LinkTextboxAtHL
	hlcoord 0, 8
	ld b, 6
	ld c, 18
	call LinkTextboxAtHL
	farcall PlaceTradePartnerNamesAndParty
	ret

INCLUDE "engine/movie/trade_animation.asm"

CheckTimeCapsuleCompatibility:
; Checks to see if your party is compatible with the Gen 1 games.
; Returns the following in wScriptVar:
; 0: Party is okay
; 1: At least one Pokémon was introduced in Gen 2
; 2: At least one Pokémon has a move that was introduced in Gen 2
; 3: At least one Pokémon is holding mail

; If any party Pokémon was introduced in the Gen 2 games, don't let it in.
	ld hl, wPartySpecies
	ld b, PARTY_LENGTH
.loop
	ld a, [hli]
	cp -1
	jr z, .checkitem
	cp JOHTO_POKEMON
	jr nc, .mon_too_new
	dec b
	jr nz, .loop

; If any party Pokémon is holding mail, don't let it in.
.checkitem
	ld a, [wPartyCount]
	ld b, a
	ld hl, wPartyMon1Item
.itemloop
	push hl
	push bc
	ld d, [hl]
	farcall ItemIsMail
	pop bc
	pop hl
	jr c, .mon_has_mail
	ld de, PARTYMON_STRUCT_LENGTH
	add hl, de
	dec b
	jr nz, .itemloop

; If any party Pokémon has a move that was introduced in the Gen 2 games, don't let it in.
	ld hl, wPartyMon1Moves
	ld a, [wPartyCount]
	ld b, a
.move_loop
	ld c, NUM_MOVES
.move_next
	ld a, [hli]
	cp STRUGGLE + 1
	jr nc, .move_too_new
	dec c
	jr nz, .move_next
	ld de, PARTYMON_STRUCT_LENGTH - NUM_MOVES
	add hl, de
	dec b
	jr nz, .move_loop
	xor a
	jr .done

.mon_too_new
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	ld a, $1
	jr .done

.move_too_new
	push bc
	ld [wNamedObjectIndexBuffer], a
	call GetMoveName
	call CopyName1
	pop bc
	call GetIncompatibleMonName
	ld a, $2
	jr .done

.mon_has_mail
	call GetIncompatibleMonName
	ld a, $3

.done
	ld [wScriptVar], a
	ret

GetIncompatibleMonName:
; Calulate which pokemon is incompatible, and get that pokemon's name
	ld a, [wPartyCount]
	sub b
	ld c, a
	inc c
	ld b, 0
	ld hl, wPartyCount
	add hl, bc
	ld a, [hl]
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	ret

EnterTimeCapsule:
	vc_patch Wireless_net_delay_6
if DEF(_CRYSTAL11_VC)
	ld c, 26
else
	ld c, 10
endc
	vc_patch_end Wireless_net_delay_6
	call DelayFrames
	ld a, $4
	call Link_EnsureSync
	ld c, 40
	call DelayFrames
	xor a
	ldh [hVBlank], a
	inc a ; LINK_TIMECAPSULE
	ld [wLinkMode], a
	ret

WaitForOtherPlayerToExit:
	ld c, 3
	call DelayFrames
	ld a, CONNECTION_NOT_ESTABLISHED
	ldh [hSerialConnectionStatus], a
	xor a
	ldh [rSB], a
	ldh [hSerialReceive], a
	ld a, (0 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld c, 3
	call DelayFrames
	xor a
	ldh [rSB], a
	ldh [hSerialReceive], a
	ld a, (0 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	ld c, 3
	call DelayFrames
	xor a
	ldh [rSB], a
	ldh [hSerialReceive], a
	ldh [rSC], a
	ld c, 3
	call DelayFrames
	ld a, CONNECTION_NOT_ESTABLISHED
	ldh [hSerialConnectionStatus], a
	ldh a, [rIF]
	push af
	xor a
	ldh [rIF], a
	ld a, IE_DEFAULT
	ldh [rIE], a
	pop af
	ldh [rIF], a
	ld hl, wLinkTimeoutFrames
	xor a
	ld [hli], a
	ld [hl], a
	ldh [hVBlank], a
	ld [wLinkMode], a
	vc_hook Wireless_term_exit
	ret

SetBitsForLinkTradeRequest:
	ld a, LINK_TRADECENTER - 1
	ld [wPlayerLinkAction], a
	ld [wChosenCableClubRoom], a
	ret

SetBitsForBattleRequest:
	ld a, LINK_COLOSSEUM - 1
	ld [wPlayerLinkAction], a
	ld [wChosenCableClubRoom], a
	ret

SetBitsForTimeCapsuleRequest:
	ld a, USING_INTERNAL_CLOCK
	ldh [rSB], a
	xor a
	ldh [hSerialReceive], a
	ld a, (0 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	xor a ; LINK_TIMECAPSULE - 1
	ld [wPlayerLinkAction], a
	ld [wChosenCableClubRoom], a
	ret

WaitForLinkedFriend:
	ld a, [wPlayerLinkAction]
	and a
	jr z, .no_link_action
	ld a, USING_INTERNAL_CLOCK
	ldh [rSB], a
	xor a
	ldh [hSerialReceive], a
	ld a, (0 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	call DelayFrame
	call DelayFrame
	call DelayFrame

.no_link_action
	ld a, $2
	ld [wLinkTimeoutFrames + 1], a
	ld a, $ff
	ld [wLinkTimeoutFrames], a
.loop
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	jr z, .connected
	cp USING_EXTERNAL_CLOCK
	jr z, .connected
	ld a, CONNECTION_NOT_ESTABLISHED
	ldh [hSerialConnectionStatus], a
	ld a, USING_INTERNAL_CLOCK
	ldh [rSB], a
	xor a
	ldh [hSerialReceive], a
	ld a, (0 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (0 << rSC_CLOCK)
; This vc_hook causes the Virtual Console to set [hSerialConnectionStatus] to
; USING_INTERNAL_CLOCK, which allows the player to proceed past the link
; receptionist's "Please wait." It assumes that hSerialConnectionStatus is at
; its original address.
	vc_hook Link_fake_connection_status
	vc_assert hSerialConnectionStatus == $ffcb, \
		"hSerialConnectionStatus is no longer located at 00:ffcb."
	vc_assert USING_INTERNAL_CLOCK == $02, \
		"USING_INTERNAL_CLOCK is no longer equal to $02."
	ldh [rSC], a
	ld a, [wLinkTimeoutFrames]
	dec a
	ld [wLinkTimeoutFrames], a
	jr nz, .not_done
	ld a, [wLinkTimeoutFrames + 1]
	dec a
	ld [wLinkTimeoutFrames + 1], a
	jr z, .done

.not_done
	ld a, USING_EXTERNAL_CLOCK
	ldh [rSB], a
	ld a, (0 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	call DelayFrame
	jr .loop

.connected
	call LinkDataReceived
	call DelayFrame
	call LinkDataReceived
	ld c, 50
	call DelayFrames
	ld a, $1
	ld [wScriptVar], a
	ret

.done
	xor a
	ld [wScriptVar], a
	ret

CheckLinkTimeout_Receptionist:
	ld a, $1
	ld [wPlayerLinkAction], a
	ld hl, wLinkTimeoutFrames
	ld a, $3
	ld [hli], a
	xor a
	ld [hl], a
	call WaitBGMap
	ld a, $2
	ldh [hVBlank], a
	call DelayFrame
	call DelayFrame
	call Link_CheckCommunicationError
	xor a
	ldh [hVBlank], a
	ld a, [wScriptVar]
	and a
	ret nz
	jp Link_ResetSerialRegistersAfterLinkClosure

CheckLinkTimeout_Gen2:
; if wScriptVar = 0 on exit, link connection is closed
	ld a, $5
	ld [wPlayerLinkAction], a
	ld hl, wLinkTimeoutFrames
	ld a, 3
	ld [hli], a
	xor a
	ld [hl], a
	call WaitBGMap
	ld a, $2
	ldh [hVBlank], a
	call DelayFrame
	call DelayFrame
	call Link_CheckCommunicationError
	ld a, [wScriptVar]
	and a
	jr z, .exit

; Wait for ~$70000 cycles to give the other GB time to be ready
	ld bc, $ffff
.wait
	dec bc
	ld a, b
	or c
	jr nz, .wait

; If other GB is not ready at this point, disconnect due to timeout
	ld a, [wOtherPlayerLinkMode]
	cp $5
	jr nz, .timeout

; Another check to increase reliability
	ld a, $6
	ld [wPlayerLinkAction], a
	ld hl, wLinkTimeoutFrames
	vc_patch Wireless_net_delay_9
if DEF(_CRYSTAL11_VC)
	ld a, $3
else
	ld a, 1
endc
	vc_patch_end Wireless_net_delay_9
	ld [hli], a
	ld [hl], 50
	call Link_CheckCommunicationError
	ld a, [wOtherPlayerLinkMode]
	cp $6
	jr z, .exit

.timeout
	xor a
	ld [wScriptVar], a
	ret

.exit
	xor a
	ldh [hVBlank], a
	ret

Link_CheckCommunicationError:
	xor a
	ldh [hSerialReceivedNewData], a
	vc_hook Wireless_prompt
	ld a, [wLinkTimeoutFrames]
	ld h, a
	ld a, [wLinkTimeoutFrames + 1]
	ld l, a
	push hl
	call .CheckConnected
	pop hl
	jr nz, .load_true
	call .AcknowledgeSerial
	call .ConvertDW
	call .CheckConnected
	jr nz, .load_true
	call .AcknowledgeSerial
	xor a ; FALSE
	jr .done

.load_true
	ld a, TRUE

.done
	ld [wScriptVar], a
	ld hl, wLinkTimeoutFrames
	xor a
	ld [hli], a
	ld [hl], a
	ret

.CheckConnected:
	call WaitLinkTransfer
	ld hl, wLinkTimeoutFrames
	vc_hook Wireless_net_recheck
	ld a, [hli]
	inc a
	ret nz
	ld a, [hl]
	inc a
	ret

.AcknowledgeSerial:
	vc_patch Wireless_net_delay_7
if DEF(_CRYSTAL11_VC)
	ld b, 26
else
	ld b, 10
endc
	vc_patch_end Wireless_net_delay_7
.loop
	call DelayFrame
	call LinkDataReceived
	dec b
	jr nz, .loop
	ret

.ConvertDW:
	; [wLinkTimeoutFrames] = ((hl - $100) / 4) + $100
	;                      = (hl / 4) + $c0
	dec h
	srl h
	rr l
	srl h
	rr l
	inc h
	ld a, h
	ld [wLinkTimeoutFrames], a
	ld a, l
	ld [wLinkTimeoutFrames + 1], a
	ret

TryQuickSave:
	ld a, [wChosenCableClubRoom]
	push af
	farcall Link_SaveGame
	vc_hook Wireless_TryQuickSave_block_input_1
	ld a, TRUE
	jr nc, .return_result
	vc_hook Wireless_TryQuickSave_block_input_2
	xor a ; FALSE
.return_result
	ld [wScriptVar], a
	ld c, 30
	call DelayFrames
	pop af
	ld [wChosenCableClubRoom], a
	ret

CheckBothSelectedSameRoom:
	ld a, [wChosenCableClubRoom]
	call Link_EnsureSync
	push af
	call LinkDataReceived
	call DelayFrame
	call LinkDataReceived
	pop af
	ld b, a
	ld a, [wChosenCableClubRoom]
	cp b
	jr nz, .fail
	ld a, [wChosenCableClubRoom]
	inc a
	ld [wLinkMode], a
	xor a
	ldh [hVBlank], a
	ld a, TRUE
	ld [wScriptVar], a
	ret

.fail
	xor a ; FALSE
	ld [wScriptVar], a
	ret

TimeCapsule:
	vc_hook Wireless_TimeCapsule
	ld a, LINK_TIMECAPSULE
	ld [wLinkMode], a
	call DisableSpriteUpdates
	callfar LinkCommunications
	call EnableSpriteUpdates
	xor a
	ldh [hVBlank], a
	ret

TradeCenter:
	vc_hook Wireless_TradeCenter
	ld a, LINK_TRADECENTER
	ld [wLinkMode], a
	call DisableSpriteUpdates
	callfar LinkCommunications
	call EnableSpriteUpdates
	xor a
	ldh [hVBlank], a
	ret

Colosseum:
	vc_hook Wireless_Colosseum
	ld a, LINK_COLOSSEUM
	ld [wLinkMode], a
	call DisableSpriteUpdates
	callfar LinkCommunications
	call EnableSpriteUpdates
	xor a
	ldh [hVBlank], a
	ret

CloseLink:
	xor a
	ld [wLinkMode], a
	ld c, 3
	call DelayFrames
	vc_hook Wireless_room_check
	jp Link_ResetSerialRegistersAfterLinkClosure

FailedLinkToPast:
	ld c, 40
	call DelayFrames
	ld a, $e
	jp Link_EnsureSync

Link_ResetSerialRegistersAfterLinkClosure:
	ld c, 3
	call DelayFrames
	ld a, CONNECTION_NOT_ESTABLISHED
	ldh [hSerialConnectionStatus], a
	ld a, USING_INTERNAL_CLOCK
	ldh [rSB], a
	xor a
	ldh [hSerialReceive], a
	ldh [rSC], a
	ret

Link_EnsureSync:
	add $d0
	ld [wPlayerLinkAction], a
	ld [wcf57], a
	ld a, $2
	ldh [hVBlank], a
	call DelayFrame
	call DelayFrame
.receive_loop
	call Serial_ExchangeLinkMenuSelection
	ld a, [wOtherPlayerLinkMode]
	ld b, a
	and $f0
	cp $d0
	jr z, .done
	ld a, [wOtherPlayerLinkAction]
	ld b, a
	and $f0
	cp $d0
	jr nz, .receive_loop

.done
	xor a
	ldh [hVBlank], a
	ld a, b
	and $f
	ret

CableClubCheckWhichChris:
	ldh a, [hSerialConnectionStatus]
	cp USING_EXTERNAL_CLOCK
	ld a, TRUE
	jr z, .yes
	dec a ; FALSE

.yes
	ld [wScriptVar], a
	ret

GSLinkCommsBorderGFX: ; unreferenced
INCBIN "gfx/trade/unused_gs_border_tiles.2bpp"

CheckSRAM0Flag: ; unreferenced
; input: hl = unknown flag array in "SRAM Bank 0"
	ld a, BANK("SRAM Bank 0")
	call OpenSRAM
	ld d, 0
	ld b, CHECK_FLAG
	predef SmallFarFlagAction
	call CloseSRAM
	ld a, c
	and a
	ret
