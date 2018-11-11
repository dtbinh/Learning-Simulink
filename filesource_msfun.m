%% S-function entry point
function filesource_msfun(block)
setup(block);

%% First required callback: setup
function setup(block)
block.NumDialogPrms  = 2; % Number of parameters
block.NumInputPorts  = 0; % Number of inports
block.NumOutputPorts = 1; % Number of outports

% Set the default properties to all ports
block.SetPreCompPortInfoToDefaults;

% Set the sample time and the offset time.
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0 0]; % cannot be inherited for sources

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

% Other callbacks
block.RegBlockMethod('PostPropagationSetup',@PostPropagationSetup);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs); % Required
block.RegBlockMethod('Update', @Update);

%% First optional callback: PostPropagationSetup
function PostPropagationSetup(block)
block.NumDworks = 1;
block.Dwork(1).Name = 'lastValue'; % required!
block.Dwork(1).Dimensions = 1;
block.Dwork(1).DatatypeID = 0; % double
block.Dwork(1).Complexity = 'Real';
block.Dwork(1).Usage = 'DWork';

%% Second optional callback: Start
function Start(block)
block.Dwork(1).Data = block.DialogPrm(2).Data;

%% Second required callback: Outputs
function Outputs(block)
fid = fopen(block.DialogPrm(1).Data, 'r'); % open file readonly
% read a line
tline = fgetl(fid); % read one line
if (tline == -1) % fail
	block.OutputPort(1).Data = block.Dwork(1).Data; % output last value
	fclose(fid);
	return
end
output = str2double(tline); % convert to double
if (isnan(output)) % check that the output is a valid number
	block.OutputPort(1).Data = block.Dwork(1).Data; % output last value
	fclose(fid);
	return
end
block.OutputPort(1).Data = output; % output the read value
fclose(fid);

%% Third optional callback: Update
function Update(block)
block.Dwork(1).Data = block.OutputPort(1).Data;

