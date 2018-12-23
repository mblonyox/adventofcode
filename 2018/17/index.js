const { createBitmapFile } = require('@ericandrewlewis/bitmap');
const readInput = require('../../lib/readInput');
const { create2dArray, flatMap, mapCount } = require('../../lib/array');

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

  /**
   * Char map:
   * . => 0
   * # => 1
   * | => 2
   * ~ => 3
   */

  const dropDown = ([x,y]) => {
    map2d[y][x] = 2;
    if(y+1 >= height) return;
    const below = map2d[y+1][x];
    if(below === 0) dropDown([x,y+1]);
    if(below === 1 || below === 3) fillUp([x,y])
  }

  const fillUp = ([x,y]) => {
    if(reachBothWalls([x,y])) {
      fillLevel([x,y]);
      fillUp([x,y-1])
    } else {
      flowLevel([x,y])
    }
  }

  const reachBothWalls = (pos) => reachWall(pos, -1) && reachWall(pos, 1)
  const reachWall = ([x,y], offset = 1) => {
    let current = x;
    while (true) {
      if (map2d[y+1][current] === 0) return false;
      if (map2d[y][current] === 1) return true;
      current += offset;
    }
  }

  const fillLevel = (pos) => {
    fillSide(pos, -1);
    fillSide(pos, 1)
  }
  const fillSide = ([x,y], offset = 1) => {
    let current = x;
    while(true) {
      if(map2d[y][current] === 1) return;
      map2d[y][current] = 3;
      current += offset;
    }
  }

  const flowLevel = (pos) => {
    flowSide(pos, -1);
    flowSide(pos, 1);
  }
  const flowSide = ([x,y], offset = 1) => {
    let current = x;
    while(true) {
      if(map2d[y][current] === 1 || map2d[y][current] === 3) return;
      map2d[y][current] = 2;
      if(map2d[y+1][current] === 0) return dropDown([current, y]);
      current += offset;
    }
  }

  dropDown([501-minX, 0]);

  const result = mapCount(flatMap(map2d));

  console.log('Part 1 : ' + result[2] + result[3]);
  console.log('Part 2 : ' + result[3]);

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
    0x00, 0x00, 0x00, 0x00,
    0x80, 0x80, 0x00, 0x00,
    0xFF, 0x00, 0x00, 0x00
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