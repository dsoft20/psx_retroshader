using UnityEngine;
using System.Collections;

public class rotate : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}

    public Vector3 rot = Vector3.zero;
	// Update is called once per frame
	void Update () {
        this.transform.Rotate(rot*Time.deltaTime);
	}
}
