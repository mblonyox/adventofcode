const create2dArray = (col, row, value) => new Array(col).fill(null).map(_ => new Array(row).fill(value));
const arraySet= (arr) => Array.from(new Set(arr))
const flatMap = (arr) => arr.reduce((t,v) => t.concat(v))
const mapCount = (arr) => arr.reduce((t,v) => {t[v] = (t[v]||0) + 1; return t}, {});

module.exports = {
  create2dArray,
  arraySet,
  flatMap,
  mapCount
};
