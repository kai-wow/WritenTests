'''
根据 评估数据 将策略表现可视化


Functions:
    - draw_value         日度收益率、最大回测率、策略净值图 三土合一
    - compare_value      策略净值标的净值对比图
'''

import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False


def draw_value(data, pic_name='strategy1'):
    data['ret'] = data['value'].pct_change()

    cummax_price = data['value'].cummax()
    data['dd_ratio'] = (data['value'] - cummax_price) / cummax_price

    # 画图
    fig = plt.figure(figsize=(10, 8))
    gs = GridSpec(4, 1, figure=fig)
    ax1 = fig.add_subplot(gs[0,0])
    plt.bar(data[data['ret']>=0].index, data[data['ret']>=0]['ret'], color='r', edgecolor='r')
    plt.bar(data[data['ret']<0].index, data[data['ret']<0]['ret'], color='g', edgecolor='g')
    plt.ylabel('daily return')

    ax2 = fig.add_subplot(gs[1:2, 0])
    plt.bar(data.index, height=data['dd_ratio'])
    plt.ylabel("策略回撤率")

    ax3 = fig.add_subplot(gs[2:4, 0])
    buy_idx = list(data[data.signal > 0].index)
    sell_idx = list(data[data.signal < 0].index)
    plt.plot(data['value'], 'k', label='strategy value')
    plt.plot(data['value'][buy_idx],'g^',label="buy", markersize=5)
    plt.plot(data['value'][sell_idx],'bv',label="sell", markersize=5)

    plt.legend()
    plt.ylabel('value')
    plt.grid(visible=True)
    plt.tight_layout()
    if pic_name:
        plt.savefig(f"results/{pic_name}.png")
    else:
        plt.show()  #   
    plt.close()
    


def compare_value(data, show=False):    
    for name in data.columns:
        plt.plot(data[name], label=name, linewidth=1.5)
    
    plt.legend()
    plt.ylabel('净值')
    plt.grid(visible=True)
    plt.tight_layout()
    if show:
        plt.show()  
    else:
        plt.savefig("results/compare_strategies.png")
    plt.close()
