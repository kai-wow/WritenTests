function [C,D] = BryBoschan(data_bench,data_candi)
% 计算拐点匹配率（参考2021年2月10日，国盛证券量化专题报告“宏观经济量化系列之一：中国经济领先指数”）
% 传入参数
% data_candi 候选指标原序列
% data_bench 基准指标原序列
% 返回参数
% C 各列数据表示：匹配拐点数 缺失拐点数 多余拐点数 无数据拐点数 拐点匹配率 多余率 平均领先阶数 领先标准差
% D 各列数据表示：候选指标原序列 基准指标原序列 候选指标平滑序列 基准指标平滑序列 ...
% 在候选指标原序列上的拐点 在基准指标原序列上的拐点 在候选指标平滑序列上的拐点 在基准指标平滑序列上的拐点
% 注意第四个子图请手动调整图例位置
% 例：[C,D] = BryBoschan(y,x)
%% 参数定义
pp = 16; % 波峰（谷）与波峰（谷）之间距离
pt = 6; % 波峰与波谷之间距离
N = 6; % 步骤一定义序列在[-N,N]之间的最大（小）值为局部极大（小）值
N_ad = 4; % 步骤三将平滑序列的[-N_ad,N_ad]的拐点调整到原序列（或次平滑序列）上
lead = 15; % 步骤四在基准指标前lead个月内搜寻匹配的候选指标上的拐点
lag = 8; % 步骤四在基准指标后lag个月内搜寻匹配的候选指标上的拐点
name_candi = '候选指标';
name_bench = '基准指标';

%% 步骤1：初始拐点识别
data_candi1 = movmean(data_candi,12); % 采用的是12项移动平均平滑序列
[IndPeaks_candi1,IndTroughs_candi1] = Check(data_candi1,N);

data_bench1 = movmean(data_bench,12); % 采用的是12项移动平均平滑序列
[IndPeaks_bench1,IndTroughs_bench1] = Check(data_bench1,N);

% 步骤2：拐点筛选
[IndPeaks_candi2,IndTroughs_candi2] = PointsClean(IndPeaks_candi1,IndTroughs_candi1,pt,pp,data_candi1);

[IndPeaks_bench2,IndTroughs_bench2] = PointsClean(IndPeaks_bench1,IndTroughs_bench1,pt,pp,data_bench1);

% 步骤3：拐点调整
% 调整的方法是在平滑后序列拐点的[-N_ad,N_ad]个月区间内，寻找原序列的最大（小）值
[IndPeaks_candi3_1, IndTroughs_candi3_1] = PointsAdjust(IndPeaks_candi2, IndTroughs_candi2, data_candi, N_ad);
[IndPeaks_candi3_2,IndTroughs_candi3_2] = PointsClean(IndPeaks_candi3_1,IndTroughs_candi3_1,pt,pp,data_candi);

[IndPeaks_bench3_1, IndTroughs_bench3_1] = PointsAdjust(IndPeaks_bench2, IndTroughs_bench2, data_bench, N_ad);
[IndPeaks_bench3_2,IndTroughs_bench3_2] = PointsClean(IndPeaks_bench3_1,IndTroughs_bench3_1,pt,pp,data_bench);

% 绘图
% 候选指标
figure;
subplot(2,2,1);
MyPlot(IndPeaks_candi1, IndTroughs_candi1, data_candi1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_candi '平滑序列潜在拐点识别']);
legend({[name_candi '平滑序列'],'极大值点','极小值点'},'Orientation','horizontal','Location','North');
subplot(2,2,2);
MyPlot(IndPeaks_candi2, IndTroughs_candi2, data_candi1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_candi '平滑序列拐点筛选']);
legend({[name_candi '平滑序列'],'极大值点','极小值点'},'Orientation','horizontal','Location','North');
subplot(2,2,3);
MyPlot(IndPeaks_candi3_2, IndTroughs_candi3_2, data_candi,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_candi '拐点调整']);
legend({[name_candi '原序列'],'调整后极大值点','调整后极小值点'},'Orientation','horizontal','Location','North');
subplot(2,2,4);
[h1, h2, h3] = MyPlot(IndPeaks_candi2, IndTroughs_candi2, data_candi1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255); % 平滑序列上是 红 深红 深绿
[h4, h5, h6] = MyPlot(IndPeaks_candi3_2, IndTroughs_candi3_2, data_candi,[4 78 126]/255,[129 166 190]/255,[180 202 216]/255); % 调整到原序列上是 蓝 深蓝 浅绿
title([name_candi '平滑序列 & 原序列']);
legend([h1,h2,h3],[name_candi '平滑序列'],'极大值点','极小值点','Orientation','horizontal','Location','North');
ah = axes('position',get(gca,'position'),'visible','off');
legend(ah,[h4,h5,h6],[name_candi '原序列'],'调整后极大值点','调整后极小值点','Orientation','horizontal','Location','North');

% 基准指标
figure;
subplot(2,2,1);
MyPlot(IndPeaks_bench1, IndTroughs_bench1,data_bench1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_bench '平滑序列潜在拐点识别']);
legend({[name_bench '平滑序列'],'极大值点','极小值点'},'Orientation','horizontal','Location','North');
subplot(2,2,2);
MyPlot(IndPeaks_bench2, IndTroughs_bench2,data_bench1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_bench '平滑序列拐点筛选']);
legend({[name_bench '平滑序列'],'极大值点','极小值点'},'Orientation','horizontal','Location','North');
subplot(2,2,3);
MyPlot(IndPeaks_bench3_2, IndTroughs_bench3_2, data_bench,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_bench '基准指标拐点调整']);
legend({[name_bench '原序列'],'调整后极大值点','调整后极小值点'},'Orientation','horizontal','Location','North');
subplot(2,2,4);
[h1,h2,h3] = MyPlot(IndPeaks_bench2, IndTroughs_bench2,data_bench1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255); % 平滑序列上是 红 深红 深绿
[h4,h5,h6] = MyPlot(IndPeaks_bench3_2, IndTroughs_bench3_2, data_bench,[4 78 126]/255,[129 166 190]/255,[180 202 216]/255); % 调整到原序列上是 蓝 深蓝 浅绿
title([name_bench '平滑序列 & 原序列']);
legend([h1,h2,h3],[name_bench '平滑序列'],'极大值点','极小值点','Orientation','horizontal','Location','North');
ah = axes('position',get(gca,'position'),'visible','off');
legend(ah,[h4,h5,h6],[name_bench '原序列'],'调整后极大值点','调整后极小值点','Orientation','horizontal','Location','North');

% 候选指标&基准指标
figure;
[h1,h2,h3] = MyPlot(IndPeaks_bench3_2, IndTroughs_bench3_2, data_bench,[255 0 0]/255,[255 128 128]/255,[129 166 190]/255); % 基准指标上是 蓝 深蓝 浅绿
[h4, ~, ~] = MyPlot(IndPeaks_candi3_2, IndTroughs_candi3_2, data_candi,[4 78 126]/255,[255 128 128]/255,[129 166 190]/255); % 候选指标上是 红 深红 深绿
title([name_candi '与' name_bench '的拐点识别与匹配']);
legend([h1,h4,h2,h3],name_bench,name_candi,'极大值点','极小值点','Orientation','horizontal','Location','North');

% 步骤4：拐点匹配
[PiPei, QueShi, DuoYu, WuShu, LeadLag] = PointsMatch(IndPeaks_candi3_2, IndTroughs_candi3_2, data_candi, IndPeaks_bench3_2, IndTroughs_bench3_2, lead, lag);
ratio_pipei = length(PiPei)/(length(PiPei)+length(QueShi)+length(DuoYu));
ratio_duoyu = length(DuoYu)/(length(PiPei)+length(DuoYu));
fprintf('匹配拐点数 = %d\n',length(PiPei));
fprintf('缺失拐点数 = %d\n',length(QueShi));
fprintf('多余拐点数 = %d\n',length(DuoYu));
fprintf('无数据拐点数 = %d\n',length(WuShu));
fprintf('拐点匹配率 = %.2f\n',ratio_pipei);
fprintf('多余率 = %.2f\n',ratio_duoyu);
fprintf('平均领先阶数 = %.2f\n',mean(LeadLag));
fprintf('领先标准差 = %.2f\n',std(LeadLag));

% 返回参数整理
% 在候选指标原序列上的拐点
mark_candi = zeros(size(data_candi,1),1);
mark_candi(IndPeaks_candi3_2) = 1;
mark_candi(IndTroughs_candi3_2) = -1;
% 在基准指标原序列上的拐点
mark_bench = zeros(size(data_bench,1),1);
mark_bench(IndPeaks_bench3_2) = 1;
mark_bench(IndTroughs_bench3_2) = -1;
% 在候选指标平滑序列上的拐点
mark_candi1 = zeros(size(data_candi1,1),1);
mark_candi1(IndPeaks_candi2) = 1;
mark_candi1(IndTroughs_candi2) = -1;
% 在基准指标平滑序列上的拐点
mark_bench1 = zeros(size(data_bench1,1),1);
mark_bench1(IndPeaks_bench2) = 1;
mark_bench1(IndTroughs_bench2) = -1;

C = [length(PiPei),length(QueShi),length(DuoYu),length(WuShu),ratio_pipei,ratio_duoyu,mean(LeadLag),std(LeadLag)];
D = [data_candi,data_bench,data_candi1,data_bench1,mark_candi,mark_bench,mark_candi1,mark_bench1];
end

%% 识别潜在拐点
% 查找极大值和极小值
% 传入data是列向量（M*1），和N（前后N个月的局部拐点）
% 返回处理过后的波峰数组IndPeaks，波谷数组IndTroughs
function [IndPeaks,IndTroughs] = Check(data, N)
dataSize = size(data,1);
% r2017b以上的版本可以使用
% IndPeaks = islocalmax(data, 'MinSeparation', 6);
% IndTroughs = islocalmin(data, 'MinSeparation', 6);

% 由于本人版本不支持，所以自己写函数实现
% 找前后1个月的局部拐点，有现有函数可以实现
if N == 1
    [~, IndPeaks] = findpeaks(data);
    [~, IndTroughs] = findpeaks(-data);
    % 找前后N（N>1）个月的局部拐点
elseif N > 1
    % 先选出前后1个月的局部拐点（加快速度）
    [~, IndPeaks0] = findpeaks(data);
    [~, IndTroughs0] = findpeaks(-data);
    m = size(IndPeaks0,1);
    n = size(IndTroughs0,1);
    % 再根据前后N个月进行筛选
    for i = 1:m
        for j = -N:N
            if IndPeaks0(i)+j > 0 && IndPeaks0(i)+j < dataSize+1 && data(IndPeaks0(i)+j) > data(IndPeaks0(i))
                IndPeaks0(i) = 0;
                break;
            end
        end
    end
    for i = 1:n
        for j = -N:N
            if IndTroughs0(i)+j > 0 &&  IndTroughs0(i)+j < dataSize+1 && data( IndTroughs0(i)+j) < data( IndTroughs0(i))
                IndTroughs0(i) = 0;
                break;
            end
        end
    end
    IndPeaks = Delete(IndPeaks0);
    IndTroughs = Delete(IndTroughs0);
else
    error('程序遇到错误，返回！');
end
end

%% 拐点规范和筛选
% 传入IndPeaks和IndTroughs是行向量（N*1）,data是列向量（N*1）
% 返回处理过后的波峰数组IndPeaks2，波谷数组IndTroughs2，格式同上
function [IndPeaks2,IndTroughs2] = PointsClean(IndPeaks1,IndTroughs1,pt,pp,data)
IndPeaks2_1 = CheckCirclePeaks(IndPeaks1, pp, data); % 周期检验
IndTroughs2_1 = CheckCircleTroughs(IndTroughs1, pp, data); % 周期检验
[IndPeaks2_2, IndTroughs2_2] = CheckCircleHalf(IndPeaks2_1, IndTroughs2_1, pt); % 半周期检验
[IndPeaks2, IndTroughs2] = CheckAlternate(IndPeaks2_2, IndTroughs2_2, data); % 交替性检验
end

% 剔除数据开头和结尾6个月内的拐点，并约束相邻峰间隔（周期）不小于pp个月
% 传入IndPeaks1, pp, data（pp一般取16个月）
% 返回处理过后的波峰数组IndPeaks2
% 删除拐点的方法是相邻波峰删除极值较小的拐点
function IndPeaks2 = CheckCirclePeaks(IndPeaks1, pp, data)
m = size(IndPeaks1,1);
prePeak = 0;
IndPeaks2 = nan(m,1);
for i = 1:m
    % 剔除数据开头和结尾6个月内的拐点
    if prePeak == 0 && IndPeaks1(i)  < 6 || size(data,1) - IndPeaks1(i) < 6
        continue;
    end
    % 约束相邻峰间隔（周期）不小于pp个月
    if prePeak ~= 0 && IndPeaks1(i) - prePeak < pp
        % 若峰值后者小于或等于前者，剔除后者
        if data(IndPeaks1(i)) <= data(prePeak)
            continue;
            % 若峰值后者大于前者，剔除前者
        else
            IndPeaks2(length(IndPeaks2(~isnan(IndPeaks2)))) = nan; % 剔除波峰数组的最后一个拐点
        end
    end
    prePeak = IndPeaks1(i);
    IndPeaks2(length(IndPeaks2(~isnan(IndPeaks2)))+1) = prePeak; % 在波峰数组中加入波峰拐点
end
IndPeaks2(isnan(IndPeaks2)) = []; % 将nan值去掉
end

% 剔除数据开头和结尾6个月内的拐点，并约束相邻谷间隔（周期）不小于pp个月
% 传入IndTroughs1, pp, data（pp一般取16个月）
% 返回处理过后的波谷数组IndTroughs2
% 删除拐点的方法是相邻波谷删除极值较大的拐点
function IndTroughs2 = CheckCircleTroughs(IndTroughs1, pp, data)
m = size(IndTroughs1,1);
preTrough = 0;
IndTroughs2 = nan(m,1);
for i = 1:m
    % 剔除数据开头和结尾6个月内的拐点
    if preTrough == 0 && IndTroughs1(i) < 6 || size(data,1) - IndTroughs1(i) < 6
        continue;
    end
    % 约束相邻谷间隔（周期）不小于pp个月
    if preTrough ~= 0 && IndTroughs1(i) - preTrough < pp
        % 若谷值后者小于或等于前者，剔除后者
        if data(IndTroughs1(i)) >= data(preTrough)
            continue;
            % 若谷值后者大于前者，剔除前者
        else
            IndTroughs2(length(IndTroughs2(~isnan(IndTroughs2)))) = nan; % 剔除波谷数组的最后一个拐点
        end
    end
    preTrough = IndTroughs1(i);
    IndTroughs2(length(IndTroughs2(~isnan(IndTroughs2)))+1) = preTrough; % 在波谷数组中加入波谷拐点
end
IndTroughs2(isnan(IndTroughs2)) = []; % 将nan值去掉
end

% 约束相邻峰谷间隔（半周期）不小于pt个月
% 传入IndPeaks1, IndTroughs1, pt（pt一般取6个月）
% 返回处理过后的波峰数组IndPeaks2，波谷数组IndTroughs2
% 删除拐点的方法是波峰波谷之间删除出现较早的拐点
function [IndPeaks2, IndTroughs2] = CheckCircleHalf(IndPeaks1, IndTroughs1, pt)
m = size(IndPeaks1,1);
n = size(IndTroughs1,1);
for i = 1:m
    for j = 1:n
        if IndTroughs1(j) < IndPeaks1(i) && abs(IndTroughs1(j)-IndPeaks1(i)) < pt
            IndTroughs1(j) = 0;
        end
        if IndTroughs1(j) > IndPeaks1(i) && abs(IndTroughs1(j)-IndPeaks1(i)) < pt
            IndPeaks1(i) = 0;
        end
    end
end
% 删除不符合的拐点
IndPeaks2 = Delete(IndPeaks1);
IndTroughs2 = Delete(IndTroughs1);
end

% 处理波峰和波谷交替
% 传入IndPeaks1, IndTroughs1, data
% 返回处理过后的波峰数组IndPeaks2，波谷数组IndTroughs2
% 删除拐点的方法是相邻波峰（谷）删除极值较小（大）的拐点
function [IndPeaks2, IndTroughs2] = CheckAlternate(IndPeaks1, IndTroughs1, data)
dataSize = size(data,1);
mark = zeros(dataSize,1);
mark(IndPeaks1) = 1;
mark(IndTroughs1) = -1;
pre = 0; % 标记上一个拐点的位置
for i = 1:dataSize
    if mark(i) == 0
        continue;
    else
        if pre == 0  % 若此前没有拐点时
            pre = i;
        else
            if mark(i)+mark(pre) == 0 % 若此时拐点与上一个拐点时交替的
                pre = i;
                % 若此时拐点与上一个拐点不是交替的，并且是连续波峰时，需要删除峰值较小的拐点
            elseif mark(i) == 1
                if data(i) >= data(pre)
                    mark(pre) = 0;
                    pre = i;
                else
                    mark(i) = 0;
                end
                % 若此时拐点与上一个拐点不是交替的，并且是连续波谷时，需要删除峰值较大的拐点
            else
                if data(i) <= data(pre)
                    mark(pre) = 0;
                    pre = i;
                else
                    mark(i) = 0;
                end
            end
        end
    end
end
IndPeaks2 = find(mark==1);
IndTroughs2 = find(mark==-1);
end

% 删除不符合的拐点
% 传入IndPoints1,不符合的拐点都标记成了0
% 返回处理过后的拐点数组IndPoints2
function IndPoints2 = Delete(IndPoints1)
IndPoints2_0 = sort(IndPoints1,1);
i = 1;
while i< length(IndPoints2_0)+1 && IndPoints2_0(i) == 0
    i = i+1;
end
if i < length(IndPoints2_0)+1
    IndPoints2 = IndPoints2_0(i:end);
else
    IndPoints2 = [];
end
end

%% 拐点调整
% 传入IndPeaks1, IndTroughs1, data, N_ad（data是需要调整到的序列）
% 返回处理过后的波峰数组IndPeaks2，波谷数组IndTroughs2
function [IndPeaks2, IndTroughs2] = PointsAdjust(IndPeaks1, IndTroughs1, data, N_ad)
dataSize = size(data,1);
m = size(IndPeaks1,1);
n = size(IndTroughs1,1);
IndPeaks2 = IndPeaks1;
IndTroughs2 = IndTroughs1;
for i = 1:m
    max = intmax;
    for j = -N_ad:N_ad
        if IndPeaks1(i)+j > 0 && IndPeaks1(i)+j < dataSize+1
            if max == intmax
                max = data(IndPeaks1(i)+j);
                IndPeaks2(i) = IndPeaks1(i)+j;
            else
                if data(IndPeaks1(i)+j) > max
                    max = data(IndPeaks1(i)+j);
                    IndPeaks2(i) = IndPeaks1(i)+j;
                end
            end
        end
    end
end
for i = 1:n
    min = intmin;
    for j = -N_ad:N_ad
        if IndTroughs1(i)+j > 0 && IndTroughs1(i)+j < dataSize+1
            if min == intmin
                min = data(IndTroughs1(i)+j);
                IndTroughs2(i) = IndTroughs1(i)+j;
            else
                if data(IndTroughs1(i)+j) < min
                    min = data(IndTroughs1(i)+j);
                    IndTroughs2(i) = IndTroughs1(i)+j;
                end
            end
        end
    end
end
end

%% 拐点匹配
% 传入IndPeaks_candi, IndTroughs_candi, data_candi, IndPeaks_bench, IndTroughs_bench, lead, lag
% 传出PiPei, QueShi, DuoYu, WuShu，记录各类别在相应序列中的位置，均为N*1格式
function [PiPei, QueShi, DuoYu, WuShu,LeadLag] = PointsMatch(IndPeaks_candi, IndTroughs_candi, data_candi, IndPeaks_bench, IndTroughs_bench, lead, lag)
m_candi = size(IndPeaks_candi,1);
n_candi = size(IndTroughs_candi,1);
m_bench = size(IndPeaks_bench,1);
n_bench = size(IndTroughs_bench,1);
PiPei0 = nan(m_bench+n_bench,1);
PiPei_candi = nan(m_candi+n_candi,1);
QueShi0 = nan(m_bench+n_bench,1);
DuoYu0 = nan(m_candi+n_candi,1);
WuShu0 = nan(m_bench+n_bench,1);
LeadLag0 = nan(m_bench+n_bench,1); % 若元素为1，则含义是候选指标上的点领先基准指标上的点1期
% 对基准指标拐点的标记：PiPei0（匹配），QueShi0（缺失）,WuShu0（无数据）
% 对候选指标拐点的标记：PiPei_candi（匹配），DuoYu（多余）
for i = 1:m_bench
    isNotNull = 0;
    for j = -lead:lag
        if IndPeaks_bench(i)+j > 0 && IndPeaks_bench(i)+j < size(data_candi,1)+1 && isnan(data_candi(IndPeaks_bench(i)+j))
        else
            isNotNull = 1;
            IdElem = Search(IndPeaks_candi, IndPeaks_bench(i)+j);
            if IdElem ~= 0
                PiPei0(length(PiPei0(~isnan(PiPei0)))+1) = IndPeaks_bench(i);
                PiPei_candi(length(PiPei_candi(~isnan(PiPei_candi)))+1) = IndPeaks_bench(i)+j;
                LeadLag0(length(LeadLag0(~isnan(LeadLag0)))+1) = -j;
                break;
            end
        end
    end
    if isNotNull == 0
        WuShu0(length(WuShu0(~isnan(WuShu0)))+1) = IndPeaks_bench(i);
    else
        if j == lag
            QueShi0(length(QueShi0(~isnan(QueShi0)))+1) = IndPeaks_bench(i);
        end
    end
end
for i = 1:n_bench
    isNotNull = 0;
    for j = -lead:lag
        if IndTroughs_bench(i)+j > 0 && IndTroughs_bench(i)+j < size(data_candi,1)+1 && isnan(data_candi(IndTroughs_bench(i)+j))
        else
            isNotNull = 1;
            IdElem = Search(IndTroughs_candi, IndTroughs_bench(i)+j);
            if IdElem ~= 0
                PiPei0(length(PiPei0(~isnan(PiPei0)))+1) = IndTroughs_bench(i);
                PiPei_candi(length(PiPei_candi(~isnan(PiPei_candi)))+1) = IndTroughs_bench(i)+j;
                LeadLag0(length(LeadLag0(~isnan(LeadLag0)))+1) = -j;
                break;
            end
        end
    end
    if isNotNull == 0
        WuShu0(length(WuShu0(~isnan(WuShu0)))+1) = IndTroughs_bench(i);
    else
        if j == lag
            QueShi0(length(QueShi0(~isnan(QueShi0)))+1) = IndTroughs_bench(i);
        end
    end
end

% 对候选指标的标记：DuoYu0（多余）
for i = 1:m_candi
    IdElem = Search(PiPei_candi, IndPeaks_candi(i));
    if IdElem == 0
        DuoYu0(length(DuoYu0(~isnan(DuoYu0)))+1) = IndPeaks_candi(i);
    end
end
for i = 1:n_candi
    IdElem = Search(PiPei_candi, IndTroughs_candi(i));
    if IdElem == 0
        DuoYu0(length(DuoYu0(~isnan(DuoYu0)))+1) = IndTroughs_candi(i);
    end
end
% 将nan值去掉
PiPei0(isnan(PiPei0)) = [];
% PiPei_candi(isnan(PiPei_candi)) = [];
QueShi0(isnan(QueShi0)) = [];
DuoYu0(isnan(DuoYu0)) = [];
WuShu0(isnan(WuShu0)) = [];
LeadLag0(isnan(LeadLag0)) = [];

% 将标记的拐点序列排序
[PiPei,b] = sort(PiPei0,1);
QueShi = sort(QueShi0,1);
DuoYu = sort(DuoYu0,1);
WuShu = sort(WuShu0,1);
LeadLag = LeadLag0(b,:);
end

% 在序列arr中查找值为elem的元素
% 传入arr,elem
% 传出IdElem,elem在arr中的位置；若找不到，则IdElem = 0
function IdElem  = Search(arr,elem)
IdElem = 0;
for i = 1:length(arr)
    if arr(i) == elem
        IdElem = i;
    end
end
end

% 绘图
function [h1, h2, h3] = MyPlot(IndPeaks, IndTroughs, data , lineColor, peaksColor, troughsColor)
x=1:size(data,1);
hold on
h1 = plot(x,data,'-','Color',lineColor);
h2 = plot(x(IndPeaks),data(IndPeaks),'.','Color',peaksColor,'MarkerSize',15);
h3 = plot(x(IndTroughs),data(IndTroughs),'.','Color',troughsColor,'MarkerSize',15);
hold off
end
