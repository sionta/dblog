(() => {
  "use strict";

  const getTheme = () =>
    localStorage.getItem("theme") ||
    (window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light");

  const activeNavbar = () => {
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

  const searchPost = () => {
    if (window.Fuse) {
      const searchData = document
        .querySelector("label[data-search]")
        ?.getAttribute("data-search");
      if (searchData) {
        fetch(searchData)
          .then((response) => response.json())
          .then((data) => {
            setupSearch(data);
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
          const searchClass = {
            item: "search-item",
            name: "search-item__name",
            desc: "search-item__desc",
            link: "search-item__link",
          };

          resultsContainer.innerHTML = "";

          if (searchTerm !== "") {
            const results = fuse.search(searchTerm);

            if (results.length > 0) {
              results.forEach((result) => {
                const item = document.createElement("li");
                item.className = searchClass.item;

                const name = document.createElement("h3");
                name.className = searchClass.name;

                const link = document.createElement("a");
                link.className = searchClass.link;
                link.href = result.item.url;
                link.textContent = result.item.title;

                name.appendChild(link);

                const desc = document.createElement("p");
                desc.className = searchClass.desc;
                desc.textContent = result.item.excerpt;

                item.appendChild(name);
                item.appendChild(desc);
                resultsContainer.appendChild(item);
              });
            } else {
              const noResults = `<li class="${searchClass.item} no-results">No results for <span>"${searchTerm}"<span></li>`;
              resultsContainer.innerHTML = noResults;
            }
          }
        });
      }
    }
  };

  const mermaidDiagram = () => {
    const mermaidElements = document.querySelectorAll(".language-mermaid");

    if (typeof mermaid !== "undefined" && mermaidElements) {
      mermaidElements.forEach((element) => {
        const preElement = element.parentElement;
        const container = document.createElement("div");
        container.className = "diagram";

        const preBackup = document.createElement("pre");
        preBackup.className = "mermaid-html";
        preBackup.style.display = "none";
        preBackup.innerHTML = preElement.innerHTML;

        const preMermaid = document.createElement("pre");
        preMermaid.className = "mermaid";
        preMermaid.textContent = preElement.textContent;

        container.appendChild(preBackup);
        container.appendChild(preMermaid);
        preElement.replaceWith(container);
      });

      const mermaidTheme = (theme) => {
        const mode = theme || getTheme();
        return {
          theme: mode === "light" ? "default" : "dark",
        };
      };

      mermaid.initialize(mermaidTheme());

      // reload mermaid when the theme is changed
      window.addEventListener("message", (event) => {
        const currentTheme = event.data.themeChange;
        const mermaidElements = document.querySelectorAll(".mermaid");
        if (currentTheme && mermaidElements) {
          mermaidElements.forEach((elem) => {
            const svgContent = elem.previousSibling.children.item(0).innerHTML;
            elem.innerHTML = svgContent;
            elem.removeAttribute("data-processed");
          });
          mermaid.initialize(mermaidTheme(currentTheme));
          mermaid.init(undefined, ".mermaid");
        }
      });
    }
  };

  const copyClipboard = () => {
    const copyButtons = document.querySelectorAll("[data-label-copy]");
    const copyContent = document.querySelectorAll("[data-block-copy]");

    if (copyButtons.length > 0 && copyContent.length > 0) {
      copyButtons.forEach((button, index) => {
        const textContent = copyContent[index].textContent;

        const setFeedback = (feedback) => {
          if (feedback === "reset") {
            button.removeAttribute("data-feedback");
          } else {
            button.setAttribute("data-feedback", feedback);
          }
        };

        button.addEventListener("click", async () => {
          try {
            await navigator.clipboard.writeText(textContent);
            setFeedback("success");
          } catch (error) {
            setFeedback("error");
            console.error("Failed to copy", error);
          } finally {
            setTimeout(() => {
              setFeedback("reset");
            }, 2000);
          }
        });
      });
    }
  };

  document.addEventListener("DOMContentLoaded", () => {
    activeNavbar();
    copyClipboard();
    searchPost();
    mermaidDiagram();
  });
})();
