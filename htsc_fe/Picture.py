'''
根据 评估数据 将策略表现可视化

Class & Functions
- Pictures      [class]
    需要 交易数据 和 策略评估数据
    Functions:
        - draw_value         日度收益率、最大回测率、策略净值图 三土合一
        - draw_value_ret     策略净值标的净值对比图
'''

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

from Trade import Trade
from Evaluate import Evaluate, get_return

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False

class Pictures():
    def __init__(self, trade_data, holding_gain) -> None:
        self.trade_data = trade_data
        self.holding_gain = holding_gain

    def draw_value(self):
        data = self.trade_data.copy()

        data['ret'] = data['value'].pct_change()

        data.loc[:, 'cummax_price'] = data['value'].cummax()
        data.loc[:, 'dd'] = -np.subtract(data.loc[:, 'cummax_price'], data.loc[:, 'value'])
        data.loc[:, 'dd_ratio'] = np.divide(data.loc[:, 'dd'], data.loc[:, 'cummax_price'])

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
        plt.plot(data['value'], 'k', label='benchmark value')
        plt.legend()
        plt.ylabel('value')
        plt.grid(visible=True)
        plt.tight_layout()
        plt.show()  # savefig(self.savefig_path + "trading_sig.png")
        plt.close()

    def draw_value_ret(self):
        data = self.trade_data.copy()
        data.loc[:, 'bench_net_val'] = np.divide(data['benchmark_value'], data['benchmark_value'].iloc[0])
        data.loc[:, 'stra_net_val'] = data.loc[:, 'value'] / data['value'].iloc[0]
        data.loc[:, 'abs_ret'] = np.divide(data.loc[:, 'stra_net_val'], data.loc[:, 'bench_net_val'])

        # 画图：策略净值、标的净值、绝对收益
        plt.rcParams['font.sans-serif'] = ['SimHei']
        plt.rcParams['axes.unicode_minus'] = False

        fig = plt.figure(figsize=(9, 6))
        gs = GridSpec(3, 1, figure=fig)
        ax1 = fig.add_subplot(gs[0, 0])
        plt.bar(data[data['abs_ret'] >= 1].index, data[data['abs_ret'] >= 1.0]['abs_ret'] - 1, bottom=1.0, color='r', edgecolor='r')
        plt.bar(data[data['abs_ret'] < 1.0].index, data[data['abs_ret'] < 1.0]['abs_ret'] - 1, bottom=1.0, color='g', edgecolor='g')
        # 设置 x轴刻度线 到1
        ax = plt.gca()
        ax.xaxis.set_ticks_position('bottom')
        ax.spines['bottom'].set_position(('data', 1))
        plt.ylabel(r"策略净值/标的净值")

        ax2 = fig.add_subplot(gs[1:3, 0])
        plt.plot(data['bench_net_val'], label="标的累计净值", linewidth=1.5)
        plt.plot(data['stra_net_val'], label="策略净值", linewidth=1.5)
        plt.legend()
        plt.ylabel('净值')
        plt.grid(visible=True)
        plt.tight_layout()
        plt.show()  # savefig(self.savefig_path + "trading_sig.png")
        plt.close()

    def paint(self):
        self.draw_value()
        self.draw_value_ret()
