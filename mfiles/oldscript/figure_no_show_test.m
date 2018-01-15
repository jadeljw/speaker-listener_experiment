for i=1:5
    x=0:0.1*pi:2*pi;
    y=sin(x);
    figure('visible','off')
    h=plot(x,y);hold on; plot(1:2:100);
    filename=['test' num2str(i) '.jpg'];
    saveas(h,filename)
    close(gcf)
end