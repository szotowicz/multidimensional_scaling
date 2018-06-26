function varargout = SI_projekt(varargin)
% SI_PROJEKT MATLAB code for SI_projekt.fig
%      SI_PROJEKT, by itself, creates a new SI_PROJEKT or raises the existing
%      singleton*.
%
%      H = SI_PROJEKT returns the handle to a new SI_PROJEKT or the handle to
%      the existing singleton*.
%
%      SI_PROJEKT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SI_PROJEKT.M with the given input arguments.
%
%      SI_PROJEKT('Property','Value',...) creates a new SI_PROJEKT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SI_projekt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SI_projekt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SI_projekt

% Last Modified by GUIDE v2.5 26-May-2018 13:28:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SI_projekt_OpeningFcn, ...
                   'gui_OutputFcn',  @SI_projekt_OutputFcn, ...
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


% --- Executes just before SI_projekt is made visible.
function SI_projekt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SI_projekt (see VARARGIN)

% Choose default command line output for SI_projekt
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SI_projekt wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SI_projekt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in InputMatrixButton.
function InputMatrixButton_Callback(hObject, eventdata, handles)

[FileName, PathName] = uigetfile('*.txt','Select your file with matrix');
handles.FileName = FileName;

address = [PathName FileName];

fileFullPath = dir(address);

if fileFullPath.bytes == 0
    disp('Matrix cannot be empty!')
    set(handles.scaleButton,'Enable','off');
    set(handles.numberFeatures,'Enable','off');
    set(handles.errorInputBox,'Visible','on');
    set(handles.infoInputBox, 'string','');
else
    M = dlmread(FileName);
    handles.M = M;
    [row_M col_M] = size(M);
    handles.col_M = col_M;
    handles.row_M = row_M;
    set(handles.scaleButton,'Enable','on');
    set(handles.numberFeatures,'Enable','on');
    set(handles.errorInputBox,'Visible','off');
    txt = [ 'Matrix contains: ' num2str(row_M) ' obiects with ' num2str(col_M)  ' features'];
    set(handles.infoInputBox, 'string',txt);
end

guidata(hObject, handles);


% --- Executes on button press in scaleButton.
function scaleButton_Callback(hObject, eventdata, handles)

FileName = handles.FileName;
M = handles.M;
row_M = handles.row_M;
col_M = handles.col_M;
features = get(handles.numberFeatures, 'string');
features = str2num(features);
if isempty(features)
    disp('The number of features provided is incorrect!')
    set(handles.errorFeaturesBox,'Visible','on');
    set(handles.numberFeatures, 'string','');
    set(handles.differenceFeatures,'Visible','off');
elseif handles.col_M <= features
    disp('The number of features provided must be less than the input!')
    set(handles.errorFeaturesBox,'Visible','off');
    set(handles.differenceFeatures,'Visible','on');
else
    set(handles.errorFeaturesBox,'Visible','off');
    set(handles.differenceFeatures,'Visible','off');
    set(handles.mistakeTXT,'Visible','on');
 
 
    %%%%%%%%%%%%   genetic algorithm   %%%%%%%%%%%%%%%%
    s = rng;
 
    multiplicationsNumber = 10;
	multip = zeros(col_M, features, multiplicationsNumber);
    newMultip = zeros(col_M, features, multiplicationsNumber);
	fitness = zeros(multiplicationsNumber);
	 
	reproductionProbability = 0.75;
	mutationProbability = 0.1;
	inputEfficiency = zeros(row_M, row_M);
	outputRes = zeros(row_M, features, multiplicationsNumber);
	outputEfficiency = zeros(row_M, row_M, multiplicationsNumber);
	 
	fitness = zeros(multiplicationsNumber);
	outputEfficiencySum = zeros(multiplicationsNumber);
	for a = 1 : multiplicationsNumber 
		for b = 1 : col_M
			for c = 1 : features
				multip ( b , c , a ) = rand() ;
			end
		end
	end
 

	% calculating the effectiveness for the input matrix
	for a = 1 : row_M
		for b = 1 : row_M
		sum = 0;
			for c = 1 : col_M
				sum = sum + (M(a,c) - M(b,c))*(M(a,c) - M(b,c));	
			end
			inputEfficiency(a,b) = sqrt(sum);
		end
	end
 
	% calculating the sum of effectiveness for the input matrix
	inputEfficiencySum=0;
	for a =1 : row_M
		for b = a : row_M
			inputEfficiencySum=inputEfficiencySum+inputEfficiency(a,b);
		end
	end
 
 
	%%% Main loop - the number of loop circuits - affects performance
	loopCircuits = 1000;
	for x = 1 : loopCircuits

		for a = 1 : multiplicationsNumber
			outputRes(:,:,a) = M * multip(:,:,a);	
		end
 
		% calculating the effectiveness for the output matrix
		for ob = 1 : multiplicationsNumber
			for a = 1 : row_M
				for b = 1 : row_M
					sum = 0;
					for c = 1 : features
						sum = sum + (outputRes(a, c, ob) - outputRes(b, c, ob)) * (outputRes(a, c, ob) - outputRes(b, c, ob));	
					end
					outputEfficiency(a, b, ob) = sqrt(sum);
				end
			end
		end
 
		% calculating the sum of effectiveness for the output matrix
		for i = 1 : multiplicationsNumber
		outputEfficiencySum(i)=0;
			for a = 1 : row_M
				for b = a : row_M
					outputEfficiencySum(i) = outputEfficiencySum(i) + outputEfficiency(a,b,i);
				end
			end
			fitness(i) = abs(inputEfficiencySum - outputEfficiencySum(i));
		end
 
		% roulette
		fitnessSum = 0;
		for i = 1 : multiplicationsNumber
			fitnessSum = fitnessSum + fitness(i);
		end
 
		numberOfPopulation = multiplicationsNumber;
		currentPopulating = 1;
 
        while numberOfPopulation
			% choosing 2 organisms using the roulette method
            parent1 = 1;
            parent2 = 1;
            random1 = rand(1,1) * fitnessSum;
            random2 = rand(1,1) * fitnessSum;
					
			random1Sum = 0;
			for i = 1 : multiplicationsNumber
				random1Sum = random1Sum + fitness(i);
				if random1Sum > random1
					parent1 = i;
					break;
				end
			end
					
			random2Sum = 0;
			for i = 1 : multiplicationsNumber
				random2Sum = random2Sum + fitness(i);
					if(random2Sum > random2)
						parent2 = i;
					break;
				end
			end

			probabilityOfReproduction = rand(1, 1);
				
            if(probabilityOfReproduction <= reproductionProbability)
				child1 = zeros(col_M, features);
				child2 = zeros(col_M, features);
				crossoverPoint = randi([1 features ], 1, 1);
						
				for r = 1 : col_M
					for c = 1 : crossoverPoint
						child1 (r, c) = multip(r, c, parent1);
						child2 (r, c) = multip(r, c, parent2);
					end
				end
 	
				% child1
				for r = 1 : col_M
					counter = crossoverPoint;
					for c = 1 : features
						isExists = 0;
						if(counter < features)
							for e = 1 : features
								if(child1 (r, e) == multip(r, c, parent2)) 
									isExists = 1;
									break;
								end
							end
							
							if(isExists == 0)
								child1 (r, counter + 1) = multip(r, c, parent2);
								counter = counter + 1;
							end
						end
					end
				end
				
				% child2
				for r = 1 : col_M
					counter = crossoverPoint;
					for c = 1 : features
						isExists = 0;
						if(counter < features)
							for e = 1 : features
								if(child2 (r,e) == multip(r, c, parent1)) 
									isExists = 1;
									break;
								end
							end
							
							if(isExists == 0)
								child2 (r, counter + 1) = multip(r, c, parent1);
								counter = counter + 1;
							end
						end
					end
				end

				for t = 1 : col_M
					for y = 1 : features
						newMultip(t, y, currentPopulating) = child1(t, y);
						newMultip(t, y, currentPopulating + 1) = child2(t, y);
					end
				end
            else % does not reproduce
				for t = 1 : col_M
					for y = 1 : features
						newMultip(t, y, currentPopulating) = multip(t, y, parent1);
						newMultip(t, y, currentPopulating + 1) = multip(t, y, parent2);
					end
				end
			end
						
		numberOfPopulation = numberOfPopulation - 2;
		currentPopulating = currentPopulating + 2;
		end
 
		% mutationProbability 
		for i = 1 : multiplicationsNumber
			fate = rand(1, 1);
			if(fate <= mutationProbability)
				r1 = randi([1 col_M], 1, 1);
				c1 = randi([1 features], 1, 1);
				r2 = randi([1 col_M], 1, 1);
				c2 = randi([1 features], 1, 1);
				tmp = newMultip(r1, c1, i);
				newMultip(r1, c1, i) = newMultip(r2, c2, i);
				newMultip(r2, c2, i) = tmp;			
			end
		end
			
		% find the best element in the old array
		bestIndex = 0;
		bestValue = 100000;
		for i = 1 : multiplicationsNumber
			if fitness(i) < bestValue
				bestValue = fitness(i);
				bestIndex = i;
			end
		end

		errorArray(x) = bestValue;
		
		% save to random position
		changeNumber = randi([1 multiplicationsNumber], 1, 1);
		for i = 1 : col_M
			for j = 1 : features
				newMultip(i, j, changeNumber) = multip(i, j, bestIndex);
			end
		end

		for i = 1 : multiplicationsNumber
			for j = 1 : col_M
				for t = 1 : features
					multip(j, t, i) = newMultip(j, t, i);
				end
			end
		end
	end
 
     
    bestIndex = 0;
	bestValue = 100000;
	for i = 1 : multiplicationsNumber
		if fitness(i) < bestValue
			bestIndex = i;
		end
	end
	
	M
    finalCollection = M * multip(:,:,bestIndex)
    multip(:,:,bestIndex);

    plot(1 : loopCircuits, errorArray)
	% mesh(M)
        
    t = uitable(handles.outputTable);
    set(t,'Data',finalCollection); 
    set(handles.mistakeVALUE, 'string',num2str(errorArray(loopCircuits)) );
end

% hObject    handle to scaleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function numberFeatures_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function numberFeatures_Callback(hObject, eventdata, handles)
% hObject    handle to numberFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberFeatures as text
%        str2double(get(hObject,'String')) returns contents of numberFeatures as a double