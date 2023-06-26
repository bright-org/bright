import {gem} from './gem.js';

export const Hooks = {
  gem: {
    mounted() {
      gem(this.el);
    }
  }
};
