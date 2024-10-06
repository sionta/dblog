---
layout: post
title: "Rouge: Code Highlighting with Rouge"
categories: test
tags: [jekyll, rouge, highlight]
image: /assets/img/posts/rouge-thumb.png
toc: true
---

[Rouge](http://rouge.jneen.net/) is a syntax highlighter written in Ruby that supports over 200 programming languages. It can generate both HTML and ANSI 256-color text output. The HTML output produced by Rouge is compatible with stylesheets designed for [Pygments](http://pygments.org), another popular syntax highlighter.

<!-- markdownlint-disable MD018 MD031 -->

## Introduction

This guide provides a comprehensive overview of how Rouge handles syntax highlighting for various programming languages and configurations, including code blocks, line numbering, and using Liquid tags for highlighting within Jekyll.

## Codes

**Sample output**: <samp>This is sample output from a computer program.</samp>

**Keyboard input**: <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Esc</kbd>

**Inline code**: `{"firstName": "John","lastName": "Smith","age": 25}`

## Code Blocks

### Unknown

```unknown
{
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```

### Plaintext

A code block without syntax highlighting or using `plaintext` (the default) will look like this:

```plaintext
{
  "thisSyntax": error
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```

This block is displayed without any syntax-specific colors or formatting.

### Line Numbers

By default, line numbers are not shown. To include line numbers, add the attribute class `{: .lineno }` before or after the code block:

**Sample:**

````markdown
```json
{
  "thisSyntax": error
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```
{:.lineno} <!-- like this -->
````

**Output:**

```json
{
  "thisSyntax": error
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```
{:.lineno}

This will enable line numbering in the highlighted code block.

### Liquid Tags

{% raw %}
In addition to using markdown for code blocks, you can use Liquid’s `{% highlight %}` tag for syntax highlighting within Jekyll. This is how you use it:

This is a code block with syntax highlighting using the Liquid `{% highlight %}` tag:

**Sample:**

```liquid
{% highlight ruby linenos mark_lines="1 2" %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}
```
{% endraw %}

**Output:**

{: .highlight-tag }
{% highlight ruby linenos mark_lines="1 2" %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}

This example highlights Ruby code and marks specific lines (lines 1 and 2) to draw attention.

### Advanced

**Sample:**

````markdown
```cpp
#include <iostream>
using namespace std;

int main() {
  cout << "Hello World!";
  return 0;
}
```
{: data-code='name:"main.c";icon:"brand-cpp";href:"https://gist.github.com/sionta/a3e9dec5ae0453cf21543bf5332e7fe0";' }
````

**Output:**

```cpp
#include <iostream>
using namespace std;

int main() {
  cout << "Hello World!";
  return 0;
}
```
{: data-code='name:"main.c";icon:"brand-cpp";href:"https://gist.github.com/sionta/a3e9dec5ae0453cf21543bf5332e7fe0";' }

## Language Examples

Here are examples of how different languages are highlighted using Rouge:

### Diff

The `diff` language shows changes between versions, with additions and deletions marked.

```diff
function addTwoNumbers (num1, num2) {
-  return 1 + 2
+  return num1 + num2
}
```

### YAML

YAML syntax is used for configuration files and data serialization.

```yaml
kramdown:
    input: GFM

# Generate social links.
social_links:
    - { title: GitHub, url: "https://github.com/sionta" }
    - { title: Twitter, url: "https://twitter.com/r007mmxv" }
```

### TOML

TOML is a configuration file format designed for simplicity.

```toml
[social_links]
  name = "Andre Attamimi"
  github = "https://github.com/sionta"

[menu]
[[menu.header]]
identifier = "about"
name = "About"
url = "/about/"
```

### HTML

HTML syntax is used for structuring web pages.

```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Document</title>
    </head>
    <body>
        <div id="app"></div>

        <!-- This is a single-line comment -->

        <script>
            document.getElementById("app").innerHTML = "<h1>Hello, World!</h1>";
        </script>
    </body>
</html>
```

### SCSS

SCSS (Sassy CSS) extends CSS with variables and nested rules.

```scss
@use "sass:math";

// This is a single-line comment

$font-size: 16px;
/* $line-height: 1.7rem; */
$line-height: 1.5;
$text-color: #121212;
$background-color: #f1f1f1;

body {
    font: 400 #{$font-size}/#{$line-height} "Lato", "Arial", sans-serif;
    color: $text-color;
    background-color: $background-color;
}

figcaption { @extend %small-font-size; }

%small-font-size {
  font-size: math.clamp(-1in, 1cm, 10mm); // 10mm
}
```

### JavaScript

JavaScript is a scripting language used for creating interactive web applications.

```javascript
// This is a single-line comment

class Person {
    constructor(name) {
        this.name = name;
    }

    greet() {
        console.log(`Hello, ${this.name}!`);
    }
}

const person = new Person("John");
person.greet();
```

### Bash

Bash scripts are used for automating tasks in Unix-based systems.

```bash
#!/usr/bin/env bash

person($1) {
    echo "Hello, $1"
}

# This is a single-line comment
person("John")
```

### PowerShell

PowerShell scripts are the powerfull of shell.

```powershell
function Write-Person {
    param (
        [string]$Name
    )

    Write-Host "Hello, $Name"
}

# This is a single-line comment
Write-Person("John")
```

### PHP

PHP is a server-side scripting language used for web development.

```php
<?php
// This is a single-line comment

class Person {
    private $name;

    public function __construct($name) {
        $this->name = $name;
    }

    public function greet() {
        echo "Hello, {$this->name}!";
    }
}

$person = new Person('John');
$person->greet();
?>
```

### Ruby

Ruby is an object-oriented programming language known for its simplicity.

```ruby
=begin
This is a multi-line comment
that spans multiple lines
=end

class Person
  attr_reader :name # This is a single-line comment

  def initialize(name)
    @name = name
  end

  def greet
    puts "Hello, #{@name}!"
  end
end

person = Person.new('John')
person.greet
```

### Python

Python is a versatile, high-level programming language used in many domains.

```python
"""
This is a multi-line comment
that spans multiple lines
"""

class Person:
    def __init__(self, name):
        self.name = name # This is a single-line comment

    def greet(self):
        print(f"Hello, {self.name}!")

person = Person('John')
person.greet()
```

For further language list support [here](https://rouge-ruby.github.io/docs/file.Languages.html)
