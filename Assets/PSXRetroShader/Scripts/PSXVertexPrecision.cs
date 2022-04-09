using System.Collections;
using System.Collections.Generic;
using UnityEngine;


/// <summary>
/// Sets vertex snapping precision.
/// </summary>
[ExecuteInEditMode]
public class PSXVertexPrecision : MonoBehaviour
{

    [SerializeField, Range(0, 1024)]
    private int xPrecision = 480;
    public int XPrecision
    {
        get => xPrecision;
        set
        {
            if (xPrecision == value)
                return;

            xPrecision = value;
            UpdatePrecision();
        }
    }
    [SerializeField, Range(0, 1024)]
    private int yPrecision = 480;
    public int YPrecision
    {
        get => yPrecision;
        set
        {
            if (yPrecision == value)
                return;

            yPrecision = value;
            UpdatePrecision();
        }
    }

    private void Start()
    {
        UpdatePrecision();
    }

    private void OnValidate()
    {
        UpdatePrecision();
    }

    private void UpdatePrecision()
    {
        Shader.SetGlobalFloat("_XPrecision", xPrecision);
        Shader.SetGlobalFloat("_YPrecision", yPrecision);
    }

}