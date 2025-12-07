typedef struct
{
	int magicNum;
	int numWadEntries;
	int offsetOfEntries;
} wad3_header;

typedef struct
{
	int offsetOfBuffer;
	int entryDiskSizeBytes;
	int entrySizeBytes;
	int padPadCompressedType;
	int fileName1;
	int fileName2;
	int fileName3;
	int fileName4;
} wad3_entries;

#define WAD3_LUMP_QPIC 0x42
#define WAD3_LUMP_MIPTEX 0x43
#define WAD3_LUMP_FONT 0x45

void
WadIndexer::IndexDecals(void)
{
#if 0
	searchhandle psh;
	filestream fh;

	psh = search_begin("decals.wad", SB_FULLPACKAGEPATH | SB_FORCESEARCH | SEARCH_ALLOWDUPES, false, GAME_DIR);
	fh = search_fopen(psh, 0);

	printf("MAIN DIR DECALS WAD: %s\n", search_getfilename(psh, 0));

	/* we found one */
	if (fh >= 0) {
		ForceLoadWad(fh);
		fclose(fh);
	}

	search_end(psh);
#endif
}

void
WadIndexer::ReadEntryAttOffset(filestream fileHandle, int theOffset)
{
	wad3_entries theEntry;
	fseek(fileHandle, theOffset);
	fread(fileHandle, &theEntry, sizeof(wad3_entries));

	int fileName[16];
	int temp;
	fileName[3] = (theEntry.fileName1 >> 24) & 0xFF;
	fileName[2] = (theEntry.fileName1 >> 16) & 0xFF;
	fileName[1] = (theEntry.fileName1 >> 8) & 0xFF;
	fileName[0] = theEntry.fileName1 & 0xFF;

	fileName[7] = (theEntry.fileName2 >> 24) & 0xFF;
	fileName[6] = (theEntry.fileName2 >> 16) & 0xFF;
	fileName[5] = (theEntry.fileName2 >> 8) & 0xFF;
	fileName[4] = theEntry.fileName2 & 0xFF;

	fileName[11] = (theEntry.fileName3 >> 24) & 0xFF;
	fileName[10] = (theEntry.fileName3 >> 16) & 0xFF;
	fileName[9] = (theEntry.fileName3 >> 8) & 0xFF;
	fileName[8] = theEntry.fileName3 & 0xFF;

	fileName[15] = (theEntry.fileName4 >> 24) & 0xFF;
	fileName[14] = (theEntry.fileName4 >> 16) & 0xFF;
	fileName[13] = (theEntry.fileName4 >> 8) & 0xFF;
	fileName[12] = theEntry.fileName4 & 0xFF;

	string part1 = strcat(chr2str(fileName[0]), chr2str(fileName[1]), chr2str(fileName[2]), chr2str(fileName[3]), chr2str(fileName[4]), chr2str(fileName[5]), chr2str(fileName[6]), chr2str(fileName[7]));
	string part2 = strcat(chr2str(fileName[8]), chr2str(fileName[9]), chr2str(fileName[10]), chr2str(fileName[11]), chr2str(fileName[12]), chr2str(fileName[13]), chr2str(fileName[14]), chr2str(fileName[15]));
	string fullName = strcat(part1, part2);

	printf("Filename: %s\n", fullName);

#if 0
	switch (theEntry.padPadCompressedType) {
	case WAD3_LUMP_QPIC:
		break;
	case WAD3_LUMP_MIPTEX:
		int mipTexWidth;
		int mipTexHeight;
		int mipOffsets[4];
		int usedPaletteColors;
		fseek(fileHandle, theEntry.offsetOfBuffer);
		fread(fileHandle, &temp, 4); /* name1 */
		fread(fileHandle, &temp, 4); /* name2 */
		fread(fileHandle, &temp, 4); /* name3 */
		fread(fileHandle, &temp, 4); /* name4 */
		fread(fileHandle, &mipTexWidth, 4);
		fread(fileHandle, &mipTexHeight, 4);
		fread(fileHandle, &mipOffsets[0], 4);
		fread(fileHandle, &mipOffsets[1], 4);
		fread(fileHandle, &mipOffsets[2], 4);
		fread(fileHandle, &mipOffsets[3], 4);

		if (mipOffsets[0] == 0) {
			return;
		}

#if 0
		if (mipOffsets[3] != 0)
			fseek(fileHandle, theEntry.offsetOfBuffer + (mipOffsets[3] + ((mipTexWidth/8) * (mipTexHeight/8))));
		else if (mipOffsets[2] != 0)
			fseek(fileHandle, theEntry.offsetOfBuffer + (mipOffsets[2] + ((mipTexWidth/4) * (mipTexHeight/4))));
		else if (mipOffsets[1] != 0)
			fseek(fileHandle, theEntry.offsetOfBuffer + (mipOffsets[1] + ((mipTexWidth/2) * (mipTexHeight/2))));
#else

		for (int i = 0; i < (mipTexWidth * mipTexHeight); i++)
			fread(fileHandle, &temp, 1);
		for (int i = 0; i < ((mipTexWidth/2) * (mipTexHeight/2)); i++)
			fread(fileHandle, &temp, 1);
		for (int i = 0; i < ((mipTexWidth/4) * (mipTexHeight/4)); i++)
			fread(fileHandle, &temp, 1);
		for (int i = 0; i < ((mipTexWidth/8) * (mipTexHeight/8)); i++)
			fread(fileHandle, &temp, 1);

#endif

		fread(fileHandle, &usedPaletteColors, 2);

		int *imageBuffer = memalloc(768 + (mipTexWidth * mipTexHeight));

		printf("preparing %s %ix%i (%i colors)\n", fullName, mipTexWidth, mipTexHeight, usedPaletteColors);

		for (int i = 0; i < (usedPaletteColors * 3); i+=3) {
			fread(fileHandle, &imageBuffer[i], 1);
			fread(fileHandle, &imageBuffer[i+1], 1);
			fread(fileHandle, &imageBuffer[i+2], 1);
		}

		fseek(fileHandle, theEntry.offsetOfBuffer + mipOffsets[0]);
		fread(fileHandle, &imageBuffer + 768, (mipTexWidth * mipTexHeight));

		printf("uploading %s %ix%i (%i colors)\n", fullName, mipTexWidth, mipTexHeight, usedPaletteColors);
		r_uploadimage(fullName, mipTexWidth, mipTexHeight, (void *)imageBuffer, 768 + (mipTexWidth * mipTexHeight), IMGFMT_P8_RGB8);

		break;
	}
#endif
}

void
WadIndexer::ForceLoadWad(filestream fileHandle)
{
	wad3_header theHeader;

	fread(fileHandle, &theHeader, sizeof(wad3_header));
	printf("Num entries: %i\n", theHeader.numWadEntries);

	for (int i = 0; i < theHeader.numWadEntries; i++) {
		ReadEntryAttOffset(fileHandle, theHeader.offsetOfEntries + (sizeof(wad3_entries) * i));
	}
}
