module Yoshied
  class Indenter
    def initialize(app)
      @app = app
      @tabWidth = 4
    end

    def tab
      tabToTabstop
    end

    def tabToTabstop
      col = @app.getColumnOfSelectionStart
      spaces = " " * (@tabWidth - col % @tabWidth)
      @app.replaceSelection(spaces)
    end

    def newline
      selectTrailingWhites
      insertLeadingWhites
    end

    def selectTrailingWhites
      selstart = @app.getSelectionStart
      while selstart >= 1 and whiteChar?(@app.getMainSubstr(selstart - 1, 1))
        selstart -= 1
      end
      selend = @app.getSelectionEnd
      @app.select(selstart, selend)
    end

    def whiteChar?(ch)
      return ch == " " || ch == "\t"
    end

    def insertLeadingWhites
      pos = @app.getSelectionStart
      leadingWhites = leadingWhites(pos)
      @app.replaceSelection("\n" + leadingWhites)
    end

    def leadingWhites(position)
      res = ""
      pos = @app.beginningOfLine(position)
      while pos != @app.endOfDocument
        ch = @app.getMainSubstr(pos, 1)
        !whiteChar?(ch) and return res
        res << ch
        pos += 1
      end
      return res
    end

    def hungryBackspace
      selection = @app.getSelection
      if emptySelection?(selection) and selection.first >= 1
        @app.select(selection.first - 1, selection.last)
      end
      selectTrailingWhites
      @app.replaceSelection("")
    end

    def emptySelection?(selection)
      return selection.first == selection.last
    end
  end
end
