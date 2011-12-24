module Yoshied
  class Undoer
    include javax.swing.event.UndoableEditListener

    def initialize
      @undoAction = UndoAction.new(self)
      @redoAction = RedoAction.new(self)
      @undoManager = UndoManager.new
      @inReplace = false
    end
    attr_reader :undoAction, :redoAction, :undoManager
    attr_writer :inReplace

    def resetUndo
      @undoManager.discardAllEdits
      @undoAction.updateUndoState(@undoManager)
      @redoAction.updateRedoState(@undoManager)
    end

    def undo
      begin
        @undoManager.undo
      rescue
        $stderr.puts($!)
        $stderr.puts($!.backtrace)
      end
      @undoAction.updateUndoState(@undoManager)
      @redoAction.updateRedoState(@undoManager)
    end

    def redo
      begin
        @undoManager.redo
      rescue
        $stderr.puts($!)
        $stderr.puts($!.backtrace)
      end
      @redoAction.updateRedoState(@undoManager)
      @undoAction.updateUndoState(@undoManager)
    end

    def undoableEditHappened(undoableEditEvent)
      edit = undoableEditEvent.getEdit
      seq = SequentialEdit.new
      seq.addEdit(edit)
      seq.editType = toEditType(edit)
      last = @undoManager.lastEdit
      last and differentEditType?(last, edit) and last.end
      @undoManager.addEdit(seq)
      @undoAction.updateUndoState(@undoManager)
      @redoAction.updateRedoState(@undoManager)
    end

    def differentEditType?(lastSeq, undoableEdit)
      !lastSeq and return false
      lastSeq.editType == :change and return true
      editType = toEditType(undoableEdit)
      lastSeq.editType != editType and !@inReplace
    end

    def toEditType(undoableEdit)
      return case undoableEdit.getType
             when DocumentEvent::EventType::CHANGE
               :change
             when DocumentEvent::EventType::INSERT
               :insert
             when DocumentEvent::EventType::REMOVE
               :remove
             else
               :unknown
             end
    end

    def lastEditEnd
      last = @undoManager.lastEdit
      !last and return
      last.end
    end
  end

  class UndoAction < AbstractAction
    def initialize(undoer)
      super("Undo")
      @undoer = undoer
      setEnabled(false)
    end

    def actionPerformed(e)
      @undoer.undo
    end

    def updateUndoState(undo)
      if undo.canUndo
        setEnabled(true)
        putValue(Action::NAME, undo.getUndoPresentationName)
      else
        setEnabled(false)
        putValue(Action::NAME, "Undo")
      end
    end
  end

  class RedoAction < AbstractAction
    def initialize(undoer)
      super("Redo")
      @undoer = undoer
      setEnabled(false)
    end

    def actionPerformed(e)
      @undoer.redo
    end

    def updateRedoState(undo)
      if undo.canRedo
        setEnabled(true)
        putValue(Action::NAME, undo.getRedoPresentationName)
      else
        setEnabled(false)
        putValue(Action::NAME, "Redo")
      end
    end
  end

  class SequentialEdit < CompoundEdit
    def initialize
      @super
      @editType = nil
    end
    attr_accessor :editType

    def isInProgress
      return false
    end
  end

  class EndUndoSequenceAction < TextAction
    def initialize(undoer, textAction)
      super(textAction.getValue(Action::NAME))
      @undoer = undoer
      @textAction = textAction
    end

    def actionPerformed(actionEvent)
      editor = actionEvent.getSource
      before = editor.getCaretPosition
      @textAction.actionPerformed(actionEvent)
      after = editor.getCaretPosition
      before != after and @undoer.lastEditEnd
    end
  end
end
