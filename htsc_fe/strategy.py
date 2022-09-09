""" 2020.08.28  9:57
美林时钟 策略
需要调用 Trade，Evaluate，Picture 三个文件中的函数
"""

from Trade import *
from Evaluate import *
from Picture import *

# 读取数据
trade_dt, trade_price = load_data(path='国内股债收盘价.xlsx')
opinion_dt, opinions = load_data(path='增长-通胀观点.xlsx')

# 获得交易日，及交易权重
weights = {}
benchmark_weight = {}
for i in range(len(trade_dt)):
    if trade_dt[i] in opinion_dt:
        try:
            weights[trade_dt[i + 1]] = get_trading_signal(opinions[trade_dt[i]])
            benchmark_weight[trade_dt[i + 1]] = {'沪深300': 0.2, '国债': 0.8}
        except IndexError:  # 溢出
            pass

# 截取交易日，使得第一天可根据 增长-通胀观点 进行首次买入
trade_dt = [d for d in trade_dt if d > opinion_dt[0]]
# 调用 Trade 类，进行【美林时钟策略】的模拟交易
trade = Trade(trade_price, current_date=trade_dt[0])  # 传入数据
trade_info = trade.trade(trade_dt, weights, show_info=True)
trade_data = pd.DataFrame.from_dict(trade_info, 'index')  # 获得交易持仓净值数据

# 【对比策略】的模拟交易：“股票20%-债券80%-月度再平衡”策略
benchmark = Trade(trade_price, current_date=trade_dt[0])  # 传入数据
benchmark_trade_info = benchmark.trade(trade_dt, benchmark_weight, show_info=False)
benchmark_trade_data = pd.DataFrame.from_dict(benchmark_trade_info, 'index')

trade_data['benchmark_value'] = benchmark_trade_data['value']

# 回测指标分析
analyse = Evaluate(trade_data)
evaluate_data = analyse.evaluate()
# 绘图
picture = Pictures(analyse.trade_data, analyse.holding_data)
picture.paint()

# 对比策略的回测分析 与 绘图
# analyse = Evaluate(benchmark_trade_data)
# evaluate_data = analyse.evaluate()
# picture = Pictures(analyse.trade_data, analyse.holding_data)
# picture.paint()
