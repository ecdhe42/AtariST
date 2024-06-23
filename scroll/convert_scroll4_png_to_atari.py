from PIL import Image

img_bg = Image.open('AtariST.png')
img_fg1 = Image.open('POV.png')
img_fg2 = Image.open('foreground2.png')

def pixel_to_bitplane(val):
    bin_val = bin(val)[2:]
    bin_val = '0'*(4-len(bin_val)) + bin_val
    return bin_val[::-1]

def get_color(val):
    r = round(val[0]*7/256)
    g = round(val[1]*7/256)
    b = round(val[2]*7/256)
    return (r, g*16 + b)

background = [0, 0]
foreground1 = [0, 0]
foreground1_mask = []
foreground2 = [0, 0]
foreground2_mask = []

for col in img_bg.palette.colors.keys():
    r, gb = get_color(col)
    background.append(r)
    background.append(gb)
    foreground1.append(r)
    foreground1.append(gb)
    foreground2.append(r)
    foreground2.append(gb)

def convert_background(img, data, filename):
    for y in range(img.height):
        for x in range(0, img.width, 16):
            pixels = [pixel_to_bitplane(img.getpixel((x+idx,y))) for idx in range(16)]
            bytes = [0, 0, 0, 0, 0, 0, 0, 0]
            weight = 128
            for pixel in pixels[:8]:
                for idx, bit in enumerate(pixel):
                    bytes[idx*2] += weight*int(bit)
                weight = int(weight/2)

            weight = 128
            for pixel in pixels[8:]:
                for idx, bit in enumerate(pixel):
                    bytes[idx*2+1] += weight*int(bit)
                weight = int(weight/2)
            data.extend(bytes)
    bin_data = b''.join([int(val).to_bytes() for val in data])
    with open(filename + '.pi1', 'wb') as f:
        f.write(bin_data)

def convert_foreground(img, data, filename):
    data_mask = []
    for y in range(img.height):
        for x in range(0, img.width, 16):
            pixels = [pixel_to_bitplane(img.getpixel((x+idx,y))) for idx in range(16)]
            bytes = [0, 0, 0, 0, 0, 0, 0, 0]
            mask = [0, 0, 0, 0, 0, 0, 0, 0]
            weight = 128
            for pixel in pixels[:8]:
                for idx, bit in enumerate(pixel):
                    bytes[idx*2] += weight*int(bit)
                if pixel == '0000':
                    mask[0] += weight
                    mask[2] += weight
                    mask[4] += weight
                    mask[6] += weight
                weight = int(weight/2)

            weight = 128
            for pixel in pixels[8:]:
                for idx, bit in enumerate(pixel):
                    bytes[idx*2+1] += weight*int(bit)
                if pixel == '0000':
                    mask[1] += weight
                    mask[3] += weight
                    mask[5] += weight
                    mask[7] += weight
                weight = int(weight/2)
            data.extend(bytes)
            data_mask.extend(mask)

    bin_data = b''.join([int(val).to_bytes() for val in data])
    bin_data_mask = b''.join([int(val).to_bytes() for val in data_mask])
    with open(filename + '.pi1', 'wb') as f:
        f.write(bin_data)
    with open(filename + '_mask.bin', 'wb') as f:
        f.write(bin_data_mask)


convert_background(img_bg, background, 'AtariST')
convert_foreground(img_fg1, foreground1, 'POV')
convert_foreground(img_fg2, foreground2, 'foreground2')
