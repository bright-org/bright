import {skillGem} from './skillgem.js';

export const Hooks = {
  skill_gem: {
    mounted() {
      skillGem(this.el);
    }
  }
};
