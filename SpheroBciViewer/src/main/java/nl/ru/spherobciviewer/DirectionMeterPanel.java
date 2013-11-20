/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.ru.spherobciviewer;

import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import javax.imageio.ImageIO;
import javax.swing.JPanel;

/**
 *
 * @author bootsman
 */
public class DirectionMeterPanel extends JPanel
{
    private double rotation;
    private BufferedImage image;
    
    /**
     * Constructor.
     */
    public DirectionMeterPanel()
    {
        super();
        
        this.setRotation(0);
        
        try
        {
            this.image = ImageIO.read(this.getClass().getResourceAsStream("/images/arrow.png"));
        }
        catch(IOException e)
        {
        }
    }
    
    public void setRotation(double rotation)
    {
        this.rotation = rotation % 360;
    }
    
    public double getRotation()
    {
        return this.rotation;
    }
    
    @Override
    public void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        
        Graphics2D g2d = (Graphics2D)g;
        
        // Draw arrow.
        g2d.drawImage(this.image, null, this);
        
        /*
        double rotationRequired = Math.toRadian(45);
double locationX = image.getWidth() / 2;
double locationY = image.getHeight() / 2;
AffineTransform tx = AffineTransform.getRotateInstance(rotationRequired, locationX, locationY);
AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_BILINEAR);

// Drawing the rotated image at the required drawing locations
g2d.drawImage(op.filter(image, null), drawLocationX, drawLocationY, null);
* */
    }
}
