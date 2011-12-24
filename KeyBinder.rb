module Yoshied
  class KeyBinder
    def initialize(app, undoer)
      @app = app
      @undoer = undoer
    end

    def addBindings(editorPane)
      bindDiamondCursors(editorPane)
      bindMetax(editorPane)
      bindInsert50(editorPane)
      bindTab(editorPane)
      bindEnter(editorPane)
      bindBackspace(editorPane)
      overrideByEndUndos(editorPane)
    end

    def bindDiamondCursors(editorPane)
      inputMap = editorPane.getInputMap
      key = KeyStroke.getKeyStroke(KeyEvent::VK_SEMICOLON, Event::CTRL_MASK)
      inputMap.put(key, DefaultEditorKit.backwardAction)

      key = KeyStroke.getKeyStroke(KeyEvent::VK_QUOTE, Event::CTRL_MASK)
      inputMap.put(key, DefaultEditorKit.forwardAction)

      key = KeyStroke.getKeyStroke(KeyEvent::VK_OPEN_BRACKET, Event::CTRL_MASK)
      inputMap.put(key, DefaultEditorKit.upAction)

      key = KeyStroke.getKeyStroke(KeyEvent::VK_SLASH, Event::CTRL_MASK)
      inputMap.put(key, DefaultEditorKit.downAction)
    end

    def bindMetax(editorPane)
      inputMap = editorPane.getInputMap
      actionMap = editorPane.getActionMap
      key = KeyStroke.getKeyStroke(KeyEvent::VK_X, Event::ALT_MASK)
      name = "meta-x"
      inputMap.put(key, name)
      action = ProcTextAction.new(name){@app.doMetaxAction}
      actionMap.put(name, action)
    end

    def bindTab(editorPane)
      inputMap = editorPane.getInputMap
      actionMap = editorPane.getActionMap
      key = KeyStroke.getKeyStroke(KeyEvent::VK_TAB, 0)
      actionKey = inputMap.get(key)
      action = ProcTextAction.new(actionKey){@app.doTab}
      actionMap.put(actionKey, action)
    end

    def bindEnter(editorPane)
      inputMap = editorPane.getInputMap
      actionMap = editorPane.getActionMap
      key = KeyStroke.getKeyStroke(KeyEvent::VK_ENTER, 0)
      actionKey = inputMap.get(key)
      action = ProcTextAction.new(actionKey){@app.doNewline}
      actionMap.put(actionKey, action)
    end

    def bindBackspace(editorPane)
      inputMap = editorPane.getInputMap
      actionMap = editorPane.getActionMap
      key = KeyStroke.getKeyStroke(KeyEvent::VK_BACK_SPACE, 0)
      actionKey = inputMap.get(key)
      action = ProcTextAction.new(actionKey){@app.doBackspace}
      actionMap.put(actionKey, action)
    end

    def overrideByEndUndos(editorPane)
      inputMap = editorPane.getInputMap
      actionMap = editorPane.getActionMap
      keyCombs = [
        KeyEvent::VK_LEFT,
        KeyEvent::VK_RIGHT,
        KeyEvent::VK_UP,
        KeyEvent::VK_DOWN,
        KeyEvent::VK_HOME,
        KeyEvent::VK_END,
        KeyEvent::VK_PAGE_UP,
        KeyEvent::VK_PAGE_DOWN,
        [KeyEvent::VK_V, Event::CTRL_MASK]
      ].each do |keyComb|
        overrideByEndUndo(inputMap, actionMap, keyComb)
      end
    end

    def overrideByEndUndo(inputMap, actionMap, keyComb)
      keyCode, modifiers = *keyComb
      modifiers ||= 0
      key = KeyStroke.getKeyStroke(keyCode, modifiers)
      actionKey = inputMap.get(key)
      action = actionMap.get(actionKey)
      endUndo = EndUndoSequenceAction.new(@undoer, action)
      actionMap.put(actionKey, endUndo)
    end

    def menuMnemonicFile
      return KeyEvent::VK_F
    end

    def menuMnemonicEdit
      return KeyEvent::VK_E
    end

    def menuKeyConfigNew
      return {
        :mnemonic => KeyEvent::VK_N,
        :accel => [KeyEvent::VK_N, ActionEvent::CTRL_MASK],
        :action => proc{|event| @app.onMenuItemNew}
      }
    end

    def menuKeyConfigOpen
      return {
        :mnemonic => KeyEvent::VK_O,
        :accel => [KeyEvent::VK_O, ActionEvent::CTRL_MASK],
        :action => proc{|event| @app.onMenuItemOpen}
      }
    end

    def menuKeyConfigSave
      return {
        :mnemonic => KeyEvent::VK_S,
        :accel => [KeyEvent::VK_S, ActionEvent::CTRL_MASK],
        :action => proc{|event| @app.onMenuItemSave}
      }
    end

    def menuKeyConfigSaveAs
      return {
        :mnemonic => KeyEvent::VK_A,
        :action => proc{|event| @app.onMenuItemSaveAs}
      }
    end

    def menuKeyConfigExit
      return {
        :mnemonic => KeyEvent::VK_X,
        :action => proc{|event| @app.onMenuItemExit}
      }
    end

    def menuKeyConfigUndo
      return {
        :mnemonic => KeyEvent::VK_U,
        :accel => [KeyEvent::VK_Z, ActionEvent::CTRL_MASK],
      }
    end

    def menuKeyConfigRedo
      return {
        :mnemonic => KeyEvent::VK_D,
        :accel => [KeyEvent::VK_Y, ActionEvent::CTRL_MASK],
      }
    end

    def menuKeyConfigCut
      return {
        :mnemonic => KeyEvent::VK_T,
        :accel => [KeyEvent::VK_X, ActionEvent::CTRL_MASK],
        :action => proc{|event| @app.onMenuItemCut}
      }
    end

    def menuKeyConfigCopy
      return {
        :mnemonic => KeyEvent::VK_C,
        :accel => [KeyEvent::VK_C, ActionEvent::CTRL_MASK],
        :action => proc{|event| @app.onMenuItemCopy}
      }
    end

    def menuKeyConfigPaste
      return {
        :mnemonic => KeyEvent::VK_P,
        :accel => [KeyEvent::VK_V, ActionEvent::CTRL_MASK],
        :action => proc{|event| @app.onMenuItemPaste}
      }
    end

    def menuKeyConfigFind
      return {
        :mnemonic => KeyEvent::VK_F,
        :accel => [KeyEvent::VK_F, ActionEvent::CTRL_MASK],
        :action => proc{|event| @app.onMenuItemFind}
      }
    end

    def menuKeyConfigFindNext
      return {
        :mnemonic => KeyEvent::VK_N,
        :accel => ["F3"],
        :action => proc{|event| @app.onMenuItemFindNext}
      }
    end

    def menuKeyConfigReplace
      return {
        :mnemonic => KeyEvent::VK_R,
        :accel => [KeyEvent::VK_R, ActionEvent::CTRL_MASK],
        :action => proc{|event| @app.onMenuItemReplace}
      }
    end

    def menuKeyConfigSelectAll
      return {
        :mnemonic => KeyEvent::VK_A,
        :accel => [KeyEvent::VK_A, ActionEvent::CTRL_MASK],
        :action => proc{|event| @app.onMenuItemSelectAll}
      }
    end

    def bindInsert50(editorPane)
      inputMap = editorPane.getInputMap
      actionMap = editorPane.getActionMap
      key = KeyStroke.getKeyStroke(KeyEvent::VK_5, Event::ALT_MASK)
      name = "insert50"
      inputMap.put(key, name)
      action = ProcTextAction.new(name){@app.doInsert50}
      actionMap.put(name, action)
    end
  end
end
