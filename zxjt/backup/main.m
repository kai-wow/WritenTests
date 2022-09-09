clear;

%% 设置导入选项并导入数据
opts = spreadsheetImportOptions("NumVariables", 20);
% 指定工作表和范围
opts.Sheet = "周期项";
opts.DataRange = "A3:T184";
% 指定列名称和类型
opts.VariableNames = ["Date", "CPI", "PPI", "CRB", "VarName5", "VarName6", "MyIpic", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "CCBFI", "VarName15", "BDI", "VarName17", "CRB1", "CRB2", "Q5500K"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% 指定变量属性
opts = setvaropts(opts, "Date", "InputFormat", "");

% 导入数据
data = readtable("通胀因子.xlsx", opts, "UseExcel", false);

% 清除临时变量
clear opts 

%% 判断拐点
% 参数
ma_period = 12; % 平滑窗口
local_period = 6; % 判断局部最大最小值：在前后 6 个月范围内
neibor_period = 4; % 在平滑后序列拐点的前后 4 个月区间内，寻找原序列的最值，
Date = data.Date;

%% 基准指标 的拐点识别
var = data.CPI; % 数据选取，以CPI环比 为例
var_name = 'CPI';
% 调用 TurnPoint 类
benchmark = TurnPoint(ma_period, local_period, neibor_period, Date, var, var_name);
benchmark = benchmark.get_local_extreme(benchmark.ma_data, 6, height(var)-6);
benchmark.draw_ma_extreme('CPI 局部极值点生成 (Step1)')
benchmark = benchmark.drop_extreme(benchmark.ma_data);
benchmark = benchmark.renew_local_extreme(benchmark.ma_data);
benchmark.draw_ma_extreme('CPI 拐点去除 (Step2)')
benchmark = benchmark.adjust_origin_extreme();
benchmark.draw('CPI 拐点调整 (Step3)'); % 画图，看拐点是否识别准确


%% 候选指标的拐点识别
var = data.CRB; % 数据选取，以 CRB 为例
var_name = 'CRB现货指数';
% 调用 TurnPoint 类
candidate = TurnPoint(ma_period, local_period, neibor_period, Date, var, var_name);
candidate = candidate.get_local_extreme(candidate.ma_data, 6, height(var)-6);
benchmark.draw_ma_extreme('CRB现货指数 局部极值点生成 (Step1)')
candidate = candidate.drop_extreme(candidate.ma_data);
candidate = candidate.renew_local_extreme(candidate.ma_data);
benchmark.draw_ma_extreme('CRB现货指数 拐点去除 (Step2)')
candidate = candidate.adjust_origin_extreme();
candidate.draw('CRB现货指数 拐点调整 (Step3)'); % 画图，看拐点是否识别准确

%% 拐点匹配
match = Match(Date,benchmark, candidate, 15, 8);
match = match.match_with_benchmark();
match_rate = match.get_match_rate();
match.draw_turnpoint_match();

