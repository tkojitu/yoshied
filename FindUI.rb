module Yoshied
  class FindUI
    LEADING = GroupLayout::Alignment::LEADING
    def initialize(app)
      @app = app
      @dialog = nil
      @textField = nil
      @caseCheckbox = nil
    end

    def create(owner)
      @dialog = JDialog.new(owner, "Find")
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
      @textField = createTextField
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
                       addComponent(@textField).
                       addComponent(@caseCheckbox).
                       addComponent(spacer1).
                       addComponent(spacer2))
      layout.setHorizontalGroup(group)

      group = layout.createSequentialGroup
      group.addComponent(@textField).
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
      prevButton = createPrevButton
      nextButton = createNextButton
      @dialog.rootPane.setDefaultButton(nextButton)
      cancelButton = createCancelButton

      panel = JPanel.new
      layout = GroupLayout.new(panel)
      panel.setLayout(layout)
      layout.setAutoCreateGaps(true)
      layout.setAutoCreateContainerGaps(true)

      group = layout.createSequentialGroup
      group.addGroup(layout.createParallelGroup(LEADING).
                       addComponent(prevButton).
                       addComponent(nextButton).
                       addComponent(cancelButton))
      layout.setHorizontalGroup(group)
      sym = "java.awt.Component".to_sym
      layout.linkSize(SwingConstants.HORIZONTAL,
                      [prevButton, nextButton, cancelButton].to_java(sym))

      group = layout.createSequentialGroup
      group.addComponent(prevButton).
        addComponent(nextButton).
        addComponent(cancelButton)
      layout.setVerticalGroup(group)

      return panel
    end

    def createPrevButton
      button = JButton.new("Find Prev")
      button.setMnemonic(KeyEvent::VK_P)
      button.addActionListener{onFindPrev}
      return button
    end

    def createNextButton
      button = JButton.new("Find Next")
      button.setMnemonic(KeyEvent::VK_N)
      button.addActionListener{onFindNext}
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

    def onFindPrev
      !@textField and return
      str = @textField.getText
      str.empty? and return
      @app.findPrev(str, @caseCheckbox.isSelected)
    end

    def onFindNext
      !@textField and return
      str = @textField.getText
      str.empty? and return
      @app.findNext(str, @caseCheckbox.isSelected)
    end

    def onCancel
      @dialog.setVisible(false)
    end

    def show
      !@dialog and create(@app.frame)
      @dialog.setVisible(true)
      @textField.requestFocusInWindow
    end
  end
end
