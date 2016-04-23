package sidekick

import com.intellij.psi._
import com.intellij.psi.util.{PsiElementFilter, PsiUtil, PsiTreeUtil}
import com.intellij.openapi.actionSystem._
import com.intellij.openapi.editor.Editor
import java.util
import com.intellij.lang.javascript.psi.ecmal4.JSClass
import com.intellij.lang.javascript.psi.stubs.JSStubElement
import com.intellij.lang.javascript.psi.impl._
import com.intellij.lang.javascript.psi.util.JSUtils
import com.intellij.lang.javascript.psi.resolve.JSResolveUtil
import com.intellij.lang.javascript.structureView.JSStructureViewElement
import com.intellij.lang.javascript.psi.ecmal4.impl.{JSClassImpl, JSClassBase}
import com.intellij.lang.javascript.psi.{JSExpressionStatement, JSReferenceExpression, JSFunction}
import org.jetbrains.annotations.{NotNull, Nullable}
import scala.annotation.tailrec
import com.intellij.psi.impl.source.tree.PsiCommentImpl
import com.intellij.psi.search.FilenameIndex
import com.intellij.openapi.diagnostic.Logger
;

class Test extends AnAction with Logging {

  def actionPerformed(e: AnActionEvent) {

    val currentProject = CommonDataKeys.PROJECT.getData(e.getDataContext())
    val currentFile = CommonDataKeys.VIRTUAL_FILE.getData(e.getDataContext())

    log info currentFile.toString

    // Get PsiElement at caret
    val editor = CommonDataKeys.EDITOR.getData(e.getDataContext())
    val psiFile = e.getData(CommonDataKeys.PSI_FILE)
    GetMethodName(editor, psiFile)

  }

}

case class SelectedMethod(
  className: String,
  methodName: String,
  contents: String,
  whitespace: String,
  comment: String,
  offset: Integer,
  path: String
)

object GetMethodName extends Logging {

  def apply(editor: Editor, psiFile: PsiFile) = {
    val offset = editor.getCaretModel.getOffset()
    val el = psiFile.getViewProvider.findElementAt(offset)
    log debug "el" + el
    log debug "el" + psiFile.getVirtualFile.getCanonicalPath

    //val parent = JSPsiImplUtils.getNonParenthesizeParent(el)
    //val method = JSUtils.getMethodNameIfInsideCall(el)
    //val method = JSResolveUtil.findParent(el)

    val clazz = PsiTreeUtil.getParentOfType(el, classOf[JSClassImpl])
    val block = PsiTreeUtil.getTopmostParentOfType(el, classOf[JSBlockStatementImpl])
    val method = PsiTreeUtil.getParentOfType(el, classOf[JSPropertyImpl])
    //log debug ("methodRef", psiFile.getOriginalFile, method.)

    if (method != null) {
      log debug "method" + method.getName
      log debug "method" + method.getText
      log debug "class" + clazz.getName
      log debug "findNameIdentifier" + method.findNameIdentifier
      //log debug "blockText" + block.getText
    }

    if (block != null) {
      val prevSibling = block.getPrevSibling
      val ws = if (prevSibling.isInstanceOf[PsiWhiteSpace]) {
        val whitespace = prevSibling.asInstanceOf[PsiWhiteSpace]
        log debug "block" + whitespace.getText
        whitespace.getText
      } else {
        ""
      }

      val _prevSibling = Option(PsiTreeUtil.getPrevSiblingOfType(method, classOf[PsiCommentImpl]))
      val comment = _prevSibling map { _.getText } getOrElse ""
      log debug "comment" + comment

      SelectedMethod(clazz.getName, method.getName, method.getText, ws, comment, method.getTextOffset, psiFile.getVirtualFile.getCanonicalPath)

    } else {
      SelectedMethod
    }

    //val method = PsiTreeUtil.getParentOfType(el, classOf[JSClass])

    // Walk up tree and find closest method and class
    //val method = PsiTreeUtil.getParentOfType(el, classOf[PsiMethod])
    //val clazz = PsiTreeUtil.getParentOfType(el, classOf[PsiClass])
    //val methodCall = PsiTreeUtil.getParentOfType(el, classOf[PsiMethodCallExpression])
    //System.out.println("class", clazz)
    //System.out.println("method", method)
    // TODO: Get nearest sibling on same line that is not whitespace
    //System.out.println("methodCall", methodCall)
    //System.out.println("expr", methodCall.getMethodExpression())
  }

}
