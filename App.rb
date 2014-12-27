module Yoshied
  class App
    include java.awt.event.WindowListener
    include java.lang.Runnable
    include javax.swing.event.ChangeListener
    include javax.swing.event.DocumentListener

    def initialize
      @frame = nil
      @mainPane = nil
      @currentFile = nil
      @undoer = Undoer.new
      @dirty = false
      @findUI = FindUI.new(self)
      @replaceUI = ReplaceUI.new(self)
      @indenter = Indenter.new(self)
      @keyBinder = KeyBinder.new(self, @undoer)
    end
    attr_reader :frame, :mainPane

    def run
      frame = createGUI
      !$yoshi_argv.empty? and openFile(File.expand_path($yoshi_argv[0]))
      frame.setVisible(true)
    end

    def createGUI
      createFrame
      return @frame
    end

    def createFrame
      @frame = JFrame.new
      @frame.setJMenuBar(createMenuBar)
      @frame.setContentPane(createContentPane)
      @frame.setDefaultCloseOperation(JFrame::DO_NOTHING_ON_CLOSE)
      @frame.setPreferredSize(java.awt.Dimension.new(640, 480))
      @frame.addWindowListener(self)
      @frame.pack
      newDocument
      return @frame
    end

    def createMenuBar
      menuBar = javax.swing.JMenuBar.new
      menuBar.add(createMenuFile)
      menuBar.add(createMenuEdit)
      return menuBar
    end

    def createMenuFile
      menu = JMenu.new("File")
      menu.setMnemonic(@keyBinder.menuMnemonicFile)
      menu.add(createMenuItemNew)
      menu.add(createMenuItemOpen)
      menu.add(createMenuItemSave)
      menu.add(createMenuItemSaveAs)
      menu.addSeparator
      menu.add(createMenuItemExit)
      return menu
    end

    def createMenuItemNew
      config = @keyBinder.menuKeyConfigNew
      config[:text] = "New"
      return createMenuItem(config)
    end

    def createMenuItem(config)
      menuItem = JMenuItem.new
      setupMenuItem(menuItem, config)
      return menuItem
    end

    def setupMenuItem(menuItem, config)
      config.key?(:text) and menuItem.setText(config[:text])
      config.key?(:mnemonic) and menuItem.setMnemonic(config[:mnemonic])
      config.key?(:accel) and
        menuItem.setAccelerator(KeyStroke.getKeyStroke(*config[:accel]))
      config.key?(:action) and menuItem.addActionListener(config[:action])
    end

    def createMenuItemOpen
      config = @keyBinder.menuKeyConfigOpen
      config[:text] = "Open..."
      return createMenuItem(config)
    end

    def createMenuItemSave
      config = @keyBinder.menuKeyConfigSave
      config[:text] = "Save"
      return createMenuItem(config)
    end

    def createMenuItemSaveAs
      config = @keyBinder.menuKeyConfigSaveAs
      config[:text] = "Save As..."
      return createMenuItem(config)
    end

    def createMenuItemExit
      config = @keyBinder.menuKeyConfigExit
      config[:text] = "Exit"
      return createMenuItem(config)
    end

    def createMenuEdit
      menu = JMenu.new("Edit")
      menu.setMnemonic(@keyBinder.menuMnemonicEdit)
      menu.add(@undoer.undoAction)
      setupMenuItemUndo(menu)
      menu.add(@undoer.redoAction)
      setupMenuItemRedo(menu)
      menu.addSeparator
      menu.add(createMenuItemCut)
      menu.add(createMenuItemCopy)
      menu.add(createMenuItemPaste)
      menu.addSeparator
      menu.add(createMenuItemFind)
      menu.add(createMenuItemFindNext)
      menu.add(createMenuItemReplace)
      menu.addSeparator
      menu.add(createMenuItemSelectAll)
      return menu
    end

    def setupMenuItemUndo(menu)
      menuItem = findMenuItemByAction(menu, @undoer.undoAction)
      config = @keyBinder.menuKeyConfigUndo
      setupMenuItem(menuItem, config)
    end

    def findMenuItemByAction(menu, action)
      menu.getItemCount.times do |i|
        menuItem = menu.getItem(i)
        menuItem.getAction == action and return menuItem
      end
      return nil
    end

    def setupMenuItemRedo(menu)
      menuItem = findMenuItemByAction(menu, @undoer.redoAction)
      config = @keyBinder.menuKeyConfigRedo
      setupMenuItem(menuItem, config)
    end

    def createMenuItemCut
      config = @keyBinder.menuKeyConfigCut
      config[:text] = "Cut"
      return createMenuItem(config)
    end

    def createMenuItemCopy
      config = @keyBinder.menuKeyConfigCopy
      config[:text] = "Copy"
      return createMenuItem(config)
    end

    def createMenuItemPaste
      config = @keyBinder.menuKeyConfigPaste
      config[:text] = "Paste"
      return createMenuItem(config)
    end

    def createMenuItemFind
      config = @keyBinder.menuKeyConfigFind
      config[:text] = "Find..."
      return createMenuItem(config)
    end

    def createMenuItemFindNext
      config = @keyBinder.menuKeyConfigFindNext
      config[:text] = "Find Next"
      return createMenuItem(config)
    end

    def createMenuItemReplace
      config = @keyBinder.menuKeyConfigReplace
      config[:text] = "Replace"
      return createMenuItem(config)
    end

    def createMenuItemSelectAll
      config = @keyBinder.menuKeyConfigSelectAll
      config[:text] = "Select All"
      return createMenuItem(config)
    end

    def createContentPane
      contentPane = JPanel.new
      contentPane.setLayout(BorderLayout.new)
      contentPane.add(createScrollPane, BorderLayout::CENTER)
      contentPane.add(createToolbar, BorderLayout::SOUTH);
      return contentPane
    end

    def createScrollPane
      scrollPane = javax.swing.JScrollPane.new
      scrollPane.setViewportView(createMainPane)
      scrollPane.setVerticalScrollBarPolicy(
        ScrollPaneConstants::VERTICAL_SCROLLBAR_ALWAYS)
      scrollPane.setHorizontalScrollBarPolicy(
        ScrollPaneConstants::HORIZONTAL_SCROLLBAR_ALWAYS)
      scrollPane.getViewport.addChangeListener(self)
      return scrollPane
    end

    def createMainPane
      @mainPane = javax.swing.JEditorPane.new
      initDocument(@mainPane)
      @keyBinder.addBindings(@mainPane)
      return @mainPane
    end

    def createToolbar
      toolbar = JPanel.new
      toolbar.add(createSaveButton)
      return toolbar
    end

    def createSaveButton
      button = JButton.new
      button.setText("Save")
      button.addActionListener(proc{|event|
        onMenuItemSave
        @mainPane.requestFocusInWindow
      })
      return button
    end

    def initDocument(editorPane)
      doc = editorPane.getDocument
      doc.addDocumentListener(self)
      doc.addUndoableEditListener(@undoer)
    end

    def onMenuItemNew
      saveDirtyDocument == :cancel and return
      newDocument
    end

    def saveDirtyDocument
      !@dirty and return :ok
      ret = askSaveDocument
      case ret
      when :yes
        return onMenuItemSave
      when :no
        return :ok
      when :cancel
        return :cancel
      end
    end

    def askSaveDocument
      ret = JOptionPane.showConfirmDialog(@frame, "Do you save the changes?",
                                          "",
                                          JOptionPane::YES_NO_CANCEL_OPTION)
      case ret
      when JOptionPane::YES_OPTION
        return :yes
      when JOptionPane::NO_OPTION
        return :no
      else
        return :cancel
      end
    end

    def newDocument
      @mainPane.setText("")
      @frame.setTitle("")
      @currentFile = nil
      @dirty = true
      @undoer.resetUndo
    end

    def onMenuItemOpen
      saveDirtyDocument == :cancel and return
      jfile = showFileOpenDialog
      !jfile and return
      openFile(jfile.getAbsolutePath)
    end

    def showFileOpenDialog
      chooser = JFileChooser.new
      dir = java.io.File.new(currentDirectory)
      chooser.setCurrentDirectory(dir)
      ret = chooser.showOpenDialog(@frame)
      ret != JFileChooser::APPROVE_OPTION and return nil
      return chooser.getSelectedFile
    end

    def currentDirectory
      return @currentFile ? File.dirname(@currentFile) : Dir.pwd
    end

    def openFile(absPath)
      bufReader = nil
      begin
        fis = java.io.FileInputStream.new(absPath)
        utf8 = java.nio.charset.Charset.forName("UTF-8")
        isReader = java.io.InputStreamReader.new(fis, utf8)
        bufReader = java.io.BufferedReader.new(isReader)
        @mainPane.read(bufReader, nil)
        initDocument(@mainPane)
      rescue
        $stderr.puts($!)
        $stderr.puts($!.backtrace)
        return
      ensure
        bufReader and bufReader.close
      end
      @mainPane.setCaretPosition(0)
      @frame.setTitle(File.basename(absPath))
      @currentFile = absPath
      @dirty = false
      @undoer.resetUndo
    end

    def onMenuItemSave
      lastEditEnd
      !@dirty and return :ok
      @currentFile and return saveDocument(@currentFile) ? :ok : :cancel
      return onMenuItemSaveAs
    end

    def saveDocument(absPath)
      bufWriter = nil
      begin
        fos = java.io.FileOutputStream.new(absPath)
        utf8 = java.nio.charset.Charset.forName("UTF-8")
        osWriter = java.io.OutputStreamWriter.new(fos, utf8)
        bufWriter = java.io.BufferedWriter.new(osWriter)
        @mainPane.write(bufWriter)
        @currentFile = absPath
        @frame.setTitle(File.basename(absPath))
        @dirty = false
        return true
      rescue
        $stderr.puts($!)
        $stderr.puts($!.backtrace)
        return false
      ensure
        bufWriter and bufWriter.close
      end
    end

    def onMenuItemSaveAs
      lastEditEnd
      jfile = showFileSaveDialog
      !jfile and return :cancel
      askReplaceFile(jfile) != :yes and return :cancel
      return saveDocument(jfile.getAbsolutePath) ? :ok : :cancel
    end

    def showFileSaveDialog
      chooser = JFileChooser.new
      dir = java.io.File.new(currentDirectory)
      chooser.setCurrentDirectory(dir)
      file = java.io.File.new(defaultSavedFile)
      chooser.setSelectedFile(file)
      ret = chooser.showSaveDialog(@frame)
      ret != JFileChooser::APPROVE_OPTION and return nil
      return chooser.getSelectedFile
    end

    def defaultSavedFile
      @currentFile and return @currentFile
      return Time.now.strftime("%Y%m%d.txt")
    end

    def askReplaceFile(jfile)
      !jfile.exists and return :yes
      filename = File.basename(jfile.getAbsolutePath)
      msg = "%s already exists. Replace it?" % filename
      ret = JOptionPane.showConfirmDialog(@frame, msg, "",
                                          JOptionPane::YES_NO_OPTION)
      return (ret == JOptionPane::YES_OPTION) ? :yes : :no
    end

    def onMenuItemExit
      saveDirtyDocument == :cancel and return
      javax.swing.SwingUtilities.invokeLater(Terminator.new)
    end

    def onMenuItemCut
      lastEditEnd
      @mainPane.cut
    end

    def onMenuItemCopy
      lastEditEnd
      @mainPane.copy
    end

    def onMenuItemPaste
      lastEditEnd
      @mainPane.paste
    end

    def onMenuItemFind
      lastEditEnd
      @findUI.show
    end

    def onMenuItemFindNext
      lastEditEnd
      @findUI.onFindNext
    end

    def onMenuItemReplace
      lastEditEnd
      @replaceUI.show
    end

    def onMenuItemSelectAll
      lastEditEnd
      @mainPane.selectAll
    end

    def findPrev(pattern, matchCase)
      text = getMainText
      curpos = @mainPane.getSelectionStart - 1
      curpos <= 0 and return
      regexp = getFindRegexp(pattern, matchCase)
      found = text.rindex(regexp, curpos)
      !found and return
      @mainPane.select(found, found + pattern.size)
    end

    def getMainText
      text = @mainPane.getText
      text.gsub!("\r", "")
      return text
    end

    def getFindRegexp(str, matchCase)
      pattern = Regexp.escape(str)
      option = matchCase ? 0 : Regexp::IGNORECASE
      return Regexp.compile(pattern, option)
    end

    def findNext(pattern, matchCase)
      text = getMainText
      curpos = @mainPane.getCaretPosition
      regexp = getFindRegexp(pattern, matchCase)
      found = text.index(regexp, curpos)
      !found and return false
      @mainPane.select(found, found + pattern.size)
      return true
    end

    def replaceAndFind(pattern, replacement, matchCase)
      replaceSelection(replacement)
      return findNext(pattern, matchCase)
    end

    def replaceSelection(replacement)
      @undoer.inReplace = !emptySelection?
      @mainPane.replaceSelection(replacement)
      @undoer.inReplace = false
    end

    def emptySelection?
      return @mainPane.getSelectionStart - @mainPane.getSelectionEnd == 0
    end

    def replaceAll(pattern, replacement, matchCase)
      loop do
        !replaceAndFind(pattern, replacement, matchCase) and break
      end
    end

    def lastEditEnd
      @undoer.lastEditEnd
    end

    def doMetaxAction
      pos = getSelectionStart
      p @indenter.leadingWhites(pos)
    end

    def getColumnOfSelectionStart
      return getSelectionStart - getBeginningOfLineOnSelection
    end

    def getSelectionStart
      return @mainPane.getSelectionStart
    end

    def getSelectionEnd
      return @mainPane.getSelectionEnd
    end

    def getSelection
      return getSelectionStart..getSelectionEnd
    end

    def select(selstart, selend)
      @mainPane.select(selstart, selend)
    end

    def getBeginningOfLineOnSelection
      pos = @mainPane.getSelectionStart
      return javax.swing.text.Utilities.getRowStart(@mainPane, pos)
    end

    def getMainSubstr(where, len)
      return @mainPane.getDocument.getText(where, len)
    end

    def emptyLine?(position)
      emptyDocument? and return true
      pos = beginningOfLine(position)
      endOfDocument?(pos) and return true
      ch = getMainSubstr(pos, 1)
      return ch == "\n"
    end

    def emptyDocument?
      return endOfDocument?(0)
    end

    def endOfDocument?(pos)
      return pos == endOfDocument
    end

    def endOfDocument
      return @mainPane.getDocument.getEndPosition
    end

    def beginningOfLine(position)
      pos = position
      while pos - 1 >= 0
        ch = getMainSubstr(pos - 1, 1)
        ch == "\n" and return pos
        pos -= 1
      end
      return pos
    end

    def doTab
      lastEditEnd
      @indenter.tab
    end

    def doNewline
      lastEditEnd
      @indenter.newline
    end

    def doBackspace
      lastEditEnd
      @indenter.hungryBackspace
    end

    def doInsert50
      replaceSelection("=" * 50)
    end

    def changedUpdate(documentEvent)
      @dirty = true
    end
    def insertUpdate(documentEvent)
      @dirty = true
    end
    def removeUpdate(documentEvent)
      @dirty = true
    end

    def windowClosing(event)
      onMenuItemExit
    end
    def windowActivated(event); end
    def windowClosed(event); end
    def windowDeactivated(event); end
    def windowDeiconified(event); end
    def windowIconified(event); end
    def windowOpened(event); end

    def stateChanged(changeEvent)
      adjustViewport(changeEvent.getSource)
    end

    def adjustViewport(viewport)
      portSize = viewport.getSize
      viewSize = viewport.getViewSize
      portSize.width == viewSize.width and return
      newSize = Dimension.new(portSize.width, viewSize.height)
      viewport.setViewSize(newSize)
    end
  end

  class Terminator
    include java.lang.Runnable

    def run
      java.lang.System.exit(0)
    end
  end

  class ProcTextAction < AbstractAction
    def initialize(name, block=Proc.new)
      @block = block
    end

    def actionPerformed(event)
      @block.call(event)
    end
  end
end
