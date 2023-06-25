const colors = require("tailwindcss/colors");
const defaultTheme = require("tailwindcss/defaultTheme");

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./_includes/**/*.{html,liquid,md}",
    "./_layouts/**/*.{html,liquid,md}",
    "./*.{html,liquid,md}",
    "./pens/*.{html,liquid,md}",
  ],
  theme: {
    extend: {
      borderColor: {
        DEFAULT: colors.neutral[500],
      },
      colors: {
        // {100: var(--theme-100, colors.red.100), …}
        theme: Object.keys(colors.red).reduce(
          (obj, num) => ({
            ...obj,
            [num]: `var(--theme-${num}, ${colors.red[num]})`,
          }),
          {}
        ),
      },
      fontFamily: {
        sans: ["Roboto", ...defaultTheme.fontFamily.sans],
      },
    },
  },
  safelist: [
    // Used in markdown-it-anchor config
    "heading-anchor",
    "heading-wrapper",
    "sr-only",
    // Used by markdown-it-footnotes
    "footnotes",
    "footnotes-list",
    "footnotes-sep",
    // used by LAMY filter
    "uppercase",
  ],
  plugins: [require("tailwindcss-logical")],
};
