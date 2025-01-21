const ScrollPos = {
  mounted() {
    const cf = document.getElementsByClassName("career_field");
    const pos = [...cf].map((c) => c.clientHeight);

    this.pushEvent("position", { pos: cf[0].id });

    document.addEventListener("scroll", () => {
      const y = window.scrollY;

      let cumulativePosition = 0;
      for (let i = 0; i < pos.length - 1; i++) {
        cumulativePosition += pos[i];
        if (y < cumulativePosition + 120) {
          this.pushEvent("position", { pos: cf[i].id });
          return;
        }
      }

      this.pushEvent("position", { pos: cf[cf.length - 1].id });
    });
  },
};

export default ScrollPos;
