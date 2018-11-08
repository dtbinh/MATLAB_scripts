function RunLeaderFollower( libHandle, deviceIds )
% Run the leader/follower test on the frst two devices

disp('Run Leader/Follower test');

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

% Motor & Control commands:
CTRL_NONE     = 0;
CTRL_POSITION = 2;
CTRL_CURRENT  = 3;

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

    % Make sure to reserve space for the outputs
    outVars  = zeros( 9, 'int32' );
    success1 = zeros( 9, 'int32' );
    success2 = zeros( 9, 'int32' );
    retData  = zeros( 9, 'int32' );
    
    initialAngle1 = 0;
    initialAngle2 = 0;
    
    % Select the variables to stream
    [retCode1, outVars ] = calllib(libHandle, 'fxSetStreamVariables', deviceIds(1),  varsToStream, 9 );
    [retCode2, outVars ] = calllib(libHandle, 'fxSetStreamVariables', deviceIds(2),  varsToStream, 9 );
    
    % Start streaming
    retCode1 = calllib(libHandle, 'fxStartStreaming', deviceIds(1), 100, false, 0 );
    retCode2 = calllib(libHandle, 'fxStartStreaming', deviceIds(2), 100, false, 0 );
    if( ~retCode1 && ~ retCode2 )
        fprintf("Couldn't start streaming...\n");
    else
        timeoutCount = 20;
        while ( timeoutCount )
            pause(1);
            
            % Get the initial positions of the two devices
            [ ptr, retData, success1] = calllib(libHandle, 'fxReadDevice', deviceIds(1), varsToStream, success1, 9);
            ptrindex1 = libpointer('int32Ptr', zeros(1:10, 'int32'));
            ptrindex1 = ptr;
            setdatatype(ptrindex1, 'int32Ptr', 1, 10);
        
            [ ptr, retData, success2] = calllib(libHandle, 'fxReadDevice', deviceIds(2), varsToStream, success2, 9);
            ptrindex2 = libpointer('int32Ptr', zeros(1:10, 'int32'));
            ptrindex2 = ptr;
            setdatatype(ptrindex2, 'int32Ptr', 1, 10);
        
            if( (success1(8) ~= -1) && (success2(8) ~= -1) )
                initialAngle1 = ptrindex1.value( 8 );
                initialAngle2 = ptrindex2.value( 8 );
                timeoutCount = 0;
            end
        end
        
        if( (success1(8) ~= -1) && (success2(8) ~= -1) )
            % set first device to current controller with 0 current (0 torque)
            calllib(libHandle, 'setControlMode', deviceIds(1), CTRL_CURRENT);
            calllib(libHandle, 'setZGains', deviceIds(1), 100, 20, 0, 0);
            calllib(libHandle, 'setMotorCurrent', deviceIds(1), 0);

            % set position controller for second device
            calllib(libHandle, 'setPosition', deviceIds(2), initialAngle1);
            calllib(libHandle, 'setControlMode', deviceIds(2), CTRL_POSITION);
            calllib(libHandle, 'setPosition', deviceIds(2), initialAngle1);
            calllib(libHandle, 'setZGains', deviceIds(2), 50, 3, 0, 0);

            %timeoutCount = 100;
            timeoutCount = 10;
            angle1 = initialAngle1;
            while( timeoutCount )
                fprintf("Device %d following device %d  (%d)\n", deviceIds(1), deviceIds(2), timeoutCount);
                pause(1);
                [ ptr, retData, success1] = calllib(libHandle, 'fxReadDevice', deviceIds(1), varsToStream, success1, 9);
                if( success1(8) ~= -1 )
                    angle1 = ptrindex1.value( 8 );
                    diff = angle1 - initialAngle1;
                    fprintf("ZZZ NEW ANLGE = %d\n", initialAngle2 + (3 * diff));
                    calllib(libHandle, 'setPosition', deviceIds(2), initialAngle2 + (3 * diff));
                end
                fprintf("Streaming data from device %d\n", deviceIds(1) );
                printDevice( libHandle, deviceIds(1), varsToStream, labels, 9)
                fprintf("Streaming data from device %d\n", deviceIds(2) );
                printDevice( libHandle, deviceIds(2), varsToStream, labels, 9)
                timeoutCount = timeoutCount -1;
            end
        end
    end
    
    % Clean up
    disp("Turning off position control\n");
    calllib(libHandle, 'setControlMode', deviceIds(1), CTRL_NONE);
    calllib(libHandle, 'setControlMode', deviceIds(2), CTRL_NONE);
    pause(1);
    calllib(libHandle, 'fxStopStreaming', deviceIds(1));
    calllib(libHandle, 'fxStopStreaming', deviceIds(2));
end