package nl.ru.spherobciviewer;

import com.github.sarxos.webcam.Webcam;
import com.github.sarxos.webcam.WebcamPanel;
import java.awt.CardLayout;
import java.awt.Color;
import java.io.IOException;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import nl.fcdonders.fieldtrip.BufferEvent;

/**
 *
 * @author bootsman
 */
public class Application extends JFrame
{
    public static final String WEBCAM_PANEL = "webcam-panel";
    public static final String DIRECTION_METER_PANEL = "direction-meter-panel";
    public static final String POWER_METER_PANEL = "power-meter-panel";
    
    public enum ApplicationEvent
    {
        APPLICATION_EVENT_WEBCAM_SHOW,
        APPLICATION_EVENT_WEBCAM_HIDE,
        APPLICATION_EVENT_WEBCAM_LOAD,
        APPLICATION_EVENT_DIRECTION_METER_SHOW,
        APPLICATION_EVENT_DIRECTION_METER_HIDE,
        APPLICATION_EVENT_DIRECTION_METER_VALUE,
        APPLICATOIN_EVENT_POWER_METER_SHOW,
        APPLICATION_EVENT_POWER_METER_HIDE,
        APPLICATION_EVENT_POWER_METER_VALUE
    }
    
    private Buffer buffer;
    
    private CardLayout cardLayout;
    private JPanel cardPanel;
    
    private WebcamPanel webcamPanel;
    private DirectionMeterPanel directionMeterPanel;
    private PowerMeterPanel powerMeterPanel;
    
    /**
     * Constructor.
     */
    public Application()
    {
        try
        {
            this.buffer = new Buffer("localhost", 1972);
            this.buffer.addEventListener(new ApplicationBufferEventListener());
            this.buffer.execute();
        }
        catch(IOException e)
        {
            System.out.println("Unable to connect to the buffer: " + e.getMessage());
        }
        
        // Create panels.
        Webcam webcam = Webcam.getWebcams().get(1);
        webcam.setViewSize(webcam.getViewSizes()[webcam.getViewSizes().length - 1]);
        this.webcamPanel = new WebcamPanel(webcam);
        
        this.directionMeterPanel = new DirectionMeterPanel();
        
        this.powerMeterPanel = new PowerMeterPanel();
        
        //https://github.com/sarxos/webcam-capture/blob/master/webcam-capture/src/example/java/CustomResolutionExample.java
        
        // Create layout.
        this.cardLayout = new CardLayout();
        this.cardPanel = new JPanel(cardLayout);
        this.cardPanel.add(this.webcamPanel, Application.WEBCAM_PANEL);
        this.cardPanel.add(this.directionMeterPanel, Application.DIRECTION_METER_PANEL);
        this.cardPanel.add(this.powerMeterPanel, Application.POWER_METER_PANEL);
        this.getContentPane().add(this.cardPanel);
        
        this.cardLayout.show(this.cardPanel, Application.WEBCAM_PANEL);
        
        this.setResizable(false);
        this.setBackground(Color.BLACK);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.pack();
    }

    private class ApplicationBufferEventListener implements BufferEventListener
    {
        public void onReceived(BufferEvent event)
        {
            try
            {
                ApplicationEvent applicationEvent = ApplicationEvent.valueOf(event.getValue().toString());
                
                switch(applicationEvent)
                {
                    case APPLICATION_EVENT_WEBCAM_SHOW:
                        cardLayout.show(cardPanel, Application.WEBCAM_PANEL);
                }
            }
            catch(IllegalArgumentException e)
            {
                System.out.println(String.format("[Unknown buffer event received]: %s:%s", event.getValue().toString(), event.getType().toString()));
            }
        }
    }
    
    /**
     * Main function.
     *
     * @param args
     */
    public static void main(String[] args)
    {
        SwingUtilities.invokeLater(new Runnable()
        {
            @Override
            public void run()
            {
                Application application = new Application();
                application.setVisible(true);
            }
        });
    }
}
