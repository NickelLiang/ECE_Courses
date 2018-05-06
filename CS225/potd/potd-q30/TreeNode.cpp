#include "TreeNode.h"

int getHeightBalance(TreeNode* root) {
  // your code here
  return 0;
}

void deleteTree(TreeNode* root)
{
  if (root == NULL) return;
  deleteTree(root->left_);
  deleteTree(root->right_);
  delete root;
  root = NULL;
}

