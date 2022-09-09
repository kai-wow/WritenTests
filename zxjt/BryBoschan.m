function [C,D] = BryBoschan(data_bench,data_candi)
% ����յ�ƥ���ʣ��ο�2021��2��10�գ���ʢ֤ȯ����ר�ⱨ�桰��۾�������ϵ��֮һ���й���������ָ������
% �������
% data_candi ��ѡָ��ԭ����
% data_bench ��׼ָ��ԭ����
% ���ز���
% C �������ݱ�ʾ��ƥ��յ��� ȱʧ�յ��� ����յ��� �����ݹյ��� �յ�ƥ���� ������ ƽ�����Ƚ��� ���ȱ�׼��
% D �������ݱ�ʾ����ѡָ��ԭ���� ��׼ָ��ԭ���� ��ѡָ��ƽ������ ��׼ָ��ƽ������ ...
% �ں�ѡָ��ԭ�����ϵĹյ� �ڻ�׼ָ��ԭ�����ϵĹյ� �ں�ѡָ��ƽ�������ϵĹյ� �ڻ�׼ָ��ƽ�������ϵĹյ�
% ע����ĸ���ͼ���ֶ�����ͼ��λ��
% ����[C,D] = BryBoschan(y,x)
%% ��������
pp = 16; % ���壨�ȣ��벨�壨�ȣ�֮�����
pt = 6; % �����벨��֮�����
N = 6; % ����һ����������[-N,N]֮������С��ֵΪ�ֲ�����С��ֵ
N_ad = 4; % ��������ƽ�����е�[-N_ad,N_ad]�Ĺյ������ԭ���У����ƽ�����У���
lead = 15; % �������ڻ�׼ָ��ǰlead��������Ѱƥ��ĺ�ѡָ���ϵĹյ�
lag = 8; % �������ڻ�׼ָ���lag��������Ѱƥ��ĺ�ѡָ���ϵĹյ�
name_candi = '��ѡָ��';
name_bench = '��׼ָ��';

%% ����1����ʼ�յ�ʶ��
data_candi1 = movmean(data_candi,12); % ���õ���12���ƶ�ƽ��ƽ������
[IndPeaks_candi1,IndTroughs_candi1] = Check(data_candi1,N);

data_bench1 = movmean(data_bench,12); % ���õ���12���ƶ�ƽ��ƽ������
[IndPeaks_bench1,IndTroughs_bench1] = Check(data_bench1,N);

% ����2���յ�ɸѡ
[IndPeaks_candi2,IndTroughs_candi2] = PointsClean(IndPeaks_candi1,IndTroughs_candi1,pt,pp,data_candi1);

[IndPeaks_bench2,IndTroughs_bench2] = PointsClean(IndPeaks_bench1,IndTroughs_bench1,pt,pp,data_bench1);

% ����3���յ����
% �����ķ�������ƽ�������йյ��[-N_ad,N_ad]���������ڣ�Ѱ��ԭ���е����С��ֵ
[IndPeaks_candi3_1, IndTroughs_candi3_1] = PointsAdjust(IndPeaks_candi2, IndTroughs_candi2, data_candi, N_ad);
[IndPeaks_candi3_2,IndTroughs_candi3_2] = PointsClean(IndPeaks_candi3_1,IndTroughs_candi3_1,pt,pp,data_candi);

[IndPeaks_bench3_1, IndTroughs_bench3_1] = PointsAdjust(IndPeaks_bench2, IndTroughs_bench2, data_bench, N_ad);
[IndPeaks_bench3_2,IndTroughs_bench3_2] = PointsClean(IndPeaks_bench3_1,IndTroughs_bench3_1,pt,pp,data_bench);

% ��ͼ
% ��ѡָ��
figure;
subplot(2,2,1);
MyPlot(IndPeaks_candi1, IndTroughs_candi1, data_candi1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_candi 'ƽ������Ǳ�ڹյ�ʶ��']);
legend({[name_candi 'ƽ������'],'����ֵ��','��Сֵ��'},'Orientation','horizontal','Location','North');
subplot(2,2,2);
MyPlot(IndPeaks_candi2, IndTroughs_candi2, data_candi1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_candi 'ƽ�����йյ�ɸѡ']);
legend({[name_candi 'ƽ������'],'����ֵ��','��Сֵ��'},'Orientation','horizontal','Location','North');
subplot(2,2,3);
MyPlot(IndPeaks_candi3_2, IndTroughs_candi3_2, data_candi,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_candi '�յ����']);
legend({[name_candi 'ԭ����'],'�����󼫴�ֵ��','������Сֵ��'},'Orientation','horizontal','Location','North');
subplot(2,2,4);
[h1, h2, h3] = MyPlot(IndPeaks_candi2, IndTroughs_candi2, data_candi1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255); % ƽ���������� �� ��� ����
[h4, h5, h6] = MyPlot(IndPeaks_candi3_2, IndTroughs_candi3_2, data_candi,[4 78 126]/255,[129 166 190]/255,[180 202 216]/255); % ������ԭ�������� �� ���� ǳ��
title([name_candi 'ƽ������ & ԭ����']);
legend([h1,h2,h3],[name_candi 'ƽ������'],'����ֵ��','��Сֵ��','Orientation','horizontal','Location','North');
ah = axes('position',get(gca,'position'),'visible','off');
legend(ah,[h4,h5,h6],[name_candi 'ԭ����'],'�����󼫴�ֵ��','������Сֵ��','Orientation','horizontal','Location','North');

% ��׼ָ��
figure;
subplot(2,2,1);
MyPlot(IndPeaks_bench1, IndTroughs_bench1,data_bench1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_bench 'ƽ������Ǳ�ڹյ�ʶ��']);
legend({[name_bench 'ƽ������'],'����ֵ��','��Сֵ��'},'Orientation','horizontal','Location','North');
subplot(2,2,2);
MyPlot(IndPeaks_bench2, IndTroughs_bench2,data_bench1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_bench 'ƽ�����йյ�ɸѡ']);
legend({[name_bench 'ƽ������'],'����ֵ��','��Сֵ��'},'Orientation','horizontal','Location','North');
subplot(2,2,3);
MyPlot(IndPeaks_bench3_2, IndTroughs_bench3_2, data_bench,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255);
title([name_bench '��׼ָ��յ����']);
legend({[name_bench 'ԭ����'],'�����󼫴�ֵ��','������Сֵ��'},'Orientation','horizontal','Location','North');
subplot(2,2,4);
[h1,h2,h3] = MyPlot(IndPeaks_bench2, IndTroughs_bench2,data_bench1,[255 0 0]/255,[255 128 128]/255,[255 178 178]/255); % ƽ���������� �� ��� ����
[h4,h5,h6] = MyPlot(IndPeaks_bench3_2, IndTroughs_bench3_2, data_bench,[4 78 126]/255,[129 166 190]/255,[180 202 216]/255); % ������ԭ�������� �� ���� ǳ��
title([name_bench 'ƽ������ & ԭ����']);
legend([h1,h2,h3],[name_bench 'ƽ������'],'����ֵ��','��Сֵ��','Orientation','horizontal','Location','North');
ah = axes('position',get(gca,'position'),'visible','off');
legend(ah,[h4,h5,h6],[name_bench 'ԭ����'],'�����󼫴�ֵ��','������Сֵ��','Orientation','horizontal','Location','North');

% ��ѡָ��&��׼ָ��
figure;
[h1,h2,h3] = MyPlot(IndPeaks_bench3_2, IndTroughs_bench3_2, data_bench,[255 0 0]/255,[255 128 128]/255,[129 166 190]/255); % ��׼ָ������ �� ���� ǳ��
[h4, ~, ~] = MyPlot(IndPeaks_candi3_2, IndTroughs_candi3_2, data_candi,[4 78 126]/255,[255 128 128]/255,[129 166 190]/255); % ��ѡָ������ �� ��� ����
title([name_candi '��' name_bench '�Ĺյ�ʶ����ƥ��']);
legend([h1,h4,h2,h3],name_bench,name_candi,'����ֵ��','��Сֵ��','Orientation','horizontal','Location','North');

% ����4���յ�ƥ��
[PiPei, QueShi, DuoYu, WuShu, LeadLag] = PointsMatch(IndPeaks_candi3_2, IndTroughs_candi3_2, data_candi, IndPeaks_bench3_2, IndTroughs_bench3_2, lead, lag);
ratio_pipei = length(PiPei)/(length(PiPei)+length(QueShi)+length(DuoYu));
ratio_duoyu = length(DuoYu)/(length(PiPei)+length(DuoYu));
fprintf('ƥ��յ��� = %d\n',length(PiPei));
fprintf('ȱʧ�յ��� = %d\n',length(QueShi));
fprintf('����յ��� = %d\n',length(DuoYu));
fprintf('�����ݹյ��� = %d\n',length(WuShu));
fprintf('�յ�ƥ���� = %.2f\n',ratio_pipei);
fprintf('������ = %.2f\n',ratio_duoyu);
fprintf('ƽ�����Ƚ��� = %.2f\n',mean(LeadLag));
fprintf('���ȱ�׼�� = %.2f\n',std(LeadLag));

% ���ز�������
% �ں�ѡָ��ԭ�����ϵĹյ�
mark_candi = zeros(size(data_candi,1),1);
mark_candi(IndPeaks_candi3_2) = 1;
mark_candi(IndTroughs_candi3_2) = -1;
% �ڻ�׼ָ��ԭ�����ϵĹյ�
mark_bench = zeros(size(data_bench,1),1);
mark_bench(IndPeaks_bench3_2) = 1;
mark_bench(IndTroughs_bench3_2) = -1;
% �ں�ѡָ��ƽ�������ϵĹյ�
mark_candi1 = zeros(size(data_candi1,1),1);
mark_candi1(IndPeaks_candi2) = 1;
mark_candi1(IndTroughs_candi2) = -1;
% �ڻ�׼ָ��ƽ�������ϵĹյ�
mark_bench1 = zeros(size(data_bench1,1),1);
mark_bench1(IndPeaks_bench2) = 1;
mark_bench1(IndTroughs_bench2) = -1;

C = [length(PiPei),length(QueShi),length(DuoYu),length(WuShu),ratio_pipei,ratio_duoyu,mean(LeadLag),std(LeadLag)];
D = [data_candi,data_bench,data_candi1,data_bench1,mark_candi,mark_bench,mark_candi1,mark_bench1];
end

%% ʶ��Ǳ�ڹյ�
% ���Ҽ���ֵ�ͼ�Сֵ
% ����data����������M*1������N��ǰ��N���µľֲ��յ㣩
% ���ش������Ĳ�������IndPeaks����������IndTroughs
function [IndPeaks,IndTroughs] = Check(data, N)
dataSize = size(data,1);
% r2017b���ϵİ汾����ʹ��
% IndPeaks = islocalmax(data, 'MinSeparation', 6);
% IndTroughs = islocalmin(data, 'MinSeparation', 6);

% ���ڱ��˰汾��֧�֣������Լ�д����ʵ��
% ��ǰ��1���µľֲ��յ㣬�����к�������ʵ��
if N == 1
    [~, IndPeaks] = findpeaks(data);
    [~, IndTroughs] = findpeaks(-data);
    % ��ǰ��N��N>1�����µľֲ��յ�
elseif N > 1
    % ��ѡ��ǰ��1���µľֲ��յ㣨�ӿ��ٶȣ�
    [~, IndPeaks0] = findpeaks(data);
    [~, IndTroughs0] = findpeaks(-data);
    m = size(IndPeaks0,1);
    n = size(IndTroughs0,1);
    % �ٸ���ǰ��N���½���ɸѡ
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
    error('�����������󣬷��أ�');
end
end

%% �յ�淶��ɸѡ
% ����IndPeaks��IndTroughs����������N*1��,data����������N*1��
% ���ش������Ĳ�������IndPeaks2����������IndTroughs2����ʽͬ��
function [IndPeaks2,IndTroughs2] = PointsClean(IndPeaks1,IndTroughs1,pt,pp,data)
IndPeaks2_1 = CheckCirclePeaks(IndPeaks1, pp, data); % ���ڼ���
IndTroughs2_1 = CheckCircleTroughs(IndTroughs1, pp, data); % ���ڼ���
[IndPeaks2_2, IndTroughs2_2] = CheckCircleHalf(IndPeaks2_1, IndTroughs2_1, pt); % �����ڼ���
[IndPeaks2, IndTroughs2] = CheckAlternate(IndPeaks2_2, IndTroughs2_2, data); % �����Լ���
end

% �޳����ݿ�ͷ�ͽ�β6�����ڵĹյ㣬��Լ�����ڷ��������ڣ���С��pp����
% ����IndPeaks1, pp, data��ppһ��ȡ16���£�
% ���ش������Ĳ�������IndPeaks2
% ɾ���յ�ķ��������ڲ���ɾ����ֵ��С�Ĺյ�
function IndPeaks2 = CheckCirclePeaks(IndPeaks1, pp, data)
m = size(IndPeaks1,1);
prePeak = 0;
IndPeaks2 = nan(m,1);
for i = 1:m
    % �޳����ݿ�ͷ�ͽ�β6�����ڵĹյ�
    if prePeak == 0 && IndPeaks1(i)  < 6 || size(data,1) - IndPeaks1(i) < 6
        continue;
    end
    % Լ�����ڷ��������ڣ���С��pp����
    if prePeak ~= 0 && IndPeaks1(i) - prePeak < pp
        % ����ֵ����С�ڻ����ǰ�ߣ��޳�����
        if data(IndPeaks1(i)) <= data(prePeak)
            continue;
            % ����ֵ���ߴ���ǰ�ߣ��޳�ǰ��
        else
            IndPeaks2(length(IndPeaks2(~isnan(IndPeaks2)))) = nan; % �޳�������������һ���յ�
        end
    end
    prePeak = IndPeaks1(i);
    IndPeaks2(length(IndPeaks2(~isnan(IndPeaks2)))+1) = prePeak; % �ڲ��������м��벨��յ�
end
IndPeaks2(isnan(IndPeaks2)) = []; % ��nanֵȥ��
end

% �޳����ݿ�ͷ�ͽ�β6�����ڵĹյ㣬��Լ�����ڹȼ�������ڣ���С��pp����
% ����IndTroughs1, pp, data��ppһ��ȡ16���£�
% ���ش������Ĳ�������IndTroughs2
% ɾ���յ�ķ��������ڲ���ɾ����ֵ�ϴ�Ĺյ�
function IndTroughs2 = CheckCircleTroughs(IndTroughs1, pp, data)
m = size(IndTroughs1,1);
preTrough = 0;
IndTroughs2 = nan(m,1);
for i = 1:m
    % �޳����ݿ�ͷ�ͽ�β6�����ڵĹյ�
    if preTrough == 0 && IndTroughs1(i) < 6 || size(data,1) - IndTroughs1(i) < 6
        continue;
    end
    % Լ�����ڹȼ�������ڣ���С��pp����
    if preTrough ~= 0 && IndTroughs1(i) - preTrough < pp
        % ����ֵ����С�ڻ����ǰ�ߣ��޳�����
        if data(IndTroughs1(i)) >= data(preTrough)
            continue;
            % ����ֵ���ߴ���ǰ�ߣ��޳�ǰ��
        else
            IndTroughs2(length(IndTroughs2(~isnan(IndTroughs2)))) = nan; % �޳�������������һ���յ�
        end
    end
    preTrough = IndTroughs1(i);
    IndTroughs2(length(IndTroughs2(~isnan(IndTroughs2)))+1) = preTrough; % �ڲ��������м��벨�ȹյ�
end
IndTroughs2(isnan(IndTroughs2)) = []; % ��nanֵȥ��
end

% Լ�����ڷ�ȼ���������ڣ���С��pt����
% ����IndPeaks1, IndTroughs1, pt��ptһ��ȡ6���£�
% ���ش������Ĳ�������IndPeaks2����������IndTroughs2
% ɾ���յ�ķ����ǲ��岨��֮��ɾ�����ֽ���Ĺյ�
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
% ɾ�������ϵĹյ�
IndPeaks2 = Delete(IndPeaks1);
IndTroughs2 = Delete(IndTroughs1);
end

% ������Ͳ��Ƚ���
% ����IndPeaks1, IndTroughs1, data
% ���ش������Ĳ�������IndPeaks2����������IndTroughs2
% ɾ���յ�ķ��������ڲ��壨�ȣ�ɾ����ֵ��С���󣩵Ĺյ�
function [IndPeaks2, IndTroughs2] = CheckAlternate(IndPeaks1, IndTroughs1, data)
dataSize = size(data,1);
mark = zeros(dataSize,1);
mark(IndPeaks1) = 1;
mark(IndTroughs1) = -1;
pre = 0; % �����һ���յ��λ��
for i = 1:dataSize
    if mark(i) == 0
        continue;
    else
        if pre == 0  % ����ǰû�йյ�ʱ
            pre = i;
        else
            if mark(i)+mark(pre) == 0 % ����ʱ�յ�����һ���յ�ʱ�����
                pre = i;
                % ����ʱ�յ�����һ���յ㲻�ǽ���ģ���������������ʱ����Ҫɾ����ֵ��С�Ĺյ�
            elseif mark(i) == 1
                if data(i) >= data(pre)
                    mark(pre) = 0;
                    pre = i;
                else
                    mark(i) = 0;
                end
                % ����ʱ�յ�����һ���յ㲻�ǽ���ģ���������������ʱ����Ҫɾ����ֵ�ϴ�Ĺյ�
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

% ɾ�������ϵĹյ�
% ����IndPoints1,�����ϵĹյ㶼��ǳ���0
% ���ش������Ĺյ�����IndPoints2
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

%% �յ����
% ����IndPeaks1, IndTroughs1, data, N_ad��data����Ҫ�����������У�
% ���ش������Ĳ�������IndPeaks2����������IndTroughs2
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

%% �յ�ƥ��
% ����IndPeaks_candi, IndTroughs_candi, data_candi, IndPeaks_bench, IndTroughs_bench, lead, lag
% ����PiPei, QueShi, DuoYu, WuShu����¼���������Ӧ�����е�λ�ã���ΪN*1��ʽ
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
LeadLag0 = nan(m_bench+n_bench,1); % ��Ԫ��Ϊ1�������Ǻ�ѡָ���ϵĵ����Ȼ�׼ָ���ϵĵ�1��
% �Ի�׼ָ��յ�ı�ǣ�PiPei0��ƥ�䣩��QueShi0��ȱʧ��,WuShu0�������ݣ�
% �Ժ�ѡָ��յ�ı�ǣ�PiPei_candi��ƥ�䣩��DuoYu�����ࣩ
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

% �Ժ�ѡָ��ı�ǣ�DuoYu0�����ࣩ
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
% ��nanֵȥ��
PiPei0(isnan(PiPei0)) = [];
% PiPei_candi(isnan(PiPei_candi)) = [];
QueShi0(isnan(QueShi0)) = [];
DuoYu0(isnan(DuoYu0)) = [];
WuShu0(isnan(WuShu0)) = [];
LeadLag0(isnan(LeadLag0)) = [];

% ����ǵĹյ���������
[PiPei,b] = sort(PiPei0,1);
QueShi = sort(QueShi0,1);
DuoYu = sort(DuoYu0,1);
WuShu = sort(WuShu0,1);
LeadLag = LeadLag0(b,:);
end

% ������arr�в���ֵΪelem��Ԫ��
% ����arr,elem
% ����IdElem,elem��arr�е�λ�ã����Ҳ�������IdElem = 0
function IdElem  = Search(arr,elem)
IdElem = 0;
for i = 1:length(arr)
    if arr(i) == elem
        IdElem = i;
    end
end
end

% ��ͼ
function [h1, h2, h3] = MyPlot(IndPeaks, IndTroughs, data , lineColor, peaksColor, troughsColor)
x=1:size(data,1);
hold on
h1 = plot(x,data,'-','Color',lineColor);
h2 = plot(x(IndPeaks),data(IndPeaks),'.','Color',peaksColor,'MarkerSize',15);
h3 = plot(x(IndTroughs),data(IndTroughs),'.','Color',troughsColor,'MarkerSize',15);
hold off
end
