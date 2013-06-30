package sidekick

import com.intellij.psi._
import com.intellij.psi.util.{PsiElementFilter, PsiUtil, PsiTreeUtil}
import com.intellij.openapi.actionSystem.{DataKeys, LangDataKeys, PlatformDataKeys, AnAction, AnActionEvent}
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
;

class Test extends AnAction {

  def actionPerformed(e: AnActionEvent) {

    val currentProject = PlatformDataKeys.PROJECT.getData(e.getDataContext())
    val currentFile = PlatformDataKeys.VIRTUAL_FILE.getData(e.getDataContext())

    System.out.println(currentFile)

    // Get PsiElement at caret
    val editor = PlatformDataKeys.EDITOR.getData(e.getDataContext())
    val psiFile = e.getData(LangDataKeys.PSI_FILE)
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

object GetMethodName {

  def apply(editor: Editor, psiFile: PsiFile) = {
    val offset = editor.getCaretModel.getOffset()
    val el = psiFile.getViewProvider.findElementAt(offset)
    System.out.println("el", el)
    System.out.println("el", psiFile.getVirtualFile.getCanonicalPath)

    //val parent = JSPsiImplUtils.getNonParenthesizeParent(el)
    //val method = JSUtils.getMethodNameIfInsideCall(el)
    //val method = JSResolveUtil.findParent(el)

    val clazz = PsiTreeUtil.getParentOfType(el, classOf[JSClassImpl])
    val block = PsiTreeUtil.getTopmostParentOfType(el, classOf[JSBlockStatementImpl])
    val method = PsiTreeUtil.getParentOfType(el, classOf[JSPropertyImpl])
    //System.out.println("methodRef", psiFile.getOriginalFile, method.)

    System.out.println("method", method.getName)
    System.out.println("method", method.getText)
    System.out.println("class", clazz.getName)
    System.out.println("findNameIdentifier", method.findNameIdentifier)
    //System.out.println("blockText", block.getText)

    val prevSibling = block.getPrevSibling
    val ws = if (prevSibling.isInstanceOf[PsiWhiteSpace]) {
      val whitespace = prevSibling.asInstanceOf[PsiWhiteSpace]
      System.out.println("block", whitespace.getText)
      whitespace.getText
    } else {
      ""
    }

    val comment =
      PsiTreeUtil.getPrevSiblingOfType(method, classOf[PsiCommentImpl]).getText
    System.out.println("comment", comment)
    System.out.println("comment1", comment)

    SelectedMethod(clazz.getName, method.getName, method.getText, ws, comment, method.getTextOffset, psiFile.getVirtualFile.getCanonicalPath)

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
