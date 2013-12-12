package nl.ru.spherobciviewer;

import nl.ru.spherobciviewer.views.PlainPanel;
import nl.ru.spherobciviewer.views.DirectionMeterPanel;
import nl.ru.spherobciviewer.views.PowerMeterPanel;
import com.github.sarxos.webcam.Webcam;
import com.github.sarxos.webcam.WebcamPanel;
import java.awt.CardLayout;
import java.awt.Color;
import java.io.IOException;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import nl.fcdonders.fieldtrip.BufferEvent;
import static nl.ru.spherobciviewer.ActionEvent.DIRECTION_METER_VALUE;
import nl.ru.spherobciviewer.views.BaselinePanel;

/**
 * Application.
 * @author Bas Bootsma
 */
public class Application extends JFrame
{
    public static final String PLAIN_PANEL = "plain-panel";
    public static final String BASELINE_PANEL = "baseline-panel";
    public static final String WEBCAM_PANEL = "webcam-panel";
    public static final String DIRECTION_METER_PANEL = "direction-meter-panel";
    public static final String POWER_METER_PANEL = "power-meter-panel";

    private Buffer buffer;
    
    private Meter meter;
    
    private CardLayout cardLayout;
    private JPanel cardPanel;
    
    private PlainPanel plainPanel;
    private BaselinePanel baselinePanel;
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
            
            System.out.printf("Connected to the buffer.%s", System.getProperty("line.separator"));
        }
        catch(IOException e)
        {
            System.out.printf("Unable to connect to the buffer: %s%s", e.getMessage(), System.getProperty("line.separator"));
        }
        
        this.meter = new Meter();
        this.meter.setDirection(0.5 * Math.PI);
        
        // Create panels.
        this.plainPanel = new PlainPanel();
        this.baselinePanel = new BaselinePanel();
        /*
        Webcam webcam = Webcam.getWebcams().get(1);
        webcam.setViewSize(webcam.getViewSizes()[webcam.getViewSizes().length - 1]);
        this.webcamPanel = new WebcamPanel(webcam);
        */
        this.directionMeterPanel = new DirectionMeterPanel(this.meter);
        this.powerMeterPanel = new PowerMeterPanel(this.meter);
        
        //https://github.com/sarxos/webcam-capture/blob/master/webcam-capture/src/example/java/CustomResolutionExample.java
        
        // Create layout.
        this.cardLayout = new CardLayout();
        this.cardPanel = new JPanel(this.cardLayout);
        //this.cardPanel.add(this.webcamPanel, Application.WEBCAM_PANEL);
        this.cardPanel.add(this.plainPanel, Application.PLAIN_PANEL);
        this.cardPanel.add(this.baselinePanel, Application.BASELINE_PANEL);
        this.cardPanel.add(this.directionMeterPanel, Application.DIRECTION_METER_PANEL);
        this.cardPanel.add(this.powerMeterPanel, Application.POWER_METER_PANEL);
        this.getContentPane().add(this.cardPanel);
        
        this.cardLayout.show(this.cardPanel, Application.BASELINE_PANEL);
        
        this.setUndecorated(true);
        this.setBackground(Color.BLACK);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setExtendedState(JFrame.MAXIMIZED_BOTH);
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
                    case WEBCAM_SHOW:
                        cardLayout.show(cardPanel, Application.WEBCAM_PANEL);
                        break;
                        
                    case WEBCAM_HIDE:
                        cardLayout.show(cardPanel, Application.PLAIN_PANEL);
                        break;
                        
                    case DIRECTION_METER_SHOW:
                        cardLayout.show(cardPanel, Application.DIRECTION_METER_PANEL);
                        break;
                        
                    case DIRECTION_METER_HIDE:
                        cardLayout.show(cardPanel, Application.PLAIN_PANEL);
                        break;
                        
                    case DIRECTION_METER_VALUE:
                        meter.setDirection(Double.parseDouble(event.getValue().toString()));
                        break;
                        
                    case POWER_METER_SHOW:
                        cardLayout.show(cardPanel, Application.POWER_METER_PANEL);
                        break;
                        
                    case POWER_METER_HIDE:
                        cardLayout.show(cardPanel, Application.PLAIN_PANEL);
                        break;
                        
                    case POWER_METER_VALUE:
                        meter.setPower(Integer.parseInt(event.getValue().toString()));
                        break;
                }
                
                System.out.printf("[Buffer event]: %s:%s%s", event.getType().toString(), event.getValue().toString(), System.getProperty("line.separator"));
            }
            catch(IllegalArgumentException e)
            {
                System.out.printf("[Unknown buffer event]: %s:%s%s", event.getType().toString(), event.getValue().toString(), System.getProperty("line.seperator"));
            }
        }
    }
    
    /**
     * Main function.
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