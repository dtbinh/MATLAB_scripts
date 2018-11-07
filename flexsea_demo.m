% FlexSEA Demo program

clearvars;
clc;
close all;
clear all;

deviceIds = [ -99, -99, -99 ];
ports = cellstr([ '', '', '' ]);

%shouldQuit = false;
%shouldQuit = onCleanup( @() signalHander(shouldQuit) ) 

% Check to see what COM ports to use
ports = readConfig();

% Set up the environment
[ errCode, deviceIds] = loadAndGetDevice( ports );
if( ~errCode )
   disp("Failed to initialize the FlexSEA environment\n");
else
    test = displayMenu();
    fprintf (" You chose test %d\n", test);

    % Run the selected test
    switch test
        case 0
            runReadOnly( 'libfx_plan_stack', deviceIds( 1 ) );
        otherwise
            disp('Unimplmented test');
    end
end

% Close COM ports
for i = 1:length( ports )
    fprintf("Closing com ports\n");
    if( ports{i} )
        calllib('libfx_plan_stack', 'fxClose', i);
    end
end

if libisloaded( 'libfx_plan_stack' )
    disp('unloading library and cleaning up');
    calllib('libfx_plan_stack', 'fxCleanup');
end
unloadlibrary 'libfx_plan_stack'


function test = displayMenu()
% Display the test selection menu and wait for user to select one

    clc;
    disp( "0) Read only");
    disp( "1) Open speed");
    disp( "2) Current Control");
    disp( "3) Hold Position");
    disp( "4) Find Poles");
    disp( "5) Two Device Position Control");
    disp( "6) Two Device Leader-Follower");

    test = input("Choose the test to run: ");
    clc;
end

function [ retCode, deviceIds] = loadAndGetDevice( ports )
% Load the FlexSEA DLL and prepare the environment
    disp('Loading library and Initializing');
    
    retCode = false;
    
    % if the FlexSEA DLL is loaded, unload it
    %  we want to use the latest version
    if libisloaded('libfx_plan_stack')
        unloadlibrary 'libfx_plan_stack'
    end
    
    % Add relative path to library/header file
    disp('Loading library');
    addpath( '..\fx_plan_stack\lib64');
    addpath( '..\fx_plan_stack\include\flexseastack');
    loadlibrary('libfx_plan_stack', 'com_wrapper');
    if libisloaded( 'libfx_plan_stack' )
        % Initialize the FX environment
        calllib('libfx_plan_stack', 'fxSetup');
    
        % We need to loop until all of the ports are open
        for i = 1:length( ports )
            if( ports{i} )
                % Now open the COM port
                fprintf("Opening port [%s]\n", ports{i});
                calllib('libfx_plan_stack', 'fxOpen', ports{i}, i);
                pause(1);
                retCode = false;
                iterCount = 10;
                while ~retCode && iterCount > 0
                    pause(1);
                    retCode = calllib('libfx_plan_stack', 'fxIsOpen', i);
                    if( ~retCode )
                        fprintf("Could not open port %s\n", ports{i});
                    end
                    iterCount = iterCount - 1;
                end
            end
        end
        
        % Get the device IDs
        deviceIds = [ -3, -2, -2 ];
        deviceIds = calllib('libfx_plan_stack', 'fxGetDeviceIds', deviceIds, 3);
        if( deviceIds( 1 ) == -1)
            fprintf("zzz got no device ids %d\n", deviceIds);
        else
            fprintf("ZZZ GOT DEVICE IDS %d\n", deviceIds);
        end
    else
        retCode = true;
    end
end

%function shouldQuit = signalHander( ShouldQuit )
%    disp("ZZZ CTRL-C Caught\n");
%    shouldQuit = true;
%end