package nl.ru.spherobciviewer;

import nl.fcdonders.fieldtrip.BufferEvent;

/**
 *
 * @author bootsman
 */
public interface BufferEventListener
{
    public void onReceived(BufferEvent event);
}