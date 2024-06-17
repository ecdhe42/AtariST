import xml.etree.ElementTree as ET 

tree = ET.parse("goldrunner.tmx")
root = tree.getroot()

def convert_value(val):
    idx = int(val)-1
    idx *= 0x180
    return ('$%08x' % (idx,)).upper()

tiles = [convert_value(val) for val in root.findall('./layer/data')[0].text.split(',')]

with open('scroll2_tilemap.s', 'w') as f:
    for idx in range(0, len(tiles), 4):
        values = tiles[idx:idx+4]

        if idx == len(tiles) - 24:
            f.write('tilemap_init\r\n')

        f.write('    dc.l '+ ','.join(values) + '\r\n')
