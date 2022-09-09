function [outputArg1,outputArg2] = GetTurnPoint(data)
    % 判断拐点 并 计算拐点匹配率（参考2021年2月10日，国盛证券量化专题报告"宏观经济量化系列之一：中国经济领先指数"）
    % 传入参数
    %   data_candi 候选指标原序列
    %   data_bench 基准指标原序列
    % 返回参数
    %   C 各列数据表示：匹配拐点数 缺失拐点数 多余拐点数 无数据拐点数 拐点匹配率 多余率 平均领先阶数 领先标准差
    %   D 各列数据表示：候选指标原序列 基准指标原序列 候选指标平滑序列 基准指标平滑序列 ...
    %           在候选指标原序列上的拐点 在基准指标原序列上的拐点 在候选指标平滑序列上的拐点 在基准指标平滑序列上的拐点
    % 注意:
    % 例：[C,D] = BryBoschan(y,x)
 
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
    match = match.get_match_rate();
    match.draw_turnpoint_match();
end

%% 步骤一：识别局部极值
function obj = get_local_extreme(data, range_begin, range_end)
    % 获取拐点
    extreme = table('Size',[height(data), 2], ...
                    'VariableTypes', {'double', 'double'}, ...
                    'VariableNames', {'max','min'});
    extreme.max(1:range_begin) = nan;
    extreme.min(1:range_begin) = nan;
    extreme.max(range_end:height(data)) = nan;
    extreme.min(range_end:height(data)) = nan;

    for i = range_begin:range_end
        begin = max(i-obj.local_period, range_begin);
        end_ = min(i+obj.local_period, range_end);
        [max_, ~] = max(data(begin:end_, 1));
        [min_, ~] = min(data(begin:end_, 1));
        if max_ == data(i) 
            extreme.max(i) = max_;
            obj.local_min(i) = nan;
            obj.ori_extreme{i, 'type'} = "max";
        elseif min_ == data(i)
            extreme.max(i) = nan;
            obj.local_min(i) = min_;
            obj.ori_extreme{i, 'type'} = "min";
        else
            extreme.max(i) = nan;
            obj.local_min(i) = nan;
        end
    end
    obj.max_idx = find(~isnan(obj.local_max));
    obj.min_idx = find(~isnan(obj.local_min));  
end
   



