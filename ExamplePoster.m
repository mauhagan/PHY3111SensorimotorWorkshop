% here is the matlab code for our example poster

% NOTE: this is just an example of how to make two figures. you can modify
% this to include your subjects and your analyses.

%% first let's load up the team data
subjects = {'RR'}; % edit this cell array to include the members of your group!
subject_colors = {'#ca0020'}; % HEX values, could also be RGB triplets

for i = 1:numel(subjects) % loop through each subject
    subject = subjects{i};
    filename = [subject '.utimages.export.mat'];
    load(filename)
    
    teamdata.(subject) = data.(subject);
    clear data
end

%% Figure 1 - example trial

subject = subjects{1}; % use subject 1 for an example trial

width = teamdata.(subject).screeninfo.dov_width; % width of the screen in degrees of visual angle

pixelsperdeg = teamdata.(subject).screeninfo.xpixels/width;
pixelxzero = teamdata.(subject).screeninfo.xpixels/2; % find the center of the screen x coordinate
pixelyzero = teamdata.(subject).screeninfo.ypixels/2; % find the center of the screen y coordinate

trialnumber = 100;

% convert x and y traces from dov into pixels
xtrace = teamdata.(subject).eyetrace.X(trialnumber,:) .* pixelsperdeg + pixelxzero;
ytrace = teamdata.(subject).eyetrace.Y(trialnumber,:) .* -pixelsperdeg + pixelyzero;

% lets find the first fixation
firstfix_x = teamdata.(subject).fixations(trialnumber).fixXY(1,1) .* pixelsperdeg + pixelxzero;
firstfix_y = teamdata.(subject).fixations(trialnumber).fixXY(2,1) .* -pixelsperdeg + pixelyzero;

% all the other fixations
fix_x = teamdata.(subject).fixations(trialnumber).fixXY(1,2:end) .* pixelsperdeg + pixelxzero;
fix_y = teamdata.(subject).fixations(trialnumber).fixXY(2,2:end) .* -pixelsperdeg + pixelyzero;

% now get the image
trind = teamdata.(subject).image_index(trialnumber); % find the id number of the image on trial 100
img = squeeze(teamdata.(subject).images(trind,:,:));

% now we can plot it all!
figure('Units','inches','Position',[1 1 4 6]);
imagesc(img)
colormap('gray')
hold on;

plot(xtrace,ytrace,'-', 'Color', subject_colors{1},'LineWidth',2) % you can also specifiy color with hex values!
plot(firstfix_x, firstfix_y,'v','Color',subject_colors{1},'MarkerFaceColor',[1 1 1],'MarkerSize',8)
plot(fix_x, fix_y,'o','Color',subject_colors{1},'MarkerFaceColor',[1 1 1],'MarkerSize',8)

% legends (matlab has built in fucntions, or you can write your own!)
plot(pixelxzero, teamdata.(subject).screeninfo.ypixels+100,'v','Color','k','MarkerFaceColor',[1 1 1],'MarkerSize',8)
text(pixelxzero + 80, teamdata.(subject).screeninfo.ypixels+100,'First fixation','FontName','Helvetica', 'FontAngle','italic','FontSize',20,'HorizontalAlignment','left');
plot(pixelxzero, teamdata.(subject).screeninfo.ypixels+300,'o','Color','k','MarkerFaceColor',[1 1 1],'MarkerSize',8)
text(pixelxzero + 80, teamdata.(subject).screeninfo.ypixels+400,{'Subsequent' 'fixations'},'FontName','Helvetica', 'FontAngle','italic','FontSize',20,'HorizontalAlignment','left');

% its always a good idea to plot a scale bar
scalebar = pixelsperdeg*10;
line([1 scalebar], [teamdata.(subject).screeninfo.ypixels+100 teamdata.(subject).screeninfo.ypixels+100],'Color',[0 0 0],'Linewidth',1)
text(mean([1 scalebar]), teamdata.(subject).screeninfo.ypixels+250,'10 dov','FontName','Helvetica', 'FontAngle','italic','FontSize',20,'HorizontalAlignment','center');

axis equal
axis off

print([subject '_exampleTrial.png'],'-dpng');

%% Firgure 2 - example fixation density

imgstr =  'cps201410017283'; % change this to look at different images
% NOTE: because images are shown randomly, its possilbe not every subject
% saw every image. We'll optimise for which images are best for your group
% in the next section.

for i = 1:numel(subjects) % loop through each subject
    subject = subjects{i};
    
    % we'll need these from week 5:
    width = teamdata.(subject).screeninfo.dov_width; % width of the screen in degrees of visual angle
    pixelsperdeg = teamdata.(subject).screeninfo.xpixels/width;
    pixelxzero = teamdata.(subject).screeninfo.xpixels/2; % find the center of the screen x coordinate
    pixelyzero = teamdata.(subject).screeninfo.ypixels/2; % find the center of the screen y coordinate

    % find all the trials that image was shown:
    trind = find(strcmp(teamdata.(subject).imgkey,imgstr));
    
    % let's first convert the x and y traces on these trials to pixels, and
    % then plot them over the image:
    xtrace = teamdata.(subject).eyetrace.X(trind,:) .* pixelsperdeg + pixelxzero;
    ytrace = teamdata.(subject).eyetrace.Y(trind,:) .* -pixelsperdeg + pixelyzero;
    
    % get the image
    imgind = teamdata.(subject).image_index(trind(1));
    img = squeeze(teamdata.(subject).images(imgind,:,:));


    % now let's convert those x and y positions into a 2D histogram
    figure('Units','inches','Position',[1 1 4.5 4]);
    % plot image
    ax1 = axes;
    imagesc(img)
    axis equal 
    
    % plot histogram
    ax2 = axes;
    
    binsize = 40; % size of bins in pixels
    hdata.(subject) = histogram2(xtrace,ytrace,'DisplayStyle','tile','XBinEdges',0:binsize:teamdata.(subject).screeninfo.xpixels,'YBinEdges',0:binsize:teamdata.(subject).screeninfo.ypixels,'Normalization','probability','EdgeColor','none','FaceAlpha',0.7)
    axis equal 
    
    linkaxes([ax1,ax2])
    
    ax1.Visible = 'off';
    ax2.Visible = 'off';
    
    ax2.YDir = 'reverse';

    colormap(ax1,'gray')
    colormap(ax2,'parula')

    clim = [0 round(max(hdata.(subject).Values(:)),2)];

    set([ax1,ax2],'Position',[0.05 .11 .685 .815]);
    cb2 = colorbar(ax2,'Position',[.77 .3 .03 .45]);
    cb2.Ticks = clim;
    cb2.Limits = clim;
    % cb2.Label.String = {'Fixation' 'density'};
    cb2.FontName = 'Helvetica';
    cb2.FontSize = 20;
    text(teamdata.(subject).screeninfo.xpixels+400,pixelyzero,{'Fixation' 'density'},'FontSize',20,'FontName','Helvetica','Rotation',270,'HorizontalAlignment','center')

    print([subject '_exampleImageFixDensity.png'],'-dpng');

end