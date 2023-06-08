/** @param {import("@11ty/eleventy").UserConfig} eleventyConfig */
module.exports = function (eleventyConfig) {
  setUpLiquid(eleventyConfig);
  setUpMarkdown(eleventyConfig);
  setUpNavigation(eleventyConfig);
  setUpCollections(eleventyConfig);

  eleventyConfig.setServerPassthroughCopyBehavior("passthrough");

  eleventyConfig.addPassthroughCopy("_headers");
  eleventyConfig.addPassthroughCopy("_redirects");
  eleventyConfig.addPassthroughCopy(".well-known");
  eleventyConfig.addPassthroughCopy("assets/files");
  eleventyConfig.addPassthroughCopy("assets/images");
  eleventyConfig.addPassthroughCopy("assets/scripts");
  eleventyConfig.addPassthroughCopy("assets/videos");
  eleventyConfig.addPassthroughCopy({
    "_tmp/styles.css": "assets/styles/styles.css",
  });
  eleventyConfig.addPassthroughCopy({
    "node_modules/seamless-scroll-polyfill/lib/bundle.min.cjs":
      "assets/scripts/seamless-scroll-polyfill/bundle.min.js",
  });
  eleventyConfig.addPassthroughCopy({
    "node_modules/seamless-scroll-polyfill/lib/bundle.min.cjs.map":
      "assets/scripts/seamless-scroll-polyfill/bundle.min.cjs.map",
  });

  eleventyConfig.addPlugin(require("@11ty/eleventy-plugin-rss"));
  eleventyConfig.addPlugin(require("eleventy-plugin-time-to-read"));

  return {
    dir: {
      layouts: "_layouts",
    },
  };
};

function setUpLiquid(eleventyConfig) {
  // Support unquoted filenames and a=b arguments in include tags like Jekyll
  eleventyConfig.setLiquidOptions({
    dynamicPartials: false,
    jekyllInclude: true,
    orderedFilterParameters: true,
  });

  // Import all filters in /lib/filters/index.js
  const filters = require("./lib/filters");
  Object.keys(filters).forEach((filter) =>
    eleventyConfig.addFilter(filter, filters[filter])
  );

  // Implement Jekyll's post_url tag
  // Usage: {% post_url post-filename-without-extension %}
  eleventyConfig.addLiquidTag("post_url", function (liquidEngine) {
    return {
      parse: function (tagToken, remainingTokens) {
        this.str = tagToken.args; // post-filename-without-extension
      },
      render: async function (context) {
        const postFilenameWithoutExtension = `./_posts/${this.str}`;
        const posts = context.environments.collections.post;
        const post = posts.find((p) =>
          p.inputPath.startsWith(postFilenameWithoutExtension)
        );
        if (post === undefined) {
          throw new Error(`${this.str} not found in posts collection.`);
        } else {
          return post.url;
        }
      },
    };
  });
}

function setUpMarkdown(eleventyConfig) {
  const anchor = require("markdown-it-anchor");
  const hljs = require("highlight.js");

  let markdownIt = require("markdown-it")({
    highlight: function (str, lang) {
      if (lang && hljs.getLanguage(lang)) {
        try {
          return hljs.highlight(str, { language: lang }).value;
        } catch (__) {}
      }

      return ""; // use external default escaping
    },
    html: true,
    typographer: true,
  });
  markdownIt.use(anchor, {
    permalink: anchor.permalink.linkAfterHeader({
      class: "heading-anchor",
      style: "visually-hidden",
      assistiveText: (title) => `Permalink to
      ${title}`,
      visuallyHiddenClass: "sr-only",
      wrapper: ['<div class="heading-wrapper">', "</div>"],
    }),
  });
  eleventyConfig.setLibrary("md", markdownIt);
}

function setUpNavigation(eleventyConfig) {
  eleventyConfig.addPlugin(require("@11ty/eleventy-navigation"));
}

function setUpCollections(eleventyConfig) {
  addPaginatedTagsCollection(eleventyConfig);
}

function addFilteredCollection(eleventyConfig, tag) {
  eleventyConfig.addCollection(tag, (collections) => {
    return getFilteredCollection(collections, tag);
  });
}

// Based on https://github.com/11ty/eleventy/issues/332#issuecomment-445236776
function addPaginatedTagsCollection(eleventyConfig) {
  eleventyConfig.addCollection("tagPages", function (collections) {
    let allTags = new Set();
    collections.getAllSorted().forEach(function (item) {
      item.data.tags?.forEach((tag) => allTags.add(tag));
    });

    // Remove content classes
    // allTags.delete("post");

    // Get each item that matches the tag
    let paginationSize = 5;
    let tagMap = [];
    let tagArray = [...allTags];
    for (let tagName of tagArray) {
      let tagItems = getFilteredCollection(collections, tagName).reverse();
      let pagedItems = chunkArray(tagItems, paginationSize);
      for (
        let pageNumber = 0, max = pagedItems.length;
        pageNumber < max;
        pageNumber++
      ) {
        tagMap.push({
          tagName: tagName,
          pageNumber: pageNumber,
          pageData: pagedItems[pageNumber],
          pageCount: max,
        });
      }
    }

    /* return data looks like:
      [{
        tagName: "tag1",
        pageNumber: 0
        pageData: [] // array of items
      },{
        tagName: "tag1",
        pageNumber: 1
        pageData: [] // array of items
      },{
        tagName: "tag1",
        pageNumber: 2
        pageData: [] // array of items
      },{
        tagName: "tag2",
        pageNumber: 0
        pageData: [] // array of items
      }]
     */
    return tagMap;
  });
}

function getFilteredCollection(collections, tag) {
  return filterHiddenContent(collections.getFilteredByTag(tag));
}

function filterHiddenContent(collection) {
  return (
    collection
      // exclude deleted
      .filter((item) => !Boolean(item.data.deleted))
      // exclude draft in production
      .filter(
        (item) =>
          process.env.ELEVENTY_ENV !== "production" ||
          (item.data.published !== false && !item.data.draft)
      )
  );
}

function chunkArray(arr, chunkSize) {
  const chunks = [];
  let arrRemaining = [...arr];
  while (arrRemaining.length > 0) {
    chunks.push(arrRemaining.slice(0, chunkSize));
    arrRemaining = arrRemaining.slice(chunkSize);
  }
  return chunks;
}
