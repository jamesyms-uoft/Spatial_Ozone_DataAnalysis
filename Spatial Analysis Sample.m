% % Jane Liu, 2015 Oct 08
% Read 2 TOST files and take difference
% Input:
%   lev1, lat1, lon1,....lon_n: -180-180
%   lev1, lat2, lon1,....lon_n

%function a_decade_diff_text_plot_1h_SL_SM(yyyy_str1,yyyy_str2,lev);
clear;
yyyy_str='2000';
%season_str='DJF';

lev=5; %for plotting a level

num_lev=26;

dlon=5;
dlat=5;
num_lon=360/dlon; %72
num_lat=180/dlat; %36

num_pix=num_lon;      
num_lin=num_lat*num_lev; %36*26

in1=zeros(num_lin,num_pix);
n=zeros(num_lin,num_pix);

%path_name1=strcat('L:\copy1_data_code\2015_o3_clim_topo_correct\Stratosphere_troposphere Climatology\OZONE_DATA\DECADAL DATA\SEA_LEVEL\2000s\JJA')
%o3_woudc2000s-DJF_sl_trop_strat_zboth_mean_smooth.asc 
%o3_woudc2000s-DJF_sl_trop_strat_zboth_mean_smooth.asc
infilename1=strcat('o3_woudc',yyyy_str,'_sl_trop_strat_zboth_mean.asc')

in1_temp=load(infilename1);

in1=in1_temp(:,3:end);  

% plot a layer  
z_str=num2str(lev-0.5);

% For 5 by 5
dlon=5;
lon_o=-180;
lon_n=180-dlon;
lon_in=lon_o:dlon:lon_n;

dlat=5;
lat_o=-90;
lat_n=90-dlat;
lat_in=lat_o:dlat:lat_n;

pix_in=360/dlon; %72
lin_in=180/dlat; %36

o3_1h=zeros(lin_in,pix_in);

% No white around the edge
lon_outmin=-175;
lon_outmax=175;
lat_outmin=60;
lat_outmax=85;

% key
row_o=lin_in*(lev-1)+1;
row_n=row_o+lin_in-1;

% key: o3 -180-0-180
o3_1h=in1(row_o:row_n,1:end);

[lon_in, lat_in]=meshgrid(lon_in,lat_in);

figure;
colormap(jet(20));
o3_1h(o3_1h==0)=nan;
pcolor(lon_in,lat_in, o3_1h);
%contourf(lon_in,lat_in, o3,20);
set(gca,'Fontsize',12);
xlim([lon_outmin lon_outmax]);
ylim([lat_outmin lat_outmax]);
% for N, max=30
% for STD
% 5:100; 10:500; 15:2000; 20:5000;25:8000
if (lev<=2)
    caxis ([0 80])
elseif (lev<=5)
    caxis ([0 100]); %level 5 
elseif (lev<=9)
    caxis ([0 130]);
elseif (lev==23)
    caxis ([0 6000]); %level 23  
else
    caxis ([2000 7000]);  %level 25 
end;

%pause;
shading flat; % Removes edge color
%shading interp; % Removes edge color

xlabel('Longitude (Deg.)','Fontsize',12);
ylabel('Latitude (Deg.)','Fontsize',12);

title(['Ozone (ppbv), ', yyyy_str, ', ', z_str,' km, SL'],'Fontsize',14);
%text(-55,65, title_label,'FontSize',8);

% colorbar
hcb=colorbar('h');
%set(get(hcb,'XLabel'),'String','Ozone Mixing Ratio (ppbv)');
set(hcb,'FontSize',10);
%set(hcb,'Position',[0.2 0.03 0.60 0.02]);
%text(-55,65, title_label,'FontSize',8);
  
% Overlay with coast line
hold on;
borders('countries','nomap','black')
%axis tight
%plot(long,lat,'-k','LineWidth', 1.5);

outputfile=strcat('a');
saveas(gcf,outputfile,'png');
saveas(gcf,outputfile,'pdf');   

