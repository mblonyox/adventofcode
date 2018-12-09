const create2dArray = (col, row, value) => new Array(col).fill(null).map(_ => new Array(row).fill(value));
const arraySet= (arr) => Array.from(new Set(arr))
const arraySum = (arr) => arr.reduce((t,v) => parseInt(t) + parseInt(v));
const flatMap = (arr) => arr.reduce((t,v) => t.concat(v))
const mapCount = (arr) => arr.reduce((t,v) => {t[v] = (t[v]||0) + 1; return t}, {});
const deepCopy = (obj) => JSON.parse(JSON.stringify(obj));
const mod = (num, base) => base ? ((num % base) + base) % base : 0;

module.exports = {
  create2dArray,
  arraySet,
  arraySum,
  flatMap,
  mapCount,
  deepCopy,
  mod
};
