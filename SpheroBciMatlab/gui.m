function varargout = gui(varargin)
% GUI M-file for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 23-Dec-2013 12:54:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;
data = handles;
data.subject = 'test';
data.level = 1;
data.speed = 6;
data.phasesCompleted = {};
data.phase = [];

% Update handles structure
guidata(hObject, data);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.gui);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function textSubject_Callback(hObject, eventdata, handles)
% hObject    handle to textSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textSubject as text
%        str2double(get(hObject,'String')) returns contents of textSubject as a double
handles.subject=get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function textSubject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonCapFitting.
function buttonCapFitting_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCapFitting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.phase = 'capFitting';
guidata(hObject,handles);
uiresume;

% --- Executes on button press in buttonEegViewer.
function buttonEegViewer_Callback(hObject, eventdata, handles)
% hObject    handle to buttonEegViewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.phase = 'eegViewer';
guidata(hObject,handles);
uiresume;

% --- Executes on button press in buttonTraining.
function buttonTraining_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTraining (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.phase = 'training';
guidata(hObject,handles);
uiresume;

% --- Executes on button press in buttonTrainClassifier.
function buttonTrainClassifier_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTrainClassifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.phase = 'trainClassifier';
guidata(hObject,handles);
uiresume;

% --- Executes on button press in buttonFeedback.
function buttonFeedback_Callback(hObject, eventdata, handles)
% hObject    handle to buttonFeedback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.phase = 'feedback';
guidata(hObject,handles);
uiresume;

% --- Executes on button press in buttonTesting.
function buttonTesting_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTesting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.phase = 'testing';
guidata(hObject,handles);
uiresume;
