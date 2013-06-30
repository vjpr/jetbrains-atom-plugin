String.prototype.leftTrim = ->
	return this.replace(/^\s+/,"")

class @List extends Backbone.View

  el: '#list'

  appendItem: (item) =>
    @$el.append item

  appendHtml: (html) =>
    @$el.html html

  appendEditor: (fileName, content, comments, path, offset) =>
    html = JST['templates/block'] doc: comments
    el = $ html
    @$el.append el
    console.log el.html()
    $editor = el.find('.editor')
    editor = ace.edit $editor[0]
    #editor.setTheme 'ace/theme/monokai'
    editor.getSession().setValue content
    editor.getSession().setMode 'ace/mode/coffee'
    editor.getSession().setTabSize '2'
    editor.setShowPrintMargin false
    editor.setDisplayIndentGuides false

    editor.setFontSize '10px'
    editor.renderer.setShowGutter false
    editor.setHighlightActiveLine false

    originalLength = content.length
    do (path, offset, originalLength) ->
      editor.getSession().getDocument().on 'change', (e) ->
        console.log e.data.action
        switch e.data.action
          when 'insertText'
            window.socket.emit 'insertText', e.data
            #console.log e.data.range
            #console.log e.data.text
        # Update IntelliJ
        window.socket.emit 'document:change',
          body: editor.getSession().getValue().leftTrim()
          path: path
          offset: offset
          to: offset + originalLength
        originalLength = editor.getSession().getValue().leftTrim().length
        return

    editor.getSession().on 'change', -> heightUpdateFunction editor, $editor
    # Set initial size to match initial content
    heightUpdateFunction editor, $editor

    #codemirror = CodeMirror $('#editor')[0],
    #  value: content
    #  mode: 'coffeescript'


# Whenever a change happens inside the ACE editor, update
# the size again
heightUpdateFunction = (editor, $el) ->

  # http://stackoverflow.com/questions/11584061/
  newHeight = editor.getSession().getScreenLength() * editor.renderer.lineHeight + editor.renderer.scrollBar.getWidth()
  $el.height newHeight.toString() + "px"

  #$("#editor-section").height newHeight.toString() + "px"

  # This call is required for the editor to fix all of
  # its inner structure for adapting to a change in size
  editor.resize()
