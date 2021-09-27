from PIL import Image
import os
import sys

def main():
    if len(sys.argv) != 2:
        sys.stderr.write("Usage: python hexgen.py <image.jpg>\n")
        sys.exit(1)

    im = Image.open(sys.argv[1])
    nim = im.resize((320, 240), Image.BILINEAR)
    pixels = nim.load()

    out_color = []
    for y in range(nim.height):
        for x in range(nim.width):
            pixel = nim.getpixel((x, y))
            print(pixel)
            convert_pixel = ((pixel[0] >> 5) << 6) | ((pixel[1] >> 5) << 3) | ((pixel[2] >> 5) & 0x7)
            out_color.append(convert_pixel)

    print(len(out_color))

    with open("data.hex", "w") as f:
        for (idx, pixel) in enumerate(out_color):
            f.write("{0:09b}\n".format(pixel))

    nim.save("result.jpg")

if __name__ == "__main__":
    main()
