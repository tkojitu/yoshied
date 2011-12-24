module Yoshied
  class ReplaceUI
    LEADING = GroupLayout::Alignment::LEADING
    def initialize(app)
      @app = app
      @dialog = nil
      @patternField = nil
      @replacementField = nil
      @caseCheckbox = nil
    end

    def create(owner)
      @dialog = JDialog.new(owner, "Replace")
      @dialog.setLayout(BorderLayout.new)
      @dialog.add(createContentPane, BorderLayout::CENTER)
      addBindings(@dialog.getRootPane)
      @dialog.pack
      locateDialog
    end

    def createContentPane
      textPane = createTextPane
      buttonPane = createButtonPane

      panel = JPanel.new
      layout = GroupLayout.new(panel)
      panel.setLayout(layout)

      group = layout.createSequentialGroup
      group.addComponent(textPane).
        addComponent(buttonPane)
      layout.setHorizontalGroup(group)

      group = layout.createSequentialGroup
      group.addGroup(layout.createParallelGroup.
                       addComponent(textPane).
                       addComponent(buttonPane))
      layout.setVerticalGroup(group)

      return panel
    end

    def createTextPane
      @patternField = createTextField
      @replacementField = createTextField
      @caseCheckbox = JCheckBox.new("Match Case")
      spacer1 = javax.swing.JLabel.new(" ")
      spacer2 = javax.swing.JLabel.new(" ")

      panel = JPanel.new
      layout = GroupLayout.new(panel)
      panel.setLayout(layout)
      layout.setAutoCreateGaps(true)
      layout.setAutoCreateContainerGaps(true)

      group = layout.createSequentialGroup
      group.addGroup(layout.createParallelGroup(LEADING).
                       addComponent(@patternField).
                       addComponent(@replacementField).
                       addComponent(@caseCheckbox).
                       addComponent(spacer1).
                       addComponent(spacer2))
      layout.setHorizontalGroup(group)

      group = layout.createSequentialGroup
      group.addComponent(@patternField).
        addComponent(@replacementField).
        addComponent(@caseCheckbox).
        addComponent(spacer1).
        addComponent(spacer2)
      layout.setVerticalGroup(group)

      return panel
    end

    def createTextField
      textField = javax.swing.JTextField.new(30)
      textField.setBorder(BorderFactory.createEtchedBorder)
      return textField
    end

    def createButtonPane
      findButton = createFindButton
      @dialog.rootPane.setDefaultButton(findButton)
      replaceButton = createReplaceButton
      allButton = createReplaceAllButton
      cancelButton = createCancelButton

      panel = JPanel.new
      layout = GroupLayout.new(panel)
      panel.setLayout(layout)
      layout.setAutoCreateGaps(true)
      layout.setAutoCreateContainerGaps(true)

      group = layout.createSequentialGroup
      group.addGroup(layout.createParallelGroup(LEADING).
                       addComponent(findButton).
                       addComponent(replaceButton).
                       addComponent(allButton).
                       addComponent(cancelButton))
      layout.setHorizontalGroup(group)
      buttons = [findButton, replaceButton, allButton, cancelButton]
      sym = "java.awt.Component".to_sym
      layout.linkSize(SwingConstants.HORIZONTAL, buttons.to_java(sym))

      group = layout.createSequentialGroup
      group.addComponent(findButton).
        addComponent(replaceButton).
        addComponent(allButton).
        addComponent(cancelButton)
      layout.setVerticalGroup(group)

      return panel
    end

    def createFindButton
      button = JButton.new("Find Next")
      button.setMnemonic(KeyEvent::VK_F)
      button.addActionListener{onFindNext}
      return button
    end

    def createReplaceButton
      button = JButton.new("Replace And Find")
      button.setMnemonic(KeyEvent::VK_R)
      button.addActionListener{onReplaceAndFind}
      return button
    end

    def createReplaceAllButton
      button = JButton.new("Replace All")
      button.setDisplayedMnemonicIndex(8)
      button.addActionListener{onReplaceAll}
      return button
    end

    def createCancelButton
      button = JButton.new("Cancel")
      button.addActionListener{onCancel}
      return button
    end

    def addBindings(rootPane)
      cancelAction = ProcTextAction.new("cancel"){onCancel}
      rootPane.getInputMap(JComponent::WHEN_IN_FOCUSED_WINDOW).
        put(KeyStroke.getKeyStroke(KeyEvent::VK_ESCAPE, 0), "cancelAction")
      rootPane.getActionMap.put("cancelAction", cancelAction)
    end

    def locateDialog
      @dialog.setLocation(calcLocation)
    end

    def calcLocation
      ownerRect = @app.frame.getBounds
      dim = @dialog.getSize
      x = ownerRect.x + (ownerRect.width - dim.width) / 2
      y = ownerRect.y + (ownerRect.height - dim.height) / 2
      return java.awt.Point.new(x, y)
    end

    def onFindNext
      !@patternField and return
      str = @patternField.getText
      str.empty? and return
      @app.findNext(str, @caseCheckbox.isSelected)
    end

    def onReplaceAndFind
      @app.lastEditEnd
      !@patternField and return
      pat = @patternField.getText
      pat.empty? and return
      rep = @replacementField.getText
      @app.replaceAndFind(pat, rep, @caseCheckbox.isSelected)
    end

    def onReplaceAll
      @app.lastEditEnd
      !@patternField and return
      pat = @patternField.getText
      pat.empty? and return
      rep = @replacementField.getText
      @app.replaceAll(pat, rep, @caseCheckbox.isSelected)
    end

    def onCancel
      @dialog.setVisible(false)
    end

    def show
      !@dialog and create(@app.frame)
      @dialog.setVisible(true)
      @patternField.requestFocusInWindow
    end
  end
end
