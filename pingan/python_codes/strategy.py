""" 
调用 Trade, Evaluate, Picture 类，进行回测
"""

from Trade import *
from Evaluate import *
import Picture 
import datetime


start = datetime.datetime(2017,12,31)
end = datetime.datetime(2021,12,31)

# 数据导入
data = pd.read_excel('000832.CSI.xlsx')  # 价格(000832.CSI)
data['交易日期'] = pd.to_datetime(data['交易日期'])
data.set_index("交易日期", inplace=True)
data.sort_index(inplace=True)

# 获取回测区间的所有交易日 & 收盘价
backtest_data = data[(data.index>start) & (data.index < end)]
trade_dt = list(backtest_data.index)  # 记录交易日信息，方便以后进行查找
trade_price = backtest_data['收盘点位'].to_dict()

# Buy and Hold 策略
signal0 = dict(zip(trade_dt, [1]+[0]*(len(trade_dt)-2)+[-1]))
trade_data0, evaluate_data0 = backtest(trade_dt, trade_price, signal0)
Picture.draw_value(trade_data0, pic_name='Buy and Hold') # 绘图

# MA20 策略
signal1 = get_ma_trading_signal(data, start, end, ma_windows=20)
trade_data1, evaluate_data1 = backtest(trade_dt, trade_price, signal1)
Picture.draw_value(trade_data1, pic_name='MA20') # 绘图

# MA60 策略
signal2 = get_ma_trading_signal(data, start, end, ma_windows=60)
trade_data2, evaluate_data2 = backtest(trade_dt, trade_price, signal2)
Picture.draw_value(trade_data2, pic_name='MA60') # 绘图

# 对比图
# 策略均值汇总
value_data = pd.concat([trade_data0['value'], trade_data1['value'], trade_data2['value']],
                        keys=['Buy and Hold','MA20','MA60'], axis=1)
Picture.compare_value(value_data)

# 回测表现汇总
bktest_data = pd.concat([evaluate_data0.stack(), evaluate_data1.stack(), evaluate_data2.stack()], 
                keys=['Buy and Hold','MA20','MA60'], axis=1)
print(bktest_data)

# 初始化保存文件
bktest_result = pd.ExcelWriter("results/bktest_result.xlsx")

# 保存结果
bktest_data.to_excel(bktest_result, "策略回测表现对比")
value_data.to_excel(bktest_result, "策略净值对比")
bktest_result.save()
bktest_result.close()
