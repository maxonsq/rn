% AORI STCM line cut
% 2020 Koge H.
clear all;
close all;
%--Note------------
% data2=cut�p�ɗp�ӂ���t�@�C���̒��g�͂���Ȍ`���ɂ܂Ƃ߂�B
% �ق����Ƃ����start��end�̎��Ԃ��g���B
% 2020-08-11 07:29:35,2020-08-11 09:06:33
% 2020-08-11 09:15:53,2020-08-11 12:33:43
% 2020-08-11 12:38:03,2020-08-12 06:02:35
% 2020-08-12 06:05:37,2020-08-12 14:44:38
% 2020-08-12 14:48:43,2020-08-12 17:02:09
% gravity�ɓK�p����̂́Afa�܂ł�����ザ��Ȃ��ƃG�g�x�X�␳���ςɂȂ�̂ŁA����̌�ɂł����t�@�C���œK�p���邱�ƁB
% STCM�̑S�f�[�^��cat���Ă���read���邱�ƁB
% �ŏ��Ƀ_�~�[�ϐ�����炸��1�߂̌v�Z�����Ă��܂��āA���Ƃ���i=2�ȍ~��ǋL��������ɕύX
%----------

%% 0. open data
[infile, inpath] = uigetfile('*.stcm', 'Open input file:');
disp('--0. import')
if (inpath == 0) 
        %break;
else
    infullpath=[inpath infile];
    data1=load(infullpath);
    display(infile);
end

data1(:,1)=data1(:,1)+2000;
    timeA = datetime(data1(:,1:6));
    format longG
    timeB = posixtime(timeA);
    TA=table(timeB,data1(:,7),data1(:,8),data1(:,9),data1(:,10),data1(:,11),data1(:,12),data1(:,13),data1(:,14),data1(:,15),data1(:,16),data1(:,17));

disp('--2. import cut_line data')
    data2 = readtable('D:\GB21-1\30STCM\20_recycle_0325convert\cutlines_irutokodake2.txt','Delimiter',',','ReadVariableNames',true,'Format','%{yyyy-MM-dd HH:mm:ss}D %{yyyy-MM-dd HH:mm:ss}D %.1f');
    data2.Properties.VariableNames{1} = 'tstart';
    data2.Properties.VariableNames{2} = 'tend';
    data2.Properties.VariableNames{3} = 'linename';

disp('--3.innerjoin')
    for i=1:size(data2,1);
        startT=posixtime(data2.tstart(i));
        endT=posixtime(data2.tend(i));
            desiredFs = 8;
            desiredS = 1/desiredFs;
            tx = startT:desiredS:endT;
        a=table(transpose(tx));
        a.Properties.VariableNames{1} = 'time';
        T=innerjoin(TA,a);

    disp('--3.1 modify to stcm')
        tt=datetime(T.time,'ConvertFrom','posixtime');
         [dataR(:,1),dataR(:,2),dataR(:,3)]= ymd(tt);
         [dataR(:,4),dataR(:,5),dataR(:,6)] = hms(tt);

        nangi=table2array(T);
        dataR(:,7:17)= nangi(:,2:12);
        
        %STCMkit�ɓn�����߂̃f�[�^����
        dataR(:,1)=dataR(:,1)-2000;
        format long
        
    disp('--3.2 export')
        %���Ƃ͂���i=1���ƂɃt�@�C����ۑ�������B�t�@�C������ms.stcm���g���q�ŁAdata2��3�s�ڂ��t�@�C�����ɂ���
        %num2str(table2array(data2(i,3)))
        rootname = 'GB21-1_line'; % �t�@�C�����Ɏg�p���镶����
        extension = '.ms.stcm'; % �g���q
        outfile = [rootname, num2str(data2.linename(i)), extension]; % �t�@�C�����̍쐬
        outfullpath=[inpath outfile];
        fid=fopen(outfullpath,'w');
        % %data=data1(1+width:size(data2(:,1)),1:17);
        %%fprintf(fid,'%02d %02d %02d %02d %02d %2.4f %09d %10.0f %4.0f %04d %04d %.0f %.0f %.0f\n',data2');%stable ver 
        %fprintf(fid,'%02d %02d %02d %02d %02d %2.4f %09d %10.0f %4.0f %04d %04d %.0f %.0f %.0f %.0f %.0f %.0f\n',data2');%test 
        fprintf(fid,'%02d %02d %02d %02d %02d %2.4f %09d %10.0f %4.0f %04d %04d %.0f %.0f %.0f %.0f %.0f %.0f\n',dataR');%test 
        fclose(fid);
        disp(outfullpath)

        clear tt
        clear dataR
        clear T
    end
disp('--Fin')