function [ result ] = func_fitness( pop )
%OBJFUNCTION ����Ӧ�ȣ���Сֵ
%   ���Ż�Ŀ�꺯��
% x:����Ⱥ���߸���
% result : ��Ⱥ��Ӧ��
objValue =  func_objValue(pop);
result  = 4001 - objValue ;
end

