const create2dArray = (col, row, cb) => new Array(col).fill(null).map((_, y) => new Array(row).fill(null).map((_,x) => typeof cb === 'function' ? cb(x,y) : cb));
const arraySet= (arr) => Array.from(new Set(arr))
const arraySum = (arr) => arr.reduce((t,v) => parseInt(t) + parseInt(v));
const flatMap = (arr) => arr.reduce((t,v) => t.concat(v))
const mapCount = (arr) => arr.reduce((t,v) => {t[v] = (t[v]||0) + 1; return t}, {});

module.exports = {
  create2dArray,
  arraySet,
  arraySum,
  flatMap,
  mapCount,
}