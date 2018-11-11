%% S-function entry point
function filesink_msfun(block)
setup(block);

%% First required callback: setup
function setup(block)
block.NumDialogPrms  = 1; % Number of parameters
block.NumInputPorts  = 1; % Number of inports
block.NumOutputPorts = 0; % Number of outports

% Set input port properties as inherited
block.SetPreCompInpPortInfoToDynamic;

% Override some properties: scalar real input
block.InputPort(1).Dimensions   = 1;
block.InputPort(1).DatatypeID   = 0; % double
block.InputPort(1).Complexity   = 'Real';
block.InputPort(1).SamplingMode = 'Inherited';
block.InputPort(1).DirectFeedthrough = 1;

% Set the sample time and the offset time.
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%  [-1 0]                : Inherited sample time
%  [-2 0]                : Variable sample time
block.SampleTimes = [-1 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'HasNoSimState';

% Other callbacks
block.RegBlockMethod('Outputs', @Outputs); % Required

%% Second required callback: Outputs
function Outputs(block)
fid = fopen(block.DialogPrm(1).Data, 'w');   % open the file, write-only
fprintf(fid, '%f', block.InputPort(1).Data); % print input port value to file
fclose(fid);                                 % close the file




