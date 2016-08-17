% Written by Mark Deimund
% Copyright 2012. Refer to 00_license.txt for details.
% This function calls the Reviewer figure, allowing the rainSTORM Reviewer 
% GUI to be operated. 

function varargout = Reviewer(varargin)
% REVIEWER M-file for Reviewer.fig
%    REVIEWER, by itself, creates a new REVIEWER or raises the existing
%    singleton*.
%
%    H = REVIEWER returns the handle to a new REVIEWER or the handle to
%    the existing singleton*.
%
%    REVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%    function named CALLBACK in REVIEWER.M with the given input arguments.
%
%    REVIEWER('Property','Value',...) creates a new REVIEWER or raises the
%    existing singleton*.  Starting from the left, property value pairs are
%    applied to the GUI before Reviewer_OpeningFcn gets called.  An
%    unrecognized property name or invalid value makes property application
%    stop.  All inputs are passed to Reviewer_OpeningFcn via varargin.
%
%    *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%    instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Reviewer

% Last Modified by GUIDE v2.5 23-May-2013 19:37:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Reviewer_OpeningFcn, ...
                   'gui_OutputFcn',  @Reviewer_OutputFcn, ...
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
end

% --- Executes just before Reviewer is made visible.
function Reviewer_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Reviewer (see VARARGIN)

% Choose default command line output for Reviewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Reviewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = Reviewer_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end





%%%%%%%%%%%%% START OF CALLBACK FUNCTIONS FOR BUTTONS %%%%%%%%%%%%%%%%%%%

%Runs rainSTORM_reviewer script.
% --- Executes on button press in reviewer.
function reviewer_Callback(~, ~, handles)
% hObject    handle to reviewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Retrieve new variables from the GUI
newThresh = get(handles.newThresh,'String');
newTol = get(handles.newTol,'String');
newSig = get(handles.newSig,'String');
newPrecision = get(handles.newPrecision,'String');
newFrames = get(handles.newFrames,'String');

% Convert variables from strings to numbers (handles "inf")
newThresh    = str2num(newThresh);
newTol       = str2num(newTol);
newSig       = str2num(newSig);
newPrecision = str2num(newPrecision);
newFrames    = str2num(newFrames);

% Collect new variables for the base workspace
countsPerPhoton = get(handles.countsPerPhoton,'String');
reconstructionScaleFactor= get(handles.reconstructionScaleFactor,'String');

countsPerPhoton = str2num(countsPerPhoton);
reconstructionScaleFactor = str2num(reconstructionScaleFactor);

assignin('base','countsPerPhoton',countsPerPhoton);
assignin('base','reconstructionScaleFactor',reconstructionScaleFactor);

SupResParams = evalin('base','SupResParams');
SupResPosits = evalin('base','SupResPosits');
myFrame = evalin('base','myFrame');
flagSB = evalin('base','flagSB');

% Call the rainSTORM_reviewer script. 
rainSTORM_reviewer(newThresh,newTol,newSig,newPrecision,SupResParams, ... 
    SupResPosits,myFrame,flagSB,newFrames);

end


%Produces histograms for the image data.
% --- Executes on button press in viewhist.
function viewhist_Callback(~, ~, ~)
% hObject    handle to viewhist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Call global variable. No! - Evalin('base',XXX) -EJR
% global SupResParams
flagHistsPlotted = evalin('base', 'flagHistsPlotted');

  try
    flagHistsPlotted = rainSTORM_histograms(flagHistsPlotted);
  catch myError
    warning('rainSTORM:histogramsFail', 'rainSTORM_histograms failed')
    assignin('base','myError', myError);
  end

assignin('base', 'flagHistsPlotted', flagHistsPlotted);

end


% --- Executes on button press in colormap_update.
function colormap_update_Callback(~, ~, handles)
% hObject    handle to colormap_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Check desired colormap and set colors vector as needed.
str = get(handles.colormap_select, 'String');
val = get(handles.colormap_select,'Value');
% Set current data to the selected data set.
switch str{val};
    case 'Green' 
    color = [0   1   0];    % Green
                 
    case 'Red' 
    color = [1   0   0];    % Red
    
    case 'Blue' 
    color = [0   0   1];    % Blue
    
    case 'Yellow' 
    color = [1   1   0];    % Yellow
    
    case 'Cyan'
    color = [0   1   1];    % Cyan
    
    case 'Magenta'
    color = [1   0   1];    % Magenta
    
    case 'Grey'
    color = [];             % Grey   
    
    case '<Colormap>'
    % Sets colors to use default 'hot' colormap.    
    color = [1   0   0;     % Red
             1   1   0];    % Yellow  
end

rainSTORM_colormap(color);

end


% --- Executes on button press in adjcontrast.
function adjcontrast_Callback(~, ~, ~)
% hObject    handle to adjcontrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of adjcontrast

%Open imcontrast for figure.
h = imgcf;
imcontrast(h);

end


% --- Executes on button press in save_image.
function save_image_Callback(~, ~, ~)
% hObject    handle to save_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

flagSaved = 0; 
flagSaved = rainSTORM_save( flagSaved ); % 

end



%%%%%%%%%%%%%%%% START OF UNUSED FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%

function newThresh_Callback(~, ~, ~)
% hObject    handle to newThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newThresh as text
%        str2double(get(hObject,'String')) returns contents of newThresh as a double
end

% --- Executes during object creation, after setting all properties.
function newThresh_CreateFcn(hObject, ~, ~)
% hObject    handle to newThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function newTol_Callback(~, ~, ~)
% hObject    handle to newTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newTol as text
%        str2double(get(hObject,'String')) returns contents of newTol as a double
end

% --- Executes during object creation, after setting all properties.
function newTol_CreateFcn(hObject, ~, ~)
% hObject    handle to newTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function newSig_Callback(~, ~, ~)
% hObject    handle to newSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newSig as text
%        str2double(get(hObject,'String')) returns contents of newSig as a double
end

% --- Executes during object creation, after setting all properties.
function newSig_CreateFcn(hObject, ~, ~)
% hObject    handle to newSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function newPrecision_Callback(~, ~, ~)
% hObject    handle to newPrecision (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newPrecision as text
%        str2double(get(hObject,'String')) returns contents of newPrecision as a double
end

% --- Executes during object creation, after setting all properties.
function newPrecision_CreateFcn(hObject, ~, ~)
% hObject    handle to newprecision (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function colormap_select_CreateFcn(hObject, ~, ~)
% hObject    handle to colormap_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in colormap_select.
function colormap_select_Callback(~, ~, ~)
% hObject    handle to colormap_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colormap_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colormap_select
end



function newFrames_Callback(hObject, eventdata, handles)
% hObject    handle to newFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newFrames as text
%        str2double(get(hObject,'String')) returns contents of newFrames as a double
end

% --- Executes during object creation, after setting all properties.
function newFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function countsPerPhoton_Callback(hObject, eventdata, handles)
% hObject    handle to countsPerPhoton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of countsPerPhoton as text
%        str2double(get(hObject,'String')) returns contents of countsPerPhoton as a double
end

% --- Executes during object creation, after setting all properties.
function countsPerPhoton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to countsPerPhoton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function reconstructionScaleFactor_Callback(hObject, eventdata, handles)
% hObject    handle to reconstructionScaleFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reconstructionScaleFactor as text
%        str2double(get(hObject,'String')) returns contents of reconstructionScaleFactor as a double
end

% --- Executes during object creation, after setting all properties.
function reconstructionScaleFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reconstructionScaleFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% 05 March 2012, Box tracking and fiducial mark drift correction

% --- Executes on button press in box_tracking.
function box_tracking_Callback(hObject, eventdata, handles)
% hObject    handle to box_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Call the rainSTORM_boxTracker script - inputs drawn from base workspace
flagBoxed = evalin('base','flagBoxed');
% flagBoxed is initialised in rainSTORM.m (the GUI script)
% flagBoxed remains at zero if boxing function fails
  try 
    flagBoxed = rainSTORM_boxTracker(flagBoxed); % Most inputs from base 
    % I have included a dummy argument for this function, because the 
    % unused argument sign ~ is only supported by 2009b and later, 
    % and I worry about empty argument lines being misinterpreted - EJR
  catch myError
    warning('rainSTORM:boxFail','Box Tracker function failed: Run Reviewer, box, wait');
    assignin('base', 'myError', myError);
  end
assignin('base', 'flagBoxed', flagBoxed);

end


% --- Executes on button press in unDriftButton.
function unDriftButton_Callback(hObject, eventdata, handles)
% hObject    handle to unDriftButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

flagUndrifted = evalin('base', 'flagUndrifted'); 
% Initialised in rainSTORM.m GUI; is zero until SupResPosits are undrifted
  try
    flagUndrifted = rainSTORM_undrift(flagUndrifted);
    % Try to run the undrift function
  catch myError
    warning('rainSTORM:undriftFail','rainSTORM_undrift function failed');
    assignin('base', 'myError', myError);
  end
assignin('base', 'flagUndrifted', flagUndrifted);

end


% --- Executes on button press in buttonRestoretDrift.
function buttonRestoretDrift_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRestoretDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Restore Localisation data from before drift compensation was applied
flagSavedSupResData = evalin('base', 'flagSavedSupResData');
if(flagSavedSupResData) % If unedited results exist for the current data:
  assignin('base', 'SupResParams', evalin('base', 'SavedSupResParams') );
  assignin('base', 'SupResPosits', evalin('base', 'SavedSupResPosits') );
end
  
end


% --- Executes on button press in buttonSetAnchor.
function buttonSetAnchor_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSetAnchor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

flagMarkAnchor = evalin('base', 'flagMarkAnchor'); % Initialised in rS.m

  try 
    flagMarkAnchor = rainSTORM_setAnchor(flagMarkAnchor);
  catch myError
    warning('rainSTORM:markAnchorFail','rainSTORM_setAnchor failed');
    assignin('base','myError', myError);
  end
assignin('base', 'flagMarkAnchor', flagMarkAnchor);

end



% 2012-April-26 Separate the method for deleting boxed localisations
% --- Executes on button press in buttonDeleteBoxed.
function buttonDeleteBoxed_Callback(~, ~, ~)
% hObject    handle to buttonDeleteBoxed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  flagSomeCuts = 0;
  try 
    flagSomeCuts = rainSTORM_DeleteBoxed(flagSomeCuts); % 
    % This flag argument becomes 1 when some localisations MAY be deleted
  catch myError
    warning('rainSTORM:delFail','Delete Boxed failed: Does data exist?');
    assignin('base', 'myError', myError);
  end
  assignin('base', 'flagSomeCuts', flagSomeCuts);
  
end

% End of: box tracking and Fiducial Mark drift correction


% 17 September 2012 - Visualisation options, and optical offset
% --- Executes on selection change in visualisationSelect.
function visualisationSelect_Callback(~, ~, handles)
% hObject    handle to visualisationSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns visualisationSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from visualisationSelect

% Determine which visualisation algorithm is required
algVisualHandles = get(handles.visualisationSelect); % Struct of GUI menu
algVisual = algVisualHandles.Value;

% algVisual = 1 ;        % For Simple Histogram Visualisation
% algVisual = 2 ;        % For Jittered Histogram Visualisation

assignin('base','algVisual',algVisual) % Overwrite structure

end

% --- Executes during object creation, after setting all properties.
function visualisationSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to visualisationSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
  algVisual = 1; % This is the default choice, 1, Simple Historgram
  assignin('base','algVisual',algVisual) % Default value to base workspace

end

% --- Executes on button press in opoffCaptCh1.
%  CAPTURES LOCALISATION AND IMAGE DATA FOR CALCULATING OFFSET - CHANNEL 1
function opoffCaptCh1_Callback(hObject, eventdata, handles)
% hObject    handle to opoffCaptCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
reviewedDeltaX = evalin('base','reviewedDeltaX');
reviewedParams = evalin('base','reviewedParams');
reviewedPosits = evalin('base','reviewedPosits');
SupResIm       = evalin('base','SupResIm');

assignin('base','opoffCh1_reviewedDeltaX', reviewedDeltaX);
assignin('base','opoffCh1_reviewedParams', reviewedParams);
assignin('base','opoffCh1_reviewedPosits', reviewedPosits);
assignin('base','opoffCh1_SupResIm',       SupResIm);

end

% --- Executes on button press in opoffCaptCh2.
%  CAPTURES LOCALISATION AND IMAGE DATA FOR CALCULATING OFFSET - CHANNEL 2
function opoffCaptCh2_Callback(hObject, eventdata, handles)
% hObject    handle to opoffCaptCh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
reviewedDeltaX = evalin('base','reviewedDeltaX');
reviewedParams = evalin('base','reviewedParams');
reviewedPosits = evalin('base','reviewedPosits');
SupResIm       = evalin('base','SupResIm');

assignin('base','opoffCh2_reviewedDeltaX',reviewedDeltaX);
assignin('base','opoffCh2_reviewedParams',reviewedParams);
assignin('base','opoffCh2_reviewedPosits',reviewedPosits);
assignin('base','opoffCh2_SupResIm',SupResIm);

end

% --- Executes on button press in opoffEvalCh2skew.
% EVALUATES OFFSET OF MARKERS IN CHANNEL 2 FROM CHANNEL 1
function opoffEvalCh2skew_Callback(~, ~, handles)
% hObject    handle to opoffEvalCh2skew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
opoff_Nmarkers = get(handles.opoffNumMarkers, 'String' );
opoff_Nmarkers = str2num(opoff_Nmarkers);

assignin('base', 'opoff_Nmarkers', opoff_Nmarkers);

flagOpoffFound = rainSTORM_offsetFind(opoff_Nmarkers);

assignin('base', 'flagOpoffFound', flagOpoffFound);
end

% --- Executes on button press in opoffSubtCh2skew.
% SUBTRACTS THE CALIBRATED OFFSET OF CHANNEL 2 FROM 1, 
% TO CORRECT REAL CHANNEL-2 DATA SO IT IS REGISTERED WITH A REAL CHANNEL-1
function opoffSubtCh2skew_Callback(~, ~, handles)
% hObject    handle to opoffSubtCh2skew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

flagOpoffCorrected = rainSTORM_unOffset( 0 );
assignin('base','flagOpoffCorrected',flagOpoffCorrected);
end


function opoffNumMarkers_Callback(~, ~, handles)
% hObject    handle to opoffNumMarkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of opoffNumMarkers as text
%        str2double(get(hObject,'String')) returns contents of opoffNumMarkers as a double
end

% --- Executes during object creation, after setting all properties.
function opoffNumMarkers_CreateFcn(hObject, ~, handles)
% hObject    handle to opoffNumMarkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
  if ispc && isequal(get(hObject,'BackgroundColor'), ...
          get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
end
%     End of September 2012 section on Optical Offset (and visualisation)


% 21 May 2013. Add button to select all quality-controlled localisations
%   This is to quickly select all the data for Diffuion Imaging etc.

% --- Executes on button press in boxAll.
function boxAll_Callback(~, ~, ~)
% hObject    handle to boxAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  boxedPosits = evalin('base','reviewedPosits');
  boxedParams = evalin('base','reviewedParams');
  boxedDeltaX = evalin('base','reviewedDeltaX');
  
  assignin('base', 'boxedDeltaX', boxedDeltaX);
  assignin('base', 'boxedParams', boxedParams);
  assignin('base', 'boxedPosits', boxedPosits);
  assignin('base', 'flagSelectedAll', 1);      % Not the same as flagBoxed
end
