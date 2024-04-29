% export data for phy 3111 students

group = 'Group 7/';

% dataraw = ['/Users/mhagan/Library/CloudStorage/GoogleDrive-maureen.hagan@monash.edu/My Drive/PHY3111 workshop/Data/' group];
% dataexport = ['/Users/mhagan/Library/CloudStorage/GoogleDrive-maureen.hagan@monash.edu/My Drive/PHY3111 workshop/DataforPHY311/' group];

dataraw = ['/Users/mhagan/Documents/PHY3111Data/' group];
dataexport = ['/Users/mhagan/Documents/PHY3111Data/export/' group];

if ~isfolder(dataexport)
    mkdir(dataexport);
end

% get all the subjects for the group:
folders = dir(dataraw);

subjects = cell(1,numel(folders));
for isubject = 1:numel(folders)
    subjects{isubject} = folders(isubject).name;
end

subjectind = ~strcmp(subjects,'.') & ~strcmp(subjects,'..') & ~strcmp(subjects,'.DS_Store');

subjects = subjects(subjectind);

for isubject = 1:numel(subjects)
    
    %% step 1: find all the files for a given student ID
    subject = subjects{isubject};
    
    disp(['now working on ' subject ' ...'])
    
    % datapath = '/Users/mhagan/Documents/PHY3111Data/';
    paradigm = 'utimages';
    
    Files = dir([dataraw filesep subject filesep subject '.' paradigm '*' '.mat']);
    
    filenames = cell(1,numel(Files));
    for ifile = 1:numel(Files)
        filenames{ifile} = Files(ifile).name;
    end
    
    %% step 2: load the data with mdbase
    tic
    d = marmodata.mdbase(filenames,'path', [dataraw filesep subject],'loadArgs',{'eye',true});
    toc
    %% step 3: use export function in analysis file
    % things we want: saccade data, fixation data, x, y eye traces, images in
    % pixels
    
    dd = freeviewing.analysis.utimages(d);
    % filename = ['/Users/mhagan/Documents/PHY3111Data/export/' subject '.utimages.export.mat'];
    % dd.exportforPHY3111('filename',filename)
    
    [x,y] = dd.getXYEyetrace;
    fixdata = dd.getFixations;
    saccdata = dd.getSaccades;
    % img = dd.get
    
    rec = d.meta.image.filename('time',Inf).data;
    
    width = d.meta.image.width('time',Inf).data; width = width(1);
    height = d.meta.image.height('time',Inf).data; height = height(1);
    screen = d.meta.cic.screen('time',Inf).data; screen = screen{1};
    
    db = imgdb.geisler('/Users/mhagan/Documents/MATLAB/UT Natural Images/');
    
    
    imgkey = cell(1,numel(rec));
    
    for itr = 1:numel(rec)
        imgkey{itr} = rec{itr}.key;
        
    end
    
    
    [uni,uni_ind,img_ind] = unique(imgkey);
    
    % just save one copy of each image, and the indexes to figure out how they
    % map onto trials
    imgs = nan(numel(uni),1080,1920);
    tic
    for itr = 1:numel(uni)
        
        r = db.info(uni{itr});
        img = freeviewing.analysis.getImg(r,width,height,screen);
        imgs(itr,:,:) = nthroot(img,2.2);
        
    end
    toc
    % figure
    % histogram(idx,unique(idx))
    
    data.(subject).eyetrace.X = x;
    data.(subject).eyetrace.Y = y;
    data.(subject).saccades = saccdata;
    data.(subject).fixations = fixdata;
    data.(subject).imgkey = imgkey;
    data.(subject).images = imgs;
    data.(subject).image_index = img_ind;
    data.(subject).screeninfo = screen;
    data.(subject).screeninfo.dov_width = width;
    data.(subject).screeninfo.dov_height = height;
    data.(subject).screeninfo.xpixels = 1920;
    data.(subject).screeninfo.ypixes = 1080;
    
    save([dataexport subject '.utimages.export.mat'], 'data','-v7.3');
    disp([subject ' is saved!'])
end