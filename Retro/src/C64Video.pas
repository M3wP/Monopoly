unit C64Video;

interface

const
	VAL_SIZ_SCREEN_PALY2X = 624;
	VAL_SIZ_SCREEN_PALX2X = 770;


type
	TC64RGBA = array[0..3] of Byte;

	TC64PaletteRGBA = array[0..15] of TC64RGBA;

	PC64PALScreen = ^TC64PALScreen;
	TC64PALScreen = array[0..VAL_SIZ_SCREEN_PALY2X - 1, 0..VAL_SIZ_SCREEN_PALX2X - 1] of TC64RGBA;

	PC64PALHalfScreen = ^TC64PALHalfScreen;
	TC64PALHalfScreen = array[0..311, 0..384] of TC64RGBA;

	TC64CharGenROM = array[0..65535] of Byte;

	TC64PalToInt = record
		case Boolean of
			False: (
				arr: TC64RGBA);
			True: (
				int: Integer);
	end;


procedure C64PaletteInit(var APalette: TC64PaletteRGBA);
procedure C64CharGenROMInit(const AFileName: string);

const
	ARR_CLR_C64ALPHA: TC64RGBA = (
		0, 0, 0, 0);

var
	GlobalC64Palette: TC64PaletteRGBA;
	GlobalC64CharGen: TC64CharGenROM;


implementation

uses
	Math, Classes;

type
	video_ycbcr_color_t = record
		y,
		cb,
		cr: Single;
	end;

	video_ycbcr_palette_t = array[0..15] of video_ycbcr_color_t;

	video_cbm_color_t = record
		luminance,
		angle: Single;
		direction: Integer;         // +1 (pos), -1 (neg) or 0 (grey)
		name: string;             	// name of this color
	end;

	video_cbm_palette_t = record
		entries: array[0..15] of video_cbm_color_t;         // array of colors
		saturation, 				// base saturation of all colors except the grey tones
		phase: Single;      		// color phase (will be added to all color angles)
	end;

const
//base saturation of all colors except the grey tones
	VICII_SATURATION = 48.0;

//phase shift of all colors
	VICII_PHASE = -4.5;

//chroma angles in UV space
	ANGLE_RED	= 112.5;
	ANGLE_GRN   = -135.0;
	ANGLE_BLU   = 0.0;
	ANGLE_ORN   = -45.0; // negative orange (orange is at +135.0 degree)
	ANGLE_BRN   = 157.5;

//new luminances
	LUMN0       = 0.0;
	LUMN1    	= 56.0;
	LUMN2    	= 74.0;
	LUMN3    	= 92.0;
	LUMN4   	= 117.0;
	LUMN5   	= 128.0;
	LUMN6   	= 163.0;
	LUMN7   	= 199.0;
	LUMN8   	= 256.0;

	vicii_palette: video_cbm_palette_t = (
			entries: (
				(luminance: LUMN0; angle: ANGLE_ORN; direction: -0; name: 'Black'),
				(luminance: LUMN8; angle: ANGLE_BRN; direction: 0; name: 'White'),
				(luminance: LUMN2; angle: ANGLE_RED; direction: 1; name: 'Red'),
				(luminance: LUMN6; angle: ANGLE_RED; direction: -1; name: 'Cyan'),
				(luminance: LUMN3; angle: ANGLE_GRN; direction: -1; name: 'Purple'),
				(luminance: LUMN5; angle: ANGLE_GRN; direction: 1; name: 'Green'),
				(luminance: LUMN1; angle: ANGLE_BLU; direction: 1; name: 'Blue'),
				(luminance: LUMN7; angle: ANGLE_BLU; direction: -1; name: 'Yellow'),
				(luminance: LUMN3; angle: ANGLE_ORN; direction: -1; name: 'Orange'),
				(luminance: LUMN1; angle: ANGLE_BRN; direction: 1; name: 'Brown'),
				(luminance: LUMN5; angle: ANGLE_RED; direction: 1; name: 'Light Red'),
				(luminance: LUMN2; angle: ANGLE_RED; direction: 0; name: 'Dark Grey'),
				(luminance: LUMN4; angle: ANGLE_GRN; direction: 0; name: 'Grey'),
				(luminance: LUMN7; angle: ANGLE_GRN; direction: 1; name: 'Light Green'),
				(luminance: LUMN4; angle: ANGLE_BLU; direction: 1; name: 'Light Blue'),
				(luminance: LUMN6; angle: ANGLE_BLU; direction: 0; name: 'Light Grey'));
			saturation: VICII_SATURATION;
			phase: VICII_PHASE);


procedure video_convert_cbm_to_ycbcr(const src: video_cbm_color_t;
		basesat, phase: Single; var dst: video_ycbcr_color_t);
	begin
	dst.y:= src.luminance;

//	chrominance (U and V) of color
	dst.cb:= (basesat * Cos((src.angle + phase) * (PI / 180.0)));
	dst.cr:= (basesat * Sin((src.angle + phase) * (PI / 180.0)));

//	convert UV to CbCr
	dst.cb:= dst.cb / 0.493111;
	dst.cr:= dst.cr / 0.877283;

//	direction of color vector (-1 = inverted vector, 0 = grey vector)
	if  src.direction = 0 then
		begin
		dst.cb:= 0.0;
		dst.cr:= 0.0;
		end
	else if src.direction < 0 then
		begin
		dst.cb:= -dst.cb;
		dst.cr:= -dst.cr;
		end;
	end;

procedure video_cbm_palette_to_ycbcr(const p: video_cbm_palette_t;
		var ycbcr: video_ycbcr_palette_t);
	var
	i: Integer;

	begin
	for i:= 0 to 15 do
		video_convert_cbm_to_ycbcr(p.entries[i], p.saturation, p.phase, ycbcr[i]);
	end;


function video_gamma(value: Single; factor: Double; gamma, bri, con: Single): Single;
	begin
	value:= value + bri;
	value:= value * con;

	if  value <= 0.0 then
		begin
		Result:= 0.0;
		Exit;
		end;

	Result:= factor * Power(value, gamma);

	if  Result < 0.0 then
		Result:= 0.0;
	end;

procedure video_convert_ycbcr_to_rgb(const src: video_ycbcr_color_t;
		sat, bri, con, gam, tin: Single; var dst: TC64RGBA);
	var
	rf,
	bf,
	gf: Single;
	cb,
	cr,
	y: Single;
	factor: Double;
	r,
	g,
	b: Integer;

	begin
	cb:= src.cb;
	cr:= src.cr;
	y:= src.y;

//	apply tint
	cr:= cr + tin;

//	apply saturation
	cb:= cb * sat;
	cr:= cr * sat;

//	convert YCbCr to RGB
	bf:= cb + y;
	rf:= cr + y;
	gf:= y - (0.1145 / 0.5866) * cb - (0.2989 / 0.5866) * cr;

	factor:= Power(255.0, 1.0 - gam);
	rf:= video_gamma(rf, factor, gam, bri, con);
	gf:= video_gamma(gf, factor, gam, bri, con);
	bf:= video_gamma(bf, factor, gam, bri, con);

//	convert to int and clip to 8 bit boundaries
	r:= Trunc(rf);
	g:= Trunc(gf);
	b:= Trunc(bf);

	if  r > 255 then
		r:= 255;

	if  g > 255 then
		g:= 255;

	if  b > 255 then
		b:= 255;

	dst[0]:= r;
	dst[1]:= g;
	dst[2]:= b;
	dst[3]:= $FF;
	end;

procedure C64PaletteInit(var APalette: TC64PaletteRGBA);
	var
	ycbr: video_ycbcr_palette_t;
	i: Integer;

	begin
	video_cbm_palette_to_ycbcr(vicii_palette, ycbr);

	for i:= 0 to 15 do
		video_convert_ycbcr_to_rgb(ycbr[i], 1.25, 0.75, 1.0, 0.75, 1.0,
				APalette[i]);
	end;


procedure C64CharGenROMInit(const AFileName: string);
	var
	m: TMemoryStream;

	begin
	m:= TMemoryStream.Create;
	try
		m.LoadFromFile(AFileName);
		m.Position:= 0;

		Move(m.Memory^, GlobalC64CharGen[0], m.Size);

		finally
		m.Free;
		end;
    end;

initialization
	C64PaletteInit(GlobalC64Palette);

end.
