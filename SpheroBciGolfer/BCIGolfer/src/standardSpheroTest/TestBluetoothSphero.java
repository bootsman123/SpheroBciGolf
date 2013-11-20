package standardSpheroTest;
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



public class TestBluetoothSphero implements BluetoothDiscoveryListener{

	/**
	 * @param args
	 * @throws RobotBluetoothException 
	 * @throws InvalidRobotAddressException 
	 */
	public TestBluetoothSphero() throws InvalidRobotAddressException, RobotBluetoothException {
		// TODO Auto-generated method stub
	
		//String id= "0006664b9a49"; //RGR Sphero
		String id= "0006664BA8A8"; //WBW Sphero
		Bluetooth bt = new Bluetooth( this, Bluetooth.SERIAL_COM );
		BluetoothDevice btd = new BluetoothDevice( bt, "btspp://" + id + ":1;authenticate=true;encrypt=false;master=false" );
		Robot r = new Robot( btd );

		if( r.connect() )
		{
		    // Successfully connected to Sphero device
		    // may start sending commands now

		    // Send a RGB command that will turn the RGB LED red
		    r.sendCommand( new RGBLEDCommand( 255, 0, 0 ) );

		    // Send a roll command to the Sphero with a given heading
		    // Notice that we havn't calibrated the Sphero so we don't know
		    // which way is which atm.
		    r.sendCommand( new RollCommand( 1, 180, false ) );

		    // Now send a time delayed command to stop the Sphero from
		    // rolling after 2500 ms (2.5 seconds)
		    r.sendCommand( new RollCommand( 1, 180, true ), 2500 );
		}
		else{
		    // Failed to connect to Sphero device due to an error
		}
		
		r.disconnect();


	}

	@Override
	public void deviceDiscovered(BluetoothDevice arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void deviceSearchCompleted(Collection<BluetoothDevice> arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void deviceSearchFailed(EVENT arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void deviceSearchStarted() {
		// TODO Auto-generated method stub
		
	}

	public void disconnect() {
		
	}

}
