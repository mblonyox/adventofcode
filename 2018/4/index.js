const {promisify} = require('util');
const fs = require('fs');
const path = require('path');

const readFile = promisify(fs.readFile);
const inputFile = path.resolve(__dirname + '/input.txt');

(async () => {
  inputText = await readFile(inputFile, { encoding: 'UTF-8'});
  inputArray = inputText.split('\r\n').sort();

  const guards = [];
  let currentGuard = null;

  inputArray.forEach(log => {
    const [,date, hr, mn] = /\[([\-\d]{10}) (\d{2}):(\d{2})\]/.exec(log);
    switch (log.split(' ').slice(-1).join('')) {
      case 'shift':
        const id = /#\d+/.exec(log)[0];
        let guard = guards.find(g => g.id === id);
        if(!guard) {
          guard = new Guard(id);
          guards.push(guard);
        }
        currentGuard = guard;
        break;
      case 'asleep':
        currentGuard.asleep(mn);
        break;
      case 'up':
        currentGuard.up(mn);
        break;
      default:
        break;
    }
  });

  const mostAsleepGuard = guards.sort((a,b) => b.sleepingTime - a.sleepingTime)[0];
  const selectedMinute1 = mostAsleepGuard.mostMinuteAsleep().selectedMinute;
  console.log('Part 1 : ' + selectedMinute1 * mostAsleepGuard.id.substr(1));
  const mostFrequentAsleepGuard = guards.sort((a,b) => b.mostMinuteAsleep().sleepCount - a.mostMinuteAsleep().sleepCount)[0]
  const selectedMinute2 = mostFrequentAsleepGuard.mostMinuteAsleep().selectedMinute
  console.log('Part 2 : ' + selectedMinute2 * mostFrequentAsleepGuard.id.substr(1));
})();

class Guard {
  constructor(id) {
    this.id = id;
    this.minutesMap = new Array(60).fill(0)
    this.sleepingTime = 0;
    this.lastAwake = null;
  }

  shift(time){

  }

  asleep(time) {
    this.lastAwake = time;
  }

  up(time) {
    const sleepingDuration = time - this.lastAwake;
    for (let i = this.lastAwake; i < time; i++) {
      this.minutesMap[i*1]++
    }
    this.sleepingTime += sleepingDuration;
    this.lastAwake = null;
  }

  mostMinuteAsleep() {
    const sleepCount = Math.max(...this.minutesMap);
    const selectedMinute = this.minutesMap.findIndex(x => x === sleepCount);
    return {sleepCount, selectedMinute};
  }
}
