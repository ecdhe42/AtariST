from PIL import Image

img = Image.open('genmicros_tiles.png')

colors = {
    0: [0, 0],
    1: [1, 1],
    2: [0, 1],
    3: [1, 0]
}

d = []

for y in range(img.height):
    for x in range(0, img.width, 16):
        pixels = [img.getpixel((x+idx,y)) for idx in range(16)]
        first_byte = 0
        second_byte = 0
        third_byte = 0
        fourth_byte = 0
        weight = 128
        for pixel in pixels[:8]:
            color = colors[pixel]
            first_byte += color[0]*weight
            third_byte += color[1]*weight
            weight = int(weight/2)
        weight = 128
        for pixel in pixels[8:]:
            color = colors[pixel]
            second_byte += color[0]*weight
            fourth_byte += color[1]*weight
            weight = int(weight/2)
        d.append(first_byte)
        d.append(second_byte)
        d.append(third_byte)
        d.append(fourth_byte)

atariST_data = b''.join([int(val).to_bytes() for val in d])

with open('goldrunner_rsc.bin', 'rb') as f:
    o = f.read()

o2 = o[:-1536] + atariST_data
with open('goldrunner_rsc2.bin', 'wb') as f:
    f.write(o2)
