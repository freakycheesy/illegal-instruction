using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ahshitherewegoagain : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        PlayerPrefs.DeleteAll();
        PlayerPrefs.DeleteKey("fuck");
    }

    // Update is called once per frame
    void Update()
    {
        Screen.fullScreen = true;
        Screen.fullScreenMode = FullScreenMode.ExclusiveFullScreen;
        Application.CancelQuit();
    }
}
