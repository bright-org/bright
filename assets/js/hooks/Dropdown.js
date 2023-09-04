// ドロップダウンのJS実行。下記を改善するためにHookとして用意
// Flowbiteはdata属性に基づいて自動実行されるが、
// phx-updateでドロップダウンが閉じるとその後のクリック操作が意図と反する。
//
// refs:
// https://flowbite.com/docs/components/dropdowns/#more-examples

import {Dropdown as FlowbiteDropdown} from 'flowbite';

const Dropdown = {
  // 画面状態とdropdownの内部状態を合わせる処理
  displayDropdown(dropdown, targetEl){
    if(targetEl.classList.contains("hidden")){
      dropdown.hide()
    }
    if(targetEl.classList.contains("block")){
      dropdown.show()
    }
  },

  mounted() {
    this.triggerEl = this.el.querySelector(".dropdownTrigger")
    this.targetEl = this.el.querySelector(".dropdownTarget")
    const offset = this.el.dataset.dropdownOffsetSkidding
    const placement = this.el.dataset.dropdownPlacement

    this.options = {
      triigerType: 'click',
      placement: placement,
      offsetSkidding: parseInt(offset),
      delay: 300,
      ignoreClickOutsideClass: false
    }

    this.dropdown = new FlowbiteDropdown(this.targetEl, this.triggerEl, this.options)
    this.displayDropdown(this.dropdown, this.targetEl)
  },

  updated() {
    this.displayDropdown(this.dropdown, this.targetEl)
  }
}

export default Dropdown
