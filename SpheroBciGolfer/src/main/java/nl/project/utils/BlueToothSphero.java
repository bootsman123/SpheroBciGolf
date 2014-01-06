package nl.project.utils;
import java.awt.Color;
import java.util.Collection;

import se.nicklasgavelin.bluetooth.Bluetooth;
import se.nicklasgavelin.bluetooth.Bluetooth.EVENT;
import se.nicklasgavelin.bluetooth.BluetoothDevice;
import se.nicklasgavelin.bluetooth.BluetoothDiscoveryListener;
import se.nicklasgavelin.sphero.Robot;
import se.nicklasgavelin.sphero.command.RGBLEDCommand;
import se.nicklasgavelin.sphero.command.RollCommand;
import se.nicklasgavelin.sphero.exception.InvalidRobotAddressException;
import se.nicklasgavelin.sphero.exception.RobotBluetoothException;

public class BlueToothSphero implements BluetoothDiscoveryListener{
	private Robot r = null ; 
	private int heading = 0; 
	private int velocity = 0;
	private int duration = 0 ; 
	
	private int RGBRed = 0 ; 
	private int RGBGreen = 0 ; 
	private int RGBBlue = 0; 
	public BlueToothSphero() throws InvalidRobotAddressException, RobotBluetoothException {
		String idSphero = "0006664b9a49"; //RGR Sphero
		//String idSphero = "0006664BA8A8"; //WBW Sphero
		Bluetooth bt = new Bluetooth( this, Bluetooth.SERIAL_COM );
		BluetoothDevice btd = new BluetoothDevice( bt, "btspp://" + idSphero + ":1;authenticate=true;encrypt=false;master=false" );
		r = new Robot( btd );

		if( r.connect() )
		{
		    // Send a RGB command that will turn the RGB LED red
		    r.sendCommand( new RGBLEDCommand( 255, 0, 0 ) );
		}
		else{
			System.out.println("Failed to connect to Sphero device due to an error");
		}
		    
	}

	@Override
	public void deviceDiscovered(BluetoothDevice arg0) {
		
	}

	@Override
	public void deviceSearchCompleted(Collection<BluetoothDevice> arg0) {
		
	}

	@Override
	public void deviceSearchFailed(EVENT arg0) {
		
	}

	@Override
	public void deviceSearchStarted() {
		
	}

	
	public void disconnect(){
		System.err.println("Trying to disconnect sphero");
		r.disconnect();
		System.err.println("Done with disconnecting");
	}
	
	
	public void move(){
		System.out.println("Sending command: " + heading + " " + velocity + " " + duration);
		r.sendCommand( new RollCommand( heading, velocity, false ) );
		r.sendCommand( new RollCommand( heading, velocity, true ), duration);
		
	}
	public void changeColor()
	{
		r.sendCommand( new RGBLEDCommand( RGBRed, RGBGreen, RGBBlue ) );
	}

	public void setHeading(int heading) {
		this.heading = heading;
		
	}
	public void setVelocity(int velocity){
		this.velocity = velocity;
	}
	public void setDuration(int duration){
		this.duration = duration;
	}

	public void setColor(Color color) {
		this.RGBRed = color.getRed();
		this.RGBGreen = color.getGreen();
		this.RGBBlue = color.getBlue();
		
	}

}
