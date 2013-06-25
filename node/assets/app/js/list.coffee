class @List extends Backbone.View

  el: '#list'

  appendItem: (item) =>
    @$el.append item

  appendHtml: (html) =>
    @$el.html html

  appendEditor: (fileName, content) =>
    codemirror = CodeMirror $('#editor')[0],
      value: content
