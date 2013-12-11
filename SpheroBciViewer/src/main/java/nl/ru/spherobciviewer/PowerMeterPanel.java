package nl.ru.spherobciviewer;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.geom.Arc2D;
import java.awt.geom.Ellipse2D;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.swing.JPanel;

/**
 * Power meter panel.
 * @author Bas Bootsma
 */
public class PowerMeterPanel extends JPanel
{
    public static final Color ROTATION_FRAME_COLOR = Color.black;
    public static final double ROTATION_POINT_SIZE_FACTOR = 0.05;
    public static final double ROTATION_CIRCLE_SIZE_FACTOR = 0.9;
    public static final int ROTATION_CIRCLE_WIDTH = 5;
        
    public static final double ARROW_RATIO = 0.9;
    
    private BufferedImage arrowImage;
    private BufferedImage curvedArrowImage;
    
    private Meter meter;
    
   /**
    * Constructor.
    * @param meter 
    */
    public PowerMeterPanel(Meter meter)
    {
        super();
        
        this.meter = meter;
        this.meter.addListener(new MeterListener()
        {
            public void onDirectionChanged(double direction)
            {
            }

            public void onPowerChanged(int power)
            {
                repaint();
            }
        });
        
        try
        {
            this.arrowImage = ImageIO.read(this.getClass().getResourceAsStream("/images/arrow.png"));
            this.curvedArrowImage = ImageIO.read(this.getClass().getResourceAsStream("/images/curved-arrow.png"));
        }
        catch(IOException e)
        {
        }
    }
    
@Override
    public void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        
        this.paintRotationFrame(g);
        this.paintArrow(g);
    }
    
    /**
     * Paint rotation frame, i.e. the point and the circle.
     * @param g 
     */
    private void paintRotationFrame(Graphics g)
    {
        Graphics2D g2d = (Graphics2D)g;
        int size = (this.getWidth() > this.getHeight()) ? this.getHeight() : this.getWidth();
        
        // Rotation point.
        double rotationPointPreferredSize = DirectionMeterPanel.ROTATION_POINT_SIZE_FACTOR * size;
        
        g2d.setColor(DirectionMeterPanel.ROTATION_FRAME_COLOR);
        g2d.fill(new Ellipse2D.Double((this.getWidth() - rotationPointPreferredSize) / 2,
                                       (this.getHeight() - rotationPointPreferredSize) / 2,
                                       rotationPointPreferredSize,
                                       rotationPointPreferredSize));
        
        // Rotation circle.
        double rotationCirclePreferredSize = DirectionMeterPanel.ROTATION_CIRCLE_SIZE_FACTOR * size;
        
        g2d.setColor(DirectionMeterPanel.ROTATION_FRAME_COLOR);
        g2d.setStroke(new BasicStroke(DirectionMeterPanel.ROTATION_CIRCLE_WIDTH));
        //g2d.drawArc((int)((this.getWidth() - rotationCirclePreferredSize) / 2), (int)((this.getHeight() - rotationCirclePreferredSize) / 2), (int)rotationCirclePreferredSize, (int)rotationCirclePreferredSize, 0, (int)Math.toDegrees(Math.PI));
        g2d.draw(new Arc2D.Double((this.getWidth() - rotationCirclePreferredSize) / 2,
                                  (this.getHeight() - rotationCirclePreferredSize) / 2,
                                  rotationCirclePreferredSize,
                                  rotationCirclePreferredSize,
                                  0,
                                  180,
                                  Arc2D.CHORD));
        
        // Draw markers.
        
    }
    
    /**
     * Paint arrow.
     * @param g 
     * http://stackoverflow.com/questions/2676719/calculating-the-angle-between-the-line-defined-by-two-points
     */
    private void paintArrow(Graphics g)
    {
        Graphics2D g2d = (Graphics2D)g;
        int size = (this.getWidth() > this.getHeight()) ? this.getHeight() : this.getWidth();
        
        // Arrow.
        double imagePreferredSize = DirectionMeterPanel.ARROW_RATIO * size;
        double imageScaleFactor = (this.arrowImage.getWidth() > this.arrowImage.getHeight()) ? imagePreferredSize / this.arrowImage.getWidth() : imagePreferredSize / this.arrowImage.getHeight();
        int imageWidth = this.arrowImage.getWidth();
        int imageHeight = this.arrowImage.getHeight();
           
        double rotationSin = Math.abs(Math.sin(this.meter.getDirection()));
        double rotationCos = Math.abs(Math.cos(this.meter.getDirection()));
        int imageNewWidth = (int)Math.floor(imageWidth * rotationCos + imageHeight * rotationSin);
        int imageNewHeight = (int)Math.floor(imageHeight * rotationCos + imageWidth * rotationSin);
        
        AffineTransform transform = new AffineTransform();
        transform.scale(imageScaleFactor, imageScaleFactor);
        transform.translate((imageNewWidth - this.arrowImage.getWidth()) / 2, (imageNewHeight - this.arrowImage.getHeight()) / 2);
        transform.rotate(this.meter.getDirection(), this.arrowImage.getWidth() / 2, this.arrowImage.getHeight() / 2);
        
        AffineTransformOp operation = new AffineTransformOp(transform, AffineTransformOp.TYPE_BILINEAR);
        BufferedImage image = operation.filter(this.arrowImage, null);

        g2d.drawImage(image, (int)((this.getWidth() - image.getWidth()) / 2), (int)((this.getHeight() - image.getHeight()) / 2), null);
    }
}