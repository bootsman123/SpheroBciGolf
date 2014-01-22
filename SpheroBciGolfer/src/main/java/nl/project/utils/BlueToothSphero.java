package nl.project.utils;
import java.awt.Color;
import java.util.Collection;

import se.nicklasgavelin.bluetooth.Bluetooth;
import se.nicklasgavelin.bluetooth.Bluetooth.EVENT;
import se.nicklasgavelin.bluetooth.BluetoothDevice;
import se.nicklasgavelin.bluetooth.BluetoothDiscoveryListener;
import se.nicklasgavelin.sphero.Robot;
import se.nicklasgavelin.sphero.RobotListener;
import se.nicklasgavelin.sphero.command.CalibrateCommand;
import se.nicklasgavelin.sphero.command.CommandMessage;
import se.nicklasgavelin.sphero.command.FrontLEDCommand;
import se.nicklasgavelin.sphero.command.RGBLEDCommand;
import se.nicklasgavelin.sphero.command.RollCommand;
import se.nicklasgavelin.sphero.exception.InvalidRobotAddressException;
import se.nicklasgavelin.sphero.exception.RobotBluetoothException;
import se.nicklasgavelin.sphero.response.InformationResponseMessage;
import se.nicklasgavelin.sphero.response.ResponseMessage;

public class BlueToothSphero implements BluetoothDiscoveryListener
{
    public static final String RGR_SPHERO = "0006664b9a49";
    public static final String WBW_SPHERO = "0006664BA8A8";
    
    private Robot robot = null ; 
    private int heading = 0; 
    private int velocity = 0;
    private int duration = 0 ; 

    private int RGBRed = 0 ; 
    private int RGBGreen = 0 ; 
    private int RGBBlue = 0;
        
    public BlueToothSphero() throws InvalidRobotAddressException, RobotBluetoothException
    {
            Bluetooth bt = new Bluetooth( this, Bluetooth.SERIAL_COM );
            BluetoothDevice btd = new BluetoothDevice( bt, "btspp://" + BlueToothSphero.RGR_SPHERO + ":1;authenticate=true;encrypt=false;master=false" );
            robot = new Robot( btd );

            if( robot.connect() )
            {
                // Send a RGB command that will turn the RGB LED red
                robot.sendCommand( new RGBLEDCommand( 255, 0, 0 ) );
            }
            else
            {
                System.out.println("Failed to connect to Sphero device due to an error");
            }
    }

	@Override
	public void deviceDiscovered(BluetoothDevice arg0)
        {
	}

	@Override
	public void deviceSearchCompleted(Collection<BluetoothDevice> arg0)
        {	
	}

	@Override
	public void deviceSearchFailed(EVENT arg0)
        {
	}

	@Override
	public void deviceSearchStarted()
        {	
	}
	
	public void disconnect()
        {
		System.err.println("Trying to disconnect sphero");
		robot.disconnect();
		System.err.println("Done with disconnecting");
	}
	
	
	public void move()
        {
            robot.sendCommand( new RollCommand( heading, velocity, false ) );
            robot.sendCommand( new RollCommand( heading, velocity, true ), duration);
	}
        
	public void changeColor()
	{
		robot.sendCommand( new RGBLEDCommand( RGBRed, RGBGreen, RGBBlue ) );
	}

	public void setHeading(int heading)
        {
		this.heading = heading;	
	}
        
	public void setVelocity(int velocity)
        {
		this.velocity = velocity;
	}
        
	public void setDuration(int duration)
        {
		this.duration = duration;
	}

	public void setColor(Color color)
        {
		this.RGBRed = color.getRed();
		this.RGBGreen = color.getGreen();
		this.RGBBlue = color.getBlue();
	}
}
