using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseEvents : MonoBehaviour {

	private Material mat;

	// Use this for initialization
	void Start () {
		Renderer renderer = GetComponent<Renderer>();
		if (renderer != null) 
		{
			mat = renderer.material;
		}
	}
	
	// Update is called once per frame
	void Update () {

	}

	void OnMouseOver()
	{
		if (mat != null) 
		{
			// Change lerp value that will begin the transtion
			float val = 1 * Mathf.PingPong (Time.time, 1);
			mat.SetFloat ("_LerpValue", val);
		}

	}

	void OnMouseExit()
	{
		if (mat != null) 
		{
			// Revert texture which previously change by OnMouseOver
			mat.SetFloat ("_LerpValue", 0);
		}		
	}

	void OnMouseDown()
	{
		// Swap Texture
		Texture2D mainTex = mat.GetTexture ("_MainTex") as Texture2D;
		Texture2D secTex = mat.GetTexture ("_ClickTex") as Texture2D;
		mat.SetTexture ("_MainTex", secTex);
		mat.SetTexture ("_ClickTex", mainTex);
	}

}
