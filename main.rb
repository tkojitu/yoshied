$KCODE = "UTF-8"
include Java

java_import java.awt.BorderLayout
java_import java.awt.Dimension
java_import java.awt.Event
java_import java.awt.Font
java_import java.awt.event.ActionEvent
java_import java.awt.event.KeyEvent
java_import java.lang.System;
java_import javax.swing.AbstractAction
java_import javax.swing.Action
java_import javax.swing.BorderFactory
java_import javax.swing.GroupLayout
java_import javax.swing.JButton
java_import javax.swing.JCheckBox
java_import javax.swing.JComponent
java_import javax.swing.JDialog
java_import javax.swing.JFileChooser
java_import javax.swing.JFrame
java_import javax.swing.JMenu
java_import javax.swing.JMenuItem
java_import javax.swing.JOptionPane
java_import javax.swing.JPanel
java_import javax.swing.JTextArea
java_import javax.swing.KeyStroke
java_import javax.swing.ScrollPaneConstants
java_import javax.swing.SwingConstants
java_import javax.swing.event.DocumentEvent
java_import javax.swing.text.DefaultEditorKit
java_import javax.swing.text.TextAction
java_import javax.swing.undo.CompoundEdit
java_import javax.swing.undo.UndoManager

require "App"
require "FindUI"
require "Indenter"
require "KeyBinder"
require "ReplaceUI"
require "Undoer"

$yoshi_argv = ARGV.dup
System.setProperty("awt.useSystemAAFontSettings", "lcd");
System.setProperty("swing.aatext", "true");
javax.swing.SwingUtilities.invokeLater(Yoshied::App.new)
