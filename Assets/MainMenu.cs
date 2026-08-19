using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    private void Start()
    {
        Application.targetFrameRate = 30;
        if (PlayerPrefs.HasKey("fuck"))
        {
            SceneManager.LoadScene(2);
        }
    }

    public void Begin()
    {
        SceneManager.LoadScene(1);
    }
}
