import numpy as np 


import matplotlib.pyplot as plt 

import seaborn as sns
from sklearn.linear_model import LogisticRegression
from sklearn.feature_selection import RFECV
from sklearn.feature_selection import RFE
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import accuracy_score
from sklearn.metrics import roc_curve, auc, log_loss
plt.rc("font", size=14)
sns.set(style="white") #white background style for seaborn plots
sns.set(style="whitegrid", color_codes=True)

import warnings
warnings.simplefilter(action='ignore')
from data_handle import *


def chose_attributes(X, y, num=8):
      # Build a logreg and compute the feature importances
      model = LogisticRegression()
      # create the RFE model and select 8 attributes
      rfe = RFE(model, num)
      rfe = rfe.fit(X, y)
      # summarize the selection of the attributes
      print('Selected features: %s' % list(X.columns[rfe.support_]))


def draw_feature_chose(X, y):
      # Create the RFE object and compute a cross-validated score.
      # The "accuracy" scoring is proportional to the number of correct classifications
      rfecv = RFECV(estimator=LogisticRegression(), step=1, cv=10, scoring='accuracy')
      rfecv.fit(X, y)

      print("Optimal number of features: %d" % rfecv.n_features_)
      print('Selected features: %s' % list(X.columns[rfecv.support_]))

      # Plot number of features VS. cross-validation scores
      plt.figure(figsize=(10,6))
      plt.xlabel("Number of features selected")
      plt.ylabel("Cross validation score (nb of correct classifications)")
      plt.plot(range(1, len(rfecv.grid_scores_) + 1), rfecv.grid_scores_)
      plt.show()

      Selected_features = list(X.columns[rfecv.support_])
      X = X[Selected_features]

      plt.subplots(figsize=(8, 5))
      sns.heatmap(X.corr(), annot=True, cmap="RdYlGn")
      plt.show()


def model_training(X, y):
      # use train/test split with different random_state values
      # we can change the random_state values that changes the accuracy scores
      # the scores change a lot, this is why testing scores is a high-variance estimate
      X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=2)

      # check classification scores of logistic regression
      logreg = LogisticRegression()
      logreg.fit(X_train, y_train)
      y_pred = logreg.predict(X_test)
      y_pred_proba = logreg.predict_proba(X_test)[:, 1]
      
      evaluate(logreg, y_test, y_pred, y_pred_proba)
      return y_pred, y_pred_proba


def evaluate(logreg, y_test, y_pred, y_pred_proba):
      [fpr, tpr, thr] = roc_curve(y_test, y_pred_proba)
      print('Train/Test split results:')
      print(logreg.__class__.__name__+" accuracy is %2.3f" % accuracy_score(y_test, y_pred))
      print(logreg.__class__.__name__+" log_loss is %2.3f" % log_loss(y_test, y_pred_proba))
      print(logreg.__class__.__name__+" auc is %2.3f" % auc(fpr, tpr))

      idx = np.min(np.where(tpr > 0.95)) # index of the first threshold for which the sensibility > 0.95

      plt.figure()
      plt.plot(fpr, tpr, color='coral', label='ROC curve (area = %0.3f)' % auc(fpr, tpr))
      plt.plot([0, 1], [0, 1], 'k--')
      plt.plot([0,fpr[idx]], [tpr[idx],tpr[idx]], 'k--', color='blue')
      plt.plot([fpr[idx],fpr[idx]], [0,tpr[idx]], 'k--', color='blue')
      plt.xlim([0.0, 1.0])
      plt.ylim([0.0, 1.05])
      plt.xlabel('False Positive Rate (1 - specificity)', fontsize=14)
      plt.ylabel('True Positive Rate (recall)', fontsize=14)
      plt.title('Receiver operating characteristic (ROC) curve')
      plt.legend(loc="lower right")
      plt.show()

      print("Using a threshold of %.3f " % thr[idx] + "guarantees a sensitivity of %.3f " % tpr[idx] +  
            "and a specificity of %.3f" % (1-fpr[idx]) + 
            ", i.e. a false positive rate of %.2f%%." % (np.array(fpr[idx])*100))


def cross_validation_n(X, y, n=10):
        # 10-fold cross-validation logistic regression
        logreg = LogisticRegression()
        # Use cross_val_score function
        # We are passing the entirety of X and y, not X_train or y_train, it takes care of splitting the data
        # cv=10 for 10 folds
        # scoring = {'accuracy', 'neg_log_loss', 'roc_auc'} for evaluation metric - althought they are many
        scores_accuracy = cross_val_score(logreg, X, y, cv=10, scoring='accuracy')
        scores_log_loss = cross_val_score(logreg, X, y, cv=10, scoring='neg_log_loss')
        scores_auc = cross_val_score(logreg, X, y, cv=10, scoring='roc_auc')
        print('K-fold cross-validation results:')
        print(logreg.__class__.__name__+" average accuracy is %2.3f" % scores_accuracy.mean())
        print(logreg.__class__.__name__+" average log_loss is %2.3f" % -scores_log_loss.mean())
        print(logreg.__class__.__name__+" average auc is %2.3f" % scores_auc.mean())


