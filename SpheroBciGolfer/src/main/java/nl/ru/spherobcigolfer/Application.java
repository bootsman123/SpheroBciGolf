package nl.ru.spherobcigolfer;

import java.io.IOException;
import javax.swing.JFrame;
import javax.swing.SwingUtilities;
import nl.fcdonders.fieldtrip.BufferEvent;
import nl.ru.spherobcigolfer.buffer.Buffer;
import nl.ru.spherobcigolfer.buffer.BufferEventListener;
import se.nicklasgavelin.sphero.exception.InvalidRobotAddressException;
import se.nicklasgavelin.sphero.exception.RobotBluetoothException;

/**
 * Application.
 * @author Bas Bootsma
 */
public class Application extends JFrame
{
    public static final String DIRECTION_METER_PANEL = "direction-meter-panel";
    public static final String POWER_METER_PANEL = "power-meter-panel";
    
    private Sphero sphero;
    private Buffer buffer;
    
    /**
     * Constructor.
     * @param model 
     */
    public Application()
    {
        this("145.116.172.195", 1972);
    }
    
    /**
     * Constructor.
     * @param model
     * @param host
     * @param port 
     */
    public Application(String host, int port)
    {
        try
        {
            this.buffer = new Buffer(host, port);
            this.buffer.addEventListener(new ApplicationBufferEventListener());
            this.buffer.execute();
            
            System.out.println("Connected to the buffer.");
        }
        catch(IOException e)
        {
            System.out.println("Unable to connect to the buffer: " + e.getMessage());
        }
        
        try
        {
            this.sphero = new Sphero();
            this.sphero.connect();
            
            System.out.println("Connected to the Sphero.");
        }
        catch(RobotBluetoothException e)
        {
            System.out.println(String.format("Invalid Sphero bluetooth: %s.", e.getMessage()));
        }
        catch(InvalidRobotAddressException e)
        {
            System.out.println(String.format("Invalid Sphero address: %s.", e.getMessage()));
        }
        
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }

    private class ApplicationBufferEventListener implements BufferEventListener
    {
        public void onReceived(BufferEvent event)
        {
            try
            {
                ActionEvent actionEvent = ActionEvent.valueOf(event.getType().toString());

                switch(actionEvent)
                {
                    case GOLFER_DIRECTION_VALUE:
        		sphero.setHeading(Float.parseFloat(event.getValue().toString()));
                        break;
                        
                    case GOLFER_POWER_VALUE:
                        sphero.setVelocity(Float.parseFloat(event.getValue().toString()));
                        break;
                        
                    case GOLFER_SHOOT:
                        sphero.move();
                        break;
                }
            
                System.out.printf("[Buffer event]: %s: %s%s", event.getType().toString(), event.getValue().toString(), System.getProperty("line.separator"));
            }
            catch(IllegalArgumentException e)
            {
                System.out.printf("[Unknown buffer event]: %s: %s%s", event.getType().toString(), event.getValue().toString(), System.getProperty("line.separator"));
            }
        }
    }
    
        /**
     * Main function.
     * @param args
     */
    public static void main(final String[] args)
    {
        SwingUtilities.invokeLater(new Runnable()
        {
            @Override
            public void run()
            {
                Application application = (args.length > 0) ? new Application(args[0], Integer.valueOf(args[1])) : new Application(); 
                application.setVisible(true);
            }
        });
    }
}
