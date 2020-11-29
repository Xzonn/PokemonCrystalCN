LoadOverworldFont::
	farcall dfsClearCache
	ld a, DFS_FONT_STYLE_OVERWORLD
	ld [wDFSFontSytle], a
	dec a ; DFS_VRAM_LIMIT_VRAM0
	ld [wDFSVramLimit], a

	ld de, .OverworldFontGFX tile (DFS_CODE_SINGLE_STA_1 - DFS_CODE_SINGLE_DYN_0)
	ld hl, vTiles1 tile (DFS_CODE_SINGLE_STA_1 - DFS_CODE_SINGLE_DYN_0)
	lb bc, BANK(.OverworldFontGFX), DFS_CODE_END - DFS_CODE_SINGLE_DYN_0_END
	call Get2bpp
	ld de, .OverworldFontSpaceGFX
	ld hl, vTiles2 tile " "
	lb bc, BANK(.OverworldFontSpaceGFX), 1
	call Get2bpp
	ret

.OverworldFontGFX:
INCBIN "gfx/font/overworld.2bpp"

.OverworldFontSpaceGFX:
INCBIN "gfx/font/overworld_space.2bpp"
