class Item {
    constructor(el) {
      this.DOM = { el: el };
      this.state = {
        initialWidth: this.DOM.el.offsetWidth,
        initialHeight: this.DOM.el.offsetHeight,
        offsetTop: this.DOM.el.offsetTop,
        offsetLeft: this.DOM.el.offsetLeft,
        isExpanded: false };
  
  
      this.onClick = this.onClick.bind(this);
      this.bindEvents();
    }
  
    bindEvents() {
      this.DOM.el.addEventListener("click", this.onClick);
    }
  
    onClick() {
      this.cloneItem();
      setTimeout(() => this.toggleExpand(), 10);
    }
  
    cloneItem() {
      if (this.DOM.itemClone) return;
      this.DOM.itemClone = this.DOM.el.cloneNode();
      this.DOM.itemClone.style.position = "absolute";
      this.DOM.itemClone.style.margin = "0";
      this.DOM.itemClone.style.top = `${this.DOM.el.offsetTop}px`;
      this.DOM.itemClone.style.left = `${this.DOM.el.offsetLeft}px`;
      this.DOM.el.appendChild(this.DOM.itemClone);
    }
  
    toggleExpand() {
      if (!this.isExpanded) {
        this.isExpanded = true;
        this.DOM.itemClone.style.width = "100%";
        this.DOM.itemClone.style.height = "100%";
        this.DOM.itemClone.style.top = "0";
        this.DOM.itemClone.style.opacity = "1";
        this.DOM.itemClone.style.left = "0";
        this.DOM.itemClone.style.bottom = "0";
        this.DOM.itemClone.style.right = "0";
        this.DOM.itemClone.style.zIndex = 10;
      } else {
        this.isExpanded = false;
        this.DOM.itemClone.style.width = `${this.DOM.el.offsetWidth}px`;
        this.DOM.itemClone.style.height = `${this.DOM.el.offsetHeight}px`;
        this.DOM.itemClone.style.top = `${this.DOM.el.offsetTop}px`;
        this.DOM.itemClone.style.left = `${this.DOM.el.offsetLeft}px`;
        this.DOM.itemClone.style.zIndex = 1;
  
        setTimeout(() => {
          this.DOM.el.removeChild(this.DOM.itemClone);
          this.DOM.itemClone = null;
        }, 1000);
      }
    }}
  
  
  const items = document.querySelectorAll(".grid__item");
  items.forEach(el => new Item(el));