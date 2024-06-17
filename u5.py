from PIL import Image

img = Image.new('RGB', (1300, 1024))

with open('../UltimaV2.bin', 'rb') as f:
    data = f.read()
with open('u5.st', 'rb') as f:
    data_map = f.read()

offset = 0x6c700-8*5-(8*16*68)
print(hex(offset))
palette = [ "0x0000", "0x0004", "0x0030", "0x0034", "0x0300", "0x0414", "0x0421", "0x0555", "0x0333", "0x0037", "0x0070", "0x0067", "0x0712", "0x0627", "0x0770", "0x0777" ]


def display_tiles():
    offset = 0x6c700-8*5 - (8*16*68)
    x = 0
    y = 0

    for _ in range(512):
        for y2 in range(16):
            bitplanes = [[], [], [], []]
            for i in range(4):
                val = data[offset]
                mask = 0x80
                for j in range(8):
                    bitplanes[i].append(1 if (val & mask) != 0 else 0)
                    mask >>= 1
                offset += 1
            for i in range(4):
                val = data[offset]
                mask = 0x80
                for j in range(8):
                    bitplanes[i].append(1 if (val & mask) != 0 else 0)
                    mask >>= 1
                offset += 1

            for x2 in range(16):
                color_index = (bitplanes[0][x2] << 0) | (bitplanes[1][x2] << 1) | (bitplanes[2][x2] << 2) | (bitplanes[3][x2] << 3)
                color_value = int(palette[color_index], 16)
                r = (((color_value >> 8) & 0x0F) * 17) << 1
                g = (((color_value >> 4) & 0x0F) * 17) << 1
                b = ((color_value & 0x0F) * 17) << 1
                pixel_x = (x + x2) * 2
                pixel_y = (y + y2) * 2
                img.putpixel((pixel_x, pixel_y), (r, g, b))
                img.putpixel((pixel_x+1, pixel_y), (r, g, b))
                img.putpixel((pixel_x, pixel_y+1), (r, g, b))
                img.putpixel((pixel_x+1, pixel_y+1), (r, g, b))
        x += 20
        if x >= 640:
            x = 0
            y += 20

    img.show()
#    img.save('ultima_tiles2.png')
    print(hex(offset))

def display_tile(idx, x, y):
    offset = 0x6c700-8*5-(8*16*68)
    offset += idx * 8*16
    for y2 in range(16):
        bitplanes = [[], [], [], []]
        for i in range(4):
            val = data[offset]
            mask = 0x80
            for j in range(8):
                bitplanes[i].append(1 if (val & mask) != 0 else 0)
                mask >>= 1
            offset += 1
        for i in range(4):
            val = data[offset]
            mask = 0x80
            for j in range(8):
                bitplanes[i].append(1 if (val & mask) != 0 else 0)
                mask >>= 1
            offset += 1

        for x2 in range(16):
            color_index = (bitplanes[0][x2] << 0) | (bitplanes[1][x2] << 1) | (bitplanes[2][x2] << 2) | (bitplanes[3][x2] << 3)
            color_value = int(palette[color_index], 16)
            r = (((color_value >> 8) & 0x0F) * 17) << 1
            g = (((color_value >> 4) & 0x0F) * 17) << 1
            b = ((color_value & 0x0F) * 17) << 1
            pixel_x = (x + x2) * 2
            pixel_y = (y + y2) * 2
            img.putpixel((pixel_x, pixel_y), (r, g, b))
            img.putpixel((pixel_x+1, pixel_y), (r, g, b))
            img.putpixel((pixel_x, pixel_y+1), (r, g, b))
            img.putpixel((pixel_x+1, pixel_y+1), (r, g, b))        

def display_tile_mask(offset, x, y):
    global img
    global data

    for y2 in range(16):
        mask = 0x80
        val = data[offset]
        offset += 1
        for x2 in range(8):
            if (val & mask) != 0:
                img.putpixel((x + x2, y + y2), (255, 255, 255))
            mask >>= 1

    for y2 in range(16):
        val = data[offset]
        offset += 1
        mask = 0x80
        for x2 in range(8):
            if (val & mask) != 0:
                img.putpixel((x+8 + x2, y + y2), (255, 255, 255))
            mask >>= 1
    return offset

def display_small_tile(idx, x, y):
    offset = 0x6c700-8*5-(8*16*68)
    offset += idx * 8*16
    for y2 in range(16):
        bitplanes = [[], [], [], []]
        for i in range(4):
            val = data[offset]
            mask = 0x80
            for j in range(8):
                bitplanes[i].append(1 if (val & mask) != 0 else 0)
                mask >>= 1
            offset += 1
        for i in range(4):
            val = data[offset]
            mask = 0x80
            for j in range(8):
                bitplanes[i].append(1 if (val & mask) != 0 else 0)
                mask >>= 1
            offset += 1

        for x2 in range(16):
            color_index = (bitplanes[0][x2] << 0) | (bitplanes[1][x2] << 1) | (bitplanes[2][x2] << 2) | (bitplanes[3][x2] << 3)
            color_value = int(palette[color_index], 16)
            r = (((color_value >> 8) & 0x0F) * 17) << 1
            g = (((color_value >> 4) & 0x0F) * 17) << 1
            b = ((color_value & 0x0F) * 17) << 1
            pixel_x = (x + x2)
            pixel_y = (y + y2)
            img.putpixel((pixel_x, pixel_y), (r, g, b))
            img.putpixel((pixel_x+1, pixel_y), (r, g, b))
            img.putpixel((pixel_x, pixel_y+1), (r, g, b))
            img.putpixel((pixel_x+1, pixel_y+1), (r, g, b))      

def display_map_quadrant(x, y, map_offset):
    for y2 in range(16):
        for x2 in range(16):
            tile_index = data_map[map_offset]
            if tile_index:
                display_tile(tile_index, (x+x2) * 16, (y+y2) * 16)
            map_offset += 1
    for y2 in range(512):
        img.putpixel((x*32+511, y*32+y2), (255,255,255))
        img.putpixel((x*32+y2, y*32+511), (255,255,255))


def display_map(map_offset):
    map_offset = 0x15cdc
    display_map_quadrant(0, 0, map_offset)
    display_map_quadrant(16, 0, map_offset+256)
    display_map_quadrant(0, 16, map_offset+512)
    display_map_quadrant(16, 16, map_offset+768)
    img.show()
#    img.save("ultima_map.png")

def display_world_quadrant(x, y, map_offset):
    for y2 in range(16):
        for x2 in range(16):
            tile_index = data_map[map_offset]
            if tile_index:
                display_small_tile(tile_index, (x+x2) * 16, (y+y2) * 16)
            map_offset += 1

def display_world_row(x, y, map_offset, width):
    for _ in range(width):
        display_world_quadrant(x, y, map_offset)
        x += 16
        map_offset += 256
    print("Row")
    return map_offset

def display_world():
    map_offset = 0x58e00
    y = 0
    map_offset = display_world_row(32, y, map_offset, 13)
    y += 16
    map_offset = display_world_row(16, y, map_offset, 14)
    y += 16
    map_offset = display_world_row(0, y, map_offset, 15)
    y += 16
    map_offset = display_world_row(0, y, map_offset, 16)
    y += 16
    map_offset = display_world_row(0, y, map_offset, 16)
    y += 16
    map_offset = display_world_row(0, y, map_offset, 16)
    y += 16
    map_offset = display_world_row(0, y, map_offset, 11)
    map_offset = display_world_row(192, y, map_offset, 4)
    y += 16
    map_offset = display_world_row(0, y, map_offset, 7)
    map_offset = display_world_row(160, y, map_offset, 2)
    map_offset = display_world_row(208, y, map_offset, 3)
    y += 16
    map_offset = display_world_row(16, y, map_offset, 6)
    map_offset = display_world_row(160, y, map_offset, 2)
    map_offset = display_world_row(208, y, map_offset, 3)
    y += 16
    map_offset = display_world_row(0, y, map_offset, 7)
    map_offset = display_world_row(128, y, map_offset, 1)
    map_offset = display_world_row(208, y, map_offset, 2)
    y += 16
    map_offset = display_world_row(0, y, map_offset, 7)
    map_offset = display_world_row(128, y, map_offset, 1)
    map_offset = display_world_row(176, y, map_offset, 1)
    y += 16
    map_offset = display_world_row(16, y, map_offset, 7)
    map_offset = display_world_row(224, y, map_offset, 2)
    y += 16
    map_offset = display_world_row(16, y, map_offset, 2)
    map_offset = display_world_row(64, y, map_offset, 4)
    map_offset = display_world_row(160, y, map_offset, 2)
    map_offset = display_world_row(208, y, map_offset, 3)
    y += 16
    map_offset = display_world_row(16, y, map_offset, 2)
    map_offset = display_world_row(64, y, map_offset, 4)
    map_offset = display_world_row(160, y, map_offset, 2)
    map_offset = display_world_row(208, y, map_offset, 3)
    y += 16
    map_offset = display_world_row(16, y, map_offset, 15)
    y += 16
    map_offset = display_world_row(48, y, map_offset, 2)
    map_offset = display_world_row(96, y, map_offset, 11)
    y += 16

    img.show()
#    img.save("ultima_world.png")

def display_town(map_offset, idx):
    global img
    img = Image.new('RGB', (1024, 1024))
    x = 0
    y = 0
    for y2 in range(32):
        for x2 in range(32):
            tile_index = data_map[map_offset]
            if tile_index:
                display_tile(tile_index, (x+x2) * 16, (y+y2) * 16)
            map_offset += 1
    print(hex(map_offset))
    img.show()
#    img.save(f"ultima_town_{idx}.png")

town_idx = 0

def save_towns(offset):
    global town_idx
    for i in range(16):
        display_town(offset, town_idx)
        town_idx += 1
        offset += 0x400

def display_dungeon(map_offset):
    global img
    img = Image.new('RGB', (16*12*14, 16*12*8))
    x = 0
    y = 0
    for idx in range(112):
        for y2 in range(11):
            for x2 in range(11):
                tile_index = data_map[map_offset]
                if tile_index:
                    display_small_tile(tile_index, (x+x2) * 16, (y+y2) * 16)
                map_offset += 1
            map_offset += 21
        y += 12
        if y >= 96:
            y = 0
            x += 12
        print(idx, hex(map_offset))
    img.show()
#    img.save(f"ultima_dungeon.png")

#display_map(0x15cdc)
#display_world()

#save_towns(0x67200)
#save_towns(0x72200)
#save_towns(0x82200)
#save_towns(0x8e200)

#display_town(0x16600, 0)
#display_dungeon(0x11200)

#display_castle(0x57600)
#display_tiles()
offset = 0x7a4d8
x = 0
y = 0
for i in range(256):
    offset = display_tile_mask(offset, x, y)
    x += 20
    if x >= 640:
        x = 0
        y += 20

img.show()
