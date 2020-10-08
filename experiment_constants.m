function C = experiment_constants(subName)

%   DESCRIPTION
%   ===================================================================
%   Config file with channel mapping with any additional metadata from
%   experiment
%
%   INPUTS
%   ===================================================================
%   subject : string specifying which ferret to run

switch subName
    
    case 'Bacchus'
        C.ROOT_PATH = 'R:\data_raw\cat\2017\Bacchus-20171212';
        C.EXPT_DATE = '12-12-17';
        
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Utah-Array-4x8';
        C.BIPOLAR_CUFF_MAPPING = {...
            [0 1]   'Pelv'
            [2 3]   'Pudendal'
            [4 5]   'Sens Branch'
            [6 7]   'Deep Peri'
            [8 9]   'Caud Rect'};
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [10 11] 'Sciatic Proximal'
            [12 13] 'Sciatic Distal' };
        C.LAYOUT_MAP = reshape([2:2:32 1:2:31], 4, 8);
        
    case 'Cerberus'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Cerberus-20180110';
        C.EXPT_DATE = '01-10-18';
        
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Utah-Array-4x8';
        C.BIPOLAR_CUFF_MAPPING = {...
            [0 1]     'Pelv'
            [2 3]     'Pelv 2'
            [8 9]     'Pudendal'
            [10 11]   'Sens Branch'
            [12 13]   'Dorsal penile'
            [14 15]   'Caud Rect'
            [16 17]   'Deep Peri'
            [18 19]   'Rectal EMG'};
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [4 5] 'Sciatic Proximal'
            [6 7] 'Sciatic Distal' };
        C.LAYOUT_MAP = reshape([2:2:32 1:2:31], 4, 8);
        
    case 'Daedalus'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Daedalus-20180206';
        C.EXPT_DATE = '02-06-18';
        
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Utah-Array-4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1]   'Pelv'
            [2 3]   'Caud Rect'
            [4 5]   'Sens Branch'
            [6 7]   'Pudendal'
            [8 9]   'Deep Peri'
            [14 15] 'Rectal EMG'};
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [10 11] 'Sciatic Proximal'
            [12 13] 'Sciatic Distal' };
        C.LAYOUT_MAP = reshape([2:2:32 1:2:31], 4, 8);
        
    case 'Hercules'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Hercules-20190402';
        C.EXPT_DATE = '04-02-19';
        
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Utah-Array-4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1]   'Pelv'
            [2 3]   'Pudendal'
            [4 5]   'Sens Branch'
            [6 7]   'Deep Peri'
            [8 9]   'Caud Rect'
            [10 11] 'Sciatic Proximal'};
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13] 'Sciatic Distal' };
        C.LAYOUT_MAP = reshape([2:2:32 1:2:31], 4, 8);
        
    case 'Janus'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Janus-20190924';
        C.EXPT_DATE = '09-26-19';
        
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Utah-Array-4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1]   'Pelv'
            [2 3]   'Pudendal'
            [4 5]   'Sens Branch'
            [6 7]   'Deep Peri'
            [8 9]   'Caud Rect'
            [10 11] 'Sciatic Proximal'
            [14 15] 'EUS EMG'
            [16 17] 'Glut EMG'
            [18 19] 'Rectal EMG'
            [20 21] 'Pelvic floor EMG'};
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13] 'Sciatic Distal' };
        C.LAYOUT_MAP = reshape([2:2:32 1:2:31], 4, 8);
        
    case 'Kronos'
        C.ROOT_PATH = 'R:\data_raw\cat\2020\Kronos-20200128'; %TODO fix
        C.EXPT_DATE = '01-28-20';
        
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Utah-Array-4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1]   'Pelv'
            [2 3]   'Pudendal'
            [4 5]   'Sens Branch'
            [6 7]   'Deep Peri'
            [8 9]   'Caud Rect'
            [10 11] 'Sciatic Proximal'
            [14 15] 'EUS EMG'
            [16 17] 'Rect EMG'
            [18 19] 'Glut EMG'
            [20 21] 'Pelvic floor EMG'};
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13] 'Sciatic Distal' };
        C.LAYOUT_MAP = reshape([2:2:32 1:2:31], 4, 8);
        
    case 'AlexanderKeith'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\AlexanderKeith-20180227';
        C.EXPT_DATE = '02-27-18';
        
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Utah-Array-4x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [2  1  4  3;
            6  5  8  7;
            10 9  12 11;
            14 13 16 15];
        
    case 'BigRock'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\BigRock-20180328';
        C.EXPT_DATE = '03-28-18';
        
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Utah-Array-4x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Deep Per'
            [4 5] 'Sens Branch'
            [6 7] 'Pudendal'
            [8 9] 'Caud Rect'
            [12 13]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [10 11]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1  2  3  4;
            5  6  7  8;
            9  10 11 12;
            13 14 15 16];
        
    case 'Caravel'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Caravel-20180501';
        C.EXPT_DATE = '05-01-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Utah-Array-4x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1  2  3  4;
            5  6  7  8;
            9  10 11 12;
            13 14 15 16];
        
    case 'Dageraad'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Daagerad-20180712';
        C.EXPT_DATE = '07-12-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 4x4'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Caud Rect'
            [8 9] 'Deep Per'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1  2  3  4;
            5  6  7  8;
            9  10 11 12;
            13 14 15 16];
        
    case 'Albus'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Albus-20180724';
        C.EXPT_DATE = '07-24-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Caud Rect'
            [8 9] 'Deep Per'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
        
    case 'Bellatrix'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Bellatrix-20180902';
        C.EXPT_DATE = '09-02-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Caud Rect'
            [8 9] 'Deep Per'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
        
    case 'Elora'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Elora-20180802';
        C.EXPT_DATE = '08-02-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Caud Rect'
            [8 9] 'Deep Per'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'Fuggles'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Fuggles-20180814'; 
        C.EXPT_DATE = '08-14-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'Grindelwald'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Grindelwald-20190326'; 
        C.EXPT_DATE = '03-26-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            [14 15] 'Rectal EMG'
            [16 17] 'Glut EMG'
            [18 19] 'Pelvic floor EMG'
            [30 31] 'Hypogastric'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'GreyMatter'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\GreyMatter-20181113'; 
        C.EXPT_DATE = '11-13-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Caud Rect'
            [8 9] 'Deep Per'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'Erebus'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Erebus-20180506';
        C.EXPT_DATE = '05-06-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Blackrock Utah 4x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = reshape([2:2:32 1:2:31], 4, 8);
        
    
        
    case 'Fulgora'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Fulgora-20180918';
        C.EXPT_DATE = '09-18-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Blackrock Utah 4x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Caud Rect'
            [8 9] 'Deep Per'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = reshape([2:2:32 1:2:31], 4, 8);
        
    case 'Ganymede'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Ganymede-20181002';
        C.EXPT_DATE = '10-02-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Blackrock Utah 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Caud Rect'
            [8 9] 'Deep Per'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = reshape([2:2:32 1:2:31], 4, 8);
        
    case 'Crookshanks'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Crookshanks-20181016';
        C.EXPT_DATE = '10-16-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Caud Rect'
            [8 9] 'Deep Per'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
        
     case 'Jorkins'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Jorkins-20191008';
        C.EXPT_DATE = '10-08-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Perineal'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            [14 15] 'EUS EMG'
            [16 17] 'Glut EMG'
            [18 19] 'Rect EMG'
            [20 21] 'Pelvic floor EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
            
    case 'Longbottom'
        C.ROOT_PATH = 'R:\data_raw\cat\2020\Longbottom-20200204';
        C.EXPT_DATE = '02-04-20';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Perineal'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            [14 15] 'EUS EMG'
            [16 17] 'Rect EMG'
            [18 19] 'Glut EMG'
            [20 21] 'Pelvic floor EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
        
            
    case 'Malfoy'
        C.ROOT_PATH = 'R:\data_raw\cat\2020\Malfoy-20200225';
        C.EXPT_DATE = '02-25-20';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Perineal'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            [14 15] 'EUS EMG'
            [18 19] 'Rect EMG'
            [20 21] 'Glut EMG'
            [22 23] 'Pelvic floor EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
    
    case 'Neville'
        C.ROOT_PATH = 'R:\data_raw\cat\2020\Neville-20200728';
        C.EXPT_DATE = '07-28-20';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Perineal'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            [14 15] 'EUS EMG'
            [16 17] 'Rect EMG'
            [18 19] 'Pelvic floor EMG'
            [20 21] 'Glut EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
        
    case 'Dudley'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\Dudley-20181120';
        C.EXPT_DATE = '11-20-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
        
    case 'Errol'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Errol-20190110';
        C.EXPT_DATE = '01-10-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11] 'Sci Prox'
            [16 17] 'Rectal EMG'
            [18 19] 'Pelvic floor EMG'
            [20 21] 'Glut EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
        
    case 'Filch'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Filch-20190116';
        C.EXPT_DATE = '01-16-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11] 'Sci Prox'
            [14 15] 'EUS EMG'
            [16 17] 'Rectal EMG'
            [18 19] 'Lateral Rectal EMG'
            [20 21] 'Pelvic floor EMG'
            [22 23] 'Glut EMG'
            [25 26] 'TA EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
        
    case 'Harry'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Harry-20190430';
        C.EXPT_DATE = '04-30-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11] 'Sci Prox'
            [16 17] 'Glut EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
        
    case 'Ignotus'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Ignotus-20190717';
        C.EXPT_DATE = '07-17-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Ripple Epidural 4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11] 'Sci Prox'
            [14 15] 'EUS EMG'
            [16 17] 'Glut EMG'
            [18 19] 'EAS EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = flipud([26:2:32; 25:2:31; 18:2:24; 17:2:23; 10:2:16; 9:2:15; 2:2:8; 1:2:7]);
        
    case 'HalfPint'
        C.ROOT_PATH = 'R:\data_raw\cat\2018\HalfPint-20181211';
        C.EXPT_DATE = '12-11-18';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv Ipsi'
            [2 3] 'Pelv Contra'
            [4 5] 'Pudendal'
            [6 7] 'Sens Branch'
            [8 9] 'Deep Per'
            [10 11] 'Caud Rect'
            [12 13]  'Sci Prox'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [14 15]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'Oland'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Oland-20191119';
        C.EXPT_DATE = '11-19-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [6 7] 'Sens Branch'
            [8 9] 'Deep Per'
            [10 11] 'Caud Rect'
            [12 13]  'Sci Prox'
            [16 17] 'EUS EMG'
            [18 19] 'Glut EMG'
            [20 21] 'EAS EMG'
            [22 23] 'Pelvic floor EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [14 15]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'Indie'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Indie-20190129';
        C.EXPT_DATE = '01-29-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            [14 15] 'EUS EMG'
            [16 17] 'Rectal EMG'
            [18 19] 'Perineal EMG'
            [20 21] 'Levator Ani EMG'
            [22 23] 'TA EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'Jasper'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Jasper-20190306';
        C.EXPT_DATE = '03-06-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11]  'Sci Prox'
            [14 15] 'EUS EMG'
            [16 17] 'Rectal EMG'
            [18 19] 'Perineal EMG'
            [20 21] 'Gluteal EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'Kingston'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Kingston-20190416';
        C.EXPT_DATE = '04-16-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11] 'Sci Prox'
            [14 15] 'Rectal EMG'
            [16 17] 'Glut EMG' 
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
    case 'Labatt'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Labatt-20190528';
        C.EXPT_DATE = '05-28-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [6 7] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11] 'Sci Prox'
            [14 15] 'EUS EMG'
            [16 17] 'Glut EMG'
            [18 19] 'Rectal EMG'
            [20 21] 'Pelvic floor EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'Molson'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Molson-20190702';
        C.EXPT_DATE = '07-02-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [20 21] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11] 'Sci Prox'
            [14 15] 'EUS EMG'
            [16 17] 'Rectal EMG'
            [18 19] 'Glut EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'Nelson'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Nelson-20190910';
        C.EXPT_DATE = '09-10-19';
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'MicroLeads Epidural 3x8'; %this was actually epidural,
        %but it's fine to use the predefined Utah layout
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1] 'Pelv'
            [2 3] 'Pudendal'
            [4 5] 'Sens Branch'
            [20 21] 'Deep Per'
            [8 9] 'Caud Rect'
            [10 11] 'Sci Prox'
            [14 15] 'EUS EMG'
            [16 17] 'Glut EMG'
            [18 19] 'Rectal EMG'
            };
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13]  'Sciatic Distal'
            };
        C.LAYOUT_MAP = [1:8;
            9:16;
            17:24];
        
    case 'Iris'
        C.ROOT_PATH = 'R:\data_raw\cat\2019\Iris-20190625';
        C.EXPT_DATE = '06-25-19';
        
        C.REC_HEADSTAGE = 'surfs2';
        C.ELECTRODE_TYPE = 'Utah-Array-4x8';
        C.BIPOLAR_CUFF_MAPPING = { ...
            [0 1]   'Pelv'
            [2 3]   'Pudendal'
            [4 5]   'Sens Branch'
            [6 7]   'Deep Peri'
            [8 9]   'Caud Rect'
            [10 11] 'Sciatic Proximal'
            [14 15] 'Glut EMG'
            [16 17] 'Rectal EMG'};
        
        C.TRIPOLAR_CUFF_MAPPING = {...
            [12 13] 'Sciatic Distal' };
        C.LAYOUT_MAP = reshape([2:2:32 1:2:31], 4, 8);
end

C.REC_FS              = 30e3;
C.PRE_WINDOW = 1; % ms; sets the amount of time prior to stimulation in window
C.RMS_THRESHOLD_MULTIPLIER = 4; %how high above threshold must something be to register as a response
C.MIN_RESPONSE_LATENCY     = 1e-3;
C.MIN_RESPONSE_EMG         = 2e-3; %longer response blanking time for EMG
C.NCUFF_FILTER_ARGS = {2, 300, 'high'}; %Args are input to Butterworth, then applied with filtfilt

end