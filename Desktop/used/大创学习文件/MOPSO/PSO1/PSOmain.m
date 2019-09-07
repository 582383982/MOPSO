% ��׼����Ⱥ(ʵ������),����Сֵ
% author zhaoyuqiang
clear all ;
close all ;
clc ;
N = 100 ; %����Ⱥ��ģ
D = 10 ; % ����ά��
T = 100 ; %����������
Xmax = 20 ;
Xmin = -20 ;
C1 = 1.5 ; %��ѧϰ����1
C2 = 1.5 ; %��ѧϰ����2
W = 0.8 ; %������Ȩ��
Vmax = 10 ; %���������ٶ�
Vmin = -10 ; %����С�����ٶ�
popx = rand(N,D)*(Xmax-Xmin)+Xmin ; % ��ʼ������Ⱥ��λ��(����λ����һ��Dά����)
popv = rand(N,D)*(Vmax-Vmin)+Vmin ; % ��ʼ������Ⱥ���ٶ�(�����ٶ���һ��Dά������) 
% ��ʼ��ÿ����ʷ��������
pBest = popx ; 
pBestValue = func_fitness(pBest) ; 
%��ʼ��ȫ����ʷ��������
[gBestValue,index] = max(func_fitness(popx)) ;
gBest = popx(index,:) ;
for t=1:T
    for i=1:N
        % ���¸����λ�ú��ٶ�
        popv(i,:) = W*popv(i,:)+C1*rand*(pBest(i,:)-popx(i,:))+C2*rand*(gBest-popx(i,:)) ;
        popx(i,:) = popx(i,:)+popv(i,:) ;
        % �߽紦������������Χ��ȡ�÷�Χ��ֵ
        index = find(popv(i,:)>Vmax | popv(i,:)<Vmin);
        popv(i,index) = rand*(Vmax-Vmin)+Vmin ; %#ok<*FNDSB>
        index = find(popx(i,:)>Xmax | popx(i,:)<Xmin);
        popx(i,index) = rand*(Xmax-Xmin)+Xmin ;
        % ����������ʷ����
        if func_fitness(popx(i,:))>pBestValue(i)    
           pBest(i,:) = popx(i,:) ;
           pBestValue(i) = func_fitness(popx(i,:));
        elseif pBestValue(i) > gBestValue
            gBest = pBest(i,:) ;
            gBestValue = pBestValue(i) ;
        end
    end
    % ÿ�����Ž��Ӧ��Ŀ�꺯��ֵ
    tBest(t) = func_objValue(gBest); %#ok<*SAGROW>
end
figure
plot(tBest);
xlabel('��������') ;
ylabel('��Ӧ��ֵ') ;
title('��Ӧ�Ƚ�������') ;