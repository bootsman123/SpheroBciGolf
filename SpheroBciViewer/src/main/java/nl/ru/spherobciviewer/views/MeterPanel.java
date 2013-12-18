package nl.ru.spherobciviewer.views;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.geom.Arc2D;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.IOException;
import javax.imageio.ImageIO;
import nl.ru.spherobciviewer.State;
import nl.ru.spherobciviewer.StateListener;
import org.apache.commons.configuration.Configuration;

/**
 * Meter panel.
 * @author Bas Bootsma
 */
public class MeterPanel extends BasePanel
{
    public static final double EPSILON = 0.01;
    
    private BufferedImage imageArrow;
    private BufferedImage imageArrowCurved;
    
    /**
     * Constructor.
     * @param state 
     */
    public MeterPanel(Configuration configuration, State state)
    {
        super(configuration, state);
        
        this.getState().addListener(new StateListener()
        {
            public void onTextChanged(String text) 
            {
            }

            public void onDirectionChanged(double direction)
            {
                repaint();
            }

            public void onPowerChanged(int power)
            {
                repaint();
            }
        });
        
        try
        {
            this.imageArrow = ImageIO.read(this.getClass().getResourceAsStream(this.getConfiguration().getString("arrow.image")));
            this.imageArrowCurved = ImageIO.read(this.getClass().getResourceAsStream(this.getConfiguration().getString("arrow-curved.image")));
        }
        catch(IOException e)
        {
            System.out.println("Unable to load resources.");
        }
    }
    
    /**
     * Returns the image arrow.
     * @return 
     */
    public BufferedImage getImageArrow()
    {
        return this.imageArrow;
    }
    
    /**
     * Returns the image arrow curved.
     * @return 
     */
    public BufferedImage getImageArrowCurved()
    {
        return this.imageArrowCurved;
    }
    
    @Override
    public void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        
        this.paintFrame(g);
        this.paintArrow(g);
    }
    
    /**
     * Paint arrow.
     * @param g
     */
    protected final void paintArrow(Graphics g)
    {
        Graphics2D g2d = (Graphics2D)g;
        int size = (this.getWidth() > this.getHeight()) ? this.getHeight() : this.getWidth();
        
        // Arrow.
        int imageWidth = this.getImageArrow().getWidth();
        int imageHeight = this.getImageArrow().getHeight();
        double imagePreferredSize = this.getConfiguration().getDouble("arrow.size") * size;
        double imageScaleFactor = (imageWidth > imageHeight) ? imagePreferredSize / imageWidth : imagePreferredSize / imageHeight;
           
        double rotationSin = Math.abs(Math.sin(this.getState().getDirection()));
        double rotationCos = Math.abs(Math.cos(this.getState().getDirection()));
        int imageNewWidth = (int)Math.floor(imageWidth * rotationCos + imageHeight * rotationSin);
        int imageNewHeight = (int)Math.floor(imageHeight * rotationCos + imageWidth * rotationSin);
        
        AffineTransform transform = new AffineTransform();
        transform.scale(imageScaleFactor, imageScaleFactor);
        transform.translate((imageNewWidth - imageWidth) / 2, (imageNewHeight - imageHeight) / 2);
        transform.rotate(this.getState().getDirection(), imageWidth / 2, imageHeight / 2);
        
        AffineTransformOp operation = new AffineTransformOp(transform, AffineTransformOp.TYPE_BILINEAR);
        BufferedImage image = operation.filter(this.getImageArrow(), null);

        g2d.drawImage(image, (int)((this.getWidth() - image.getWidth()) / 2), (int)((this.getHeight() - image.getHeight()) / 2), null);
    }
    
    /**
     * Paint frame including markers.
     * @param g 
     */
    protected final void paintFrame(Graphics g)
    {
        Graphics2D g2d = (Graphics2D)g;
        int size = (this.getWidth() > this.getHeight()) ? this.getHeight() : this.getWidth();
        
        // Rotation circle.
        double frameSize = this.getConfiguration().getDouble("frame.size") * size;
        double frameRadius = 0.5 * frameSize;
        double frameWidth = this.getConfiguration().getDouble("frame.width") * size;
        
        g2d.setColor(Color.decode(this.getConfiguration().getString("frame.color")));
        g2d.setStroke(new BasicStroke((int)frameWidth));
        g2d.draw(new Arc2D.Double((this.getWidth() - frameSize) / 2,
                                  (this.getHeight() - frameSize) / 2,
                                  frameSize,
                                  frameSize,
                                  this.getConfiguration().getInt("frame.angle.start"),
                                  this.getConfiguration().getInt("frame.angle.end"),
                                  Arc2D.CHORD));
        
        // Draw markers.
        double markerSize = this.getConfiguration().getDouble("marker.size") * size;
        int markerCount = (Math.abs(Math.toRadians(this.getConfiguration().getInt("frame.angle.end") - this.getConfiguration().getInt("frame.angle.start")) - 2 * Math.PI) <= MeterPanel.EPSILON) ? this.getConfiguration().getInt("marker.count") : this.getConfiguration().getInt("marker.count") - 1;

        double markerAngleStep = (Math.toRadians(this.getConfiguration().getInt("frame.angle.end")) - Math.toRadians(this.getConfiguration().getInt("frame.angle.start"))) / markerCount;
        double markerValueStep = (this.getConfiguration().getInt("marker.value.max") - this.getConfiguration().getInt("marker.value.min")) / markerCount;
        
        for(int marker = 0; marker < this.getConfiguration().getInt("marker.count"); marker++)
        {
            // Marker.
            double markerAngle = marker * markerAngleStep;
            g2d.fill(new Ellipse2D.Double((this.getWidth() - markerSize) / 2 + frameRadius * Math.cos(markerAngle),
                                          (this.getHeight() - markerSize) / 2 + frameRadius * Math.sin(-markerAngle),
                                          markerSize,
                                          markerSize));
            
            // Marker value.
            Font font = new Font(this.getConfiguration().getString("text.font"), Font.PLAIN, this.getConfiguration().getInt("text.size"));
            FontMetrics fontMetrics = this.getFontMetrics(font);
            
            double markerValue = marker * markerValueStep;
            Rectangle2D markerValueBounds = fontMetrics.getStringBounds(String.valueOf(markerValue), g);
            
            g2d.setFont(font);
            g2d.setColor(Color.decode(this.getConfiguration().getString("text.color")));
            g2d.drawString(String.valueOf(markerValue),
                          (int)((this.getWidth() - markerValueBounds.getWidth()) / 2 + frameRadius * Math.cos(markerAngle) * 1.08),
                          (int)((this.getHeight() - markerValueBounds.getHeight()) / 2 + fontMetrics.getAscent() + frameRadius * Math.sin(-markerAngle) * 1.08));
        }
    }
    
    /*
     *         int numberOfMarkers = 12;
        double angleTotal = 2 * Math.PI;
        double angleStep = angleTotal / numberOfMarkers;
        
        for(double angle = 0; angle < angleTotal; angle += angleStep)
        {
            g2d.fill(new Ellipse2D.Double((this.getWidth() - rotationMarkerPreferredSize) / 2 + rotationCircleRadius * Math.cos(angle),
                                          (this.getHeight() - rotationMarkerPreferredSize) / 2 + rotationCircleRadius * Math.sin(-angle),
                                          rotationMarkerPreferredSize,
                                          rotationMarkerPreferredSize));
        }
     */
    
    
    
    
    
    /*
        
        Graphics2D g2d = (Graphics2D)g;
        int size = (this.getWidth() > this.getHeight()) ? this.getHeight() : this.getWidth();
        
        // Draw fixation point.
        double fixationPointPreferredSize = BaselinePanel.FIXATION_POINT_SIZE_FACTOR * size;
        double fixationPointPreferredWidth = BaselinePanel.FIXATION_POINT_WIDTH_FACTOR * size;
        double fixationPointTopLeftX = (this.getWidth() - fixationPointPreferredSize) / 2;
        double fixationPointTopLeftY = (this.getHeight() - fixationPointPreferredSize) / 2;
        
        g2d.setColor(BaselinePanel.FIXATION_POINT_COLOR);
        g2d.setStroke(new BasicStroke((int)fixationPointPreferredWidth));
        
        // Horizontal line.
        g2d.draw(new Line2D.Double(fixationPointTopLeftX,
                                   fixationPointTopLeftY + 0.5 * fixationPointPreferredSize,
                                   fixationPointTopLeftX + fixationPointPreferredSize,
                                   fixationPointTopLeftY + 0.5 * fixationPointPreferredSize));
        
        // Vertical line.
        g2d.draw(new Line2D.Double(fixationPointTopLeftX + 0.5 * fixationPointPreferredSize,
                                   fixationPointTopLeftY,
                                   fixationPointTopLeftX + 0.5 * fixationPointPreferredSize,
                                   fixationPointTopLeftY + fixationPointPreferredSize));
                                   * */
}
