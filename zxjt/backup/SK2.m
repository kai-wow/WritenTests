%% 导入电子表格中的数据
clc

%% 设置导入选项并导入数据
opts = spreadsheetImportOptions("NumVariables", 20);

% 指定工作表和范围
opts.Sheet = "OriginalData";
opts.DataRange = "A3:T184";

% 指定列名称和类型
opts.VariableNames = ["Date", "CPI", "PPI", "CRB", "VarName5", "VarName6", "MyIpic", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "CCBFI", "VarName15", "BDI", "VarName17", "CRB1", "CRB2", "Q5500K"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% 指定变量属性
opts = setvaropts(opts, "Date", "InputFormat", "");

% 导入数据
data = readtable("通胀因子.xlsx", opts, "UseExcel", false);

%% 数据清洗
miss = isnan(data.CPI);
idx = any(miss,2);
nnz(idx)

%% 输出为列向量
Date = data.Date;
CPI = data.CPI;
PPI = data.PPI;

%% 清除临时变量
clear opts tbl

%% 判断局部最大最小值：在前后 N 个月（N 取 6）范围内
% 参数
N = 6;
var = data.CPI;
% 定义占位矩阵
local_max = zeros(height(var),1); % 行数相同
local_min = zeros(height(var),1);
local_value = zeros(height(var),1);
% 计算 局部最大最小值
local_value(1) = var(1);
for i = 2:height(var)
    begin = max(i-N, 1);
    end_ = min(i+N, height(var));
    [local_max_,max_idx] = max(var(begin:end_, 1));
    [local_min_,min_idx] = min(var(begin:end_, 1));
    if local_max_ == var(i) 
        local_max(i,1) = true;
        local_min(i,1) = false;
        local_value(i,1) = var(i);%1;
    elseif local_min_ == var(i)
        local_max(i,1) = false;
        local_min(i,1) = true;
        local_value(i) = var(i);%1;
    else
        local_value(i) = nan; %0;
    end
end

%% 拐点筛选
% 去除拐点原则：两个极大（小）值优先去除较小（大）的，一个极大一个极小值优先去除时间较早的
% 1. 去除数据开头与结尾 6 个月内的拐点。
local_max(1:6, 1) = false;
local_min(1:6, 1) = false;
local_value(1:6, 1) = nan;

local_max(height(var)-6:height(var), 1) = false;
local_min(height(var)-6:height(var), 1) = false;
local_value(height(var)-6:height(var), 1) = nan;

% 2. 峰与谷（或谷与峰）之间，需要间隔至少 6 个月
max_idx = find(local_max);
    
% 3. 峰与峰（或谷与谷）之间，需要间隔至少 16 个月

% 4. 峰谷相邻，同为峰（谷），则去除一个。

%% 画图验证
plot(Date,CPI,'k-'); hold on;
plot(Date,local_value,'ro'); hold off;
legend('CPI','local min','CPI');  

%% 归一化
% 时间转化为数值
% 数据归一化
obj.benchmark.ori_data = normalize(obj.benchmark.ori_data,'range');
obj.candidate.ori_data = normalize(obj.candidate.ori_data,'range');
disp('更改后');
disp(obj.benchmark.ori_data);
%disp('更改前');
%disp(obj.benchmark.ori_local_max);

obj.benchmark = obj.benchmark.renew_local_extreme(obj.benchmark.ori_data, 1);
obj.candidate = obj.candidate.renew_local_extreme(obj.candidate.ori_data, 1);

nan_max = setdiff(1:height(obj.Date), obj.benchmark.max_idx);
nan_min = setdiff(1:height(obj.Date), obj.benchmark.min_idx);
obj.benchmark.ori_local_max = obj.benchmark.ori_data;
obj.benchmark.ori_local_min = obj.benchmark.ori_data;
obj.benchmark.ori_local_max(nan_max) = nan;
obj.benchmark.ori_local_min(nan_min) = nan;

disp('更改后');
disp(obj.benchmark.ori_local_max);