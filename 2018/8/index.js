const readInput = require('../readInput');
const { arraySum } = require('../tools');

(async () => {
  const inputText = await readInput();
  const inputArray = inputText.split(' ');

  // Part 1
  const nodes = [];
  const parseNode = (input) => {
    const childs = [];
    const metas = []
    const childNumber = input.shift();
    const metaNumber = input.shift();
    for (let i = 0; i < childNumber; i++) {
      childs.push(parseNode(input));
    }
    for (let j = 0; j < metaNumber; j++) {
      metas.push(input.shift())
    }
    const node = {header: {childNumber, metaNumber}, childs, metas};
    nodes.push(node);
    return node;
  }
  const rootNode = parseNode(inputArray);
  console.log('Part 1 : ' + nodes.reduce((t,v) => t + arraySum(v.metas), 0));

  // Part 2
  const nodeValue = (node) => {
    if(!node.childs.length) return arraySum(node.metas)
    let sumValue = 0;
    for (let i = 0; i < node.metas.length ; i++) {
      const childIndex = parseInt(node.metas[i]) - 1;
      if(node.childs[childIndex]) {
        sumValue += nodeValue(node.childs[childIndex])
      }
    }
    return sumValue;
  }
  console.log('Part 2 : ' + nodeValue(rootNode));
})();

