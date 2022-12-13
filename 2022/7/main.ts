const input = await Deno.readTextFile("input.txt");

const disk = input.trim().split("\n").reduce((s, e) => {
  if (e.startsWith("$ cd ")) {
    const arg = e.substring(5);
    switch (arg) {
      case "/":
        s.cwd = "/";
        break;
      case "..":
        s.cwd = s.cwd.substring(0, s.cwd.lastIndexOf("/"));
        break;
      default:
        s.cwd += (s.cwd.endsWith("/") ? "" : "/") + arg;
        break;
    }
  }
  if (e.startsWith("dir")) {
    s.dir.push({ name: e.substring(4), path: s.cwd });
  }
  if (e.match(/^\d+ \w+/)) {
    const [size, name] = e.split(" ");
    s.files.push({ size: parseInt(size), name, path: s.cwd });
  }
  return s;
}, {
  cwd: "/",
  dir: [] as { name: string; path: string }[],
  files: [] as { size: number; name: string; path: string }[],
});

const part1 = disk.dir.map(({ name, path }) =>
  disk.files.filter((f) =>
    f.path.startsWith(path + (path.endsWith("/") ? "" : "/") + name)
  ).reduce((t, f) => t + f.size, 0)
).filter((x) => x <= 100000)
  .reduce((t, x) => t + x, 0);

console.log(`Part 1 : ${part1}`);

const total_used = disk.files.reduce((t, f) => t + f.size, 0);
const unused_space = 70000000 - total_used;
const min_size = 30000000 - unused_space;

const part2 = disk.dir.map(({ name, path }) =>
  disk.files.filter((f) =>
    f.path.startsWith(path + (path.endsWith("/") ? "" : "/") + name)
  ).reduce((t, f) => t + f.size, 0)
).filter((x) => x >= min_size)
  .sort((a, b) => a - b)
  .at(0);

console.log(`Part 2 : ${part2}`);
