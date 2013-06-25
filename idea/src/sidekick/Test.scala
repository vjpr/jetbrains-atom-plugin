package sidekick

import com.intellij.psi._
import com.intellij.psi.util.PsiTreeUtil
import com.intellij.openapi.actionSystem.{DataKeys, LangDataKeys, PlatformDataKeys, AnAction, AnActionEvent}
import com.intellij.openapi.editor.Editor
import java.util

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

object GetMethodName {
  def apply(editor: Editor, psiFile: PsiFile) = {
    val offset = editor.getCaretModel.getOffset()
    val el = psiFile.getViewProvider.findElementAt(offset)

    // Walk up tree and find closest method and class
    val method = PsiTreeUtil.getParentOfType(el, classOf[PsiMethod])
    val clazz = PsiTreeUtil.getParentOfType(el, classOf[PsiClass])
    val methodCall = PsiTreeUtil.getParentOfType(el, classOf[PsiMethodCallExpression])
    System.out.println(clazz)
    System.out.println(method)
    // TODO: Get nearest sibling on same line that is not whitespace
    System.out.println(methodCall)
    System.out.println(methodCall.getMethodExpression())
  }
}
