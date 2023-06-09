const colors = require("tailwindcss/colors");
const defaultTheme = require("tailwindcss/defaultTheme");

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./_includes/**/*.{html,liquid}",
    "./_layouts/**/*.{html,liquid}",
    "./*.{html,liquid}",
  ],
  theme: {
    extend: {
      borderColor: {
        DEFAULT: "#ADB8AB",
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
  ],
  plugins: [require("tailwindcss-logical")],
};
