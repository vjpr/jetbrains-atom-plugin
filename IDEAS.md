# Sidekick for Programmers

Goals:

- The program should evolve over time. Deleting documentation feels bad because it takes a lot of time and thought to write.
    - Put programmer at ease when deleting code.
 

---

**The following is an exploration of literate programming.**

There are three main parts.

- A web application
- A chrome extension
- An IntelliJ extension

People will be writing in text-editor file-based approach for decades.

Ways to break up a program:

- Aspects
  - Authentication
  - Caching
  - Persistence
  
- Events
- Dataflows
- Endpoints 'http://sidekick.io/something'
- Backend/Frontend flows
- User stories/interactions

Ideas:

- Provide headings for common aspects of web applications and allow drag drop of methods into them

Headings:

- Received web request
- Boot
- Started
- Events...


# IntelliJ Idea Counterpart Plugin

*VERY EARLY STAGE*

This plugin publishes notifications over websockets when you start looking at another file or symbol within IntelliJ.

**Goal**

Provide the developer with additional files or documents they might need when editing/reading the file in the active editor.

This plugin can be used to:

 * Open a companion file in another tab group. This is similar to how XCode deals with companion files by opening the `.c` file with the `.h` file. For example:
   * the generated JavaScript for a CoffeeScript file.
   * an interface for an implementation file.
   * a server-side API source file (e.g. written in Scala) for a client-side API source file (e.g. written in CoffeeScript).
 * Opening [Docco](https://github.com/jashkenas/docco) documentation on tab change in a web browser.
 * Opening documentation/tutorial for a JavaScript library.
 * Opening a README file from the directory which the currently active file resides in.
 * Open support code such as definitions/package members/etc.

**Motivation**

[Docco](https://github.com/jashkenas/docco) is a really nice way to read and understand code. At present it is tedious to quickly jump to the supporting documentation when needed.

## TODO

 * Use the same technique as the [JsTestDriver](http://confluence.jetbrains.net/display/WI/Development+of+JsTestDriver+IntelliJ+plugin) Idea plugin to capture a browser tab for displaying companion files.
 * Create settings dialog for creating mappings between resources leveraging Idea Command Line Tools macros and regex if possible.
 * Create setting to specify where to send events.
 * ASIDE: Chrome browser extension to add links from GitHub source files to IntelliJ using the Remote Call plugin. Also, detect links to source files and hyperlink them.