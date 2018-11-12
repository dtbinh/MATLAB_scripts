function runPositionControl(libHandle, devId)

CTRL_NONE     = 0;
CTRL_POSITION = 2;

% field ids
FX_RIGID_DEVTYPE   = 0;
FX_RIGID_DEVTID    = 1;
FX_RIGID_STATETIME = 2;
FX_RIGID_ACCELX = 3;
FX_RIGID_ACCELY = 4;
FX_RIGID_ACCELZ = 5;
FX_RIGID_GYROX  = 6;
FX_RIGID_GYROY  = 7;
FX_RIGID_GYROZ  = 8;
FX_RIGID_ENC_ANG = 9;
FX_RIGID_ENC_VEL = 10;
FX_RIGID_ENC_ACC = 11;
FX_RIGID_MOT_CURR = 12;
FX_RIGID_MOT_VOLT = 13;
FX_RIGID_BATT_VOLT = 14;
FX_RIGID_BATT_CURR = 15;
FX_RIGID_BATT_TEMP = 16;
FX_RIGID_BATT_STATUS = 17;
FX_RIGID_GEN_VAR_BASE = 18;
FX_RIGID_GEN_VAR_0 = (FX_RIGID_GEN_VAR_BASE + 0);
FX_RIGID_GEN_VAR_1 = (FX_RIGID_GEN_VAR_BASE + 1);
FX_RIGID_GEN_VAR_2 = (FX_RIGID_GEN_VAR_BASE + 2);
FX_RIGID_GEN_VAR_3 = (FX_RIGID_GEN_VAR_BASE + 3);
FX_RIGID_GEN_VAR_4 = (FX_RIGID_GEN_VAR_BASE + 4);
FX_RIGID_GEN_VAR_5 = (FX_RIGID_GEN_VAR_BASE + 5);
FX_RIGID_GEN_VAR_6 = (FX_RIGID_GEN_VAR_BASE + 6);
FX_RIGID_GEN_VAR_7 = (FX_RIGID_GEN_VAR_BASE + 7);
FX_RIGID_GEN_VAR_8 = (FX_RIGID_GEN_VAR_BASE + 8);
FX_RIGID_GEN_VAR_9 = (FX_RIGID_GEN_VAR_BASE + 9);

labels = [  "State time", ...
            "accel x", "accel y", "accel z", ...
            "gyro x", "gyro y", "gyro z", 	 ...
            "encoder angle",                ...
            "motor voltage"					...
];

varsToStream = [ 							...
	FX_RIGID_STATETIME, 					...
	FX_RIGID_ACCELX, FX_RIGID_ACCELY, FX_RIGID_ACCELZ, 	...
	FX_RIGID_GYROX,  FX_RIGID_GYROY,  FX_RIGID_GYROZ,	...
	FX_RIGID_ENC_ANG,						...
	FX_RIGID_MOT_VOLT						...
];

    outVars = [ 99, 99, 99, 99, 99, 99, 99, 99, 99 ];
    
    % Select the variables to stream
    [retCode, outVars ] = calllib(libHandle, 'fxSetStreamVariables', devId,  varsToStream, 9 );
    
    % Start streaming
    retCode = calllib(libHandle, 'fxStartStreaming', devId, 100, false, 0 );
    if( ~retCode)
        fprintf("Couldn't start streaming...\n");
    else
        % Determine the devices initial angle
        timeoutCount = 100;
        initialAngle = readDeviceVar( libHandle, devId, FX_RIGID_ENC_ANG);
        while( timeoutCount && isnan( initialAngle ) )
            pause(.100);
            initialAngle = readDeviceVar( libHandle, devId, FX_RIGID_ENC_ANG);
            timeoutCount = timeoutCount -1;
        end
        % Enable the controller 
        calllib(libHandle, 'setPosition', devId, initialAngle);
        calllib(libHandle, 'setControlMode', devId, CTRL_POSITION);
        calllib(libHandle, 'setPosition', devId, initialAngle);
        calllib(libHandle, 'setZGains', devId, 50, 3, 0, 0);
            
        % Now, hold this poisition against user turn
        for i = 100: -1: 0
            pause(.250);
            clc;
            fprintf("H0lding device %d at position %d (%d)\n", devId, initialAngle, i);
            printDevice( libHandle, devId, varsToStream, labels, 9);
        end

        pause(.200);
        calllib(libHandle, 'setControlMode', devId, CTRL_NONE);
        pause(.200);
        calllib(libHandle, 'fxStopStreaming', devId);
    end
end

