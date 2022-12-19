const input = await Deno.readTextFile("input.txt");

interface Pos {
  x: number;
  y: number;
}

interface Mov {
  dx: number;
  dy: number;
}

function tailFollowHead(headPos: Pos, tailPos: Pos): Mov {
  const dx = headPos.x - tailPos.x;
  const dy = headPos.y - tailPos.y;
  if (Math.abs(dx) >= 2 || Math.abs(dy) >= 2) {
    return {
      dx: dx == 0 ? 0 : dx / Math.abs(dx),
      dy: dy == 0 ? 0 : dy / Math.abs(dy),
    };
  }
  return { dx: 0, dy: 0 };
}

function posToStr(pos: Pos): string {
  return `${pos.x},${pos.y}`;
}

function posMove(pos: Pos, mov: Mov) {
  pos.x += mov.dx;
  pos.y += mov.dy;
}

function part1(input: string): number {
  const headPos: Pos = {
    x: 0,
    y: 0,
  };

  const tailPos: Pos = {
    x: 0,
    y: 0,
  };

  const visited = new Set([posToStr(tailPos)]);

  input.trim().split("\n").forEach((l) => {
    const [dir, stepStr] = l.split(" ");
    const step = parseInt(stepStr);

    for (let i = 0; i < step; i++) {
      switch (dir) {
        case "U":
          posMove(headPos, { dx: 0, dy: -1 });
          break;
        case "D":
          posMove(headPos, { dx: 0, dy: 1 });
          break;
        case "L":
          posMove(headPos, { dx: -1, dy: 0 });
          break;
        case "R":
          posMove(headPos, { dx: 1, dy: 0 });
          break;
        default:
          break;
      }
      const mov = tailFollowHead(headPos, tailPos);
      posMove(tailPos, mov);
      visited.add(posToStr(tailPos));
    }
  });

  return visited.size;
}

console.log(`Part 1: ${part1(input)}`);

function part2(input: string): number {
  const headPos: Pos = {
    x: 0,
    y: 0,
  };

  const tails = new Array(9).fill(null).map((_) => ({ x: 0, y: 0 }) as Pos);

  const visited = new Set([posToStr(tails[8])]);

  input.trim().split("\n").forEach((l) => {
    const [dir, stepStr] = l.split(" ");
    const step = parseInt(stepStr);

    for (let i = 0; i < step; i++) {
      switch (dir) {
        case "U":
          posMove(headPos, { dx: 0, dy: -1 });
          break;
        case "D":
          posMove(headPos, { dx: 0, dy: 1 });
          break;
        case "L":
          posMove(headPos, { dx: -1, dy: 0 });
          break;
        case "R":
          posMove(headPos, { dx: 1, dy: 0 });
          break;
        default:
          break;
      }
      for (let i = 0; i < tails.length; i++) {
        const mov = tailFollowHead(i == 0 ? headPos : tails[i - 1], tails[i]);
        posMove(tails[i], mov);
      }
      visited.add(posToStr(tails[8]));
    }
  });

  return visited.size;
}

console.log(`Part 2: ${part2(input)}`);
