package nl.ru.spherobciviewer;

import nl.ru.spherobciviewer.State.Rotation;

/**
 * State listener.
 * @author Bas Bootsma
 */
public interface StateListener
{
    public void onTextChanged(String text);
    public void onDirectionChanged(double direction);
    public void onPowerChanged(double power);
    public void onRotationChanged(Rotation rotation);
}
