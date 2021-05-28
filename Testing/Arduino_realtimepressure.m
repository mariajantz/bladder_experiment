
clc
close all
clear all
a = arduino('COM11');
interv = 12000;
init_time = 1;
x=0;
figure(1)
set(gcf,'color','w')

subplot 511
while (init_time >= 1 && init_time <= 2400)   %(init_time<interv)
  b=readVoltage(a,'A0');
%reading voltages from pin A0 , reads voltages not adc value ,
%voltages = (ADC*5)/1024
  x=[x,b];
  plot(x,'-r','LineWidth',2)
  title('Bladder Pressure (mmHg)','FontSize',12,'FontWeight','bold','Color','k')
  xlabel(' Time (minutes)','FontSize',12,'FontWeight','bold','Color','k');  
  ylabel ('Pressure (mmHg)','FontSize',12,'FontWeight','bold','Color','k')
  legend('Bladder Pressure')
  grid ON
  grid on 
    ylim([-0.5 2])
    set(gca,'ytickLabel',[0 20 40])
  xticks([1 300 600 900 1200 1500 1800 2100 2400])
  set(gca,'xtickLabel',[0 .5 1 1.5 2 2.5 3 3.5 4])
     init_time=init_time+1
  xlim([1 2400])

  drawnow 
end
init_time=init_time+1
clear x
x=0;
subplot 512
while (init_time >= 2401 && init_time <= 4800)
  b=readVoltage(a,'A0');
  x=[x,b];
  plot(x,'-r','LineWidth',2)
  title('Bladder Pressure (mmHg)','FontSize',12,'FontWeight','bold','Color','k')
  xlabel(' Time (minutes)','FontSize',12,'FontWeight','bold','Color','k');
  ylabel ('Pressure (mmHg)','FontSize',12,'FontWeight','bold','Color','k')
  legend('Bladder Pressure')
  grid ON
  grid on 
    ylim([-0.5 2])
     xlim([1 2400])
    set(gca,'ytickLabel',[0 20 40])
  xticks([1 300 600 900 1200 1500 1800 2100 2400])
  set(gca,'xtickLabel',[0 .5 1 1.5 2 2.5 3 3.5 4])
  

  init_time=init_time+1;
 xlim([1 2400])
   drawnow 
end
clear x
x=0;
subplot 513
while (init_time >= 4801 && init_time <= 7200)
  b=readVoltage(a,'A0');
  x=[x,b];
  plot(x,'-r','LineWidth',2)

  title('Bladder Pressure (mmHg)','FontSize',12,'FontWeight','bold','Color','k')
  xlabel(' Time (minutes)','FontSize',12,'FontWeight','bold','Color','k');
  ylabel ('Pressure (mmHg)','FontSize',12,'FontWeight','bold','Color','k')
  legend('Bladder Pressure')
  grid ON
  grid on 
   
 ylim([-0.5 2])
  xlim([1 2400])
    set(gca,'ytickLabel',[0 20 40])
  xticks([1 300 600 900 1200 1500 1800 2100 2400])
  set(gca,'xtickLabel',[0 .5 1 1.5 2 2.5 3 3.5 4])
  init_time=init_time+1;
  
   drawnow 
end
clear x
x=0;
subplot 514
while (init_time >= 7201 && init_time <= 9600)
  b=readVoltage(a,'A0');
  x=[x,b];
  plot(x,'-r','LineWidth',2)

  title('Bladder Pressure (mmHg)','FontSize',12,'FontWeight','bold','Color','k')
  xlabel(' Time (minutes)','FontSize',12,'FontWeight','bold','Color','k');
  ylabel ('Pressure (mmHg)','FontSize',12,'FontWeight','bold','Color','k')
  legend('Bladder Pressure')
  grid ON
  grid on 
  ylim([-0.5 2])
   xlim([1 2400])
    set(gca,'ytickLabel',[0 20 40])
  xticks([1 300 600 900 1200 1500 1800 2100 2400])
  set(gca,'xtickLabel',[0 .5 1 1.5 2 2.5 3 3.5 4])

  init_time=init_time+1;
 
   drawnow 
end
clear x
x=0;
subplot 515
while (init_time >= 9601 && init_time <= 12000)
  b=readVoltage(a,'A0');
   x=[x,b];
  plot(x,'-r','LineWidth',2)

  title('Bladder Pressure (mmHg)','FontSize',12,'FontWeight','bold','Color','k')
  xlabel(' Time (minutes)','FontSize',12,'FontWeight','bold','Color','k');
  ylabel ('Pressure (mmHg)','FontSize',12,'FontWeight','bold','Color','k')
  legend('Bladder Pressure')
  grid ON
  grid on 
   ylim([-0.5 2])
    xlim([1 2400])
    set(gca,'ytickLabel',[0 20 40])
  xticks([1 300 600 900 1200 1500 1800 2100 2400])
  set(gca,'xtickLabel',[0 .5 1 1.5 2 2.5 3 3.5 4])

  init_time=init_time+1;

   drawnow 
end


%the above loop will run for 200 values, if you want to run it for more time change the interv value  
  
