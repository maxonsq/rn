% AORI STCM line cut
% 2020 Koge H.
clear all;
close all;
%--Note------------
% data2=cut用に用意するファイルの中身はこんな形式にまとめる。
% ほしいところのstartとendの時間を使う。
% 2020-08-11 07:29:35,2020-08-11 09:06:33
% 2020-08-11 09:15:53,2020-08-11 12:33:43
% 2020-08-11 12:38:03,2020-08-12 06:02:35
% 2020-08-12 06:05:37,2020-08-12 14:44:38
% 2020-08-12 14:48:43,2020-08-12 17:02:09
% gravityに適用するのは、faまでやった後じゃないとエトベス補正が変になるので、これの後にできたファイルで適用すること。
% STCMの全データをcatしてからreadすること。
% 最初にダミー変数を作らずに1つめの計算をしてしまって、あとからi=2以降を追記する方式に変更
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
        
        %STCMkitに渡すためのデータ整理
        dataR(:,1)=dataR(:,1)-2000;
        format long
        
    disp('--3.2 export')
        %あとはこのi=1ごとにファイルを保存させる。ファイル名はms.stcmが拡張子で、data2の3行目をファイル名にする
        %num2str(table2array(data2(i,3)))
        rootname = 'GB21-1_line'; % ファイル名に使用する文字列
        extension = '.ms.stcm'; % 拡張子
        outfile = [rootname, num2str(data2.linename(i)), extension]; % ファイル名の作成
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