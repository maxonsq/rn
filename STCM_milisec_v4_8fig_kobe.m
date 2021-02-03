% AORI STCM calc milisecond and resampling
% 2020 Koge H.
% 02_AORIstcm_cat.sh->STCM_milisec_v3.m->stc2fld->fld2anm->STCM_filtering(including
% remove duplicate point),cut lines-> anm2anmd
clear all;
close all;
%--Note------------
% AORIのSTCMはミリ秒の収録がないので後から補完してやる必要があるので、それをやる。
% v3 STCMkit用に出力を変更。緯度経度の小数点を省略し、heading,roll,pitchを100倍にする。 
% v4 stc, stcmどちらも出力するように改善。->この機能はstcm2stcに実装して、本プログラムからは消去。
% v4 8の字用のチューニングをした。といってもコマンドを出てくるようにしただけなので、実際はフツーのファイルにも使える。
% 神戸大のは8hzが変換するときに既に入ってるので、ミリ節句の補完というよりはプロトンとのデータ補完のほうに注力した。
%----------
proton=1; %プロトンのデータがある場合、ここを1とする。
%-----------
%% 0. open data
[infile, inpath] = uigetfile('*_stcm.dat', 'Open input file:');
disp('--0. import')
if (inpath == 0) 
        %break;
else
    infullpath=[inpath infile];
    data1=load(infullpath);
    display(infile);
end

% step=2;
% data=data(1+step:end,:);

%% 1.ミリ秒を補完する。

timeA = datetime(data1(:,1:6));
format longG
timeB = posixtime(timeA); %グループ化変数のためにunixtimeをセット


%% 1.5 プロトンのデータを後から入れ込む
if (proton == 0)
    disp('skip --1.5  supply proton')
else
    [infile, inpath] = uigetfile('*dat.matd', 'Open input file:');
    disp('--0. import proton')
    if (inpath == 0) 
            %break;
    else
        infullpath=[inpath infile];
        dataP=load(infullpath);
        display(infile);
    end
    %
    desiredFs = 8;
    desiredS = 1/desiredFs;
    %
    timePA = datetime(dataP(:,1:6));
    timePB = posixtime(timePA);
    propro =timeseries(dataP(:,7),timePB,'Name','data');
    ttx = fix(min(timePB))+1:desiredS:max(timePB);
    propro_r =resample(propro,ttx);
    tttx=transpose(ttx); 
    
    ttttx=datetime(ttx,'ConvertFrom','posixtime');
    clear dataP
    [dataP(:,1),dataP(:,2),dataP(:,3)]= ymd(ttttx);
    [dataP(:,4),dataP(:,5),dataP(:,6)] = hms(ttttx);
    dataP(:,7)=propro_r.data;
    %
    dataP_j(:,1)=tttx;
    dataP_j(:,2)=propro_r.data;
    T1 = array2table(dataP_j,'VariableNames',{'time','proton'});
end

%% 2.resampling
disp('--2. resampling at 8Hz')
disp('--for kobe data, this part was for innerjoin two data')

timeA = datetime(data1(:,1:6)); %ミリ秒付きのデータに再定義
steps=0; %stcmとプロトンのデータにはずれがある。2秒とか。
timeB = posixtime(timeA)+steps; %timeseriesでcellとして扱うために変換,timeAはミリ秒付きに再定義されたもの

%innerjoinのための準備
    data1_j(:,1)=timeB; %dummy
    data1_j(:,2:12)=data1(:,7:17);
    T2=array2table(data1_j,'VariableNames',{'time','lat','lon','depth','protonF','grav','hx','hy','hz','heading','roll','pitch'});
    format long
%innerjoin
T = innerjoin(T2,T1);
%整理
TT=table2array(T);
TT(:,5)=TT(:,13);
TT(:,13)=[];

%STCMkitに渡すためのデータ整理
data2=zeros(size(TT,1),17);
tt=datetime(TT(:,1),'ConvertFrom','posixtime');
    [data2(:,1),data2(:,2),data2(:,3)]= ymd(tt);
    [data2(:,4),data2(:,5),data2(:,6)] = hms(tt);
    data2(:,7:17)=TT(:,2:12);
    %
    data2(:,1)=data2(:,1)-2000;
    data2(:,7:8)=data2(:,7:8)*10000000;
    data2(:,15:17)=data2(:,15:17)*100;
    format long

    for i=7:17
        data2(:,i)=round(data2(:,i),0);
    end


%% plot and check
figure(1) %tracks and per 1 hour dots
hold on;
plot3(data2(:,8),data2(:,7),tt)
plot3(data2(1,8),data2(1,7),tt(1),'o')
title(['Track at ',num2str(infile)])
hold off
datacursormode
%読み取る。
display('--3. digitize to cut time-start time-end')
%
figure(2)
subplot(5,1,1)
plot(data2(:,12))
subplot(5,1,2)
plot(data2(:,13))
subplot(5,1,3)
plot(data2(:,14))
subplot(5,1,4)
plot(data2(:,15))
subplot(5,1,5)
plot(data2(:,16))

%% end. save file STCM
width=20;
[outfile, outpath] = uiputfile('*.ms.stcm', 'Save as:');
outfullpath=[outpath outfile];
fid=fopen(outfullpath,'w');
% %data=data1(1+width:size(data2(:,1)),1:17);
%fprintf(fid,'%02d %02d %02d %02d %02d %2.4f %09d %10.0f %4.0f %04d %04d %.0f %.0f %.0f\n',data2');%stable ver 
fprintf(fid,'%02d %02d %02d %02d %02d %2.4f %09d %10.0f %4.0f %04d %04d %.0f %.0f %.0f %.0f %.0f %.0f\n',data2');%test 
fclose(fid);

%% suggest the next step
la=data2(1,7)/10000000;
lo=data2(1,8)/10000000;
k1=fix(la);
k2=fix((la-fix(la))*60);
k3=fix(lo);
k4=fix((lo-fix(lo))*60);
k5 = ['calc_coeff_prep ',outfile,' -D',num2str(data2(1,1)),'/',num2str(data2(1,2)),'/',num2str(data2(1,3)),' -P',num2str(k1),':',num2str(k2),'/', num2str(k3),':',num2str(k4),' -S >temp.dat'];
disp(k5)
k6 = ['calc_coeff temp.dat > 8figure_coeff.dat'];
disp(k6)
disp('next stcm2stc.m')
