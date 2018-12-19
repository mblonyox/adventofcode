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
    // console.log({xy,a,b1,b2})
  });
  const maxY = Math.max(...clays.map(tuple => tuple[1]));
  const minY = Math.min(...clays.map(tuple => tuple[1]));
  const maxX = Math.max(...clays.map(tuple => tuple[0]));
  const minX = Math.min(...clays.map(tuple => tuple[0]));

  const height = maxY-minY+1;
  const width = maxX-minX+3;
  const map2d = create2dArray(height, width, 0);
  clays.forEach(([x,y]) => {
    map2d[y-minY][x-minX+1] = 1;
  })

  const sampleMap = [
    [1,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,1,0,1,0,0],
    [0,0,0,0,0,0,0,1],

  ]
  await create4bpp(map2d);
})();

create4bpp = async (map2d) => {
  const height = map2d.length;
  const width = map2d[0].length;
  const buffersize = (width - width%8) /2;

  const imageData = Buffer.concat(map2d.map(row => {
    const buffer = new Uint8Array(buffersize);
    for (let i = 0; i < width; i += 2) {
      buffer[i / 2] = (row[i] << 4) | row[i+1];
    }
    return buffer;
  }).reverse(), height*buffersize);

  const colorTable = Buffer.from([
    0xFF, 0xFF, 0xFF, 0x00,
    0xFF, 0x00, 0xFF, 0x00,
    0x00, 0xFF, 0xFF, 0x00,
    0x00, 0x00, 0x00, 0x00
  ])
  await createBitmapFile({
    filename: 'output.bmp',
    imageData: imageData,
    width,
    height,
    bitsPerPixel: 4,
    colorTable
  })
}