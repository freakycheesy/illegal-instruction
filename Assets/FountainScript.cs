using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

public class FountainScript : MonoBehaviour
{
    public UnityEvent holyShit;
    private void Update()
    {
        if (PlayerController.completedMissionCount < 2 && (!PlayerController.inventory.ContainsKey("torch") || (PlayerController.inventory.ContainsKey("torch") && PlayerController.inventory["torch"] < 4))) return;
        holyShit.Invoke();
        bool isClose = Vector3.Distance(PlayerController.instance.transform.position, transform.position) < 30;
        if (isClose)
        {
            Camera.main.fieldOfView = Camera.main.GetComponent<PlayerCamera>().defaultFOV + Vector3.Distance(PlayerController.instance.transform.position, transform.position);
        }
        bool isCloser = Vector3.Distance(PlayerController.instance.transform.position, transform.position) < 10;
        if (isCloser)
        {
            PlayerPrefs.SetInt("fuck", 1);
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#endif
            Application.Quit();
        }
    }
}
