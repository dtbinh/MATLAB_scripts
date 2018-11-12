
function runReadOnly( libHandle, deviceId )
% Read the FlexSEA Parameters and display them
    disp('Read Only test');
    
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

    labels = {  'State time', 	    ...
                'accel x', 	'accel y', 	'accel z', 	...
                'gyro x', 	'gyro y',	'gyro z', 	...
                'encoder angle', 	...
                'ankle angle',		...
                'motor voltage'		...
};

varsToStream = [ 		...
	FX_RIGID_STATETIME, 		...
    FX_RIGID_ACCELX,	FX_RIGID_ACCELY,	FX_RIGID_ACCELZ, 	...
    FX_RIGID_GYROX,  	FX_RIGID_GYROY,  	FX_RIGID_GYROZ,	...
	FX_RIGID_ENC_ANG,		...
    FX_RIGID_GEN_VAR_9,     ...
	FX_RIGID_MOT_VOLT		...
];

    outVars = [ 99, 99, 99, 99, 99, 99, 99, 99, 99, 99 ];
    
    % Select the variables to stream
    [retCode, outVars ] = calllib(libHandle, 'fxSetStreamVariables', deviceId,  varsToStream, 10 );
    
    % Start streaming
    retCode = calllib(libHandle, 'fxStartStreaming', deviceId, 100, false, 0 );
    if( ~retCode)
        fprintf("Couldn't start streaming...\n");
    else

        for count = 1:10
            pause(1);
            clc;
            fprintf("Streaming data from device %d\n", deviceId );
            printDevice( libHandle, deviceId, varsToStream, labels, 10);
        end
    end
    calllib(libHandle, 'fxStopStreaming', deviceId);
end
