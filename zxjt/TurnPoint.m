classdef TurnPoint
    %TURNPOINT 此处显示有关此类的摘
    properties
        local_max
        local_min
        ori_local_max
        ori_local_min

        max_idx
        min_idx

        ma_period % 平滑窗口
        local_period  % 判断局部最大最小值的时间区间
        neigbor_period % 平滑后序列拐点 和原序列拐点 的误差区间

        data_name
        Date
        ori_data
        ma_data

        ori_extreme
        ma_extreme
    end
    
    methods
        function obj = TurnPoint(ma_period, local_period, neibor_period, ...
                                Date, ori_data, data_name)
            % TURNPOINT 构造此类的实例
            %   data 为列向量，月度数据
            obj.ma_period = ma_period; % 平滑窗口
            obj.local_period = local_period; % 判断局部最大最小值的时间区间
            obj.neigbor_period = neibor_period;% 平滑后序列拐点 和原序列拐点 的误差区间

            obj.Date = Date;
            obj.data_name = data_name;
            obj.ori_data = ori_data;
            obj.ma_data = smoothdata(obj.ori_data,"movmean",obj.ma_period);

            obj.local_max = zeros(height(obj.ori_data),1); % 行数相同
            obj.local_min = zeros(height(obj.ori_data),1);
            obj.ori_extreme = obj.initialize_data_table(ori_data);
            obj.ma_extreme = obj.initialize_data_table(obj.ma_data);
        end

        function table_ = initialize_data_table(obj, data)
            % table 的一些参数
            varTypes = {'datetime','double','string','double'};
            varNames = {'Date','index','type','value'};
            sz = [height(data), 4];
            % 新建 table 文件函数
            table_ = table('Size',sz,'VariableTypes',varTypes, ...
                                'VariableNames',varNames);
            table_.Date = obj.Date;
            table_.value = data;
            % 现成的函数？怎么实现 range？
            %range = perms(1:height(data));
            %disp(range)
            %table_.index = num2cell(perms(1:height(data)));
        end
       
        %% 识别局部极值
        function obj = get_local_extreme(obj, data, range_begin, range_end)
            % get_local_extreme 获取拐点
            obj.local_max(1:range_begin) = nan;
            obj.local_min(1:range_begin) = nan;
            obj.local_max(range_end:height(data)) = nan;
            obj.local_min(range_end:height(data)) = nan;

            for i = range_begin:range_end
                begin = max(i-obj.local_period, range_begin);
                end_ = min(i+obj.local_period, range_end);
                [max_,~] = max(data(begin:end_, 1));
                [min_,~] = min(data(begin:end_, 1));
                if max_ == data(i) 
                    obj.local_max(i) = max_;
                    obj.local_min(i) = nan;
                    obj.ori_extreme{i, 'type'} = "max";
                elseif min_ == data(i)
                    obj.local_max(i) = nan;
                    obj.local_min(i) = min_;
                    obj.ori_extreme{i, 'type'} = "min";
                else
                    obj.local_max(i) = nan;
                    obj.local_min(i) = nan;
                end
            end
            obj.max_idx = find(~isnan(obj.local_max));
            obj.min_idx = find(~isnan(obj.local_min));
            
        end
        
        %% 画图展示步骤一： 局部极值点生成
        function draw_ma_extreme(obj, title_)
            % 画图验证
            plot(obj.Date, obj.ma_data,'b-'); hold on;
            plot(obj.Date, obj.local_max,'ro','LineWidth',0.8); hold on;
            plot(obj.Date, obj.local_min,'go','LineWidth',0.8); hold off;
            legend([obj.data_name,'平滑后'],'峰','谷');
            title(title_);
            saveas(gcf, title_, 'png')
        end

        %% 获取拐点：去除一些 周期上不符合条件的局部极值
        function obj = drop_extreme(obj, data)
            % drop_extreme 去除拐点
            % 只保留极值点 的index （位置）
            extreme_index = [[obj.max_idx  ones(height(obj.max_idx),1)];
                             [obj.min_idx  -ones(height(obj.min_idx),1)]];
            [extreme_idx, ~] = sortrows(extreme_index, 1);
            disp(extreme_idx)
            disp('处理中...')
            
            i = 2; % 从第二个点开始处理
            while i <= height(extreme_idx)
                % 1. 峰与谷（或谷与峰）之间，需要间隔至少 6 个月
                if extreme_idx(i,2) ~= extreme_idx(i-1,2) && ...
                   extreme_idx(i,1) - extreme_idx(i-1,1) < 6
                    extreme_idx(i,:) = []; % 优先去除时间较早的
                    i = i - 1;

                % 2. 必须峰谷相邻，否则去除一个: 两个极大（小）值优先去除较小（大）的
                elseif extreme_idx(i,2) == extreme_idx(i-1,2) 
                   if extreme_idx(i,2) == 1   % 两个极大值优先去除较小的
                       if data(extreme_idx(i,1)) < data(extreme_idx(i-1,1))  
                            extreme_idx(i,:) = [];
                       else
                           extreme_idx(i-1,:) = [];
                       end
                   elseif extreme_idx(i,2) == -1 % 两个极小值优先去除较大的
                       if data(extreme_idx(i,1)) < data(extreme_idx(i-1,1)) 
                            extreme_idx(i-1,:) = [];
                       else
                           extreme_idx(i,:) = [];
                       end
                   end
                   i = i-1;

                % 3. 峰与峰（或谷与谷）之间，需要间隔至少 16 个月
                elseif i >= 3 && extreme_idx(i,1) - extreme_idx(i-2,1) < 16
                    if extreme_idx(i,2) == 1  % 两个极大值优先去除较小的
                        if data(extreme_idx(i,1)) < data(extreme_idx(i-2,1))
                            extreme_idx(i,:) = [];
                        else
                            extreme_idx(i-2,:) = [];
                        end
                    elseif extreme_idx(i,2) == -1 % 两个极小值优先去除较大的
                        if data(extreme_idx(i,1)) < data(extreme_idx(i-2,1))
                            extreme_idx(i-2,:) = [];
                        else
                            extreme_idx(i,:) = [];
                        end
                    end
                    i = i-1;
                
                end
                i = i+1;
            end
            disp(extreme_idx)
            disp('处理结束')

            % 更新新的 最大最小值
            obj.max_idx = extreme_idx(ismember(extreme_idx(:,2),1),1);
            obj.min_idx = extreme_idx(ismember(extreme_idx(:,2),-1),1);
        end
        
        %% 更新极值数据（辅助函数）
        function obj = renew_local_extreme(obj, data, ori)
            % 根据 max_idx, min_idx 更新 local_max, local_min 序列
            if(~exist('type_','var')) % 如果未出现该变量，则对其进行赋值
                ori = 0;  % 是否更新为原始数据 的局部极值
            end
            nan_max = setdiff(1:height(data), obj.max_idx);
            nan_min = setdiff(1:height(data), obj.min_idx);
            if ori==1
                obj.ori_local_max = data;
                obj.ori_local_min = data;
                obj.ori_local_max(nan_max) = nan;
                obj.ori_local_min(nan_min) = nan;
            else
                %obj.local_max = obj.ma_data;
                %obj.local_min = obj.ma_data;
                obj.local_max(nan_max) = nan;
                obj.local_min(nan_min) = nan;
            end
        end
        
        %% 找区域极值（辅助函数）
        function [ex_, ex_idx_] = find_extreme(obj, data, type)
            if type == "max"
                [ex_, ex_idx_] = max(data);
            elseif type == "min"
                [ex_, ex_idx_] = min(data);
            end
        end
        
        %% 从平滑曲线的拐点 到 原始曲线的拐点
        function obj = adjust_origin_extreme(obj)
            for i = 1:height(obj.max_idx)
                begin_ = obj.max_idx(i) - obj.neigbor_period;
                end_ = obj.max_idx(i) + obj.neigbor_period;
                %disp('读取 4')
                %disp(begin_) ;disp(end_);
                %disp(obj.ori_data(begin_: end_));
                [max_, max_idx_] = obj.find_extreme(obj.ori_data(begin_:end_),'max');
                max_idx_ = begin_ + max_idx_ - 1;
                obj.max_idx(i) = max_idx_;
            end
            for i = 1:height(obj.min_idx)
                begin_ = obj.min_idx(i) - obj.neigbor_period;
                end_ = obj.min_idx(i) + obj.neigbor_period;
                [min_, min_idx_] = obj.find_extreme(obj.ori_data(begin_:end_),'min');
                min_idx_ = begin_ + min_idx_ - 1;
                obj.min_idx(i) = min_idx_;
            end
            % 求得原始数据的 局部极值
            obj.ori_local_max = obj.ori_data;
            obj.ori_local_min = obj.ori_data;
            nan_max = setdiff(1:height(obj.ori_data), obj.max_idx);
            nan_min = setdiff(1:height(obj.ori_data), obj.min_idx);
            obj.ori_local_max(nan_max) = nan;
            obj.ori_local_min(nan_min) = nan;
        end
        
        %% 画图
        function draw(obj, title_)
            % 时间转化为数值
            d = datenum(obj.Date);%(1:height(obj.Date))';
            % gplot散点虚线的数据
            max_dot = [[d obj.local_max]; [d obj.ori_local_max];];
            [m,n] = find(isnan(max_dot));
            max_dot(m,:) = [];
            
            min_dot = [[d obj.local_min]; [d obj.ori_local_min]];
            [m,n] = find(isnan(min_dot));
            min_dot(m,:) = [];
           
            A = zeros(height(max_dot), height(max_dot));
            for i = 1:height(max_dot)-height(obj.max_idx)
                A(i,i+height(obj.max_idx))=1;end
            B = zeros(height(min_dot), height(min_dot));
            for i = 1:height(min_dot)-height(obj.min_idx)
                B(i,i+height(obj.min_idx))=1;end

            % 画图验证
            plot(d,obj.ma_data,'b-'); hold on;
            plot(d,obj.local_max,'ro','LineWidth',0.8); hold on;
            plot(d,obj.local_min,'go','LineWidth',0.8); hold on;
            plot(d,obj.ori_data,'k-'); hold on;
            plot(d,obj.ori_local_max,'ro','MarkerFaceColor','r'); hold on;
            plot(d,obj.ori_local_min,'go','MarkerFaceColor','g'); hold on;
            gplot(A, max_dot,'r-'); hold on;
            gplot(B, min_dot,'g-'); hold off;
            datetick('x','yyyy'); % datenum数据类型以年份形式展现在x轴上
            legend([obj.data_name,'平滑后'],'峰值（平滑后）','谷值（平滑后）', ...
                    obj.data_name,'峰值','谷值', ...
                    'Location','best', 'NumColumns', 2);  
            title(title_);
            fig = gcf;
            saveas(fig, title_, 'png')
        end
    end
end

