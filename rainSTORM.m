% rainSTORM
% Copyright 2012. Refer to 00_license.txt for details.
% Written by Mark Deimund and Eric Rees
% This function calls the rainSTORM figure, allowing the rainSTORM GUI to 
% be operated. 

function varargout = rainSTORM(varargin)
% RAINSTORM M-file for rainSTORM.fig
%   RAINSTORM, by itself, creates a new RAINSTORM or raises the existing
%   singleton*.
%
%   H = RAINSTORM returns the handle to a new RAINSTORM or the handle to
%   the existing singleton*.
%
%   RAINSTORM('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in RAINSTORM.M with the given input arguments.
%
%   RAINSTORM('Property','Value',...) creates a new RAINSTORM or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before rainSTORM_OpeningFcn gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to rainSTORM_OpeningFcn via varargin.
%
%   *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%   instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rainSTORM

% Last Modified by GUIDE v2.5 27-Apr-2012 15:14:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rainSTORM_OpeningFcn, ...
                   'gui_OutputFcn',  @rainSTORM_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before rainSTORM is made visible.
function rainSTORM_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rainSTORM (see VARARGIN)

% Choose default command line output for rainSTORM
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rainSTORM wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end
end

% --- Outputs from this function are returned to the command line.
function varargout = rainSTORM_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


%%%%%%%%%%%%% START OF CALLBACK FUNCTIONS FOR BUTTONS %%%%%%%%%%%%%%%%%%%

%Allows user to browse for the directory containing the images to analyse
%and uses this directory in subsequent routines.
% --- Executes on button press in browse_image.
function browse_image_Callback(hObject, ~, handles)
% hObject    handle to browse_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global FileName PathName

[FileName,PathName] = uigetfile({'*.tif';'*.raw'});

set(handles.pathway,'String',fullfile(PathName,FileName));

guidata(hObject, handles);
end




%Run main rainSTORM program upon button press of Process Images.
% --- Executes on button press in process_images.
function process_images_Callback(~, ~, handles)
% PRESSING 'PROCESS IMAGES' RUNS THE LOCALISATION ALGORITHM ON A FILE
% hObject    handle to process_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 1. Get the input file name and directory 
% 2. Get localisation algorithm arguments.
% 3. Pass these arguments to the appropriate 'MAIN' localisation algorithm
% And write to MATLAB base workspace as appropriate

% 1. 
[pathstr, name, ext] = fileparts(get(handles.pathway,'String'));

filename = fullfile(pathstr,name);

% 2. 
% initX0 = get(handles.initX0,'String'); % ('0' = centre of maximum pixel)
initX0  = 0; % Sensible choice. Don't need to set this via GUI!
initSig = get(handles.initSig,'String'); % Initial guess of P.S.F. sigma
%              % Initial guess of Gaussian height is best done from data!
rad = get(handles.rad,'String');  % Radius for fitting. Square LN(-rad:rad)
tol = get(handles.tol,'String');  % Tolerance for least squares fit (0.10)
Thresh = get(handles.Thresh,'String'); % Ignore (SKIP) non-bright maxima
maxIts = get(handles.maxIts,'String');  % Number of fitting iterations 
pixelWidth = get(handles.pixelWidth,'String'); % Pixel width on sample (nm)

% Convert typed GUI string inputs to numbers
initSig   = str2num(initSig); 
rad       = str2num(rad);
tol       = str2num(tol);     % An OK Quality Control parameter, not great
Thresh    = str2num(Thresh);  % This is for Counts in a 3x3 region
maxIts    = str2num(maxIts);  % Fitting may be halted earlier by failure
pixelWidth= str2num(pixelWidth); 

% Note flags to indicate this is fresh localisation data, 
% and hence no post-processing has been applied yet 
% Obviously, SAVE/LOAD or manual edits could easily confuse these states
assignin('base','flagHistsPlotted',0); % New data: no hisotgrams yet
assignin('base','flagBoxed', 0);       % New data: none tracked in box
assignin('base','flagCalculatedJH',0); % New data: no JH visualisation yet
assignin('base','flagMarkAnchor',0);   % New data: no fiducial anchor yet
assignin('base','flagSaved',0);        % New data: no images saved
assignin('base','flagSavedSupResData', 0); % New data: results not saved
assignin('base','flagSelectedAll', 0); % New data: nno boxedPosits this way
assignin('base','flagUndrifted', 0);   % New data: no drift corrected yet
assignin('base','pixelWidth', pixelWidth ); % Essential!
assignin('base','ext', ext);

%Check algorithm type for use in calculations.
str = get(handles.algorithm, 'String');
val = get(handles.algorithm,'Value');
% Set current data to the selected data set. (MAD52)
% Case(string) proofs against text re-ordering in GUI, but seems complex.
switch str{val};
case 'Least-Squares Gaussian Halt3' 
    alg=1;
case 'Least-Squares Gaussian Thorough' 
    alg=2;
case 'Centre of Mass' 
    alg=3;
end

%Check whether a scalebar is desired or not.
if (get(handles.scalebar,'Value') == get(handles.scalebar,'Max'))
   % Checkbox is checked-add scalebar
   flagSB=true;   
else
   % Checkbox is not checked-do not add scalebar
   flagSB=false;
end
% ASSIGN SCALEBAR CHOICE TO BASE WORKSPACE - need for preview AND review
assignin('base','flagSB',flagSB); % Needed by rainSTORM_display

%Check whether sumimage is desired or not.
if (get(handles.sumimage,'Value') == get(handles.sumimage,'Max'))
   % Checkbox is checked-add sum image
   flagSum=true;  
else
   % Checkbox is not checked-do not add sum image
   flagSum=false;  
end


% 3.
% Select a function based on parallel computing options and file type.
% A) If the input data is "TIF", 
%    It can be processed in series by "rainSTORM_main_GUI_both"
%    Or in parallel by "rainSTORM_main_GUI_tif"
%
% B) "RAW" data recorded as per NPL software, with "XML" metadata
%    Can be read in series by "rainSTORM_main_GUI_both"
%    Or in parallel by Alex Knight's "rainSTORM_main_GUI_RAW_par"
%
% Check for the presence of the MATLAB Parallel toolbox: 
 % Check if Parallel Computing Toolbox is available.
 % parCompTool = license('test','Distrib_Computing_Toolbox');
 v = ver;
 parCompTool = 0;
 
 for k=1:length(v)
   if strfind(v(k).Name, 'Parallel Computing Toolbox')
     parCompTool = str2num((sprintf( v(k).Version)));
   end
 end
    
 parCompTool = 0; % UNCOMMENT THIS TO DISABLE PARALLEL PROCESSING


switch ext;
case '.tif' 

    if parCompTool > 0 
        % If so, check whether matlabpool is running.
        workers = matlabpool('size');

        if workers > 0
            % If so, run the parallel routine.
            rainSTORM_main_GUI_tif(filename,initX0,initSig,rad,tol,Thresh,maxIts,flagSB,alg,flagSum,pixelWidth);
        
        elseif workers == 0
            % If not, start the workers.
            matlabpool open;
            % Then, run the parallel routine.
            rainSTORM_main_GUI_tif(filename,initX0,initSig,rad,tol,Thresh,maxIts,flagSB,alg,flagSum,pixelWidth);
        end
        
    elseif parCompTool == 0
        % If not, use serial routine.
        rainSTORM_main_GUI_both(filename,ext,initX0,initSig,rad,tol,Thresh,maxIts,flagSB,alg,flagSum,pixelWidth);
    end
    
case '.raw' 
   %Run the main rainSTORM program.
       if parCompTool > 0 
        % If so, check whether matlabpool is running.
        workers = matlabpool('size');

        if workers > 0
            % If so, run the parallel routine.
            rainSTORM_main_GUI_RAW_par(filename,initX0,initSig,rad,tol,Thresh,maxIts,flagSB,alg,flagSum,pixelWidth);
        
        elseif workers == 0
            % If not, start the workers.
            matlabpool open;
            % Then, run the parallel routine.
            rainSTORM_main_GUI_RAW_par(filename,initX0,initSig,rad,tol,Thresh,maxIts,flagSB,alg,flagSum,pixelWidth);
        end
        
    elseif parCompTool == 0
        % If not, use serial routine.
        rainSTORM_main_GUI_both(filename,ext,initX0,initSig,rad,tol,Thresh,maxIts,flagSB,alg,flagSum,pixelWidth);
    end
    
    
end

%Allow Reviewer to be opened and parameters to be saved to Excel.
set(handles.reviewer,'Enable','on');

end




%Opens Reviewer window to allow for further data analysis.
% --- Executes on button press in reviewer.
function reviewer_Callback(~, ~, handles)
% hObject    handle to reviewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% EJR - I have removed the use of global variables from _main and _reviewer
% global SupResPosits SupResParams myFrame flagSB

%Check whether scalebar is desired or not.
if (get(handles.scalebar,'Value') == get(handles.scalebar,'Max'))
   % Checkbox is checked-add scalebar
   flagSB=true;
else
   % Checkbox is not checked-do not add scalebar
   flagSB=false;
end

SupResPosits = evalin('base','SupResPosits');
SupResParams = evalin('base','SupResParams');
myFrame = evalin('base','myFrame');

%Run the Reviewer m-file.
Reviewer(SupResPosits,SupResParams,myFrame)

end



%%%%%%%%%%%%%%%% START OF UNUSED FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%

function pathway_Callback(~, ~, ~)
% hObject    handle to pathway (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pathway as text
%        str2double(get(hObject,'String')) returns contents of pathway as a double
end

% --- Executes during object creation, after setting all properties.
function pathway_CreateFcn(hObject, ~, ~)
% hObject    handle to pathway (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end





% --- Executes on selection change in algorithm.
function algorithm_Callback(~, ~, ~)
% hObject    handle to algorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns algorithm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from algorithm
end

% --- Executes during object creation, after setting all properties.
function algorithm_CreateFcn(hObject, ~, ~)
% hObject    handle to algorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end




function initSig_Callback(~, ~, ~)
% hObject    handle to initSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initSig as text
%        str2double(get(hObject,'String')) returns contents of initSig as a double
end

% --- Executes during object creation, after setting all properties.
function initSig_CreateFcn(hObject, ~, ~)
% hObject    handle to initSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




function tol_Callback(~, ~, ~)
% hObject    handle to tol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tol as text
%        str2double(get(hObject,'String')) returns contents of tol as a double
end

% --- Executes during object creation, after setting all properties.
function tol_CreateFcn(hObject, ~, ~)
% hObject    handle to tol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




function rad_Callback(~, ~, ~)
% hObject    handle to rad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rad as text
%        str2double(get(hObject,'String')) returns contents of rad as a double
end

% --- Executes during object creation, after setting all properties.
function rad_CreateFcn(hObject, ~, ~)
% hObject    handle to rad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




function maxIts_Callback(~, ~, ~)
% hObject    handle to maxIts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxIts as text
%        str2double(get(hObject,'String')) returns contents of maxIts as a double
end

% --- Executes during object creation, after setting all properties.
function maxIts_CreateFcn(hObject, ~, ~)
% hObject    handle to maxIts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




function Thresh_Callback(~, ~, ~)
% hObject    handle to Thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Thresh as text
%        str2double(get(hObject,'String')) returns contents of Thresh as a double
end

% --- Executes during object creation, after setting all properties.
function Thresh_CreateFcn(hObject, ~, ~)
% hObject    handle to Thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




function pathway_editText_Callback(~, ~, ~)
% hObject    handle to pathway (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pathway as text
%        str2double(get(hObject,'String')) returns contents of pathway as a double
end

% --- Executes during object creation, after setting all properties.
function pathway_editText_CreateFcn(hObject, ~, ~)
% hObject    handle to pathway (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



%Adds or removes scale bar on processed images.
% --- Executes on button press in scalebar.
function scalebar_Callback(~, ~, ~)
% hObject    handle to scalebar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of scalebar
end



% --- Executes on button press in sumimage.
function sumimage_Callback(~, ~, ~)
% hObject    handle to sumimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sumimage
end



function pixelWidth_Callback(hObject, eventdata, handles)
% hObject    handle to pixelWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixelWidth as text
%        str2double(get(hObject,'String')) returns contents of pixelWidth as a double
end

% --- Executes during object creation, after setting all properties.
function pixelWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
