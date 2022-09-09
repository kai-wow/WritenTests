from unicodedata import category
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def transfer_to_numeric(data, data_type):
    """_summary_

    Args:
        data (dataframe): 训练数据/测试数据
        data_type (dict): 特征的数据类型
    """
    data = data.replace('?', np.nan)
    types = {'数值型':float, '字符型':object}
    for feature_name in data.columns:
        t = data_type[feature_name] 
        data[feature_name] = data[feature_name].astype(types[t])

    data = data.replace('nan', np.nan)
    # print(data.describe())
    nominal_feat = data.select_dtypes(include='category')
    nominal_name = nominal_feat.columns
    
    
    for feat in data.columns:
        miss_ratio = data[feat].isnull().sum()/data.shape[0]
        # print('Percent of missing "{}" records is {:.2f}%'.format(feat, miss_ratio)
        # if data[feat].isnull().sum() > 0:
        #     show_feature_distribute(data[feat], feature_name='feature1')
        
        # 缺失值处理
        if miss_ratio>0:
            if data_type[feat] == '数值型':
                data[feat].fillna(data[feat].median(skipna=True), inplace=True)
            elif data_type[feat] == '字符型':
                print(data[feat].value_counts())
                data[feat].fillna(data[feat].value_counts().idxmax(), inplace=True)
                
                # df = data[[feat, 'LABEL']].reset_index()
                # bins = sc.woebin(df, y='LABEL', method='chimerge')  # 决策树分箱
                # print(bins)
                # sc.woebin_plot(bins)
                # plt.show()
                
        # elif miss_ratio>0:
        #     data.drop('Cabin', axis=1, inplace=True)
    # print(data.info())
    return data

def show_feature_distribute(feature, feature_name='feature1'):
    try:
        ax = feature.hist(bins=15, density=True, stacked=True, color='teal', alpha=0.6)
        feature.plot(kind='density', color='teal')
        ax.set(xlabel=feature_name)
        plt.xlim(feature.min(), feature.max())
        plt.show()
    except:
        print(feature.value_counts())


def draw_compare(original, adjusted, feat_name):
    plt.figure(figsize=(15,8))
    ax = original.hist(bins=15, density=True, stacked=True, color='teal', alpha=0.6)
    original.plot(kind='density', color='teal')
    ax = adjusted.hist(bins=15, density=True, stacked=True, color='orange', alpha=0.5)
    adjusted.plot(kind='density', color='orange')
    ax.legend([f'Raw {feat_name}', f'Adjusted {feat_name}'])
    ax.set(xlabel='feat_name')
    # plt.xlim(-10,85)
    plt.show()




if __name__ == "__main__":
    # import classifier
    train = pd.read_excel(r'CMB\data\train.xlsx', index_col=0)
    data_type = pd.read_excel(r'CMB\data\特征说明.xlsx', header=1, index_col=0)  # 字段名称 作为index
    data_type = data_type.to_dict()['字符类型']
    # print(data_type)
    transfer_to_numeric(train, data_type)

    # Read  test data file into DataFrame
    test = pd.read_excel(r'C:\Users\shao\Desktop\实习\written_test\CMB\data\test_A榜.xlsx', index_col=0)
    test_data = transfer_to_numeric(test, data_type)
    
    print(train)
    print(test)
    data = pd.concat([train, test], axis=0)
    print(data)

    col = ['MON_12_CUST_CNT_PTY_ID', 'WTHR_OPN_ONL_ICO', 'LGP_HLD_CARD_LVL', 'NB_CTC_HLD_IDV_AIO_CARD_SITU']
    for i in col:
        print(train[i].value_counts())
        # train[i].fillna(train[i].value_counts().idxmax(), inplace=True)
        print(test[i].value_counts())
        # test[i].fillna(test[i].value_counts().idxmax(), inplace=True)

