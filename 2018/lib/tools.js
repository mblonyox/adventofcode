const mod = (num, base) => base ? ((num % base) + base) % base : 0;

module.exports = {
  mod,
};
