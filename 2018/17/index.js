const { padImageData, createBitmapFile } = require('@ericandrewlewis/bitmap');
const readInput = require('../../lib/readInput');
const { create2dArray } = require('../../lib/array');

(async() => {
  const input = await readInput();
  const clays = [];
  input.split('\n').forEach(string => {
    let [, xy, a, b1, b2] = string.match(/([xy])\=(\d+)\, [xy]\=(\d+)\.\.(\d+)/);
    [a, b1, b2] = [a, b1, b2].map(d => parseInt(d));
    for (let i = b1; i <= b2; i++){
      let tuple = [a, i];
      clays.push(xy === 'x' ? tuple : tuple.reverse())
    }
    console.log(`Processed ${string}`)
  });
  const claysString = clays.map(tuple => `${tuple}`);
  const maxY = Math.max(...clays.map(tuple => tuple[1])) + 1;
  const map2d = create2dArray(maxY, 1000, (x,y) => ~claysString.indexOf(`${[x,y]}`) ? 1 : 0);

  // Create Image
  const unpaddedImageData = Buffer.concat(map2d.map(row => {
    let buffer = new Uint8Array(row.length / 4);
    for (let i = 0; i < row.length; i += 4) {
      buffer[i / 4] =
        row[i] |
        (row[i + 1] << 2) |
        (row[i + 2] << 4) |
        (row[i + 3] << 6);
    }
    return buffer;
  }))
  const width = 1000;
  const height = maxY;
  const colorTable = Buffer.from([
    0xFF, 0xFF, 0xFF, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0xFF, 0x00, 0xFF, 0x00,
    0x00, 0xFF, 0xFF, 0x00
  ])
  await createBitmapFile({
    filename: 'output.bmp',
    imageData: padImageData({unpaddedImageData, width, height}),
    width,
    height,
    bitsPerPixel: 2,
    colorTable
  })
})();
