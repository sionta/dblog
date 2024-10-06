(() => {
  "use strict";

  const search = function () {
    if (typeof Fuse !== "undefined") {
      const searchData = document
        .querySelector("[data-search]")
        ?.getAttribute("data-search");
      if (searchData) {
        fetch(searchData)
          .then((response) => response.json())
          .then((data) => {
            setupSearch(data);
          })
          .then((err) => {
            console.log(err);
          });
      }

      function setupSearch(json) {
        const searchInput = document.getElementById("search-input");
        if (!searchInput) return;

        const fuse = new Fuse(json, {
          keys: ["title", "url", "excerpt"],
          includeMatches: true,
          threshold: 0.3,
        });

        let resultsContainer = document.getElementById("search-results");
        if (!resultsContainer) {
          resultsContainer = document.createElement("ul");
          resultsContainer.id = "search-results";
          searchInput.insertAdjacentElement("afterend", resultsContainer);
        }

        searchInput.addEventListener("input", function () {
          const searchTerm = searchInput.value.trim();
          resultsContainer.innerHTML = "";

          if (searchTerm !== "") {
            const results = fuse.search(searchTerm);

            if (results.length > 0) {
              results.forEach((result) => {
                resultsContainer.innerHTML = `<li class="search-list"><a href="${result.item.url}">${result.item.title}</a><p>${result.item.excerpt}</p></li>`;
              });
            } else {
              const noResults = `<li class="no-results"><p>No results for <span>"${searchTerm}"<span></p></li>`;
              resultsContainer.innerHTML = noResults;
            }
          }
        });
      }
    }
  };

  const copy = function () {
    const copyButtons = document.querySelectorAll(".copy-button");

    if (copyButtons) {
      copyButtons.forEach((button) => {
        let copyFeedback = button.querySelector(".copy-feedback");

        if (!copyFeedback) {
          copyFeedback = document.createElement("span");
          copyFeedback.className = "copy-feedback";
          copyFeedback.textContent = "Copy";
          button.appendChild(copyFeedback);
        }

        const successMessage = button.getAttribute("data-success") || "Copied";
        const originalText = copyFeedback.textContent;

        button.addEventListener("click", async () => {
          const codeBlock = button.closest(".highlighter-rouge");
          if (!codeBlock) return;

          const codeElement =
            codeBlock.querySelector(".rouge-code") ||
            codeBlock.querySelector(".code") ||
            codeBlock.querySelector("code");
          if (!codeElement) return;

          try {
            await navigator.clipboard.writeText(codeElement.innerText);
            button.setAttribute("data-feedback", "success");
            copyFeedback.textContent = successMessage;
          } catch (error) {
            button.setAttribute("data-feedback", "error");
            copyFeedback.textContent = "Failed to copy";
          } finally {
            setTimeout(() => {
              button.removeAttribute("data-feedback");
              copyFeedback.textContent = originalText;
            }, 2000);
          }
        });
      });
    }
  };

  const toc = function () {
    if (typeof tocbot !== "undefined") {
      const setupToc = () => {
        const tocTag = window.innerWidth >= 768 ? "#toc" : "#toc-mobile";
        if (!tocTag) return;

        const tocCfg = {
          tocSelector: tocTag,
          contentSelector: ".post-content",
          ignoreSelector: ".no_toc, .no-toc",
          headingSelector: "h2, h3",
          orderedList: false,
          collapseDepth: 0,
          hasInnerContainers: true,
          listClass: "toc-list",
          listItemClass: "toc-item",
          activeListItemClass: "toc-item-actived",
          linkClass: "toc-link",
          activeLinkClass: "toc-link-actived",
          isCollapsedClass: "toc-collapsed",
          collapsibleClass: "toc-collapsible",
          positionFixedClass: "toc-fixed",
          fixedSidebarOffset: "auto",
        };

        if (tocTag == "#toc-mobile") {
          tocCfg.orderedList = true;
          tocCfg.headingSelector = "h2";
        }

        tocbot.destroy();
        tocbot.init(tocCfg);
        tocbot.refresh();
      };

      setupToc();
      window.addEventListener("resize", setupToc);
    }
  };

  window.addEventListener("DOMContentLoaded", () => {
    search();
    copy();
    toc();
  });
})();
