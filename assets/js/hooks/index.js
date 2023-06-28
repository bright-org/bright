import {SkillGem} from './SkillGem.js';

export const Hooks = {
  SkillGem: {
    mounted() {
      SkillGem(this.el);
    }
  }
};
