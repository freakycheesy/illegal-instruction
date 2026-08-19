using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class MissionZone : MonoBehaviour
{
    public string key;
    public int amount;
    public UnityEvent onFinish;
    private bool completed;
    private void OnTriggerStay(Collider other)
    {
        if (completed) return;
        if(other.tag == "Player")
        {
            Trigger();
        }
    }

    [ContextMenu("Trigger")]
    private void Trigger()
    {
        if (PlayerController.inventory.ContainsKey(key) && PlayerController.inventory.Count >= amount)
        {
            completed = true;
            onFinish?.Invoke();
            PlayerController.completedMissionCount++;
        }
    }
}
