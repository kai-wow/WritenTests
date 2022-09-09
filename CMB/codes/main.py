import numpy as np 
import pandas as pd 

import matplotlib.pyplot as plt 

import seaborn as sns
from sklearn.linear_model import LogisticRegression
plt.rc("font", size=14)
sns.set(style="white") #white background style for seaborn plots
sns.set(style="whitegrid", color_codes=True)

import warnings
warnings.simplefilter(action='ignore')

from data_handle import *
from classifier import *


# 导入数据
MAIN_PATH = 'CMB/data/'
train = pd.read_excel(MAIN_PATH+'train.xlsx', index_col=0)
data_type = pd.read_excel(r'CMB\data\特征说明.xlsx', header=1, index_col=0)  # 字段名称 作为index
data_type = data_type.to_dict()['字符类型']

# Read  test data file into DataFrame
test = pd.read_excel(r'C:\Users\shao\Desktop\实习\written_test\CMB\data\test_B榜.xlsx', index_col=0)

data = pd.concat([train, test], axis=0)
data = transfer_to_numeric(data, data_type)
train_data = data.iloc[:len(train),:]
test_data = data.iloc[len(train):,:]
print(data)

#create categorical variables and drop some variables
numeric_col = train_data.select_dtypes(exclude="object").columns
categorical_col = train_data.select_dtypes(include="object").columns

# 处理类别类数据：one-hot编码
training = pd.get_dummies(train_data, columns=categorical_col, drop_first=True)
# print(training.info())

# sns.barplot('AGN_CNT_RCT_12_MON', 'LABEL', data=training, color="darkturquoise")
# plt.show()

testing = pd.get_dummies(test_data, columns=categorical_col)

final_train = training
final_test = testing


# 拆分 特征 & label
X = final_train.drop(['LABEL'], axis=1)
y = final_train['LABEL']
# 训练
logreg = LogisticRegression()
logreg.fit(X, y)

# 预测
new = [c for c in final_test.columns if c not in X.columns]
final_test = final_test.drop(new, axis=1)
y_pred = logreg.predict(final_test)
y_pred_proba = logreg.predict_proba(final_test)[:, 1]
# 输出预测概率
y_pred_proba = pd.DataFrame(y_pred_proba, index=final_test.index)
y_pred_proba = y_pred_proba.round(10)
print(y_pred_proba)
y_pred_proba.to_csv(MAIN_PATH+'prdt.txt', header=False, sep=' ')

# print('final result:\n')
# evaluate(y_test, y_pred, y_pred_proba)
