module.exports = {
  // Usage {% pen AL star %}
  pen: function (liquidEngine) {
    return {
      parse: function (tagToken, remainingTokens) {
        this.penName = tagToken.args; // "AL star"
      },
      render: async function (context) {
        const pens = context.environments.collections.pen;
        const pen = pens.find(
          (pen) => (pen.data.name ?? pen.fileSlug) === this.penName
        );
        if (pen === undefined) {
          return this.penName;
        } else {
          return `<a href="${pen.url}">${pen.data.title}</a>`;
        }
      },
    };
  },
};
