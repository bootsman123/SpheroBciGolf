package nl.ru.spherobciviewer;

import com.github.sarxos.webcam.Webcam;
import nl.ru.spherobciviewer.buffer.Buffer;
import nl.ru.spherobciviewer.buffer.BufferEventListener;
import com.github.sarxos.webcam.WebcamPanel;
import java.awt.CardLayout;
import java.awt.Color;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.io.IOException;
import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.KeyStroke;
import javax.swing.SwingUtilities;
import nl.fcdonders.fieldtrip.BufferEvent;
import nl.ru.spherobciviewer.views.DirectionMeterPanel;
import nl.ru.spherobciviewer.views.PlainPanel;
import nl.ru.spherobciviewer.views.PowerMeterPanel;
import nl.ru.spherobciviewer.views.TextPanel;
import org.apache.commons.configuration.Configuration;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.lang.StringEscapeUtils;

/**
 * Application.
 * @author Bas Bootsma
 */
public class Application extends JFrame
{
    public static final String PLAIN_PANEL = "plain-panel";
    public static final String TEXT_PANEL = "text-panel";
    public static final String WEBCAM_PANEL = "webcam-panel";
    public static final String DIRECTION_METER_PANEL = "direction-meter-panel";
    public static final String POWER_METER_PANEL = "power-meter-panel";

    private Buffer buffer;
    private Webcam webcam;
    
    private State state;
    
    private CardLayout cardLayout;
    private JPanel cardPanel;
    
    private PlainPanel plainPanel;
    private TextPanel textPanel;
    private WebcamPanel webcamPanel;
    private DirectionMeterPanel directionMeterPanel;
    private PowerMeterPanel powerMeterPanel;
    
    /**
     * Constructor.
     */
    public Application()
    {
        this("localhost", 1972);
    }
    
    /**
     * Constructor.
     * @param bufferHost
     * @param bufferPort 
     */
    public Application(String bufferHost, int bufferPort)
    {
        this.addWindowListener(new ApplicationWindowListener());
        
        // Buffer.
        try
        {
            this.buffer = new Buffer(bufferHost, bufferPort);
            this.buffer.addEventListener(new ApplicationBufferEventListener());
            this.buffer.execute();
            
            System.out.printf("Connected to the buffer.%s", System.getProperty("line.separator"));
        }
        catch(IOException e)
        {
            System.out.printf("Unable to connect to the buffer: %s%s", e.getMessage(), System.getProperty("line.separator"));
        }
        
        this.state = new State();
        this.state.reset();
        this.state.setText("Welcome to the Sphero Golf experiment.");

        // Create panels.
        // Plain panel.
        this.plainPanel = new PlainPanel(null, this.state);
        
        // Text panel.
        try
        {
            Configuration textConfiguration = new PropertiesConfiguration(this.getClass().getResource("/properties/Text.properties"));
            this.textPanel = new TextPanel(textConfiguration, this.state);
        }
        catch(ConfigurationException e)
        {
            System.out.println(String.format("Unable to load direction meter configuration: %s", e.getMessage()));
        }
        
        // Webcam panel.
        //https://github.com/sarxos/webcam-capture/blob/master/webcam-capture/src/example/java/CustomResolutionExample.java
        this.webcam = Webcam.getWebcams().get(Webcam.getWebcams().size() - 1);
        this.webcam.setViewSize(this.webcam.getViewSizes()[this.webcam.getViewSizes().length - 1]);
        this.webcamPanel = new WebcamPanel(this.webcam);
        this.webcamPanel.setFillArea(true);
        
        for(Webcam w : Webcam.getWebcams())
        {
            System.out.printf("Webcam: %s\n", w.getName());
        }
 
        // Direction meter panel.
        try
        {
            Configuration directionMeterConfiguration = new PropertiesConfiguration(this.getClass().getResource("/properties/DirectionMeter.properties"));
            this.directionMeterPanel = new DirectionMeterPanel(directionMeterConfiguration, this.state);
        }
        catch(ConfigurationException e)
        {
            System.out.println(String.format("Unable to load direction meter configuration: %s", e.getMessage()));
        }
        
        // Power meter panel.
        try
        {
            Configuration powerMeterConfiguration = new PropertiesConfiguration(this.getClass().getResource("/properties/PowerMeter.properties"));
            this.powerMeterPanel = new PowerMeterPanel(powerMeterConfiguration, this.state);
        }
        catch(ConfigurationException e)
        {
            System.out.println(String.format("Unable to load power meter configuration: %s", e.getMessage()));
        }
        
        Action onLeftArrowPressed = new AbstractAction()
        {
            public void actionPerformed(java.awt.event.ActionEvent event)
            {
                try
                {
                    buffer.sendEvents(new BufferEvent("key.pressed", "left-arrow", -1));
                }
                catch(IOException e)
                {
                }
            }
        };
        
        Action onRightArrowPressed = new AbstractAction()
        {
            public void actionPerformed(java.awt.event.ActionEvent event)
            {                
                try
                {
                    buffer.sendEvents(new BufferEvent("key.pressed", "right-arrow", -1));
                }
                catch(IOException e)
                {
                }
            }
        };
        
        // Create layout.
        this.cardLayout = new CardLayout();
        this.cardPanel = new JPanel(this.cardLayout);
        this.cardPanel.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke("LEFT"), "LEFT_ARROW");
        this.cardPanel.getActionMap().put("LEFT_ARROW", onLeftArrowPressed);
        this.cardPanel.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke("RIGHT"), "RIGHT_ARROW");
        this.cardPanel.getActionMap().put("RIGHT_ARROW", onRightArrowPressed);
        
        this.cardPanel.add(this.plainPanel, Application.PLAIN_PANEL);
        this.cardPanel.add(this.textPanel, Application.TEXT_PANEL);
        this.cardPanel.add(this.webcamPanel, Application.WEBCAM_PANEL);
        this.cardPanel.add(this.directionMeterPanel, Application.DIRECTION_METER_PANEL);
        this.cardPanel.add(this.powerMeterPanel, Application.POWER_METER_PANEL);
        this.getContentPane().add(this.cardPanel);
        
        this.cardLayout.show(this.cardPanel, Application.WEBCAM_PANEL);
        
        this.setUndecorated(true);
        this.setBackground(Color.BLACK);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setExtendedState(JFrame.MAXIMIZED_BOTH);
    }

    /**
     * Application buffer event listener.
     * @author Bas Bootsma
     */
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
                        
                    case DIRECTION_METER_RESET:
                        state.reset();
                        break;
                        
                    case DIRECTION_METER_ROTATION:
                        state.setRotation(State.Rotation.valueOf(event.getValue().toString()));
                        break;
                        
                    case DIRECTION_METER_VALUE:
                        state.setDirection(Double.parseDouble(event.getValue().toString()));
                        break;
                        
                    case POWER_METER_SHOW:
                        cardLayout.show(cardPanel, Application.POWER_METER_PANEL);
                        break;
                        
                    case POWER_METER_HIDE:
                        cardLayout.show(cardPanel, Application.PLAIN_PANEL);
                        break;
                        
                    case POWER_METER_RESET:
                        state.reset();
                        break;
                        
                    case POWER_METER_VALUE:
                        state.setPower(Double.parseDouble(event.getValue().toString()));
                        break;
                        
                    case TEXT_SHOW:
                        cardLayout.show(cardPanel, Application.TEXT_PANEL);
                        break;
                        
                    case TEXT_HIDE:
                        cardLayout.show(cardPanel, Application.PLAIN_PANEL);
                        break;
                        
                    case TEXT_RESET:
                        state.reset();
                        break;
                        
                    case TEXT_VALUE:
                        state.setText(StringEscapeUtils.unescapeJava(event.getValue().toString()));
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
     * Application window listener.
     * @author Bas Bootsma
     */
    private class ApplicationWindowListener implements WindowListener
    {
        public void windowOpened(WindowEvent e)
        {
        }

        public void windowClosing(WindowEvent e)
        {
        }

        public void windowClosed(WindowEvent e)
        {
            webcam.close();
        }

        public void windowIconified(WindowEvent e)
        {
            webcamPanel.resume();
        }

        public void windowDeiconified(WindowEvent e)
        {
            webcamPanel.pause();
        }

        public void windowActivated(WindowEvent e)
        {
        }

        public void windowDeactivated(WindowEvent e) 
        {
        }
    }
    
    /**
     * Application key listener.
     * @author Bas Bootsma
     */
    private class ApplicationKeyListener implements KeyListener
    {
        public void keyTyped(KeyEvent e)
        {
            System.out.println("[Key types]: " + e.getKeyCode());
        }

        public void keyPressed(KeyEvent e)
        {
        }

        public void keyReleased(KeyEvent e)
        {
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