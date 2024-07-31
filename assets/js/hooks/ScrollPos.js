const ScrollPos = {
  mounted() {
    const engineer = document.getElementById("engineer");
    const product = document.getElementById("product");
    const designer = document.getElementById("designer");
    const marketer = document.getElementById("marketer");
    const cxo = document.getElementById("cxo");
    const pos = [
      engineer ? engineer.clientHeight : 0,
      product ? product.clientHeight : 0,
      designer ? designer.clientHeight : 0,
      marketer ? marketer.clientHeight : 0,
      cxo ? cxo.clientHeight : 0,
    ];

    document.addEventListener("scroll", () => {
      const y = window.scrollY;
      if (y < pos[0]) {
        this.pushEvent("position", { pos: "engineer" });
      } else if (y < pos[0] + pos[1]) {
        this.pushEvent("position", { pos: "product" });
      } else if (y < pos[0] + pos[1] + pos[2]) {
        this.pushEvent("position", { pos: "designer" });
      } else if (y < pos[0] + pos[1] + pos[2] + pos[3]) {
        this.pushEvent("position", { pos: "marketer" });
      } else {
        this.pushEvent("position", { pos: "cxo" });
      }
    });
  },
};

export default ScrollPos;
