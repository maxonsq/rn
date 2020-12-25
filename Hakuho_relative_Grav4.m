% Hakuho, merge navigation to gravity data.
% 2020 Koge H.
%%--計算手順--------
% 00 00Hakuho_grav_split.sh ファイルの整理
% 01 位置情報がないのでSTCMのところからall_stcm.datに対して
%    cat all_stcm.dat |awk -F" " '{print $1,$2,$3,$4,$5,$6,$7,$8,$9}'|awk 'NR%8==0' |sed -e 's/ /,/g'>tnav3.csv
%    を実行しtnav3.csvを作成
% 02 Hakuho_relative_Grav4.m で位置情報をくっつける
% 03 gabs.mで絶対重力に変換
% 04 fa.mでフリーエアに変換
% 05 sbg.mで単純ブーゲーに変換
% 06 Hakuho_gravity_cut.mでsbgのデータからノイズを除去、移動平均1分にした後、回頭中の乱れたデータをカットする
% 07 Surface.shでグリッド化する

clear;close;
data1=csvread('result.csv');
data2=csvread('tnav3.csv');

disp('--1. import time and gravity')
timeA = datetime(data1(:,1:6));
    format longG
    TA=table(timeA,data1(:,7),data1(:,8),'VariableNames',{'time','grab','st'});
disp('--2. import time and navigation')
    timeB = datetime(data2(:,1:6));
    format longG
    for i=7:9   
        data2(:,i)=filloutliers(data2(:,i),'linear','movmedian',20);
    end
    TB=table(timeB,data2(:,7),data2(:,8),data2(:,9),'VariableNames',{'time','lat','lon','depth'});

%interpolateする
    disp('--2.1 resampling at 1Hz')
        desiredFs = 1;
        desiredS = 1/desiredFs;
        timeB = posixtime(timeB); %timeseriesでcellとして扱うために変換,timeAはミリ秒付きに再定義されたもの
        tx = fix(min(timeB))+1:desiredS:max(timeB);
            lat = timeseries(TB.lat,timeB,'Name','data');
                lat_r = resample(lat,tx);
            lon = timeseries(TB.lon,timeB,'Name','data');
                lon_r = resample(lon,tx);        
            depth = timeseries(TB.depth,timeB,'Name','data');
                depth_r = resample(lat,tx);
        tt=datetime(transpose(tx),'ConvertFrom','posixtime');
            [data3(:,1),data3(:,2),data3(:,3)]= ymd(tt);
            [data3(:,4),data3(:,5),data3(:,6)] = hms(tt);
        TD=table(tt,lat_r.data,lon_r.data,depth_r.data);
        TD.Properties.VariableNames = {'time','lat','lon','depth'};
disp('--3. merge inner join on time')
    TC=innerjoin(TA,TD);
disp('--4. save file as result.rgrv')
    data=zeros(size(TC.time,1),10); 
    [data(:,1),data(:,2),data(:,3)]= ymd(TC.time);
    [data(:,4),data(:,5),data(:,6)] = hms(TC.time);
    data(:,7)=TC.lon;
    data(:,8)=TC.lat;
    data(:,9)=TC.grab;
    data(:,10)=TC.depth;

% output file
%[outfile, outpath] = uiputfile('*.rgrv', 'Save as:');
%outfullpath=[outpath outfile];
%fid=fopen(outfullpath,'w'); 

fid=fopen('result.rgrv','w');
fprintf(fid,'%4d %02d %02d %02d %02d %02d %8.5f %8.5f %8.1f %7.1f\n',data');
fclose(fid);

%
figure(1)
    ax1 = subplot(2,1,1)
        plot(TC.time,TC.grab)
        title('innerjoined with navigation')
    ax2 = subplot(2,1,2)
        plot(timeA,data1(:,7))
        title('original')
    linkaxes([ax1,ax2],'xy')

figure(2)
   plot3(TC.lon,TC.lat,TC.time);

figure(3)
%   c = linspace(min(TC.grab),max(TC.grab),length(TC.grab));
   c = linspace(3580,3600,length(TC.grab));
   scatter(TC.lon,TC.lat,TC.grab,c,'filled')
   
   
   
figure(4)
    TC1 = TC(27410:28250,1:6);
    TC2 = TC(28322:29198,1:6);
    TC3 = TC(29206:30074,1:6);
    axx1 = subplot(3,1,1);plot(TC1.lon,TC1.grab);
    axx2 = subplot(3,1,2);plot(TC2.lon,TC2.grab);
    axx3 = subplot(3,1,3);plot(TC3.lon,TC3.grab);
    linkaxes([axx1,axx2,axx3],'x')

%うまくいったぞしめしめ
%あとはgabsに使えるように出力するだけ
writetable(TC);