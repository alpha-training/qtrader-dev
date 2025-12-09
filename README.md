# qtrader-dev
The goal of this project is to build a minimalist kdb+ trading platform.

## Workflow

1. High level task is created by Kieran or another developer
2. Task is assigned to developer (**A**)
3. **A** adds feature and commits code, perhaps in a new branch depending on its size
4. Developer **B** (and perhaps **C**) code review, and may suggest changes
5. Once any edits are made, the feature is merged into the **main** branch

**Important**: Whenever a task is:

* Created
* Assigned
* Started
* In review, and 
* Completed

it should be updated in the project planner.

## Coding convention
Apart from the aforementioned notes [on style](https://github.com/alpha-training/fundamentals/blob/main/reading/onstyle.md), some rules we want to follow:

* No harcoding of variables
* Variables that are common to all, shoudl go in json
* Variables that are user-specific should go in .env
* Functions should be readable
* Variable names should be intuitive
* Tables begin with an upper letter and use the singular (e.g. **Order** not **Orders**)
* Column names are lower case, and only if needed, use an _
* Highly repeated tasks should be promoted to common libraries / functions
* Internal discussions should take place regularly about design decisions

## Way of proceeding
Rather than suffer from *analysis paralysis*, we should just push ahead and build processes, writing the best code we can. As we progress, we can take occasional breaks to scan the *hygiene* and structure of our codebase, and look for improvements.

