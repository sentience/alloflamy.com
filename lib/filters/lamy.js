module.exports = {
  lamy: function (str) {
    return str.replace(/(?<!(Josef|Manfred) )\bLamy\b/g, "LAMY");
  },
  lamyHtml: function (str) {
    return str.replace(
      /(?<!(Josef|Manfred) )\bLamy\b/g,
      '<span class="uppercase">Lamy</span>'
    );
  },
};
