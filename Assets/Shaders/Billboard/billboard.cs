using UnityEngine;
using System.Collections;

public class billboard : MonoBehaviour
{

	void Start ()
    {
        if (billboard.cam == null)
        {
            cam = GameObject.FindGameObjectWithTag("MainCamera").GetComponent<Transform>();
        }
    }

    public static Transform cam;
    public Vector3 freeRotation = Vector3.one;
    Vector3 eangles = Vector3.zero;

    void LateUpdate()
    {
        this.transform.LookAt(billboard.cam);
        transform.Rotate(0, 180, 0);
        eangles = transform.eulerAngles;
        eangles.x *= freeRotation.x;
        eangles.y *= freeRotation.y;
        eangles.z *= freeRotation.z;
        transform.eulerAngles = eangles;
    }
}
