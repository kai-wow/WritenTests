'''
根据因子信号进行交易


Functions 
- get_ma_trading_signal 获取移动均值策略的交易信号
- backtest 进行回测
    - 需要调用 Trade 类

Class
- Trade  根据策略信号 进行 买buy()、卖sell()、更新持仓净值hold() 等操作


Return
- trade_data [dict]  {date: {
                            'date','all_position_value', 'cash',
                            'value', 'signal', 'cost',
                            '','r_price','position', 'position_value'}
                     }
'''
from copyreg import pickle
import pandas as pd
import datetime

from Evaluate import *
import Picture 


def get_ma_trading_signal(data, start, end, ma_windows=20):
    data['MA%d'%ma_windows] = data['收盘点位'].rolling(ma_windows).mean()
    data['MA%d_diff'%ma_windows] = data['收盘点位'] - data['MA%d'%ma_windows]
    data['pre_MA%d_diff'%ma_windows] = data['MA%d_diff'%ma_windows].shift(1)  

    # 截取时间始末
    backtest_data = data[(data.index>start) & (data.index < end)]
    
    signal = backtest_data.apply(lambda x:1 if x['pre_MA%d_diff'%ma_windows]<0 and x['MA%d_diff'%ma_windows]>=0 else(
                                         -1 if x['pre_MA%d_diff'%ma_windows]>0 and x['MA%d_diff'%ma_windows]<=0 else 0), axis=1)
    signal = signal.to_dict()
    return signal


def backtest(trade_dt, trade_price, signal):
    trade_dict = {}
    # 调用 Trade 类，进行模拟交易
    trade = Trade()  
    for date in trade_dt:
        trade.update(date, price=trade_price[date], signal=signal[date])
        trade_dict[date] = trade.trade()
    
    trade_data = pd.DataFrame.from_dict(trade_dict, 'index')  # 获得交易持仓净值数据
    trade_data.index = pd.to_datetime(trade_data.index)
    # 回测指标分析
    analyse = Evaluate(trade_data)
    evaluate_data = analyse.evaluate()
    return trade_data, evaluate_data


class Trade():
    def __init__(self, allocation=1):
        self.date = None  # signalData.date
        self.current_price = None
        self.signal = None

        # 参数：初始资金 1
        self.allocation = allocation

        # 交易数据
        self.cash = self.allocation  # 初始化现金为上期现金值
        self.value = allocation
        self.position = 0
        self.position_value = 0

    def buy(self, amount=None):
        if not amount:
            self.position = self.cash / self.current_price
        else:
            self.position = amount / self.current_price
        self.position_value = self.position * self.current_price
        self.cash = self.cash - self.position_value
        return self.position_value

    def sell(self):
        self.get_position_value()
        self.cash += self.position_value
        self.position = 0
        self.position_value = self.position * self.current_price
        
        # return self.position_value

    def hold(self):
        self.get_position_value()
        # cash 不变
        self.value = self.cash + self.position_value

    def get_position_value(self):
        self.position_value = self.position * self.current_price
        return self.position_value

    def update(self, date, price, signal):
        self.date = date
        # self.weight = weight
        self.current_price = price  
        self.signal = signal # 0


    def trade(self, show_info=False):
        """ 开始交易"""
        if self.signal > 0:
            if self.cash > 0:
                self.buy()
        elif self.signal < 0:  
            if self.position > 0:         
                self.sell()
        elif self.signal == 0:
            self.hold()
        else:
            raise ValueError('Invalid "signal" value!')
        self.value = self.position_value + self.cash
    
        trade_info = self.get_trade_data()
        if show_info:
            self.show_trading_info()  # 打印交易详情
        return trade_info

    # 获取 并 存储
    def get_trade_data(self):
        '''
        Return
            [dict]  {date: {'date','all_position_value', 'cash', 'weight', 'signal',
                            
                            }
        '''
        param_list = ['value', 'current_price', 'position_value', 'cash', 'signal']
        value = {name: getattr(self, name) for name in param_list}
        return value

    def show_trading_info(self):
        if self.signal > 0:
            print(f'{self.date} 换仓，买入，'
                  f'持仓价值 {self.position_value:.2f}，剩余 {self.cash:.2f} 现金')
        else:
            print(f'{self.date} 无操作，当前持仓价值 {self.position_value:.2f}，总资产 {self.value:.2f}')



if __name__ == '__main__':
    # 数据导入国内股债收盘价
    start = datetime(2017,12,31)
    end = datetime(2021,12,31)
    data = pd.read_excel('000832.CSI.xlsx')  # 价格(000832.CSI)
    data.set_index("交易日期", inplace=True)
    data.index = pd.to_datetime(data.index)
    data.sort_index(inplace=True)
    
    backtest_data = data[(data.index>start) & (data.index < end)]
    trade_dt = list(backtest_data.index)  # 记录交易日信息，方便以后进行查找
    trade_price = backtest_data['收盘点位'].to_dict()


    # signal0 = dict(zip(trade_dt, [1]+[0]*(len(trade_dt)-2)+[-1]))
    # trade_data0, evaluate_data0 = backtest(trade_dt, trade_price, signal0)
    
    signal1 = get_ma_trading_signal(data, start, end, ma_windows=20)
    trade_data1, evaluate_data1 = backtest(trade_dt, trade_price, signal1)

    signal2 = get_ma_trading_signal(data, start, end, ma_windows=60)
    trade_data2, evaluate_data2 = backtest(trade_dt, trade_price, signal2)

    value_data = pd.concat([trade_data1['value'], trade_data2['value']],
                        keys=['MA20','MA60'], axis=1)
    Picture.compare_value(value_data )

