(() => {
  "use strict";

  const activeNavbar = function () {
    const menuToggle = document.querySelector("#menu-toggle");
    const menuBurger = document.querySelector(".menu-burger");
    const menuSubInput = document.querySelector(".menu-sublist input");
    const menuSubLabel = document.querySelector(".menu-sublist label");

    if (menuToggle && menuBurger) {
      menuToggle.addEventListener("change", (event) => {
        menuToggle.setAttribute("aria-checked", event.target.checked);
        menuBurger.setAttribute("aria-expanded", event.target.checked);
      });
    }

    if (menuSubInput && menuSubLabel) {
      menuSubInput.addEventListener("change", (event) => {
        menuSubInput.setAttribute("aria-checked", event.target.checked);
        menuSubLabel.setAttribute("aria-expanded", event.target.checked);
      });
    }
  };

  const tabBlock = function () {
    const tabLabel = document.querySelectorAll(".tab-label");
    if (!tabLabel) return;

    tabLabel.forEach((tab, index, tabs) => {
      tab.addEventListener("click", function () {
        activateTab(this, tabs);
      });

      tab.addEventListener("keydown", function (e) {
        if (e.key === "ArrowRight" || e.key === "ArrowLeft") {
          const newIndex = e.key === "ArrowRight" ? index + 1 : index - 1;
          const nextTab =
            tabs[newIndex < 0 ? tabs.length - 1 : newIndex % tabs.length];
          nextTab.focus();
          activateTab(nextTab, tabs);
        }
      });
    });

    function activateTab(selectedTab, tabs) {
      const tabId = selectedTab.getAttribute("aria-controls");

      // Remove active state from all tabs
      tabs.forEach((tab) => {
        tab.classList.remove("active");
        tab.setAttribute("aria-selected", "false");
        tab.setAttribute("tabindex", "-1");
      });

      // Hide all tab contents
      document.querySelectorAll(".tab-content").forEach((content) => {
        content.classList.remove("active");
        content.setAttribute("hidden", true);
      });

      // Activate the clicked tab and show corresponding content
      selectedTab.classList.add("active");
      selectedTab.setAttribute("aria-selected", "true");
      selectedTab.setAttribute("tabindex", "0");
      document.getElementById(tabId)?.classList.add("active");
      document.getElementById(tabId)?.removeAttribute("hidden");
    }
  };

  const searchPost = function () {
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

  const copyClipboard = function () {
    const copyButtons = document.querySelectorAll("[data-label-copy]");
    const copyContent = document.querySelectorAll("[data-block-copy]");

    if (copyButtons && copyContent) {
      let count = 0;

      copyButtons.forEach((button) => {
        const setFeedback = (feedback) => {
          if (feedback === "reset") {
            button.removeAttribute("data-feedback");
          } else {
            button.setAttribute("data-feedback", feedback);
          }
        };

        const textContent = copyContent.item(count).textContent;
        count = count + 1;

        button.addEventListener("click", async () => {
          try {
            await navigator.clipboard.writeText(textContent);
            setFeedback("success");
            // console.log(textContent);
          } catch (error) {
            setFeedback("error");
            console.log("Failed to copy", error);
          } finally {
            setTimeout(() => {
              setFeedback("reset");
            }, 2000);
          }
        });
      });
    }
  };

  addEventListener("DOMContentLoaded", () => {
    activeNavbar();
    copyClipboard();
    searchPost();
    // tabBlock();
  });
})();
