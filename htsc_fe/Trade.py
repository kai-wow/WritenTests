'''
根据因子信号进行交易

Class
- Asset  进行单个资产（如，股或债）的 买、卖、更新当日市值 等操作
- Trade  根据策略信号 进行 买buy()、卖sell()、更新持仓净值hold() 等操作
    - 需调用 Stock 类
Return
- trade_data [dict]  {date: {
                            'date','all_position_value', 'cash',
                            'value', 'signal', 'cost',
                            '','r_price','position', 'position_value'}
                     }
'''

# 数据读取
def load_data(path='国内股债收盘价.xlsx'):
    # 数据导入
    data = pd.read_excel(path)
    data.set_index(data["日期"], inplace=True)
    dates = list(data.index)  # 记录交易日信息，方便以后进行查找
    data_dict = data.to_dict(orient='index')
    return dates, data_dict


def get_trading_signal(opinions=None):
    if opinions['增长'] == -1 and opinions['通胀'] == -1:  # 衰退
        weight = {'沪深300': 0.1, '国债': 0.9}
    elif opinions['增长'] == -1 and opinions['通胀'] == 1:  # 滞胀
        weight = {'沪深300': 0.15, '国债': 0.85}
    elif opinions['增长'] == 1 and opinions['通胀'] == -1:  # 复苏
        weight = {'沪深300': 0.5, '国债': 0.5}
    elif opinions['增长'] == 1 and opinions['通胀'] == 1:  # 过热
        weight = {'沪深300': 0.3, '国债': 0.7}
    else:
        weight = {'沪深300': 0.2, '国债': 0.8}

    return weight


class Asset():
    def __init__(self, type):
        self.type = type  # 资产类型：股/债
        self.price = None

        # 交易数据
        self.position = None
        self.position_value = None

    def buy(self, price_data, amount):
        self.get_current_price(price_data)
        self.position = amount // self.price
        self.position_value = self.position * self.price
        return self.position_value

    def sell(self, price_data):
        self.get_current_price(price_data)
        self.position = 0
        self.position_value = self.position * self.price
        # return self.position_value

    def get_current_price(self, price_data):
        self.price = price_data[self.type]
        return self.price

    def get_position_value(self, price_data):
        self.get_current_price(price_data)
        self.position_value = self.position * self.price
        return self.position_value


class Trade():
    def __init__(self, price_data, current_date):
        self.date = current_date  # signalData.date
        self.price_data = price_data
        self.stock = Asset(type='沪深300')
        self.bond = Asset(type='国债')
        self.current_price = self.price_data[current_date]
        self.weight = None
        self.position_chg = None

        # 参数：初始资金 一千万
        self.allocation = 10000000

        self.cash = self.allocation  # 初始化现金为上期现金值
        self.all_position_value = None
        self.value = None

    def update(self, date):
        self.date = date
        # self.weight = weight
        self.current_price = self.price_data[date]
        self.position_chg = 0

    # 买入合约，并获取 头寸净值、策略净值
    def buy(self, weight):
        # 对股、债进行买卖
        self.weight = weight
        self.stock.buy(self.current_price, weight['沪深300'] * self.allocation)
        self.bond.buy(self.current_price, weight['国债'] * self.allocation)

        self.all_position_value = self.stock.position_value + self.bond.position_value

        self.cash = self.cash - self.all_position_value
        self.value = self.cash + self.all_position_value
        self.position_chg = 1

    def sell(self):
        self.stock.get_position_value(self.current_price)
        self.bond.get_position_value(self.current_price)
        sold_position_value = self.stock.position_value + self.bond.position_value

        self.stock.sell(self.current_price)
        self.bond.sell(self.current_price)

        self.all_position_value = 0
        self.cash = self.cash + sold_position_value
        self.value = self.cash + self.all_position_value

    def hold(self):
        self.stock.get_position_value(self.current_price)
        self.bond.get_position_value(self.current_price)
        self.all_position_value = self.stock.position_value + self.bond.position_value
        # cash 不变
        self.value = self.cash + self.all_position_value

    def trade(self, trade_dt, weights, show_info=False):
        """ 开始交易

        Args:
            trade_dt: 所有交易日期 (第一天是换仓日期/月初)
            weights: 所有月末换仓日及换仓权重； {换仓日期: 换仓权重}
            show_info: 是否展示每天的交易细节，默认为False
        Returns:
            dict 交易数据
        """
        self.buy(weights[trade_dt[0]])  # 初始配置
        trade_info = {}
        for date in trade_dt[1:]:
            self.update(date)  # 更新价格
            if not weights.get(date):  # 若换仓权重dict中不存在本日日期，说明不用 换仓
                self.hold()
            else:  # 换仓，先卖出 后买入
                self.sell()
                self.buy(weights[date])
            trade_info[date] = self.get_trade_data()
            if show_info:
                self.show_trading_info()  # 打印交易详情
        return trade_info

    # 获取 并 存储
    def get_trade_data(self):
        '''
        Return
            [dict]  {date: {'date','all_position_value', 'cash', 'weight', 'position_chg',
                            '沪深300_type', '沪深300_price', '沪深300_position', '沪深300_position_value',
                            '国债_type', '国债_price', '国债_position', '国债_position_value'
                            }
        '''
        param_list = ['value', 'all_position_value', 'cash', 'weight', 'position_chg']
        value = {name: getattr(self, name) for name in param_list}

        # 每个资产的数据
        stock_param = ['type', 'price', 'position', 'position_value']
        for i in [self.stock, self.bond]:
            for name in stock_param:
                value[getattr(i, 'type') + '_' + name] = getattr(i, name)
        return value

    def show_trading_info(self):
        if self.position_chg > 0:
            print(f'{self.date} 换仓，买入 {self.weight["沪深300"]:.0%} 股票、{self.weight["国债"]:.0%} 债券，'
                  f'持仓价值 {self.all_position_value:.2f}，剩余 {self.cash:.2f} 现金')
        else:
            print(f'{self.date} 无操作，当前持仓价值 {self.all_position_value:.2f}，总资产 {self.value:.2f}')


if __name__ == '__main__':
    from strategy import *
    from Evaluate import *
    from Picture import *

    trade_dt, trade_price = load_data(path='国内股债收盘价.xlsx')
    opinion_dt, opinions = load_data(path='增长-通胀观点.xlsx')
    print(trade_price[trade_dt[0]], opinions[opinion_dt[0]])

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

    trade_dt = [d for d in trade_dt if d > opinion_dt[0]]

    trade = Trade(trade_price, current_date=trade_dt[0])  # 传入数据

    trade_info = trade.trade(trade_dt, weights, show_info=True)
    trade_data = pd.DataFrame.from_dict(trade_info, 'index')
    print(trade_data)
    print(trade_data.columns)

    # 对比策略：“股票20%-债券80%-月度再平衡”策略
    benchmark = Trade(trade_price, current_date=trade_dt[0])  # 传入数据
    benchmark_trade_info = benchmark.trade(trade_dt, benchmark_weight, show_info=False)
    benchmark_trade_data = pd.DataFrame.from_dict(benchmark_trade_info, 'index')

    trade_data['benchmark_value'] = benchmark_trade_data['value']

    plt.figure(figsize=(9, 5))
    plt.plot(trade_data['value'] / trade_data['value'].iloc[0], label='策略')
    plt.plot(benchmark_trade_data['value'] / benchmark_trade_data['value'].iloc[0],  label='benchmark')
    plt.plot(trade_data['沪深300_price'] / trade_data['沪深300_price'].iloc[0],  linewidth=1.0, label='沪深300')
    plt.plot(trade_data['国债_price'] / trade_data['国债_price'].iloc[0],  label='国债')
    plt.grid(visible=True)
    plt.legend()
    plt.show()

    # analyse = Evaluate(trade_data)
    # evaluate_data = analyse.evaluate()
    # print(evaluate_data)
    #
    # picture = Pictures(analyse.trade_data, analyse.holding_data)
    # picture.paint()

    analyse = Evaluate(benchmark_trade_data)
    evaluate_data = analyse.evaluate()
    # picture = Pictures(analyse.trade_data, analyse.holding_data)
    # picture.paint()

