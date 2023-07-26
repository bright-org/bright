const InputReseter = {
  mounted() {
    this.defaultValue = this.el.dataset.defaultValue

    this.handleEvent("reset_form", _payload => {
      this.el.value = this.defaultValue
    })
  }
}

export default InputReseter
