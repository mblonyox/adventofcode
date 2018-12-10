const readInput = require('../../lib/readInput');
const { deepCopy } = require('../../lib/object');

(async () => {
  const inputText = await readInput();
  const inputArray = inputText.split('\n').map(string => ([string.substr(5,1), string.substr(36,1)]))

  const inputMap = inputArray.reduce((t,v) => {
    if(!t[v[1]]) t[v[1]] = {};
    if(!t[v[0]]) t[v[0]] = {};
    t[v[1]].prev ? t[v[1]].prev.push(v[0]) : t[v[1]].prev = [v[0]];
    t[v[0]].next ? t[v[0]].next.push(v[1]) : t[v[0]].next = [v[1]];
    return t
  }, {})

  const steps = deepCopy(inputMap);
  let result = '';
  while(Object.keys(steps).length) {
    possibleSteps = Object.keys(steps).filter(key => !steps[key].prev || !steps[key].prev.length);
    selectedPath = possibleSteps.sort()[0];
    nextPaths = steps[selectedPath].next
    if(nextPaths) {
      nextPaths.forEach(path => {
        steps[path].prev.splice(steps[path].prev.indexOf(selectedPath),1);
      });
    }
    delete steps[selectedPath];
    result += selectedPath;
  }
  console.log('Part 1 : ' + result);

  const steps2 = deepCopy(inputMap);
  const workers = new Array(5).fill(null).map(_ => ({step: null, time: 0}));
  let result2 = '';
  let totalTime = 0;

  while(result2.length < 26) {
    workers.forEach(worker => {
      worker.time--
      if(worker.step && worker.time <=0) {
        nextPaths = worker.step.next
        if(nextPaths) {
          nextPaths.forEach(path => {
            steps2[path].prev.splice(steps2[path].prev.indexOf(worker.step.selectedPath),1);
          });
        }
        result2 += worker.step.selectedPath;
        worker.step = null;
      }
      if(!worker.step) {
        possibleSteps = Object.keys(steps2).filter(key => !steps2[key].prev || !steps2[key].prev.length);
        if (possibleSteps.length) {
          selectedPath = possibleSteps.sort()[0];
          worker.step = {selectedPath ,...steps2[selectedPath]};
          worker.time = selectedPath.charCodeAt(0) - 4;
          delete steps2[selectedPath];
        }
      }
    });
    totalTime++;
  }

  console.log('Part 2 : ' + (totalTime-2));
})();
