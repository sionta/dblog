---
layout: post
title: "Mermaid.js: Build Complex Diagrams with Simple Text Descriptions"
categories: test
tags: [mermaid]
author: Andre Attamimi
image: /assets/img/posts/mermaid-diagram.png
toc: true
diagram: true
---

Mermaid.js is a powerful JavaScript-based tool for creating diagrams and visualizations using simple text descriptions. It allows you to dynamically render various types of diagrams directly from Markdown-inspired text definitions. Below, you’ll find descriptions and examples for different types of diagrams supported by Mermaid.js.

## Introduction

Here’s a refined and detailed explanation of the different types of diagrams you can create with Mermaid.js, including the syntax used for each Each type of Mermaid diagram is designed to fulfill specific needs in documentation and programming, providing an intuitive way to visualize complex information through simple text descriptions:

## Flowchart

Flowcharts are used to represent process flows or workflows. They show the sequence of steps in a process, helping to visualize the order and connections between tasks.

```mermaid
flowchart TD
    A[Christmas] -->|Get money| B(Go shopping)
    B --> C{Let me think}
    C -->|One| D[Laptop]
    C -->|Two| E[iPhone]
    C -->|Three| F[fa:fa-car Car]
```

- `flowchart TD` specifies a top-down layout.
- Arrows (`-->`) indicate the direction of flow.
- `|Get money|` represents the label on the arrow.

## Gantt Chart

Gantt charts are used for project planning, displaying timelines and the progress of various tasks over time.

```mermaid
gantt
    title A Gantt Diagram
    dateFormat  YYYY-MM-DD
    section Section
    A task           :a1, 2014-01-01, 30d
    Another task     :after a1  , 20d
    section Another
    Task in sec      :2014-01-12  , 12d
    another task      : 24d
```

- `gantt` denotes the chart type.
- `dateFormat` sets the date format.
- `section` groups tasks into sections.
- Tasks are defined with a start date and duration.

## Class Diagram

Class diagrams represent the structure of classes in object-oriented programming, showing their attributes and methods.

```mermaid
classDiagram
    Animal <|-- Duck
    Animal <|-- Fish
    Animal <|-- Zebra
    Animal : +int age
    Animal : +String gender
    Animal: +isMammal()
    Animal: +mate()
    class Duck{
      +String beakColor
      +swim()
      +quack()
    }
    class Fish{
      -int sizeInFeet
      -canEat()
    }
    class Zebra{
      +bool is_wild
      +run()
    }
```

- `classDiagram` specifies the diagram type.
- `Animal <|-- Duck` shows inheritance.
- Classes and their attributes/methods are defined within `class` blocks.

## State Diagram

State diagrams represent states and transitions of an entity, useful for modeling state changes in a system.

```mermaid
stateDiagram-v2
    [*] --> Still
    Still --> [*]
    Still --> Moving
    Moving --> Still
    Moving --> Crash
    Crash --> [*]
```

- `stateDiagram-v2` indicates the version.
- `[*]` represents the initial and final states.
- Transitions are shown with arrows.

## Entity Relationship Diagram (ERD)

ERDs show the relationships between entities in a database, useful for designing and understanding data structures.

```mermaid
erDiagram
    CUSTOMER }|..|{ DELIVERY-ADDRESS : has
    CUSTOMER ||--o{ ORDER : places
    CUSTOMER ||--o{ INVOICE : "liable for"
    DELIVERY-ADDRESS ||--o{ ORDER : receives
    INVOICE ||--|{ ORDER : covers
    ORDER ||--|{ ORDER-ITEM : includes
    PRODUCT-CATEGORY ||--|{ PRODUCT : contains
    PRODUCT ||--o{ ORDER-ITEM : "ordered in"
```

- `erDiagram` specifies the diagram type.
- Relationships are denoted with different symbols (`}|..|{`, `||--o{`, etc.).

## Pie Chart

Pie charts represent data distribution in a circular format, showing the proportion of each category.

```mermaid
pie title Pets adopted by volunteers
    "Dogs" : 386
    "Cats" : 85
    "Rats" : 15
```

- `pie` specifies the diagram type.
- `title` sets the chart’s title.
- Categories and values are listed with their proportions.

## Journey

Journey diagrams represent the steps involved in a process or scenario, showing different stages and actions.

```mermaid
journey
    title My working day
    section Go to work
      Make tea: 5: Me
      Go upstairs: 3: Me
      Do work: 1: Me, Cat
    section Go home
      Go downstairs: 5: Me
      Sit down: 3: Me
```

- `journey` specifies the diagram type.
- `section` groups stages of the journey.
- Actions are listed with their durations and participants.

## Requirement Diagram

Requirement diagrams represent system requirements and their relationships, useful for capturing and validating system needs.

```mermaid
 requirementDiagram

 requirement test_req {
 id: 1
 text: the test text.
 risk: high
 verifymethod: test
 }

 element test_entity {
 type: simulation
 }

 test_entity - satisfies -> test_req
```

- `requirementDiagram` indicates the diagram type.
- `requirement` and `element` define requirements and their properties.
- Relationships are shown with arrows.

## GitGraph

GitGraph diagrams visualize Git repositories and branches, helping to understand the branching and merging history.

```mermaid
gitGraph
    commit
    commit
    branch develop
    checkout develop
    commit
    commit
    checkout main
    merge develop
    commit
    commit
```

- `gitGraph` specifies the diagram type.
- `commit` represents a commit in the graph.
- `branch`, `checkout`, and `merge` commands show branch operations.
