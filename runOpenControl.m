function runOpenControl( libHandle, devId );
% Run the Open Control demo
disp('Open Control test');
    
% Motor & Control commands:
CTRL_NONE = 0;
CTRL_OPEN = 1;

% field ids
FX_RIGID_STATETIME = 2;
FX_RIGID_ACCELX = 3;
FX_RIGID_ACCELY = 4;
FX_RIGID_ACCELZ = 5;
FX_RIGID_GYROX  = 6;
FX_RIGID_GYROY  = 7;
FX_RIGID_GYROZ  = 8;
FX_RIGID_ENC_ANG = 9;
FX_RIGID_MOT_VOLT = 13;

labels = {  'State time', 	    ...
                'accel x', 	'accel y', 	'accel z', 	...
                'gyro x', 	'gyro y',	'gyro z', 	...
                'encoder angle', 	...
                'motor voltage'		...
};

varsToStream = [ 		...
	FX_RIGID_STATETIME, 		...
    FX_RIGID_ACCELX,	FX_RIGID_ACCELY,	FX_RIGID_ACCELZ, 	...
    FX_RIGID_GYROX,  	FX_RIGID_GYROY,  	FX_RIGID_GYROZ,	...
	FX_RIGID_ENC_ANG,		...
	FX_RIGID_MOT_VOLT		...
];

    outVars = [ 99, 99, 99, 99, 99, 99, 99, 99, 99];
    
    % Select the variables to stream
    [retCode, outVars ] = calllib(libHandle, 'fxSetStreamVariables', devId,  varsToStream, 9 );
    
    % Start streaming
    retCode = calllib(libHandle, 'fxStartStreaming', devId, 100, false, 0 );
    if( ~retCode)
        fprintf("Couldn't start streaming...\n");
    else
        calllib(libHandle, 'setControlMode', devId, CTRL_OPEN);
        
        numSteps = 100;
        maxVoltage = 3000;
        numTimes = 2;

        tDelay = .200;
        for time = 1: numTimes
            for i = 1: numSteps
                pause( tDelay );
                mV = maxVoltage * (i*1.0 /numSteps);
                calllib(libHandle, 'setMotorVoltage', devId, mV);
                clc;
                fprintf('Open Control demo...\n');
                fprintf("Ramping up controller...\n");
                printDevice( libHandle, devId, varsToStream, labels, 9);
            end
            
            for i = 1: numSteps
                pause( tDelay );
                mV = maxVoltage * ((numSteps - i)*1.0 / numSteps);
                calllib(libHandle, 'setMotorVoltage', devId, mV);
                clc;
                fprintf('Open Control demo...\n');
                fprintf("Ramping down controller...\n");
                printDevice( libHandle, devId, varsToStream, labels, 9);
            end
        end
    end
    calllib(libHandle, 'setControlMode', devId, CTRL_NONE);
    pause(.200);
    calllib(libHandle, 'fxStopStreaming', devId);
end