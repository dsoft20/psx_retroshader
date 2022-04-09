using System.Collections;
using System.Collections.Generic;
using UnityEngine;


/// <summary>
/// Sets vertex snapping positions.
/// </summary>
[ExecuteInEditMode]
public class PSXVertexPrecision : MonoBehaviour
{

    [SerializeField, Range(0, 1024)]
    private int xPrecision = 480;
    [SerializeField, Range(0, 1024)]
    private int yPrecision = 480;

    private void Start()
    {
        Shader.SetGlobalFloat("_XPrecision", xPrecision);
        Shader.SetGlobalFloat("_YPrecision", yPrecision);
    }

    private void OnValidate()
    {
        Shader.SetGlobalFloat("_XPrecision", xPrecision);
        Shader.SetGlobalFloat("_YPrecision", yPrecision);
    }

}