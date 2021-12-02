const readInput = require('../lib/readInput');

(async() => {
  const input = await readInput();
  const [immuneSystem, infection] = input.split(/\n\n/)
    .map(string => string.split('\n').slice(1)
      .map(line => {
        const {groups} = line.match(/(?<unit>\d+) units each with (?<hp>\d+) hit points .*with an attack that does (?<attackDamage>\d+) (?<attackType>\w+) damage at initiative (?<initiative>\d+)/);
        const wk = line.match(/weak to (?<w>[\w \,]+)/);
        const im = line.match(/immune to (?<i>[\w \,]+)/);
        const unit = parseInt(groups.unit);
        const hp = parseInt(groups.hp);
        const attackDamage = parseInt(groups.attackDamage);
        const attackType = groups.attackType;
        const initiative = parseInt(groups.initiative);
        const weak = wk ? wk.groups.w.split(', ') : [];
        const immune = im ? im.groups.i.split(', ') : [];
        return {unit, hp, attackDamage, attackType, initiative, weak, immune};
      })
    );
  const parsedInput = {
    immuneSystem: immuneSystem.map(group => ({enemy: 'infection', ...group})),
    infection: infection.map(group => ({enemy: 'immuneSystem', ...group}))
  }

  const run = ({immuneSystem, infection}, boost = 0) => {
    immuneSystem = immuneSystem.map(group => new Group(group, boost));
    infection = infection.map(group => new Group(group));
    const allUnits = [...immuneSystem, ...infection];
    while(immuneSystem.some(group => group.isRemain) && infection.some(group => group.isRemain)) {
      const unitAtStart = allUnits.filter(group => group.isRemain).reduce((prev, curr) => prev + curr.unit, 0);
      const availableOpponents = {
        immuneSystem : immuneSystem.filter(group => group.isRemain),
        infection: infection.filter(group => group.isRemain)
      }
      const selectionOrder = allUnits
        .filter(group => group.isRemain)
        .sort((a, b) => b.effectivePower - a.effectivePower || b.initiative - a.initiative);
      const attackOrder = [];
      for (const group of selectionOrder) {
        const {effectivePower, attackType, enemy} = group;
        const target = availableOpponents[enemy]
          .sort((a,b) =>
            b.modifyDamage(effectivePower, attackType) - a.modifyDamage(effectivePower, attackType) ||
            b.effectivePower - a.effectivePower ||
            b.initiative - a.initiative
          ).shift();
        if(target && target.modifyDamage(effectivePower, attackType) === 0) availableOpponents[enemy].unshift(target);
        else if(target) attackOrder.push({attacker: group, defender: target})
      }
      attackOrder.sort((a,b) => b.attacker.initiative - a.attacker.initiative);
      for (const order of attackOrder) {
        const {attacker, defender} = order;
        if(!attacker.isRemain || !defender.isRemain) continue;
        defender.applyDamage(defender.modifyDamage(attacker.effectivePower, attacker.attackType));
      }
      const unitAtEnd = allUnits.filter(group => group.isRemain).reduce((prev, curr) => prev + curr.unit, 0);
      if(unitAtStart === unitAtEnd) {
        return false;
      }
    }

    return {
      army: immuneSystem.some(group => group.isRemain) ? 'immuneSystem' : 'infection',
      unit: allUnits.filter(group => group.isRemain).reduce((prev, curr) => prev + curr.unit, 0)
    }
  }

  // Part 1
  console.log('Part 1 : ' + run(parsedInput).unit);

  // Part 2
  let boost = 1;
  let result = null;
  while (!result || result.army === 'infection') {
    result = run(parsedInput, boost);
    boost++;
  }
  console.log('Part 2 : ' + result.unit);
})();

class Group {
  constructor({unit, hp, attackDamage, attackType, initiative, weak, immune, enemy}, boost = 0) {
    this.unit = unit;
    this.hp = hp;
    this.attackDamage = attackDamage + boost;
    this.attackType = attackType;
    this.initiative = initiative;
    this.weak = weak;
    this.immune = immune;
    this.enemy = enemy;
  }

  get isRemain() {
    return this.unit > 0;
  }

  get effectivePower() {
    return this.unit * this.attackDamage;
  }

  modifyDamage(effectivePower, attackType) {
    if(~this.immune.indexOf(attackType)) return 0;
    if(~this.weak.indexOf(attackType)) return 2*effectivePower;
    return effectivePower;
  }

  applyDamage(damage) {
    this.unit -= Math.floor(damage/this.hp)
  }

}
