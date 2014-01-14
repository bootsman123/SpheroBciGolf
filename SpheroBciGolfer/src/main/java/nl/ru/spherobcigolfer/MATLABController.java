package nl.ru.spherobcigolfer;

import java.io.IOException;
import nl.fcdonders.fieldtrip.BufferEvent;
import nl.ru.spherobcigolfer.buffer.Buffer;
import nl.ru.spherobcigolfer.buffer.BufferEventListener;

/**
 * MATLAB Controller.
 * @author Roland Meertens
 */
public class MATLABController
{
    public static final String DIRECTION_METER_PANEL = "direction-meter-panel";
    public static final String POWER_METER_PANEL = "power-meter-panel";
    private WorldModel model;
    public static final double MAXIMUM_DURATION = 5000.0;
    public static final double MINIMUM_DURATION = 500.0;

    private Buffer buffer;
    
    /**
     * Constructor.
     * @param model 
     */
    public MATLABController(WorldModel model)
    {
        this(model, "localhost", 1972);
    }
    
    /**
     * Constructor.
     * @param model
     * @param host
     * @param port 
     */
    public MATLABController(WorldModel model, String host, int port)
    {
    	this.model = model;
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
        		model.setHeading((int)Double.parseDouble(event.getValue().toString()));
                        break;
                        
                    case GOLFER_POWER_VALUE:
                        model.setDuration((int)(MINIMUM_DURATION + Double.parseDouble(event.getValue().toString()) * 1.0/(MAXIMUM_DURATION - MINIMUM_DURATION)));
                        break;
                        
                    case GOLFER_SHOOT:
                        model.executeCommandOnSphero();
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
}
