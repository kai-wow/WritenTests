classdef Match
    % 匹配候选指标和基准指标

    properties
        Date
        benchmark
        candidate
        M % 在基准指标拐点前 M 个月搜寻候选指标的拐点
        N % 在基准指标拐点后 N 个月搜寻候选指标的拐点
        
        match   % table 存储数据：匹配上的各点
        b_match % table: benchmark 的匹配情况
        c_match % table: candidate 的匹配情况

        match_result
    end

    methods
        function obj = Match(Date,benchmark,candidate,M,N)
            % Match 构造此类的实例
            obj.Date = Date;
            % 其中benchmark 和 candidate都是 TurnPoint 实例
            obj.benchmark = benchmark;
            obj.candidate = candidate;
            obj.M = M; % 在基准指标拐点前 M 个月搜寻候选指标的拐点
            obj.N = N; % 在基准指标拐点后 N 个月搜寻候选指标的拐点
            
            obj.b_match = obj.initialize_match_data('benchmark');
            obj.c_match = obj.initialize_match_data('candidate');
        end
        
        %% 初始化 match 数据
        function match_data = initialize_match_data(obj, type_)
            if type_ == "benchmark"
                object = obj.benchmark;
            elseif type_ == "candidate"
                object = obj.candidate;
            end

            % table 的一些参数
            varTypes = {'datetime','string','double','string','double','double'};
            varNames = {'Date','type','index','MatchType','MatchIdx','value'};
            sz = [height(object.max_idx)+height(object.min_idx), 6];
            % 新建 table 文件
            match_data = table('Size',sz,'VariableTypes',varTypes, ...
                              'VariableNames',varNames);
            % 填充 'type' 数据：先 max 后 min
            for i = 1:height(object.max_idx)
                match_data{i, 'type'} = "max";
            end
            for i = height(object.max_idx)+1:height(match_data)
                match_data{i, 'type'} = "min";
            end
            % 填充 'index' 数据：先 max 后 min
            match_data(1:height(object.max_idx), 'index') = num2cell(object.max_idx);
            match_data(height(object.max_idx)+1:end, 'index') = num2cell(object.min_idx);
            % 填充 Date，value
            match_data.value = object.ori_data(match_data.index);
            match_data.Date = object.Date(match_data.index);
        end

        %% 匹配候选指标和基准指标
        function obj = match_with_benchmark(obj)
            % 匹配最大值点
            for i = 1:height(obj.benchmark.max_idx) 
                begin_ = obj.benchmark.max_idx(i)-15;
                end_ = obj.benchmark.max_idx(i)+8;
                for j = 1:height(obj.candidate.max_idx) 
                    if obj.candidate.max_idx(j) > begin_ ...
                        && obj.candidate.max_idx(j) < end_
                        obj.b_match{i,'MatchType'} = "匹配";
                        obj.b_match{i,'MatchIdx'} = obj.candidate.max_idx(j);
                        obj.c_match{j,'MatchType'} = "匹配";
                        obj.c_match{j,'MatchIdx'} = obj.benchmark.max_idx(i);
                        break
                    end
                % 基准指标拐点没有搜寻到任何可匹配的候选指标拐点
                obj.b_match{i,'MatchType'} = "缺失";
                end
            end
            
            % 匹配最小值点
            for i = 1:height(obj.benchmark.min_idx) 
                begin_ = obj.benchmark.min_idx(i)-15;
                end_ = obj.benchmark.min_idx(i)+8;
                for j = 1:height(obj.candidate.min_idx) 
                    if obj.candidate.min_idx(j) > begin_ ...
                        && obj.candidate.min_idx(j) < end_
                        
                        obj.b_match{height(obj.benchmark.max_idx)+i,'MatchType'} = "匹配";
                        obj.c_match{height(obj.candidate.max_idx)+j,'MatchType'} = "匹配";
                        obj.b_match{height(obj.benchmark.max_idx)+i,'MatchIdx'} = ...
                                    obj.candidate.min_idx(j);
                        obj.c_match{height(obj.candidate.max_idx)+j,'MatchIdx'} = ...
                                    obj.benchmark.min_idx(i);
                        break
                    end
                % 基准指标拐点没有搜寻到任何可匹配的候选指标拐点
                obj.b_match{height(obj.benchmark.max_idx)+i,'MatchType'} = "缺失";
                end
            end
            obj.c_match = fillmissing(obj.c_match,'constant',"多余",'DataVariables',{'MatchType'});

            % 匹配 的各极值的信息
            obj = get_match_point_info(obj);
        end
        
        %% 计算 匹配上的各点信息 
        function obj = get_match_point_info(obj)
            % 去除没匹配上的点
            toDelete = obj.c_match.MatchType~="匹配";
            obj.match = obj.c_match;
            obj.match(toDelete,:) = [];
            % 点的日期
            obj.match.Date = obj.Date(obj.match.index);
            obj.match.MatchDate = obj.Date(obj.match.MatchIdx);
            % 点的值
            obj.match.value = obj.candidate.ori_data(obj.match.index);
            obj.match.MatchValue = obj.benchmark.ori_data(obj.match.MatchIdx);
        end

        %% 计算匹配率等指标
        function obj = get_match_rate(obj)
            b_num = height(obj.b_match);
            c_num = height(obj.c_match);
            % 现成的函数？ 找table中特定元素的出现次数
            match_num = sum(cellfun(@(x)strcmp(x,"匹配"), table2cell(obj.c_match(:,'MatchType'))));
            
            obj.match.lead_order = obj.match.index - obj.match.MatchIdx;
            disp( obj.match)

            turnpoint_num = c_num;
            match_rate = match_num/b_num; % 匹配率 = 匹配数/基准指标拐点数
            excess_rate = 1 - match_num/c_num; % 多余率 = 1 - 匹配数/候选指标拐点数
            lead_order = mean(obj.match.lead_order);% 拐点领先
            lead_order_std = std(obj.match.lead_order);% 拐点领先阶数标准差
            obj.match_result = table(turnpoint_num, match_rate, excess_rate, ...
                    lead_order, lead_order_std, ...
                    'VariableNames', {'可匹配拐点','匹配率','多余率','拐点领先','拐点领先阶数标准差'}, ...
                    'RowNames', {obj.candidate.data_name});

            disp(obj.match_result)
        end
     
        %% 画图
        function obj = draw_turnpoint_match(obj)
            % 日期转化为 datenum
            d = datenum(obj.Date);
            obj.b_match.Date = datenum(obj.b_match.Date);
            obj.c_match.Date = datenum(obj.c_match.Date);
            obj.match.Date = datenum(obj.match.Date);
            obj.match.MatchDate = datenum(obj.match.MatchDate);
            
            % gplot散点虚线的数据
            max_ = obj.match(obj.match.type~="max",:);
            min_ = obj.match(obj.match.type~="min",:);
            max_dot = [max_(:, {'Date','value'}).Variables; max_(:, {'MatchDate','MatchValue'}).Variables];
            min_dot = [min_(:, {'Date','value'}).Variables; min_(:, {'MatchDate','MatchValue'}).Variables];
            
            A = zeros(height(max_dot)); 
            for i = 1:height(max_); A(i,i+height(max_)) = 1; end
            
            B = zeros(height(min_dot)); 
            for i = 1:height(min_); B(i,i+height(min_)) = 1; end

            % 画图验证
            plot(d, obj.benchmark.ma_data,'b-'); hold on;
            plot(d, obj.benchmark.ori_local_max,'ro','LineWidth',0.8); hold on;
            plot(d, obj.benchmark.ori_local_min,'go','LineWidth',0.8); hold on;            

            plot(d, obj.candidate.ori_data,'k-'); hold on;
            plot(d, obj.candidate.ori_local_max,'ro','MarkerFaceColor','r'); hold on;
            plot(d, obj.candidate.ori_local_min,'go','MarkerFaceColor','g'); hold on;
            gplot(A, max_dot,'g-'); hold on; %obj.match_max_idx
            gplot(B, min_dot,'r-'); hold off;
            
            % 标注 未匹配上的各点的信息
            for i = 1:height(obj.b_match) % max_dot 和 obj.match 的行数一样
                if obj.b_match{i,'MatchType'} ~= "匹配"
                    text(obj.b_match{i,'Date'}, obj.b_match{i,'value'}, obj.b_match{i,'MatchType'});
                end
            end
            for i = 1:height(obj.c_match)
                if obj.c_match{i,'MatchType'} ~= "匹配" 
                    text(obj.c_match{i,'Date'}, obj.c_match{i,'value'}, obj.c_match{i,'MatchType'})
                end
            end

            datetick('x','yyyy'); % datenum数据类型以年份形式展现在x轴上
            legend(obj.benchmark.data_name, ...
                [obj.benchmark.data_name,' 峰'], [obj.benchmark.data_name,' 谷'], ...
                obj.candidate.data_name, ...
                [obj.candidate.data_name,' 峰'],[obj.candidate.data_name,' 谷'], ...
                'Location','best', 'NumColumns', 2); 
            
            saveas(gcf, 'match', 'png')
        end
    end
end