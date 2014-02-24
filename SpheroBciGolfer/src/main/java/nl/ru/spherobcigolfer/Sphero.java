package nl.ru.spherobcigolfer;
import java.awt.Color;
import java.util.Collection;

import se.nicklasgavelin.bluetooth.Bluetooth;
import se.nicklasgavelin.bluetooth.BluetoothDevice;
import se.nicklasgavelin.bluetooth.BluetoothDiscoveryListener;
import se.nicklasgavelin.sphero.Robot;
import se.nicklasgavelin.sphero.command.RGBLEDCommand;
import se.nicklasgavelin.sphero.command.RollCommand;
import se.nicklasgavelin.sphero.exception.InvalidRobotAddressException;
import se.nicklasgavelin.sphero.exception.RobotBluetoothException;

public class Sphero
{
    public static final String RGR_SPHERO_ID = "0006664b9a49";
    public static final String WBW_SPHERO_ID = "0006664BA8A8";
    
    private BluetoothDiscoveryListener spheroBluetoothDiscoveryListener;
    private Robot robot;
    
    private float heading; 
    private float velocity;
    private Color color;
    
    /**
     * Constructs a Sphero defaulted to the RGR-Sphero.
     * @throws InvalidRobotAddressException
     * @throws RobotBluetoothException 
     */
    public Sphero() throws InvalidRobotAddressException, RobotBluetoothException
    {
        this(Sphero.RGR_SPHERO_ID);
    }
    
    /**
     * Constructor.
     * @param id
     * @throws InvalidRobotAddressException
     * @throws RobotBluetoothException 
     */
    public Sphero(String id) throws InvalidRobotAddressException, RobotBluetoothException
    {
        this.spheroBluetoothDiscoveryListener = new SpheroBluetoothDiscoveryListener();
        
        Bluetooth bluetooth = new Bluetooth(this.spheroBluetoothDiscoveryListener, Bluetooth.SERIAL_COM);
        BluetoothDevice bluetoothDevice = new BluetoothDevice(bluetooth, "btspp://" + id + ":1;authenticate=true;encrypt=false;master=false");
        
        this.robot = new Robot(bluetoothDevice);
        this.robot.connect(true);
        
        this.setHeading(0.0f);
        this.setVelocity(0.0f);
        this.setColor(new Color(255, 0, 0));
    }
    
    /**
     * Connect.
     */
    public void connect()
    {
        if(this.robot != null &&
           !this.robot.isConnected())
        {
            this.robot.connect(true);
        }
    }
    
    /**
     * Disconnect.
     */
    public void disconnect()
    {
        if(this.robot != null &&
           this.robot.isConnected())
        {
            this.robot.disconnect();
        }
    }
    
    /**
     * Moves the Sphero with a given heading and velocity.
     * @param heading
     * @param velocity 
     */
    public void move(float heading, float velocity)
    {
        this.setHeading(heading);
        this.setVelocity(velocity);
        this.move();
    }
    
    /**
     * Moves the sphero.
     */
    public void move()
    {
        //this.robot.roll(this.heading, this.velocity);
        //this.robot.stopMotors();
        
        this.robot.sendCommand(new RollCommand(this.heading, this.velocity, false));
        this.robot.sendCommand(new RollCommand(this.heading, 0.0f, true), 1000);
    }
    
    /**
     * Sets the heading.
     * @param heading 
     */
    public void setHeading(float heading)
    {
        this.heading = heading;
    }
    
    /**
     * Returns the heading.
     * @return 
     */
    public float getHeading()
    {
        return this.heading;
    }
    
    /**
     * Sets the velocity.
     * @param velocity 
     */
    public void setVelocity(float velocity)
    {
        this.velocity = velocity;
    }
    
    /**
     * Returns the velocity.
     * @return 
     */
    public float getVelocity()
    {
        return this.velocity;
    }
    
    /**
     * Sets the color.
     * @param color 
     */
    public void setColor(Color color)
    {
        this.color = color;
        this.robot.sendCommand(new RGBLEDCommand(this.color.getRed(), this.color.getGreen(), this.color.getBlue()));
    }
    
    /**
     * Returns the color.
     * @return 
     */
    public Color getColor()
    {
        return this.color;
    }
    
    /**
     * SpheroBluetoothDiscoveryListener.
     */
    private class SpheroBluetoothDiscoveryListener implements BluetoothDiscoveryListener
    {
        public void deviceSearchCompleted(Collection<BluetoothDevice> clctn)
        {
        }

        public void deviceDiscovered(BluetoothDevice bd)
        {
        }

        public void deviceSearchFailed(Bluetooth.EVENT event)
        {
        }

        public void deviceSearchStarted()
        {
        }
    }
}
