using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickup : MonoBehaviour
{
    public string key;

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            CollectPickup();
        }
    }

    [ContextMenu("Pickup")]
    public void CollectPickup()
    {
        if (!PlayerController.inventory.ContainsKey(key)) PlayerController.inventory.Add(key, 0);
        PlayerController.inventory[key]++;
        gameObject.SetActive(false);
    }
}
